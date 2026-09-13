-- Worlds Query judgement: finite questions over exact open Geometry.
--
-- A Question is not Geometry, authority, programme state or an acceleration.
-- It is a finite judgement parameter:
--
--   Q = (A, B, S, T, R, C, E0)
--
-- A   source/world Geometry
-- B   target/development Geometry
-- S   selected exact egress(A)
-- T   selected exact ingress(B)
-- R   targets which must be matched
-- C   optional finite admissibility relation C subset S x T
-- E0  seeded exact equations
--
-- Search strategy lives separately in worlds.query_engine.  Complete source,
-- target and required sections remain symbolic internally: the public
-- accessors materialise defensive arrays only when asked for them.
local QMARK_KEY,QSTATE_KEY,QUESTION={},{},{}
local RMARK_KEY,RSTATE_KEY,REFUTATION={},{},{}
return function(W,K)
assert(type(W)=='table' and type(W.is_geometry)=='function','Worlds Query requires exact Worlds kernel')
K=K or require('worlds._kernel').private
local Compiled=require('worlds._compiled')(K)
local DENSE=require('worlds._array')
local Engine=require('worlds.query_engine')(W,K,Compiled)
local M={}
local function immutable() error('Worlds values are immutable',2) end
local QuestionMT,RefutationMT={},{}
local SPEC={sources=true,targets=true,required=true,admissible=true,seeds=true}
local function array(xs) local r={} for i=1,#(xs or {}) do r[i]=xs[i] end return r end
local function pairs_copy(xs) local r={} for i,e in ipairs(xs or {}) do r[i]={from=e.from or e[1],to=e.to or e[2]} end return r end
local function private_state(x,mark_key,mark,state_key)
  if type(x)~='table' then return nil end
  local ok,m=pcall(function() return x[mark_key] end); if not ok or m~=mark then return nil end
  local ok2,st=pcall(function() return x[state_key] end); return ok2 and st or nil
end
local function question_state(x) return private_state(x,QMARK_KEY,QUESTION,QSTATE_KEY) end
local function refutation_state(x) return private_state(x,RMARK_KEY,REFUTATION,RSTATE_KEY) end
local function question_value(st)
  return setmetatable({}, {
    __newindex=immutable,__metatable='Worlds Question',
    __index=function(_,k) if k==QMARK_KEY then return QUESTION elseif k==QSTATE_KEY then return st else return QuestionMT[k] end end,
  })
end
local function refutation_value(st)
  return setmetatable({}, {
    __newindex=immutable,__metatable='Worlds Refutation',
    __index=function(_,k) if k==RMARK_KEY then return REFUTATION elseif k==RSTATE_KEY then return st else return RefutationMT[k] end end,
  })
end
local function canonical_subset(pos,selected,label)
  if selected==nil then return nil,true end
  DENSE.length(selected,label)
  local out,seen={},{}
  for _,x in ipairs(selected) do assert(pos[x],label..' contains a Strand outside the exact open boundary'); assert(not seen[x],label..' contains a duplicate Strand'); seen[x]=true; out[#out+1]=x end
  table.sort(out,function(a,b) return pos[a]<pos[b] end)
  return out,false
end
local function membership(xs) local set={}; for _,x in ipairs(xs or {}) do set[x]=true end; return set end
local function pair_map(pairs,source_has,target_has)
  if pairs==nil then return nil,true,nil end
  DENSE.length(pairs,'Question admissible')
  local by_to,normal={},{}
  for _,e in ipairs(pairs) do
    assert(type(e)=='table','Question admissible entries must be exact pairs')
    local from,to=e.from or e[1],e.to or e[2]
    assert(source_has(from),'Question admissible source is outside sources')
    assert(target_has(to),'Question admissible target is outside targets')
    local bt=by_to[to]; if not bt then bt={}; by_to[to]=bt end
    assert(not bt[from],'Question admissible contains a duplicate pair')
    bt[from]=true; normal[#normal+1]={from=from,to=to}
  end
  return by_to,false,normal
end
local function clone(x,seen)
  if W.kind(x) then return x end
  if type(x)~='table' then return x end
  seen=seen or {}; if seen[x] then return seen[x] end
  local out={}; seen[x]=out; for k,v in pairs(x) do out[clone(k,seen)]=clone(v,seen) end; return out
end
local function refutation(question,reason)
  return refutation_value{question=question,reason=clone(reason or {kind='exhausted'})}
end
local function wrap_solve(raw,question,deferred)
  local final_no
  local methods={}
  function methods:step(fuel)
    if final_no then return 'no',final_no end
    local tag,value=raw:step(fuel)
    if tag=='no' then
      if not question then question=M.new(deferred.source,deferred.target,{seeds=deferred.seeds}) end
      final_no=refutation(question,value); return 'no',final_no
    end
    return tag,value
  end
  return setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds Question solve'})
end
function M.is_refutation(x) return refutation_state(x)~=nil end
function RefutationMT:question() return assert(refutation_state(self),'Worlds Refutation required').question end
function RefutationMT:reason() return clone(assert(refutation_state(self),'Worlds Refutation required').reason) end
function RefutationMT:source() return self:question():source() end
function RefutationMT:target() return self:question():target() end

function M.new(source,target,spec)
  if spec==nil then spec={} else assert(type(spec)=='table','Question specification must be a table') end
  for k in next,spec do assert(SPEC[k],'unknown Question field: '..tostring(k)) end
  assert(W.is_geometry(source) and W.is_geometry(target),'Question ambient values must be Worlds Geometry')
  -- A retained Question owns only presently open source authority.  The kernel
  -- memoises boundary projection and the private compiled view shares the exact
  -- outgoing section without exposing mutable kernel arrays publicly.
  source=W.boundary(source)
  local sc,tc=assert(Compiled.view(source),'missing compiled source Geometry'),assert(Compiled.view(target),'missing compiled target Geometry')
  local spos,tpos
  local function source_positions() if not spos then spos=Compiled.egress_positions(source) end; return spos end
  local function target_positions() if not tpos then tpos=Compiled.ingress_positions(target) end; return tpos end
  local sources,full_sources
  if spec.sources==nil then sources=nil; full_sources=true else sources,full_sources=canonical_subset(source_positions(),spec.sources,'Question sources') end
  local targets,full_targets
  if spec.targets==nil then targets=nil; full_targets=true else targets,full_targets=canonical_subset(target_positions(),spec.targets,'Question targets') end
  local source_set=full_sources and nil or membership(sources)
  local target_set=full_targets and nil or membership(targets)
  local function source_has(x) if full_sources then return not not sc.sset[x] end; return not not source_set[x] end
  local function target_has(x) if full_targets then return not not(tc.sset[x] and tc.producer[x]==nil) end; return not not target_set[x] end
  local required,required_all
  if spec.required==nil then
    required=nil; required_all=true
  else
    required=canonical_subset(target_positions(),spec.required,'Question required')
    required_all=false
    for _,x in ipairs(required) do assert(target_has(x),'Question required target is outside targets') end
  end
  local allowed_by_to,admissible_all,admissible=pair_map(spec.admissible,source_has,target_has)
  if admissible then
    table.sort(admissible,function(a,b)
      local tp,sp=target_positions(),source_positions(); local at,bt=tp[a.to],tp[b.to]
      if at~=bt then return at<bt end
      return sp[a.from]<sp[b.from]
    end)
  end
  local seeds={}; local seed_pair,seed_from,seed_to={},{},{}
  local seed_input=spec.seeds or {}; DENSE.length(seed_input,'Question seeds')
  for _,e in ipairs(seed_input) do
    assert(type(e)=='table','Question seed entries must be exact equations')
    local from,to=e.from or e[1],e.to or e[2]
    assert(source_has(from),'Question seed source is outside sources')
    assert(target_has(to),'Question seed target is outside targets')
    assert(admissible_all or (allowed_by_to[to] and allowed_by_to[to][from]),'Question seed is outside admissibility')
    local by_to=seed_pair[to]; if not by_to then by_to={}; seed_pair[to]=by_to end
    assert(not by_to[from],'Question seeds contain a duplicate pair')
    assert(not seed_from[from] or seed_from[from]==to,'Question seeds assign one source to multiple targets')
    assert(not seed_to[to] or seed_to[to]==from,'Question seeds assign one target to multiple sources')
    by_to[from]=true; seed_from[from]=to; seed_to[to]=from
    seeds[#seeds+1]={from=from,to=to}
  end
  if #seeds>1 then
    local tp=target_positions()
    table.sort(seeds,function(a,b) return tp[a.to]<tp[b.to] end)
  end
  local st={kernel=W,source=source,target=target,sources=sources,targets=targets,required=required,required_all=required_all,seeds=seeds,admissible=admissible,allowed_by_to=allowed_by_to,admissible_all=admissible_all,full_sources=full_sources,full_targets=full_targets}
  return question_value(st)
end
function M.complete(source,target,seeds) return M.new(source,target,{seeds=seeds or {}}) end
function M.is_question(x) return question_state(x)~=nil end
function QuestionMT:source() return assert(question_state(self),'Worlds Question required').source end
function QuestionMT:target() return assert(question_state(self),'Worlds Question required').target end
function QuestionMT:sources() local q=assert(question_state(self),'Worlds Question required'); return array(q.sources or Compiled.view(q.source).egress) end
function QuestionMT:targets() local q=assert(question_state(self),'Worlds Question required'); return array(q.targets or Compiled.view(q.target).ingress) end
function QuestionMT:required() local q=assert(question_state(self),'Worlds Question required'); if q.required then return array(q.required) end; return array(q.targets or Compiled.view(q.target).ingress) end
function QuestionMT:seeds() return pairs_copy(assert(question_state(self),'Worlds Question required').seeds) end
function QuestionMT:admissible() local x=assert(question_state(self),'Worlds Question required').admissible; return x and pairs_copy(x) or nil end
function M.solve(question)
  local q=assert(question_state(question),'Worlds Query Question required')
  assert(q.kernel==W,'Worlds Query Question belongs to another kernel')
  -- Engine receives an internal compiled copy; complete sections remain
  -- symbolic so a rigid query need not enumerate unrelated open authority.
  local raw=Engine.solve{
    source=q.source,target=q.target,
    sources=q.sources and array(q.sources) or nil,
    targets=q.targets and array(q.targets) or nil,
    required=q.required and array(q.required) or nil,
    required_all=q.required_all,
    seeds=pairs_copy(q.seeds),
    allowed_by_to=q.allowed_by_to,admissible_all=q.admissible_all,
    full_sources=q.full_sources,full_targets=q.full_targets,
  }
  return wrap_solve(raw,question,nil)
end
-- Fast complete-coverage façade used by W.solve.  It implements the same
-- complete Question judgement but avoids allocating the public Question value
-- and its defensive set copies on successful hot-path solves.  If exhaustive
-- failure occurs, the exact public Question is materialised so `no` still
-- carries the same Refutation evidence as Query.solve(Query.complete(...)).
local function complete_solve(source,target,seeds)
  assert(W.is_geometry(source) and W.is_geometry(target),'Question ambient values must be Worlds Geometry')
  source=W.boundary(source)
  local sc,tc=assert(Compiled.view(source),'missing compiled source Geometry'),assert(Compiled.view(target),'missing compiled target Geometry')
  seeds=seeds or {}; DENSE.length(seeds,'Question seeds')
  local normal={}
  if #seeds==1 then
    local e=seeds[1]; assert(type(e)=='table','Question seed entries must be exact equations')
    local from,to=e.from or e[1],e.to or e[2]
    assert(sc.sset[from],'Question seed source is outside sources'); assert(tc.sset[to] and tc.producer[to]==nil,'Question seed target is outside targets')
    normal[1]={from=from,to=to}
  elseif #seeds>1 then
    local seed_pair,seed_from,seed_to={},{},{}
    for _,e in ipairs(seeds) do
      assert(type(e)=='table','Question seed entries must be exact equations')
      local from,to=e.from or e[1],e.to or e[2]
      assert(sc.sset[from],'Question seed source is outside sources')
      assert(tc.sset[to] and tc.producer[to]==nil,'Question seed target is outside targets')
      local by_to=seed_pair[to]; if not by_to then by_to={}; seed_pair[to]=by_to end
      assert(not by_to[from],'Question seeds contain a duplicate pair')
      assert(not seed_from[from] or seed_from[from]==to,'Question seeds assign one source to multiple targets')
      assert(not seed_to[to] or seed_to[to]==from,'Question seeds assign one target to multiple sources')
      by_to[from]=true; seed_from[from]=to; seed_to[to]=from
      normal[#normal+1]={from=from,to=to}
    end
    local tpos=Compiled.ingress_positions(target)
    table.sort(normal,function(a,b) return tpos[a.to]<tpos[b.to] end)
  end
  local raw=Engine.complete(source,target,normal)
  return wrap_solve(raw,nil,{source=source,target=target,seeds=normal})
end

return M,{complete_solve=complete_solve}
end
