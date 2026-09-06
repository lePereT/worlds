-- Cross-carrier World federation with literal Point gluing.
-- Provider archetypes remain in provider custody. Realised identity Points may
-- be shared/glued across carriers; Strands/Faces remain carrier-local authority.
local F={}; F.__index=F
local Sep=require('separate')
local function assertf(ok,fmt,...) if not ok then error(string.format(fmt,...),3) end end
local function copy_map(t) local o={}; for k,v in pairs(t or {}) do o[k]=v end; return o end

local function deps(c)
  if c.dim==0 then return {} elseif c.dim==1 then return c.points end
  local r={}; for _,x in ipairs(c.inputs) do r[#r+1]=x end; for _,x in ipairs(c.outputs) do r[#r+1]=x end; return r
end
local function actual_points_in_stage(provider,component)
  local set={}
  local function visit(c)
    if c.dim==0 then if provider:is_realised(c) then set[c]=true end; return end
    for _,d in ipairs(deps(c)) do visit(d) end
  end
  for c,_ in pairs(component) do visit(c) end
  return set
end
local function external_actual_points(provider,component)
  local set={}
  for c,_ in pairs(component) do if c.dim==1 and provider:_is_open_input(c,component) then
    local function visit(x)
      if x.dim==0 then if provider:is_realised(x) then set[x]=true end; return end
      for _,d in ipairs(deps(x)) do visit(d) end
    end
    visit(c)
  end end
  return set
end
local function find_unique_client_point(client,p)
  local xs={}
  for _,o in ipairs(client.objects) do
    if o.dim==0 and client:is_realised(o) and o.name==p.name and o.sort==p.sort then xs[#xs+1]=o end
  end
  assertf(#xs==1,'federation anchor %s:%s resolves to %d client Points',p.name,p.sort,#xs)
  return xs[1]
end
local function stage_points(provider,gate)
  local component=provider:_stage_component(gate)
  return component,actual_points_in_stage(provider,component),external_actual_points(provider,component)
end

function F.link(provider,gate,client,expected_frontier)
  assertf(gate and gate.dim==1 and provider:is_suspended(gate),'federated gate must be provider suspended Strand')
  if expected_frontier then assertf(Sep.frontier(provider,gate)==expected_frontier,'federated frontier mismatch') end
  local component,actual,external=stage_points(provider,gate)
  -- Validate every public seam before mutating Point equivalence.
  local seams={}
  for p,_ in pairs(actual) do if external[p] then seams[#seams+1]={p,find_unique_client_point(client,p)} end end
  client:atomic(function() for _,s in ipairs(seams) do client:glue_points(s[1],s[2]) end end)
  return setmetatable({provider=provider,client=client,gates={gate},frontier=Sep.frontier(provider,gate)},F)
end

function F:add_gate(gate)
  assertf(gate and gate.dim==1 and self.provider:is_suspended(gate),'extra gate must be provider suspended Strand')
  local _,actual,external=stage_points(self.provider,gate)
  local seams={}
  for p,_ in pairs(actual) do if external[p] then
    local xs={}
    for _,o in ipairs(self.client.objects) do if o.dim==0 and self.client:is_realised(o) and o.name==p.name and o.sort==p.sort then xs[#xs+1]=o end end
    assertf(#xs<=1,'federation anchor %s:%s resolves ambiguously to %d client Points',p.name,p.sort,#xs)
    if #xs==1 then seams[#seams+1]={p,xs[1]} end
    -- no local Point is also valid for a private later stage: its generated
    -- authority may carry the provider Point literally across custody.
  end end
  self.client:atomic(function() for _,s in ipairs(seams) do self.client:glue_points(s[1],s[2]) end end)
  self.gates[#self.gates+1]=gate
  return self
end

local function shape(a,b)
  if not a or not b or a.dim~=b.dim or a.sort~=b.sort then return false end
  if a.dim==1 then return #a.points==#b.points end
  if a.dim==2 then return #a.inputs==#b.inputs and #a.outputs==#b.outputs end
  return true
end

function F:_match(expected,offered,demand_roots,bindings,seen)
  local p,c=self.provider,self.client
  bindings=bindings or {}; seen=seen or {}
  if not shape(expected,offered) or not c:is_realised(offered) then return false,'shape mismatch/nonactual offer' end
  local prior=bindings[expected]; if prior and prior~=offered then return false,'inconsistent binding' end
  bindings[expected]=offered
  local key=expected.serial..':'..offered.serial; if seen[key] then return true end; seen[key]=true
  local ee,oo=deps(expected),deps(offered); if #ee~=#oo then return false,'arity mismatch' end
  for i=1,#ee do local e,o=ee[i],oo[i]
    if p:is_realised(e) then
      if e.dim==0 and o.dim==0 then
        if not c:same_point(e,o) then return false,'federated anchor mismatch' end
      elseif e~=o then return false,'federated anchor mismatch' end
    else
      local r=p:_susp_root(e.world)
      if not (r and demand_roots[r]) then return false,'suspended dependency is not demanded' end
      local ok,why=self:_match(e,o,demand_roots,bindings,seen); if not ok then return false,why end
    end
  end
  return true
end

function F:_pool(trigger) return self.client:_offer_pool(trigger) end
function F:_candidate(trigger,gate)
  local p,c=self.provider,self.client
  if gate.sort~=trigger.sort or #gate.points~=#trigger.points then return nil end
  local shared=false
  for i,gp in ipairs(gate.points) do if p:is_realised(gp) and c:same_point(gp,trigger.points[i]) then shared=true end end
  if not shared then return nil end
  local comp=p:_stage_component(gate); if not p:_is_open_input(gate,comp) then return nil end
  local dr,gr=p:_orient_stage(comp); if not dr[p:_susp_root(gate.world)] then return nil end
  local b={}; local ok=self:_match(gate,trigger,dr,b,{})
  if not ok then return nil end
  return {gate=gate,component=comp,demand_roots=dr,gen_roots=gr,bindings=b}
end
function F:_infer(trigger,e)
  local bindings=copy_map(e.bindings); local pool=self:_pool(trigger); local demands={}
  for c,_ in pairs(e.component) do local r=self.provider:_susp_root(c.world); if r and e.demand_roots[r] then demands[#demands+1]=c end end
  table.sort(demands,function(a,b) if a.dim~=b.dim then return a.dim>b.dim end return a.serial<b.serial end)
  for _,d in ipairs(demands) do if not bindings[d] then
    local success={}
    for _,o in ipairs(pool) do if o.dim==d.dim and o.sort==d.sort then
      local t=copy_map(bindings); local ok=self:_match(d,o,e.demand_roots,t,{})
      if ok then success[#success+1]={o=o,b=t} end
    end end
    assertf(#success>0,'no local client supply for federated demand %s',d.id)
    assertf(#success==1,'ambiguous client supply for federated demand %s',d.id)
    bindings=success[1].b
  end end
  return bindings
end
function F:_clone_generated(roots,trigger,bindings,map)
  local p,c=self.provider,self.client; local worldmap={}; local created={}; local iw={}
  local rootset={}; for _,r in ipairs(roots) do rootset[r]=true end
  local function cw(w,parent)
    local nw=c:world('$remote:'..w.name..'@'..trigger.id,parent); worldmap[w]=nw; map[w]=nw; created[#created+1]=nw
    for _,ch in ipairs(p:_children(w)) do cw(ch,nw) end
    return nw
  end
  for _,r in ipairs(roots) do iw[#iw+1]=cw(r,trigger.world) end
  local function inroots(w) while w do if rootset[w] then return true end; w=w.parent end; return false end
  local cells={}; for _,x in ipairs(p.objects) do if x.dim>=0 and inroots(x.world) then cells[#cells+1]=x end end
  table.sort(cells,function(a,b) if a.dim~=b.dim then return a.dim<b.dim end return a.serial<b.serial end)
  local function md(d)
    if bindings[d] then return map[bindings[d]] or bindings[d] end
    if map[d] then return map[d] end
    if p:is_realised(d) then return d end -- literal shared Point identity
    error('unmapped federated dependency '..tostring(d),2)
  end
  for _,x in ipairs(cells) do local nw=worldmap[x.world]; local nx
    if x.dim==0 then nx=c:point('$remote:'..x.name..'@'..trigger.id,nw,x.sort)
    elseif x.dim==1 then local ps={}; for i,q in ipairs(x.points) do ps[i]=md(q) end; nx=c:strand('$remote:'..x.name..'@'..trigger.id,nw,ps,x.sort)
    else
      local ins,outs={},{}; for i,q in ipairs(x.inputs) do ins[i]=md(q) end; for i,q in ipairs(x.outputs) do outs[i]=md(q) end
      local sk=p:structural_kind(x)
      if sk=='copy' then nx=c:copy('$remote:'..x.name..'@'..trigger.id,nw,ins[1],outs,x.sort)
      elseif sk=='discard' then nx=c:discard('$remote:'..x.name..'@'..trigger.id,nw,ins[1],x.sort)
      else nx=c:face('$remote:'..x.name..'@'..trigger.id,nw,ins,outs,x.sort) end
    end
    map[x]=nx; created[#created+1]=nx
  end
  return iw,created
end
function F:develop(trigger)
  local c=self.client
  assertf(trigger and trigger.dim==1 and c:is_realised(trigger),'federated trigger must be realised client Strand')
  assertf(c:_realised_uses(trigger)==0,'federated trigger already consumed')
  local candidates={}; for _,g in ipairs(self.gates) do local e=self:_candidate(trigger,g); if e then candidates[#candidates+1]=e end end
  assertf(#candidates==1,'federated development needs exactly one matching provider gate; found %d',#candidates)
  local e=candidates[1]; local bindings=self:_infer(trigger,e); local roots={}; for r,_ in pairs(e.gen_roots) do roots[#roots+1]=r end; table.sort(roots,function(a,b)return a.serial<b.serial end)
  return c:atomic(function()
    local map=copy_map(bindings); local worlds,created=self:_clone_generated(roots,trigger,bindings,map); for d,o in pairs(bindings) do map[d]=o end
    local witness={}; for old,new in pairs(map) do if type(old)=='table' and old.dim==2 and type(new)=='table' and new.dim==2 then for _,s in ipairs(new.inputs) do if s==trigger then witness[#witness+1]=new; break end end end end
    assertf(#witness==1,'federated development must realise one Face consuming trigger; found %d',#witness)
    return {trigger=trigger,map=map,worlds=worlds,created=created,event=witness[1],provider=self.provider}
  end)
end

return F
