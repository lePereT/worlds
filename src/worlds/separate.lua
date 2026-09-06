-- worlds/separate.lua
-- Separate-compilation artefact layer derived from geometry.
--
-- Public frontier =
--   * open incoming Strands (demands), plus
--   * produced Strands with no consumer inside the stage (egress).
--
-- No core cell carries a visibility/public bit. An actual Point appearing on an
-- incoming frontier is an external named anchor. Other actual Points in opaque
-- provider geometry are linker-private and are anonymised at the frontier.

local S={FORMAT='worlds.unit/1'}
local Internal=require('worlds.internal')
local Topology=require('worlds.topology')
local function assertf(ok,fmt,...)
  if not ok then error(string.format(fmt,...),3) end
end
local function sorted_keys(t,cmp)
  local xs={}; for k,_ in pairs(t) do xs[#xs+1]=k end; table.sort(xs,cmp); return xs
end

local function produced_in(m,s,component)
  for _,p in ipairs(m:_parents(s)) do
    if p.dim==2 and component[p] then for _,x in ipairs(p.outputs) do if x==s then return true end end end
  end
  return false
end
local function consumed_in(m,s,component)
  for _,p in ipairs(m:_parents(s)) do
    if p.dim==2 and component[p] then for _,x in ipairs(p.inputs) do if x==s then return true end end end
  end
  return false
end
local function is_egress(m,s,component)
  return s.dim==1 and m:is_suspended(s) and component[s] and produced_in(m,s,component) and not consumed_in(m,s,component)
end

local function boundary_cells(m,gate)
  local component=Topology.component(m,gate)
  assertf(Topology.is_open_input(m,gate,component),'frontier gate must be an open input')
  local demands,egress={},{}
  for c,_ in pairs(component) do
    if c.dim==1 and Topology.is_open_input(m,c,component) then demands[#demands+1]=c end
    if c.dim==1 and is_egress(m,c,component) then egress[#egress+1]=c end
  end
  local function order(a,b)
    if a.name~=b.name then return a.name<b.name end
    if a.sort~=b.sort then return a.sort<b.sort end
    return a.serial<b.serial
  end
  table.sort(demands,order); table.sort(egress,order)
  return component,demands,egress
end

local function collect_actual_points(m,c,set)
  if c.dim==0 then if m:is_realised(c) then set[c]=true end; return end
  for _,d in ipairs(m:deps(c)) do collect_actual_points(m,d,set) end
end

local function cell_sig(m,c,ctx)
  if c.dim==0 then
    local nm
    if m:is_realised(c) and ctx.external[c] then nm=c.name
    else
      nm=ctx.anon[c]
      if not nm then nm='$'..tostring(ctx.next_anon); ctx.next_anon=ctx.next_anon+1; ctx.anon[c]=nm end
    end
    return string.format('P{%s:%s:%s}',nm,c.sort,m:is_realised(c) and 'anchor' or 'open')
  elseif c.dim==1 then
    local ps={}; for _,p in ipairs(c.points) do ps[#ps+1]=cell_sig(m,p,ctx) end
    return string.format('S{%s:%s}[%s]',c.name,c.sort,table.concat(ps,','))
  else
    local ins,outs={},{}
    for _,x in ipairs(c.inputs) do ins[#ins+1]=cell_sig(m,x,ctx) end
    for _,x in ipairs(c.outputs) do outs[#outs+1]=cell_sig(m,x,ctx) end
    return string.format('F{%s:%s}[%s]->[%s]',c.name,c.sort,table.concat(ins,','),table.concat(outs,','))
  end
end

function S.frontier(m,gate)
  m=Internal.model(m)
  assertf(gate and gate.dim==1 and m:is_suspended(gate),'frontier gate must be suspended Strand')
  local _,demands,egress=boundary_cells(m,gate)
  local external={}; for _,c in ipairs(demands) do collect_actual_points(m,c,external) end
  local ctx={anon={},next_anon=1,external=external}; local ds,es={},{}
  for _,c in ipairs(demands) do ds[#ds+1]=cell_sig(m,c,ctx) end
  for _,c in ipairs(egress) do es[#es+1]=cell_sig(m,c,ctx) end
  return 'DEMAND{'..table.concat(ds,'|')..'};EGRESS{'..table.concat(es,'|')..'}'
end

local function certify_stage(m,gate)
  local component=Topology.component(m,gate)
  assertf(Topology.is_open_input(m,gate,component),'stage gate is not open input')
  for s,_ in pairs(component) do
    if s.dim==1 then
      local uses=0
      for _,p in ipairs(m:_parents(s)) do
        if p.dim==2 and component[p] then for _,x in ipairs(p.inputs) do if x==s then uses=uses+1 end end end
      end
      assertf(uses<=1,'portable stage strand %s has %d suspended uses',s.id,uses)
    end
  end
  return true
end

local function stage_payload(m,gate,anchor_index,anchors,external_anchors)
  local component=Topology.component(m,gate)
  local worlds={}
  local function add_world(w)
    if not w or worlds[w] or m:is_realised(w) then return end
    worlds[w]=true; if w.parent then add_world(w.parent) end
  end
  for c,_ in pairs(component) do add_world(c.world) end
  local wlist=sorted_keys(worlds,function(a,b)return a.serial<b.serial end); local widx={}; for i,w in ipairs(wlist) do widx[w]=i end
  local cells={}; for c,_ in pairs(component) do cells[#cells+1]=c end
  table.sort(cells,function(a,b) if a.dim~=b.dim then return a.dim<b.dim end return a.serial<b.serial end); local cidx={}; for i,c in ipairs(cells) do cidx[c]=i end

  local function anchor_key(p)
    local k=anchor_index[p]
    if not k then
      k='A'..tostring(#anchors+1); anchor_index[p]=k
      anchors[#anchors+1]={key=k,name=p.name,sort=p.sort,external=external_anchors[p]==true}
    end
    return k
  end
  local function ref(c)
    if m:is_realised(c) then assertf(c.dim==0,'portable stage may anchor only to realised Points, got %s',tostring(c)); return {anchor=anchor_key(c)} end
    assertf(cidx[c],'stage dependency escapes portable component: %s',tostring(c)); return {cell=cidx[c]}
  end
  local wp={}; for i,w in ipairs(wlist) do wp[i]={name=w.name,parent=w.parent and widx[w.parent] or nil} end
  local cp={}
  for i,c in ipairs(cells) do
    local x={name=c.name,dim=c.dim,sort=c.sort,world=widx[c.world]}
    if c.dim==1 then x.points={}; for _,p in ipairs(c.points) do x.points[#x.points+1]=ref(p) end
    elseif c.dim==2 then x.inputs={}; x.outputs={}; x.structural=m:structural_kind(c); for _,s in ipairs(c.inputs) do x.inputs[#x.inputs+1]=ref(s) end; for _,s in ipairs(c.outputs) do x.outputs[#x.outputs+1]=ref(s) end end
    cp[i]=x
  end
  return {worlds=wp,cells=cp,gate=cidx[gate],frontier=S.frontier(m,gate)}
end

function S.export_unit(m,entry_gate,extra_gates)
  m=Internal.model(m)
  certify_stage(m,entry_gate)
  local _,demands=boundary_cells(m,entry_gate)
  local external={}; for _,c in ipairs(demands) do collect_actual_points(m,c,external) end
  local anchors,anchor_index={},{}
  local stages={stage_payload(m,entry_gate,anchor_index,anchors,external)}
  for _,g in ipairs(extra_gates or {}) do certify_stage(m,g); stages[#stages+1]=stage_payload(m,g,anchor_index,anchors,external) end
  return {format=S.FORMAT,frontier=S.frontier(m,entry_gate),anchors=anchors,stages=stages}
end

local function pure_ref_ok(r,anchors,limit)
  if type(r)~='table' then return false end
  if r.anchor then return type(r.anchor)=='string' and anchors[r.anchor]==true and r.cell==nil end
  return type(r.cell)=='number' and r.cell>=1 and r.cell<limit and r.anchor==nil
end

function S.validate_unit(unit)
  assertf(type(unit)=='table' and unit.format==S.FORMAT,'unsupported unit format')
  assertf(type(unit.anchors)=='table' and type(unit.stages)=='table','malformed unit')
  local anchors={}
  for _,a in ipairs(unit.anchors) do
    assertf(type(a)=='table' and type(a.key)=='string' and type(a.name)=='string' and type(a.sort)=='string','malformed unit anchor')
    assertf(not anchors[a.key],'duplicate unit anchor %s',a.key); anchors[a.key]=true
    assertf(a.external==nil or type(a.external)=='boolean','malformed external flag for anchor %s',a.key)
  end
  for si,st in ipairs(unit.stages) do
    assertf(type(st)=='table' and type(st.worlds)=='table' and type(st.cells)=='table','malformed unit stage %d',si)
    for wi,w in ipairs(st.worlds) do
      assertf(type(w)=='table' and type(w.name)=='string','malformed World in stage %d',si)
      assertf(w.parent==nil or (type(w.parent)=='number' and w.parent>=1 and w.parent<wi),'invalid World parent in stage %d',si)
    end
    for i,c in ipairs(st.cells) do
      assertf(type(c)=='table' and (c.dim==0 or c.dim==1 or c.dim==2),'malformed cell in stage %d',si)
      assertf(type(c.name)=='string' and type(c.sort)=='string' and type(c.world)=='number' and st.worlds[c.world],'malformed cell metadata in stage %d',si)
      if c.dim==1 then
        for _,r in ipairs(c.points or {}) do assertf(pure_ref_ok(r,anchors,i),'invalid Point reference in stage %d cell %d',si,i) end
      elseif c.dim==2 then
        assertf(c.structural==nil or c.structural=='copy' or c.structural=='discard','unsupported structural Face in portable stage')
        for _,r in ipairs(c.inputs or {}) do assertf(pure_ref_ok(r,anchors,i),'invalid input reference in stage %d cell %d',si,i) end
        for _,r in ipairs(c.outputs or {}) do assertf(pure_ref_ok(r,anchors,i),'invalid output reference in stage %d cell %d',si,i) end
      end
    end
    assertf(type(st.gate)=='number' and st.cells[st.gate] and st.cells[st.gate].dim==1,'stage %d gate is not a Strand',si)
    assertf(st.frontier==nil or type(st.frontier)=='string','malformed stage frontier')
  end
  assertf(unit.frontier==nil or type(unit.frontier)=='string','malformed unit frontier')
  return true
end

local function find_external_anchor(m,a)
  local found={}
  for _,c in ipairs(m.objects) do if c.dim==0 and m:is_realised(c) and c.name==a.name and c.sort==a.sort then found[#found+1]=c end end
  assertf(#found==1,'external anchor %s:%s resolves to %d client Points',a.name,a.sort,#found)
  return found[1]
end

function S.import_unit(m,unit,expected_frontier)
  m=Internal.model(m)
  S.validate_unit(unit)
  if expected_frontier then assertf(unit.frontier==expected_frontier,'frontier mismatch') end
  return m:atomic(function()
    local serial=m.next_serial
    local anchors={}; local private_needed=false
    for _,a in ipairs(unit.anchors) do if not a.external then private_needed=true; break end end
    local link_world=private_needed and m:world('$link-unit-'..tostring(serial),m.actuality) or nil
    for _,a in ipairs(unit.anchors) do
      if a.external then anchors[a.key]=find_external_anchor(m,a)
      else anchors[a.key]=m:point('$private:'..a.key,link_world,a.sort) end
    end
    local imported={}
    for si,st in ipairs(unit.stages) do
      local wm={}; for i,w in ipairs(st.worlds) do wm[i]=m:world('$u'..si..':'..w.name,w.parent and wm[w.parent] or nil) end
      local cm={}
      local function deref(r) if r.anchor then return anchors[r.anchor] end; assertf(r.cell and cm[r.cell],'forward/invalid cell reference in unit'); return cm[r.cell] end
      for i,c in ipairs(st.cells) do
        local x
        if c.dim==0 then x=m:point(c.name,wm[c.world],c.sort)
        elseif c.dim==1 then local ps={}; for _,r in ipairs(c.points or {}) do ps[#ps+1]=deref(r) end; x=m:strand(c.name,wm[c.world],ps,c.sort)
        else
          local ins,outs={},{}; for _,r in ipairs(c.inputs or {}) do ins[#ins+1]=deref(r) end; for _,r in ipairs(c.outputs or {}) do outs[#outs+1]=deref(r) end
          if c.structural=='copy' then x=m:copy(c.name,wm[c.world],ins[1],outs,c.sort)
          elseif c.structural=='discard' then x=m:discard(c.name,wm[c.world],ins[1],c.sort)
          else x=m:face(c.name,wm[c.world],ins,outs,c.sort) end
        end
        cm[i]=x
      end
      imported[si]={gate=cm[st.gate],worlds=wm,cells=cm,frontier=st.frontier}
    end
    return {stages=imported,anchors=anchors,frontier=unit.frontier,link_world=link_world}
  end)
end

return S
