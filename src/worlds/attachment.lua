-- Worlds 0.2 attachment semantics.
--
-- Att_K(P) is the complete space of admissible boundary embeddings of a
-- detached open patch P into the currently available boundary of actual
-- locality K.  The semantic relation is simultaneous and permutation-invariant;
-- search order below is only an implementation strategy.
--
-- This public module deliberately separates:
--   * Patch     - an opaque designation of derived detached geometry;
--   * Query     - retained search for one witness or an emptiness proof;
--   * Witness   - one complete attachment embedding;
--   * graft     - fresh actualisation of a revalidated Witness.

local Internal=require('worlds.internal')
local Topology=require('worlds.topology')
local internal_model=assert(Internal.model)
local internal_is_model=assert(Internal.is_model)
local topology_patch=assert(Topology.patch)
local topology_patches=assert(Topology.patches)
local topology_fingerprint=assert(Topology.fingerprint)
local A={}

local PatchMT={}; PatchMT.__index=PatchMT; PatchMT.__metatable=false
local QueryMT={}; QueryMT.__index=QueryMT; QueryMT.__metatable=false
local WitnessMT={}; WitnessMT.__index=WitnessMT; WitnessMT.__metatable=false
local CertMT={}; CertMT.__index=CertMT; CertMT.__metatable=false
for _,mt in ipairs{PatchMT,QueryMT,WitnessMT,CertMT} do
  mt.__newindex=function() error('Worlds attachment handles are immutable',2) end
end

local patch_state=setmetatable({}, {__mode='k'})
local query_state=setmetatable({}, {__mode='k'})
local witness_state=setmetatable({}, {__mode='k'})
local cert_state=setmetatable({}, {__mode='k'})

local function assertf(ok,fmt,...)
  if not ok then error(string.format(fmt,...),3) end
end
local function copy_map(t) local o={}; for k,v in pairs(t or {}) do o[k]=v end; return o end
local function copy_array(xs) local o={}; for i=1,#(xs or {}) do o[i]=xs[i] end; return o end
local function model(m)
  assertf(internal_is_model(m),'expected World Model')
  return internal_model(m)
end
local function state_of(map,x,what)
  local s=map[x]; if not s then error('expected Worlds '..what,3) end; return s
end

local function shape(a,b)
  if not a or not b or a.dim~=b.dim or a.sort~=b.sort then return false end
  if a.dim==1 then return #a.points==#b.points end
  if a.dim==2 then return #a.inputs==#b.inputs and #a.outputs==#b.outputs end
  return true
end

local function point_rep(m,p)
  local best
  for _,o in ipairs(m.objects) do
    if o.dim==0 and m:is_realised(o) and m:same_point(p,o) then
      if not best or o.serial<best then best=o.serial end
    end
  end
  return best or p.serial
end

-- Recursive incidence matching. Bindings are simultaneous constraints even
-- though this reference solver discovers them incrementally.
local function match(m,expected,offered,patch,bindings,seen)
  bindings=bindings or {}; seen=seen or {}
  if not shape(expected,offered) or not m:is_realised(offered) then return false,'shape' end
  local prior=bindings[expected]
  if prior then
    if expected.dim==0 and prior.dim==0 and offered.dim==0 then
      if not m:same_point(prior,offered) then return false,'point-consistency' end
      offered=prior
    elseif prior~=offered then
      return false,'binding-consistency'
    end
  else
    bindings[expected]=offered
  end
  local key=tostring(expected.serial)..':'..tostring(offered.serial)
  if seen[key] then return true end
  seen[key]=true
  local ee,oo=m:deps(expected),m:deps(offered)
  if #ee~=#oo then return false,'arity' end
  for i=1,#ee do
    local e,o=ee[i],oo[i]
    if m:is_realised(e) then
      if e.dim==0 and o.dim==0 then
        if not m:same_point(e,o) then return false,'anchor' end
      elseif e~=o then return false,'anchor' end
    else
      local r=m:_susp_root(e.world)
      if not (r and patch.demand_roots[r]) then return false,'not-boundary' end
      local ok,why=match(m,e,o,patch,bindings,seen)
      if not ok then return false,why end
    end
  end
  return true
end

local function shape_key(c)
  local width='-'
  if c.dim==1 then width=tostring(#c.points)
  elseif c.dim==2 then width=tostring(#c.inputs)..'/'..tostring(#c.outputs) end
  return tostring(c.dim)..':'..tostring(c.sort)..':'..width
end

local function relevant_shapes(patch)
  local out={}
  for _,d in ipairs(patch.demands) do out[shape_key(d)]=true end
  return out
end

local function offer_pool(m,patch,world)
  local shapes=relevant_shapes(patch)
  local pool,seen={},{}
  local function add(c)
    if c and not seen[c] then seen[c]=true; pool[#pool+1]=c end
  end
  local function add_strand(s)
    if m:_uses(s)==0 then
      if shapes[shape_key(s)] then add(s) end
      for _,p in ipairs(s.points) do if shapes[shape_key(p)] then add(p) end end
    end
  end
  for _,c in ipairs(m.objects) do
    if c.dim>=0 and m:is_realised(c) and c.world==world then
      if c.dim==0 then if shapes[shape_key(c)] then add(c) end
      elseif c.dim==1 then add_strand(c) end
    end
  end
  -- Search order is explicitly non-semantic. Stable ordering only makes the
  -- executable reference deterministic and easy to test.
  table.sort(pool,function(a,b)
    if a.dim~=b.dim then return a.dim>b.dim end
    return a.serial<b.serial
  end)
  return pool
end

local function strand_injective(bindings,except,offered)
  if not offered or offered.dim~=1 then return true end
  for d,o in pairs(bindings) do
    if d~=except and o==offered and d.dim==1 then return false end
  end
  return true
end

local function prospective_valid(m,patch,bindings)
  local counts={}
  for c in pairs(patch.component) do
    local r=m:_susp_root(c.world)
    if c.dim==2 and r and patch.generated_roots[r] then
      for _,d in ipairs(c.inputs) do
        local offered=bindings[d]
        if offered and offered.dim==1 and m:is_realised(offered) then
          counts[offered]=(counts[offered] or 0)+1
        end
      end
    end
  end
  for s,n in pairs(counts) do
    if m:_uses(s)+n>1 then return false end
  end
  return true
end

local function candidate_bindings(m,patch,pool,d,bindings)
  local out,points={},{}
  for _,o in ipairs(pool) do
    if o.dim==d.dim and o.sort==d.sort and strand_injective(bindings,d,o) then
      local skip=false
      if d.dim==0 then
        local r=point_rep(m,o)
        if points[r] then skip=true else points[r]=true end
      end
      if not skip then
        local b=copy_map(bindings)
        local ok=match(m,d,o,patch,b,{})
        if ok then out[#out+1]={offered=o,bindings=b} end
      end
    end
  end
  return out
end

local function complete(patch,bindings)
  for _,d in ipairs(patch.demands) do if not bindings[d] then return false end end
  return true
end

local function choose_demand(m,patch,pool,bindings)
  local best,bestc
  for _,d in ipairs(patch.demands) do
    if not bindings[d] then
      local cs=candidate_bindings(m,patch,pool,d,bindings)
      if not best or #cs<#bestc or (#cs==#bestc and d.serial<best.serial) then best,bestc=d,cs end
      if #cs==0 then break end
    end
  end
  return best,bestc
end

local function point_binding_key(m,o)
  return 'P'..tostring(point_rep(m,o))
end
local function binding_signature(m,patch,bindings)
  local rows={}
  for _,d in ipairs(patch.demands) do
    local o=bindings[d]
    if o then
      local rhs
      if o.dim==0 then rhs=point_binding_key(m,o)
      elseif o.dim==1 then rhs='S'..tostring(o.serial)
      else rhs='C'..tostring(o.serial) end
      rows[#rows+1]=tostring(d.serial)..'='..rhs
    end
  end
  table.sort(rows)
  return table.concat(rows,',')
end

local function patch_fingerprint(m,p) return topology_fingerprint(m,p) end

-- Conservative proof/search invalidation frontier. This is deliberately an
-- implementation aid, not part of Att's mathematical definition.
local function frontier(m,patch,world)
  local shapes=relevant_shapes(patch)
  local facts={'W:'..tostring(world.serial),'P:'..patch_fingerprint(m,patch)}
  local constants={}
  for c in pairs(patch.component) do
    for _,d in ipairs(m:deps(c)) do if d.dim==0 and m:is_realised(d) then constants[d]=true end end
  end
  for p in pairs(constants) do facts[#facts+1]='A:'..p.serial..'=P'..point_rep(m,p) end
  for _,c in ipairs(m.objects) do
    if c.dim>=0 and m:is_realised(c) and c.world==world then
      if c.dim==0 and shapes[shape_key(c)] then
        facts[#facts+1]='P:'..c.sort..':P'..point_rep(m,c)
      elseif c.dim==1 and shapes[shape_key(c)] then
        local ps={}; for _,p in ipairs(c.points) do ps[#ps+1]=p.sort..'=P'..point_rep(m,p) end
        facts[#facts+1]='S:'..c.serial..':'..c.sort..':u'..m:_uses(c)..':['..table.concat(ps,';')..']'
      end
    end
  end
  table.sort(facts)
  return table.concat(facts,'|'),facts
end

local function derive_patch(ps)
  local im=model(ps.model)
  local p=topology_patch(im,ps.seed)
  assertf(p.attachable,'detached component is no longer an attachable patch')
  return im,p
end

function A.patch(m,seed)
  local im=model(m)
  assertf(seed and seed.dim and seed.dim>=0 and im:is_suspended(seed),'Attachment.patch expects suspended geometry')
  local p=Topology.patch(im,seed)
  assertf(p.attachable,'detached component is not an attachable open patch')
  local h=setmetatable({},PatchMT); patch_state[h]={model=m,seed=seed}; return h
end

function A.patches(m)
  local im=model(m); local out={}
  for _,p in ipairs(topology_patches(im)) do
    local h=setmetatable({},PatchMT); patch_state[h]={model=m,seed=p.seed}; out[#out+1]=h
  end
  return out
end

function PatchMT:seed() return state_of(patch_state,self,'Patch').seed end
function PatchMT:inputs()
  local _,p=derive_patch(state_of(patch_state,self,'Patch')); return copy_array(p.inputs)
end
function PatchMT:outputs()
  local _,p=derive_patch(state_of(patch_state,self,'Patch')); return copy_array(p.outputs)
end
function PatchMT:demands()
  local _,p=derive_patch(state_of(patch_state,self,'Patch')); return copy_array(p.demands)
end
function PatchMT:cells()
  local _,p=derive_patch(state_of(patch_state,self,'Patch')); local xs={}
  for c in pairs(p.component) do xs[#xs+1]=c end
  table.sort(xs,function(a,b)return a.serial<b.serial end); return xs
end

local function fixed_bindings(m,patch,world,fixed)
  local bindings={}
  local demand_set={}; for _,d in ipairs(patch.demands) do demand_set[d]=true end
  for i,row in ipairs(fixed or {}) do
    assertf(type(row)=='table' and row.demand and row.supply,'binding %d requires demand and supply',i)
    assertf(demand_set[row.demand],'binding %d demand is not on this patch boundary',i)
    if row.demand.dim==1 then
      if not (row.supply.dim==1 and m:is_realised(row.supply) and row.supply.world==world and m:_uses(row.supply)==0) then
        return nil,'nonlocal-or-spent-authority'
      end
    end
    if not strand_injective(bindings,row.demand,row.supply) then return nil,'scarcity' end
    local b=copy_map(bindings)
    local ok,why=match(m,row.demand,row.supply,patch,b,{})
    if not ok then return nil,why end
    bindings=b
  end
  return bindings
end

local function make_witness(qs,bindings)
  local h=setmetatable({},WitnessMT)
  witness_state[h]={
    model=qs.model,world=qs.world,patch=qs.patch,bindings=copy_map(bindings),
    signature=binding_signature(qs.im,qs.derived,bindings),
  }
  return h
end

local function reset(qs,reason)
  qs.im,qs.derived=derive_patch(state_of(patch_state,qs.patch,'Patch'))
  assertf(qs.im:is_realised(qs.world),'attachment locality must be actual')
  qs.frontier_key,qs.frontier_facts=frontier(qs.im,qs.derived,qs.world)
  qs.pool=offer_pool(qs.im,qs.derived,qs.world)
  qs.restarts=qs.restarts+(qs.started and 1 or 0); qs.started=true; qs.done=false; qs.result=nil
  local base,why=fixed_bindings(qs.im,qs.derived,qs.world,qs.fixed)
  local im,patch,world,pool=qs.im,qs.derived,qs.world,qs.pool
  qs.co=coroutine.create(function()
    if not base then
      local c=setmetatable({},CertMT)
      cert_state[c]={model=qs.model,patch=qs.patch,world=world,key=qs.frontier_key,facts=qs.frontier_facts}
      return 'retry',c
    end
    local function search(bindings)
      coroutine.yield('tick')
      if complete(patch,bindings) then
        if prospective_valid(im,patch,bindings) then return 'hit',make_witness(qs,bindings) end
        return nil
      end
      local d,cs=choose_demand(im,patch,pool,bindings)
      if not d or #cs==0 then return nil end
      for _,c in ipairs(cs) do
        local status,w=search(c.bindings)
        if status=='hit' then return status,w end
      end
      return nil
    end
    local status,w=search(base)
    if status=='hit' then return status,w end
    local c=setmetatable({},CertMT)
    cert_state[c]={model=qs.model,patch=qs.patch,world=world,key=qs.frontier_key,facts=qs.frontier_facts}
    return 'retry',c
  end)
  qs.last_reset_reason=reason or 'initial'
end

function A.query(m,world,patch,fixed)
  model(m)
  local ps=state_of(patch_state,patch,'Patch')
  assertf(ps.model==m,'Patch belongs to another World Model')
  local copied_fixed={}
  for i,row in ipairs(fixed or {}) do copied_fixed[i]={demand=row.demand,supply=row.supply} end
  local q=setmetatable({},QueryMT)
  local qs={model=m,world=world,patch=patch,fixed=copied_fixed,steps=0,restarts=0,started=false}
  query_state[q]=qs; reset(qs,'initial'); return q
end

function QueryMT:step(budget)
  local qs=state_of(query_state,self,'Query'); budget=budget or 1
  -- A retained query denotes the current Att_K(P), not a historical answer.
  -- Revalidate the relevant frontier even after a prior Hit/Retry; otherwise a
  -- completed query could keep reporting a stale fact after actuality changes.
  local current=frontier(qs.im,topology_patch(qs.im,state_of(patch_state,qs.patch,'Patch').seed),qs.world)
  if current~=qs.frontier_key then reset(qs,'frontier-changed') end
  if qs.done then return qs.result.status,qs.result.value end
  for _=1,budget do
    qs.steps=qs.steps+1
    local ok,status,value=coroutine.resume(qs.co)
    if not ok then error(status,2) end
    if coroutine.status(qs.co)=='dead' then
      qs.done=true; qs.result={status=status,value=value}; return status,value
    end
    assert(status=='tick','unexpected attachment search yield '..tostring(status))
  end
  return 'unknown',{steps=qs.steps,restarts=qs.restarts,facts=copy_array(qs.frontier_facts)}
end
function QueryMT:steps() return state_of(query_state,self,'Query').steps end
function QueryMT:restarts() return state_of(query_state,self,'Query').restarts end

function WitnessMT:patch() return state_of(witness_state,self,'Witness').patch end
function WitnessMT:world() return state_of(witness_state,self,'Witness').world end
function WitnessMT:bindings()
  local s=state_of(witness_state,self,'Witness'); local rows={}
  for d,o in pairs(s.bindings) do rows[#rows+1]={demand=d,supply=o} end
  table.sort(rows,function(a,b)return a.demand.serial<b.demand.serial end); return rows
end
function WitnessMT:signature() return state_of(witness_state,self,'Witness').signature end

function CertMT:valid()
  local s=state_of(cert_state,self,'Certificate')
  local ok,im,p=pcall(function()
    local im,p=derive_patch(state_of(patch_state,s.patch,'Patch'))
    return im,p
  end)
  if not ok then return false end
  local k=frontier(im,p,s.world); return k==s.key
end
function CertMT:facts() return copy_array(state_of(cert_state,self,'Certificate').facts) end

local function exact_bindings(ws)
  local im,p=derive_patch(state_of(patch_state,ws.patch,'Patch'))
  if not im:is_realised(ws.world) then return nil,'dead-locality' end
  local bindings={}
  for _,d in ipairs(p.demands) do
    local o=ws.bindings[d]
    if not o then return nil,'missing-binding' end
    if o.dim==1 then
      if o.world~=ws.world or im:_uses(o)~=0 or not strand_injective(bindings,d,o) then return nil,'stale-authority' end
    elseif not im:is_realised(o) then return nil,'stale-binding' end
    local b=copy_map(bindings); local ok,why=match(im,d,o,p,b,{})
    if not ok then return nil,why end
    bindings=b
  end
  if not prospective_valid(im,p,bindings) then return nil,'prospective-scarcity' end
  if binding_signature(im,p,bindings)~=ws.signature then return nil,'changed-binding' end
  return bindings,p,im
end

function A.graft(witness)
  local ws=state_of(witness_state,witness,'Witness')
  local im=model(ws.model)
  return im:atomic(function()
    local bindings=exact_bindings(ws)
    assertf(bindings,'stale or invalid attachment witness')
    return im:_graft_attachment(state_of(patch_state,ws.patch,'Patch').seed,ws.world,bindings)
  end)
end

function A.is_patch(x) return patch_state[x]~=nil end
function A.is_witness(x) return witness_state[x]~=nil end
function A.is_certificate(x) return cert_state[x]~=nil end

return A
