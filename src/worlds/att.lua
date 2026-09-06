-- Worlds 0.3 complete attachment over available frontiers.
--
-- Att_F(P) is one relation.  F may be the available frontier of current
-- actuality or an exact residual frontier derived from a Witness.  Models and
-- immutable certified/read-only geometry use the same matcher; only a live
-- Model Witness may graft.  Residual frontiers create no carrier objects.

local Internal=require('worlds.internal')
local Topology=require('worlds.topology')
local internal_is_model=assert(Internal.is_model)
local internal_model=assert(Internal.model)

local A={}
local PatchMT={}; PatchMT.__index=PatchMT; PatchMT.__metatable=false
local FrontierMT={}; FrontierMT.__index=FrontierMT; FrontierMT.__metatable=false
local QueryMT={}; QueryMT.__index=QueryMT; QueryMT.__metatable=false
local WitnessMT={}; WitnessMT.__index=WitnessMT; WitnessMT.__metatable=false
local CertMT={}; CertMT.__index=CertMT; CertMT.__metatable=false
local CutMT={}; CutMT.__index=CutMT; CutMT.__metatable=false
for _,mt in ipairs{PatchMT,FrontierMT,QueryMT,WitnessMT,CertMT,CutMT} do mt.__newindex=function() error('Worlds Att handles are immutable',2) end end

local patch_state=setmetatable({}, {__mode='k'})
local frontier_state=setmetatable({}, {__mode='k'})
local query_state=setmetatable({}, {__mode='k'})
local witness_state=setmetatable({}, {__mode='k'})
local cert_state=setmetatable({}, {__mode='k'})
local cut_state=setmetatable({}, {__mode='k'})
local adapter_cache=setmetatable({}, {__mode='k'})

local function assertf(ok,fmt,...) if not ok then error(string.format(fmt,...),3) end end
local function copy_array(xs) local o={}; for i=1,#(xs or {}) do o[i]=xs[i] end; return o end
local function copy_map(t) local o={}; for k,v in pairs(t or {}) do o[k]=v end; return o end
local function copy_set(t) local o={}; for k,v in pairs(t or {}) do if v then o[k]=true end end; return o end
local function state_of(map,x,what) local s=map[x]; if not s then error('expected Worlds '..what,3) end; return s end
local function deps(c)
  if c.dim==0 then return {} end
  if c.dim==1 then return c.points or {} end
  local out={}; for _,x in ipairs(c.inputs or {}) do out[#out+1]=x end; for _,x in ipairs(c.outputs or {}) do out[#out+1]=x end; return out
end
local function id_sort(a,b) return a.serial<b.serial end
local function cell_token(c) return c.key or c.raw_id or tostring(c.serial) end

-- --------------------------------------------------------------------------
-- Read-only geometry adapter.  It is an index/view, never a reconstructed Model.
-- --------------------------------------------------------------------------
local function make_reader_adapter(r)
  local cached=adapter_cache[r]; if cached then return cached end
  assertf(type(r)=='table' and type(r.worlds)=='function' and type(r.point)=='function' and type(r.strand)=='function' and type(r.face)=='function','Att source must be a World Model or geometric Reader')
  local m={source=r,live=false,objects={},worlds={}}
  local by_world,by_point,by_strand,by_face={},{},{},{}
  local serial=0
  local function next_serial() serial=serial+1; return serial end
  for _,id in ipairs(r:worlds()) do local x=r:world(id); local w={dim=-1,serial=next_serial(),raw_id=id,id=id,name=id,sort='world',_record=x}; by_world[id]=w; m.worlds[#m.worlds+1]=w; m.objects[#m.objects+1]=w end
  for id,w in pairs(by_world) do local p=w._record.parent; w.parent=p and by_world[p] or nil end
  local root=r:root(); m.actuality=assert(by_world[root],'Reader root missing')
  local function world_of(id) return assert(by_world[id],'unknown reader World '..tostring(id)) end
  for _,id in ipairs(r:points()) do local x=r:point(id); local c={dim=0,serial=next_serial(),raw_id=id,id=id,name=id,sort=x.sort,world=world_of(x.world),component=x.component,origin_id=x.origin}; by_point[id]=c; m.objects[#m.objects+1]=c end
  for _,id in ipairs(r:strands()) do local x=r:strand(id); local c={dim=1,serial=next_serial(),raw_id=id,id=id,name=id,sort=x.sort,world=world_of(x.world),points={},origin_id=x.origin}; by_strand[id]=c; m.objects[#m.objects+1]=c end
  for id,c in pairs(by_strand) do for _,pid in ipairs(r:strand(id).points or {}) do c.points[#c.points+1]=assert(by_point[pid],'reader Strand Point missing') end end
  for _,id in ipairs(r:faces()) do local x=r:face(id); local c={dim=2,serial=next_serial(),raw_id=id,id=id,name=id,sort=x.sort,world=world_of(x.world),inputs={},outputs={},structural=x.structural,origin_id=x.origin}; by_face[id]=c; m.objects[#m.objects+1]=c end
  for id,c in pairs(by_face) do local x=r:face(id); for _,sid in ipairs(x.inputs or {}) do c.inputs[#c.inputs+1]=assert(by_strand[sid]) end; for _,sid in ipairs(x.outputs or {}) do c.outputs[#c.outputs+1]=assert(by_strand[sid]) end end
  local parents={}; for _,c in ipairs(m.objects) do if c.dim>=1 then for _,d in ipairs(deps(c)) do local xs=parents[d] or {}; parents[d]=xs; xs[#xs+1]=c end end end
  local function root_of(w) while w and w.parent do w=w.parent end; return w end
  function m:is_realised(x) local w=x.dim==-1 and x or x.world; return root_of(w)==self.actuality end
  function m:is_suspended(x) return not self:is_realised(x) end
  function m:_susp_root(w) local q=root_of(w); return q==self.actuality and nil or q end
  function m:_parents(c) return copy_array(parents[c] or {}) end
  function m:deps(c) return deps(c) end
  function m:same_point(a,b) if not (a and b and a.dim==0 and b.dim==0) then return false end; return r:same_point(a.raw_id,b.raw_id) end
  function m:_uses(s) local n=0; for _,f in ipairs(parents[s] or {}) do if f.dim==2 and self:is_realised(f) then for _,x in ipairs(f.inputs) do if x==s then n=n+1 end end end end; return n end
  function m:_owned(x,dim) return type(x)=='table' and x.dim==dim and ((dim==-1 and by_world[x.raw_id]==x) or (dim==0 and by_point[x.raw_id]==x) or (dim==1 and by_strand[x.raw_id]==x) or (dim==2 and by_face[x.raw_id]==x)) end
  function m:lookup(x)
    if type(x)=='table' and x.dim~=nil then return x end
    return by_world[x] or by_point[x] or by_strand[x] or by_face[x]
  end
  m._reader=r; m._by_world=by_world; m._by_point=by_point; m._by_strand=by_strand; m._by_face=by_face
  adapter_cache[r]=m; return m
end

local function adapter(source)
  if internal_is_model(source) then
    local cached=adapter_cache[source]; if cached then return cached end
    local raw=internal_model(source)
    local m=setmetatable({source=source,live=true,raw=raw},{__index=function(_,k) if k=='objects' or k=='worlds' or k=='actuality' then return raw[k] end end})
    function m:is_realised(x) return raw:is_realised(x) end
    function m:is_suspended(x) return raw:is_suspended(x) end
    function m:_susp_root(w) return raw:_susp_root(w) end
    function m:_parents(c) return raw:_parents(c) end
    function m:deps(c) return raw:deps(c) end
    function m:same_point(a,b) return raw:same_point(a,b) end
    function m:_uses(s) return raw:_uses(s) end
    function m:_owned(x,dim) return raw:_owned(x,dim) end
    function m:lookup(x) return x end
    function m:atomic(f) return raw:atomic(f) end
    function m:_graft_attachment(seed,world,bindings) return raw:_graft_attachment(seed,world,bindings) end
    adapter_cache[source]=m; return m
  end
  return make_reader_adapter(source)
end
local function resolve(m,x,dim)
  local o=m.lookup and m:lookup(x) or x
  if dim==nil then assertf(o and o.dim~=nil,'expected geometric cell'); return o end
  assertf(o and o.dim==dim,'expected dimension %d geometry',dim)
  return o
end
local function public_cell(m,c) return (not m.live and c.raw_id) or c end

-- --------------------------------------------------------------------------
-- Point terms and available offers.
-- --------------------------------------------------------------------------
local function is_virtual(x) return type(x)=='table' and x._virtual==true end
local function point_rep(m,p)
  if is_virtual(p) then return p.key end
  local best=p
  for _,o in ipairs(m.objects) do if o.dim==0 and m:is_realised(o) and m:same_point(p,o) and o.serial<best.serial then best=o end end
  return 'P'..cell_token(best)
end
local function point_equal(m,a,b)
  if is_virtual(a) or is_virtual(b) then return is_virtual(a) and is_virtual(b) and a.key==b.key end
  return m:same_point(a,b)
end
local function offer_key(o)
  if is_virtual(o) then return o.key end
  return (o.dim==0 and 'AP:' or 'AS:')..cell_token(o)
end
local function offer_points(o) return o.points or {} end
local function offer_sort(o) return o.sort end
local function actual_offers(m,world)
  local out={}
  for _,c in ipairs(m.objects) do if c.dim==1 and m:is_realised(c) and c.world==world and m:_uses(c)==0 then out[#out+1]=c end end
  table.sort(out,function(a,b)return offer_key(a)<offer_key(b) end); return out
end
local function actual_points(m,world)
  local out={}; for _,c in ipairs(m.objects) do if c.dim==0 and m:is_realised(c) and c.world==world then out[#out+1]=c end end
  table.sort(out,id_sort); return out
end

-- --------------------------------------------------------------------------
-- Patches are topology, not stored ontology.
-- --------------------------------------------------------------------------
local function derive_patch(ps)
  local p=Topology.patch(ps.im,ps.seed); assertf(p.attachable,'detached component is no longer attachable'); return p
end
function A.patch(source,seed)
  local m=adapter(source); seed=resolve(m,seed,seed and seed.dim or nil)
  assertf(seed and seed.dim and seed.dim>=0 and m:is_suspended(seed),'Att.patch expects detached geometry')
  local p=Topology.patch(m,seed); assertf(p.attachable,'detached component is not an attachable open patch')
  local h=setmetatable({},PatchMT); patch_state[h]={source=source,im=m,seed=seed}; return h
end
function A.patches(source)
  local m=adapter(source); local out={}
  for _,p in ipairs(Topology.patches(m)) do local h=setmetatable({},PatchMT); patch_state[h]={source=source,im=m,seed=p.seed}; out[#out+1]=h end
  return out
end
function PatchMT:seed() local s=state_of(patch_state,self,'Patch'); return public_cell(s.im,s.seed) end
function PatchMT:inputs() local s=state_of(patch_state,self,'Patch'); local out={}; for _,x in ipairs(derive_patch(s).inputs) do out[#out+1]=public_cell(s.im,x) end; return out end
function PatchMT:outputs() local s=state_of(patch_state,self,'Patch'); local out={}; for _,x in ipairs(derive_patch(s).outputs) do out[#out+1]=public_cell(s.im,x) end; return out end
function PatchMT:demands() local s=state_of(patch_state,self,'Patch'); local out={}; for _,x in ipairs(derive_patch(s).demands) do out[#out+1]=public_cell(s.im,x) end; return out end
function PatchMT:cells() local s=state_of(patch_state,self,'Patch'); local out={}; for x in pairs(derive_patch(s).component) do out[#out+1]=public_cell(s.im,x) end; return out end

-- --------------------------------------------------------------------------
-- Frontiers.
-- --------------------------------------------------------------------------
local function frontier_signature(s)
  local xs={}; for _,o in ipairs(s.available) do
    local ps={}; for _,p in ipairs(offer_points(o)) do ps[#ps+1]=point_rep(s.im,p) end
    xs[#xs+1]=offer_key(o)..':'..tostring(offer_sort(o))..'['..table.concat(ps,',')..']'
  end
  table.sort(xs); return table.concat(xs,'|')
end
local function make_frontier(s)
  local h=setmetatable({},FrontierMT); s.signature=frontier_signature(s); frontier_state[h]=s; return h
end
function A.at(source,locality)
  local m=adapter(source); locality=resolve(m,locality,-1); assertf(m:is_realised(locality),'Att.at locality must be actual')
  return make_frontier{source=source,im=m,locality=locality,available=actual_offers(m,locality),points=actual_points(m,locality),past={}}
end
function FrontierMT:signature() return state_of(frontier_state,self,'Frontier').signature end
function FrontierMT:offers()
  local s=state_of(frontier_state,self,'Frontier'); local out={}
  for _,o in ipairs(s.available) do out[#out+1]={key=offer_key(o),sort=offer_sort(o),kind=is_virtual(o) and 'residual' or 'actual'} end
  return out
end

-- --------------------------------------------------------------------------
-- Complete matching over either actual or residual available geometry.
-- --------------------------------------------------------------------------
local function expected_point_match(m,p,term,bindings)
  if m:is_realised(p) then return (not is_virtual(term)) and point_equal(m,p,term) end
  local prior=bindings[p]; if prior then return point_equal(m,prior,term) end
  bindings[p]=term; return true
end
local function strand_match(m,demand,offer,bindings)
  if demand.dim~=1 or offer_sort(offer)~=demand.sort or #offer_points(offer)~=#demand.points then return false end
  for i,p in ipairs(demand.points) do if not expected_point_match(m,p,offer_points(offer)[i],bindings) then return false end end
  return true
end
local function point_offers(fs)
  local s=state_of(frontier_state,fs,'Frontier'); local out,seen={},{}
  local function add(p) local k=point_rep(s.im,p); if not seen[k] then seen[k]=true; out[#out+1]=p end end
  for _,o in ipairs(s.available) do for _,p in ipairs(offer_points(o)) do add(p) end end
  for _,p in ipairs(s.points or {}) do add(p) end
  table.sort(out,function(a,b)return point_rep(s.im,a)<point_rep(s.im,b) end); return out
end
local function demand_candidates(fs,d,bindings,used)
  local s=state_of(frontier_state,fs,'Frontier'); local out={}
  if d.dim==1 then
    for _,o in ipairs(s.available) do if not used[offer_key(o)] then local b=copy_map(bindings); if strand_match(s.im,d,o,b) then b[d]=o; out[#out+1]={offer=o,bindings=b} end end end
  elseif d.dim==0 then
    for _,o in ipairs(point_offers(fs)) do local b=copy_map(bindings); if expected_point_match(s.im,d,o,b) then b[d]=o; out[#out+1]={offer=o,bindings=b} end end
  else
    error('Att currently expects Point/Strand boundary demands; found dim '..tostring(d.dim),2)
  end
  return out
end
local function choose_demand(fs,p,bindings,used)
  local best,bestc
  for _,d in ipairs(p.demands) do if not bindings[d] then
    local cs=demand_candidates(fs,d,bindings,used)
    if not best or #cs<#bestc or (#cs==#bestc and d.serial<best.serial) then best,bestc=d,cs end
    if #cs==0 then break end
  end end
  return best,bestc
end
local function complete(p,bindings) for _,d in ipairs(p.demands) do if not bindings[d] then return false end end; return true end
local function event_key(patch,rows)
  local ps=state_of(patch_state,patch,'Patch'); local xs={}
  for _,r in ipairs(rows) do xs[#xs+1]=tostring(r.demand.serial)..'='..offer_key(r.offer) end; table.sort(xs)
  return 'E{'..cell_token(ps.seed)..'}['..table.concat(xs,',')..']'
end
local function make_witness(fs,patch,rows,bindings)
  local h=setmetatable({},WitnessMT); local key=event_key(patch,rows)
  witness_state[h]={frontier=fs,patch=patch,rows=copy_array(rows),bindings=copy_map(bindings),key=key}; return h
end
local function enumerate(fs,patch,fixed,yield_tick,stop_first)
  local fstate=state_of(frontier_state,fs,'Frontier'); local ps=state_of(patch_state,patch,'Patch')
  assertf(ps.im==fstate.im,'Patch and Frontier belong to different geometry')
  local p=derive_patch(ps); local base,used,rows={},{},{}; local results={}
  for i,row in ipairs(fixed or {}) do
    local d=resolve(ps.im,row.demand,row.demand and row.demand.dim or nil); local o=resolve(ps.im,row.supply or row.offer,(row.supply or row.offer) and (row.supply or row.offer).dim or nil)
    local found=false; for _,pd in ipairs(p.demands) do if pd==d then found=true end end; assertf(found,'fixed binding %d demand is not in Patch',i)
    local b=copy_map(base)
    if d.dim==1 then
      if used[offer_key(o)] then return results end
      local present=false; for _,x in ipairs(fstate.available) do if offer_key(x)==offer_key(o) then present=true; o=x; break end end
      if not present or not strand_match(ps.im,d,o,b) then return results end
      b[d]=o; used[offer_key(o)]=true
    elseif d.dim==0 then if not expected_point_match(ps.im,d,o,b) then return results end; b[d]=o end
    base=b; rows[#rows+1]={demand=d,offer=o}
  end
  local function search(bindings,used0,rows0)
    if yield_tick then yield_tick() end
    if complete(p,bindings) then results[#results+1]=make_witness(fs,patch,rows0,bindings); return stop_first and true or false end
    local d,cs=choose_demand(fs,p,bindings,used0); if not d or #cs==0 then return false end
    for _,c in ipairs(cs) do
      local u=copy_map(used0); if d.dim==1 then u[offer_key(c.offer)]=true end
      local r=copy_array(rows0); r[#r+1]={demand=d,offer=c.offer}; if search(c.bindings,u,r) and stop_first then return true end
    end
    return false
  end
  search(base,used,rows)
  table.sort(results,function(a,b)return witness_state[a].key<witness_state[b].key end); return results
end
function FrontierMT:witnesses(patch,fixed) return enumerate(self,patch,fixed,nil,false) end

local function patch_signature(patch)
  local ps=state_of(patch_state,patch,'Patch'); local rows={}
  for _,c in ipairs(patch:cells()) do
    local o=resolve(ps.im,c,nil); local ds={}; for _,d in ipairs(deps(o)) do ds[#ds+1]=cell_token(d) end; table.sort(ds)
    rows[#rows+1]=table.concat({cell_token(o),o.dim,tostring(o.sort),table.concat(ds,',')},':')
  end
  table.sort(rows); return table.concat(rows,'|')
end
local function query_signature(frontier,patch)
  local fs=state_of(frontier_state,frontier,'Frontier'); local ps=state_of(patch_state,patch,'Patch'); local p=derive_patch(ps); local shapes={}
  for _,d in ipairs(p.demands) do shapes[d.dim..':'..tostring(d.sort)..':'..(d.dim==1 and #d.points or 0)]=true end
  local rows={'P:'..patch_signature(patch)}
  for _,o in ipairs(fs.available) do
    local k='1:'..tostring(offer_sort(o))..':'..#offer_points(o)
    if shapes[k] then local pts={}; for _,q in ipairs(offer_points(o)) do pts[#pts+1]=point_rep(fs.im,q) end; rows[#rows+1]=offer_key(o)..'['..table.concat(pts,',')..']' end
  end
  for _,q in ipairs(point_offers(frontier)) do if shapes['0:'..tostring(q.sort)..':0'] then rows[#rows+1]='Q:'..point_rep(fs.im,q)..':'..tostring(q.sort) end end
  table.sort(rows); return table.concat(rows,'|')
end
local function query_coroutine(qs)
  return coroutine.create(function()
    local results=enumerate(qs.frontier,qs.patch,qs.fixed,function() coroutine.yield('tick') end,true)
    if #results>0 then return 'hit',results[1] end
    local c=setmetatable({},CertMT); cert_state[c]={frontier=qs.frontier,patch=qs.patch,signature=query_signature(qs.frontier,qs.patch)}; return 'retry',c
  end)
end
local function reset_query(qs,frontier)
  qs.frontier=frontier or qs.frontier; qs.co=query_coroutine(qs); qs.done=false; qs.result=nil
end
function FrontierMT:query(patch,fixed)
  local q=setmetatable({},QueryMT); local qs={frontier=self,patch=patch,fixed=copy_array(fixed or {}),steps=0,restarts=0,done=false,result=nil}; query_state[q]=qs; reset_query(qs); return q
end
function QueryMT:step(budget)
  local s=state_of(query_state,self,'Query'); budget=budget or 1
  local fs=state_of(frontier_state,s.frontier,'Frontier')
  if fs.im.live and not next(fs.past) then
    local fresh=A.at(fs.source,public_cell(fs.im,fs.locality))
    if query_signature(fresh,s.patch)~=query_signature(s.frontier,s.patch) then s.restarts=s.restarts+1; reset_query(s,fresh) end
  end
  if s.done then return s.result[1],s.result[2] end
  for _=1,budget do
    s.steps=s.steps+1; local ok,a,b=coroutine.resume(s.co); if not ok then error(a,2) end
    if coroutine.status(s.co)=='dead' then s.done=true; s.result={a,b}; return a,b end
  end
  return 'unknown',{steps=s.steps,restarts=s.restarts}
end
function QueryMT:steps() return state_of(query_state,self,'Query').steps end
function QueryMT:restarts() return state_of(query_state,self,'Query').restarts end
function CertMT:valid() local s=state_of(cert_state,self,'Certificate'); local fs=state_of(frontier_state,s.frontier,'Frontier'); local f=s.frontier; if fs.im.live and not next(fs.past) then f=A.at(fs.source,public_cell(fs.im,fs.locality)) end; local ok,v=pcall(query_signature,f,s.patch); return ok and v==s.signature end
function CertMT:facts() return {state_of(cert_state,self,'Certificate').signature} end

-- --------------------------------------------------------------------------
-- Exact witnesses, residual frontiers and causality.
-- --------------------------------------------------------------------------
function WitnessMT:patch() return state_of(witness_state,self,'Witness').patch end
function WitnessMT:frontier() return state_of(witness_state,self,'Witness').frontier end
function WitnessMT:key() return state_of(witness_state,self,'Witness').key end
function WitnessMT:signature() return self:key() end
function WitnessMT:bindings()
  local ws=state_of(witness_state,self,'Witness'); local ps=state_of(patch_state,ws.patch,'Patch'); local out={}
  for _,r in ipairs(ws.rows) do out[#out+1]={demand=public_cell(ps.im,r.demand),supply=is_virtual(r.offer) and r.offer or public_cell(ps.im,r.offer)} end
  return out
end
function WitnessMT:support()
  local ws=state_of(witness_state,self,'Witness'); local ps=state_of(patch_state,ws.patch,'Patch'); local out={}
  for _,r in ipairs(ws.rows) do if r.demand.dim==1 then out[#out+1]=is_virtual(r.offer) and r.offer or public_cell(ps.im,r.offer) end end
  return out
end
function WitnessMT:predecessors()
  local ws=state_of(witness_state,self,'Witness'); local seen,out={},{}
  local function add(k) if k and not seen[k] then seen[k]=true; out[#out+1]=k end end
  for _,r in ipairs(ws.rows) do
    if is_virtual(r.offer) then add(r.offer.producer) end
    for _,p in ipairs(offer_points(r.offer)) do if is_virtual(p) then add(p.producer) end end
  end
  for _,t in pairs(ws.bindings) do if is_virtual(t) then add(t.producer) end end
  table.sort(out); return out
end
local function exact_valid(ws)
  local fs=state_of(frontier_state,ws.frontier,'Frontier'); if not fs.im.live or next(fs.past) then return true end
  -- Validate the chosen geometry directly; never rerun Att to rediscover it.
  local now={}; for _,o in ipairs(actual_offers(fs.im,fs.locality)) do now[offer_key(o)]=o end
  for _,r in ipairs(ws.rows) do if r.demand.dim==1 then local o=now[offer_key(r.offer)]; if not o then return false,'stale-authority' end end end
  return true
end
function WitnessMT:valid() return exact_valid(state_of(witness_state,self,'Witness')) end

local function patch_generated_points(ps,p)
  local out={}; for c in pairs(p.component) do local root=ps.im:_susp_root(c.world); if c.dim==0 and root and p.generated_roots[root] then out[c]=true end end; return out
end
local function materialise_outputs(ws)
  local ps=state_of(patch_state,ws.patch,'Patch'); local p=derive_patch(ps); local generated=patch_generated_points(ps,p); local point_map=copy_map(ws.bindings)
  local function mapped(x)
    if point_map[x] then return point_map[x] end
    if ps.im:is_realised(x) then point_map[x]=x; return x end
    if generated[x] then local v={_virtual=true,dim=0,sort=x.sort,key='VP{'..ws.key..'}:'..cell_token(x),producer=ws.key,proto=x}; point_map[x]=v; return v end
    error('Att residual egress has unmapped suspended Point '..cell_token(x),2)
  end
  local out={}; for _,s in ipairs(p.outputs) do local pts={}; for i,x in ipairs(s.points) do pts[i]=mapped(x) end; out[#out+1]={_virtual=true,dim=1,sort=s.sort,points=pts,key='VS{'..ws.key..'}:'..cell_token(s),producer=ws.key,proto=s} end
  return out
end
function WitnessMT:egress()
  local ws=state_of(witness_state,self,'Witness'); local ps=state_of(patch_state,ws.patch,'Patch'); local p=derive_patch(ps); local offers=materialise_outputs(ws); local out={}
  for i,o in ipairs(offers) do out[#out+1]={output=public_cell(ps.im,p.outputs[i]),offer=o} end
  return out
end
function WitnessMT:after()
  local ws=state_of(witness_state,self,'Witness'); local ok,why=exact_valid(ws); assertf(ok,'stale exact Witness%s',why and (': '..why) or '')
  local fs=state_of(frontier_state,ws.frontier,'Frontier'); local consumed={}; for _,r in ipairs(ws.rows) do if r.demand.dim==1 then consumed[offer_key(r.offer)]=true end end
  local available={}; for _,o in ipairs(fs.available) do if not consumed[offer_key(o)] then available[#available+1]=o end end
  for _,o in ipairs(materialise_outputs(ws)) do available[#available+1]=o end; table.sort(available,function(a,b)return offer_key(a)<offer_key(b) end)
  local past=copy_set(fs.past); assertf(not past[ws.key],'exact residual occurrence already present'); past[ws.key]=true
  return make_frontier{source=fs.source,im=fs.im,locality=fs.locality,available=available,points=fs.points,past=past}
end
function WitnessMT:graft()
  local ws=state_of(witness_state,self,'Witness'); local fs=state_of(frontier_state,ws.frontier,'Frontier'); assertf(fs.im.live and not next(fs.past),'graft requires a live actual Frontier')
  local ok,why=exact_valid(ws); assertf(ok,'stale exact Witness%s',why and (': '..why) or '')
  local ps=state_of(patch_state,ws.patch,'Patch'); local bindings={}
  for d,o in pairs(ws.bindings) do if not is_virtual(o) then bindings[d]=o end end
  for _,r in ipairs(ws.rows) do if r.demand.dim==1 then bindings[r.demand]=r.offer end end
  return fs.im:atomic(function() return fs.im:_graft_attachment(ps.seed,fs.locality,bindings) end)
end


-- --------------------------------------------------------------------------
-- Pointed cuts inside one exact attached patch.  A Cut is proof geometry over
-- existing incidence, not a residual carrier or a second matching subsystem.
-- --------------------------------------------------------------------------
local function cut_new(base,live,done)
  local h=setmetatable({},CutMT); cut_state[h]={witness=base.witness,ps=base.ps,p=base.p,faces=base.faces,fset=base.fset,live=live,done=done,binding=base.binding}; return h
end
function WitnessMT:cut()
  local ws=state_of(witness_state,self,'Witness'); local ok,why=exact_valid(ws); assertf(ok,'cut requires current exact Witness%s',why and (': '..why) or '')
  local ps=state_of(patch_state,ws.patch,'Patch'); local p=derive_patch(ps); local faces,fset={},{}
  for c in pairs(p.component) do local root=ps.im:_susp_root(c.world); if c.dim==2 and root and p.generated_roots[root] then faces[#faces+1]=c; fset[c]=true end end
  table.sort(faces,id_sort)
  local producer,strands={},{}
  for _,f in ipairs(faces) do for _,x in ipairs(f.inputs) do strands[x]=true end; for _,x in ipairs(f.outputs) do strands[x]=true; assertf(not producer[x] or producer[x]==f,'multiple suspended producers'); producer[x]=f end end
  local input_set={}; for _,x in ipairs(p.inputs) do input_set[x]=true end
  local live={}; for x in pairs(strands) do if not producer[x] then assertf(input_set[x],'causal input is not attached open input'); live[x]=true end end
  local binding={}; for d,o in pairs(ws.bindings) do binding[d]=o end
  return cut_new({witness=self,ps=ps,p=p,faces=faces,fset=fset,binding=binding},live,{})
end
local function cut_enabled(s,f) if not s.fset[f] or s.done[f] then return false end; for _,x in ipairs(f.inputs) do if not s.live[x] then return false end end; return true end
local function cut_after(cut,face,revalidate)
  local s=state_of(cut_state,cut,'Cut'); if revalidate then local ok,why=s.witness:valid(); assertf(ok,'Cut no longer has current exact boundary%s',why and (': '..why) or '') end
  face=resolve(s.ps.im,face,2); assertf(cut_enabled(s,face),'Face is not enabled at this exact Cut')
  local live,done=copy_set(s.live),copy_set(s.done); for _,x in ipairs(face.inputs) do live[x]=nil end; for _,x in ipairs(face.outputs) do live[x]=true end; done[face]=true
  return cut_new(s,live,done)
end
function CutMT:enabled() local s=state_of(cut_state,self,'Cut'); local ok,why=s.witness:valid(); assertf(ok,'Cut no longer current%s',why and (': '..why) or ''); local out={}; for _,f in ipairs(s.faces) do if cut_enabled(s,f) then out[#out+1]=public_cell(s.ps.im,f) end end; return out end
function CutMT:after(face) return cut_after(self,face,true) end
function CutMT:past() local s=state_of(cut_state,self,'Cut'); local out={}; for f in pairs(s.done) do out[#out+1]=public_cell(s.ps.im,f) end; table.sort(out,function(a,b) return tostring(a)<tostring(b) end); return out end
function CutMT:cut() local s=state_of(cut_state,self,'Cut'); local out={}; for x in pairs(s.live) do out[#out+1]=public_cell(s.ps.im,x) end; table.sort(out,function(a,b)return tostring(a)<tostring(b) end); return out end
function CutMT:remaining() local s=state_of(cut_state,self,'Cut'); local out={}; for _,f in ipairs(s.faces) do if not s.done[f] then out[#out+1]=public_cell(s.ps.im,f) end end; return out end
function CutMT:terminal() return #self:remaining()==0 end
function CutMT:signature()
  local s=state_of(cut_state,self,'Cut'); local function ids(xs) local os={} for _,x in ipairs(xs) do os[#os+1]=resolve(s.ps.im,x,nil) end table.sort(os,id_sort); local out={} for _,o in ipairs(os) do out[#out+1]=cell_token(o) end return table.concat(out,',') end
  return 'W{'..s.witness:key()..'}|D{'..ids(self:past())..'}|L{'..ids(self:cut())..'}'
end
function CutMT:binding(demand) local s=state_of(cut_state,self,'Cut'); local d=resolve(s.ps.im,demand,nil); local o=s.binding[d]; return o and (is_virtual(o) and o or public_cell(s.ps.im,o)) or nil end
local function same_cut(a,b) local x=state_of(cut_state,a,'Cut'); local y=state_of(cut_state,b,'Cut'); if x.witness:key()~=y.witness:key() then return false end; for f in pairs(x.done) do if not y.done[f] then return false end end; for f in pairs(y.done) do if not x.done[f] then return false end end; for q in pairs(x.live) do if not y.live[q] then return false end end; for q in pairs(y.live) do if not x.live[q] then return false end end; return true end
local function cut_coherence(cut,faces)
  local root=state_of(cut_state,cut,'Cut'); local resolved={}; local seen={}; for i,f in ipairs(faces or {}) do f=resolve(root.ps.im,f,2); assertf(not seen[f],'coherence Face %d repeated',i); seen[f]=true; if not cut_enabled(root,f) then return false,{reason='not-initially-enabled',face=public_cell(root.ps.im,f)} end; resolved[i]=f end
  local n=#resolved; local vertices={[0]=cut}; local function popbit(mask) for i=1,n do local bit=2^(i-1); if mask%(bit*2)>=bit then return i,mask-bit end end end
  for mask=1,2^n-1 do local i,parent=popbit(mask); vertices[mask]=cut_after(vertices[parent],resolved[i],false) end
  for mask=0,2^n-1 do for i=1,n do local bit=2^(i-1); if mask%(bit*2)<bit then local to=cut_after(vertices[mask],resolved[i],false); if not same_cut(to,vertices[mask+bit]) then return false,{reason='incoherent-face-map',mask=mask,face=public_cell(root.ps.im,resolved[i])} end end end end
  return true,{dimension=n,vertex_count=2^n,vertices=vertices}
end

function A.same(a,b)
  if cut_state[a] or cut_state[b] then return cut_state[a]~=nil and cut_state[b]~=nil and same_cut(a,b) end
  local x=state_of(frontier_state,a,'Frontier'); local y=state_of(frontier_state,b,'Frontier'); return x.im==y.im and x.locality==y.locality and a:signature()==b:signature()
end
local function exact_successor(cur,initial)
  local key=initial:key(); for _,w in ipairs(cur:witnesses(initial:patch())) do if w:key()==key then return w end end; return nil
end
local function frontier_coherence(frontier,family)
  local root=state_of(frontier_state,frontier,'Frontier'); family=copy_array(family or {}); local seen={}
  for i,w in ipairs(family) do local ws=state_of(witness_state,w,'Witness'); assertf(A.same(ws.frontier,frontier),'coherence Witness %d is not enabled at root Frontier',i); assertf(not seen[ws.key],'coherence repeats exact occurrence'); seen[ws.key]=true end
  local n=#family; local vertices={[0]=frontier}; local function popbit(mask) for i=1,n do local bit=2^(i-1); if mask% (bit*2)>=bit then return i,mask-bit end end end
  for mask=1,2^n-1 do local i,parent=popbit(mask); local cur=vertices[parent]; local w=exact_successor(cur,family[i]); if not w then return false,{reason='exact-event-not-residual',event=family[i],mask=mask} end; vertices[mask]=w:after() end
  for mask=0,2^n-1 do for i=1,n do local bit=2^(i-1); if mask%(bit*2)<bit then local w=exact_successor(vertices[mask],family[i]); if not w then return false,{reason='missing-face',mask=mask,event=family[i]} end; local got=w:after(); if not A.same(got,vertices[mask+bit]) then return false,{reason='non-commuting-face',mask=mask,event=family[i]} end end end end
  return true,{dimension=n,vertex_count=2^n,vertices=vertices}
end
function A.coherence(base,family)
  if cut_state[base] then return cut_coherence(base,family) end
  return frontier_coherence(base,family)
end

function A.is_patch(x) return patch_state[x]~=nil end
function A.is_frontier(x) return frontier_state[x]~=nil end
function A.is_witness(x) return witness_state[x]~=nil end
function A.is_certificate(x) return cert_state[x]~=nil end
function A.is_cut(x) return cut_state[x]~=nil end

return A
