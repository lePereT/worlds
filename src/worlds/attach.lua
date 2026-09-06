-- Exact attachment maps and fresh gluing.
--
-- A possible action is just another Geometry. Selection is supplied directly
-- as a set/list of membrane occurrences in the source Geometry; it is not a
-- stateful object. Attachment enumerates complete incidence-preserving
-- maps of every input Strand (and Point variables in mapped membranes)
-- into the terminal authority exposed by that selection. Gluing fresh-copies
-- every unmapped part of the pattern.

local Geometry=require('worlds.geometry')
local A={}

local attachment_state=setmetatable({}, {__mode='k'})
local AttachmentMT={__newindex=function() error('Attachment values are immutable',2) end}
AttachmentMT.__index=AttachmentMT

local function copy_map(m) local r={} for k,v in pairs(m) do r[k]=v end return r end

local function assert_attachment(w)
  local x=attachment_state[w]
  assert(x,'expected Attachment')
  return x
end

local function map_membrane(ps,gs,mm,pm,gm)
  local p,g=pm,gm
  while p do
    local pc=ps.membranes[p]
    local gc=gs.membranes[g]
    if not gc or pc.sort~=gc.sort then return false end
    if mm[p] and mm[p]~=g then return false end
    mm[p]=g
    p=pc.parent
    if p then
      g=gc.parent
      if not g then return false end
    end
  end
  return true
end

local function modifications_allowed(ps, selected, mm)
  local input={}
  for _,sid in ipairs(ps.sorder) do if ps.producer[sid]==nil then input[sid]=true end end

  for pm,gm in pairs(mm) do
    if not selected[gm] then
      -- Structural ancestry may infer an existing membrane, but only selected
      -- membranes are open for fresh causal/authority geometry.
      if #(ps.local_faces[pm] or {})>0 then return false end
      for _,sid in ipairs(ps.local_strands[pm] or {}) do if not input[sid] then return false end end
      for _,child in ipairs(ps.children[pm] or {}) do if not mm[child] then return false end end
    end
  end
  for _,pm in ipairs(ps.morder) do
    if not mm[pm] then
      local parent=ps.membranes[pm].parent
      if parent and mm[parent] and not selected[mm[parent]] then return false end
    end
  end
  return true
end

local function make_attachment(source, pattern, strand_map, point_map, membrane_map)
  local w=setmetatable({},AttachmentMT)
  attachment_state[w]={
    source=source, pattern=pattern,
    strands=copy_map(strand_map), points=copy_map(point_map), membranes=copy_map(membrane_map),
  }
  return w
end

function AttachmentMT:source() return assert_attachment(self).source end
function AttachmentMT:pattern() return assert_attachment(self).pattern end
function AttachmentMT:strand(pattern_strand) return assert_attachment(self).strands[pattern_strand] end
function AttachmentMT:point(pattern_point) return assert_attachment(self).points[pattern_point] end
function AttachmentMT:membrane(pattern_membrane) return assert_attachment(self).membranes[pattern_membrane] end

function A.all(source, membranes, pattern)
  local gs=Geometry._state(source)
  local ps=Geometry._state(pattern)
  local selected,selection=Geometry._selection(gs,membranes)
  local offers=Geometry._offers_selected(gs,selected)
  local visible_points=Geometry._visible_points_selected(gs,selected)
  local input={}
  for _,sid in ipairs(ps.sorder) do if ps.producer[sid]==nil then input[#input+1]=sid end end

  local candidates={}
  for _,sid in ipairs(input) do
    local strand=ps.strands[sid]
    local xs={}
    for _,gid in ipairs(offers) do
      local got=gs.strands[gid]
      if strand.sort==got.sort and #strand.points==#got.points then xs[#xs+1]=gid end
    end
    candidates[sid]=xs
  end
  table.sort(input,function(a,b) return #candidates[a] < #candidates[b] end)

  local results={}
  local smap,sused,pmap,mmap={},{},{},{}

  local function bind_point(pp,gp)
    local pc,gc=ps.points[pp],gs.points[gp]
    if not pc or not gc or pc.sort~=gc.sort then return false end
    if pmap[pp] then return pmap[pp]==gp end
    if not map_membrane(ps,gs,mmap,pc.membrane,gc.membrane) then return false end
    pmap[pp]=gp
    return true
  end

  local function restore_points(snapshot)
    for pp in pairs(pmap) do if not snapshot[pp] then pmap[pp]=nil end end
  end

  local function assign_points(demands,idx)
    if idx>#demands then
      if modifications_allowed(ps,selected,mmap) then
        results[#results+1]=make_attachment(source,pattern,smap,pmap,mmap)
      end
      return
    end
    local pp=demands[idx]
    if pmap[pp] then return assign_points(demands,idx+1) end
    local pc=ps.points[pp]
    local required=mmap[pc.membrane]
    for _,gp in ipairs(visible_points) do
      if gs.points[gp].sort==pc.sort and gs.points[gp].membrane==required then
        pmap[pp]=gp
        assign_points(demands,idx+1)
        pmap[pp]=nil
      end
    end
  end

  local function finish_strands()
    local demands={}
    for _,pp in ipairs(ps.porder) do
      if mmap[ps.points[pp].membrane] and not pmap[pp] then demands[#demands+1]=pp end
    end
    assign_points(demands,1)
  end

  local function search(i)
    if i>#input then return finish_strands() end
    local sid=input[i]
    local strand=ps.strands[sid]
    for _,gid in ipairs(candidates[sid]) do
      if not sused[gid] then
        local got=gs.strands[gid]
        local oldp=copy_map(pmap)
        local oldm=copy_map(mmap)
        local ok=map_membrane(ps,gs,mmap,strand.membrane,got.membrane)
        if ok then
          for pos,pp in ipairs(strand.points) do
            if not bind_point(pp,got.points[pos]) then ok=false; break end
          end
        end
        if ok then
          smap[sid]=gid; sused[gid]=true
          search(i+1)
          smap[sid]=nil; sused[gid]=nil
        end
        for k in pairs(mmap) do mmap[k]=nil end
        for k,v in pairs(oldm) do mmap[k]=v end
        restore_points(oldp)
      end
    end
  end

  if #input==0 then finish_strands() else search(1) end
  return results
end

function A.one(source,membranes,pattern)
  local xs=A.all(source,membranes,pattern)
  return xs[1]
end

local function clone_base(gs)
  return {
    membranes=Geometry._shallow_map(gs.membranes), points=Geometry._shallow_map(gs.points),
    strands=Geometry._shallow_map(gs.strands), faces=Geometry._shallow_map(gs.faces),
    morder=Geometry._copy_array(gs.morder), porder=Geometry._copy_array(gs.porder),
    sorder=Geometry._copy_array(gs.sorder), forder=Geometry._copy_array(gs.forder),
  }
end

function A.glue(attachment)
  local ws=assert_attachment(attachment)
  local gs=Geometry._state(ws.source)
  local ps=Geometry._state(ws.pattern)
  local ns=clone_base(gs)
  local image={membranes=copy_map(ws.membranes),points=copy_map(ws.points),strands=copy_map(ws.strands),faces={}}

  for _,pm in ipairs(ps.morder) do
    if not image.membranes[pm] then
      local pc=ps.membranes[pm]
      local id=Geometry._fresh_id('m')
      local parent=pc.parent and image.membranes[pc.parent] or nil
      ns.membranes[id]={id=id,parent=parent,sort=pc.sort,name=pc.name}
      ns.morder[#ns.morder+1]=id
      image.membranes[pm]=id
    end
  end

  for _,pp in ipairs(ps.porder) do
    if not image.points[pp] then
      local pc=ps.points[pp]
      local id=Geometry._fresh_id('p')
      ns.points[id]={id=id,membrane=image.membranes[pc.membrane],sort=pc.sort,name=pc.name}
      ns.porder[#ns.porder+1]=id
      image.points[pp]=id
    end
  end

  for _,sid in ipairs(ps.sorder) do
    if not image.strands[sid] then
      local sc=ps.strands[sid]
      local pts={}
      for i,p in ipairs(sc.points) do pts[i]=image.points[p] end
      local id=Geometry._fresh_id('s')
      ns.strands[id]={id=id,membrane=image.membranes[sc.membrane],sort=sc.sort,points=pts,name=sc.name}
      ns.sorder[#ns.sorder+1]=id
      image.strands[sid]=id
    end
  end

  for _,fid in ipairs(ps.forder) do
    local fc=ps.faces[fid]
    local ins,outs={},{}
    for i,s in ipairs(fc.inputs) do ins[i]=image.strands[s] end
    for i,s in ipairs(fc.outputs) do outs[i]=image.strands[s] end
    local id=Geometry._fresh_id('f')
    ns.faces[id]={id=id,membrane=image.membranes[fc.membrane],sort=fc.sort,inputs=ins,outputs=outs,name=fc.name}
    ns.forder[#ns.forder+1]=id
    image.faces[fid]=id
  end

  return Geometry._make_geometry(ns),image
end

return A
