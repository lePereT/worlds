-- Worlds Question judgement: finite questions over exact open Geometry.
--
-- A Question is not Geometry, authority, programme state or an acceleration.
-- Worlds currently exposes two precise finite judgement forms:
--
--   Match(A,B; S,T,D,R,C,E0)
--     directional realisation of target/development B from source/world A.
--
--   Close(P; S,T,D,R,C,E0)
--     direct finite closure over an ordered set P of disjoint Geometry parts.
--
-- Both share the same evidence algebra.  Every public yes(E) is validated by
-- the same strict quotient/Geometry law as public join before it is exposed.
-- Search strategy lives in replaceable engines outside the verified centre.
local QMARK_KEY,QSTATE_KEY,QUESTION={},{},{}
local RMARK_KEY,RSTATE_KEY,REFUTATION={},{},{}
return function(W,K)
assert(type(W)=='table' and type(W.is_geometry)=='function','Worlds Question requires exact Worlds kernel')
K=K or require('worlds._kernel').private
local Compiled=require('worlds._compiled')(K)
local DENSE=require('worlds._array')
local MatchEngine=require('worlds.query_engine')(W,K,Compiled)
local CloseEngine=require('worlds.query_closure_engine')()
local M={}
local function immutable() error('Worlds values are immutable',2) end
local QuestionMT,RefutationMT={},{}
local SPEC={sources=true,targets=true,required_sources=true,required_targets=true,admissible=true,seeds=true}
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
local function membership(xs) local set={}; for _,x in ipairs(xs or {}) do set[x]=true end; return set end
local function canonical_subset(pos,selected,label)
  if selected==nil then return nil,true end
  DENSE.length(selected,label)
  local out,seen={},{}
  for _,x in ipairs(selected) do
    assert(pos[x],label..' contains a Strand outside the exact open boundary')
    assert(not seen[x],label..' contains a duplicate Strand')
    seen[x]=true; out[#out+1]=x
  end
  table.sort(out,function(a,b) return pos[a]<pos[b] end)
  return out,false
end
local function pair_map(pairs,source_has,target_has,label)
  if pairs==nil then return nil,true,nil end
  DENSE.length(pairs,label or 'Question admissible')
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
local function check_spec(spec)
  if spec==nil then return {} end
  assert(type(spec)=='table','Question specification must be a table')
  for k in next,spec do assert(SPEC[k],'unknown Question field: '..tostring(k)) end
  return spec
end
local function normal_seeds(spec,source_has,target_has,allowed_by_to,admissible_all,target_pos)
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
  if #seeds>1 then table.sort(seeds,function(a,b) return target_pos[a.to]<target_pos[b.to] end) end
  return seeds
end
local function normal_relation(spec,source_has,target_has,source_pos,target_pos)
  local allowed_by_to,admissible_all,admissible=pair_map(spec.admissible,source_has,target_has)
  if admissible then
    table.sort(admissible,function(a,b)
      local at,bt=target_pos[a.to],target_pos[b.to]
      if at~=bt then return at<bt end
      return source_pos[a.from]<source_pos[b.from]
    end)
  end
  return allowed_by_to,admissible_all,admissible
end

local function join_parts(q)
  if q.form=='close' then return q.parts end
  return q.internal and {q.target} or {q.source,q.target}
end

local function wrap_solve(raw,question,deferred)
  local final_no,valid_hits,last_unlawful=nil,0,nil
  local solve
  local function qstate()
    if question then return assert(question_state(question),'Worlds Question required') end
    return deferred
  end
  local function public_question()
    if not question then question=M.match(deferred.source,deferred.target,{seeds=deferred.seeds}) end
    return question
  end
  local function lawful(equations)
    local q=qstate()
    if q.required_sources and #q.required_sources>0 then
      local used={}; for _,e in ipairs(equations) do used[e.from or e[1]]=true end
      for _,source in ipairs(q.required_sources) do if not used[source] then return false,'required source remains open' end end
    end
    local geometry,why=K.try_join(join_parts(q),equations)
    return geometry~=nil,why
  end
  local function no(reason)
    final_no=refutation(public_question(),reason)
    return 'no',final_no
  end
  local methods={}
  function methods:step(fuel)
    if final_no then return 'no',final_no end
    local unbounded=fuel==math.huge
    while true do
      local tag,value=raw:step(fuel)
      if tag=='yes' then
        local ok,why=lawful(value)
        if ok then valid_hits=valid_hits+1; return 'yes',value end
        last_unlawful={kind='unlawful-realisation',reason=why}
        if not unbounded then return 'more',solve end
      elseif tag=='done' then
        if valid_hits>0 then return 'done',valid_hits end
        return no(last_unlawful or {kind='question-support-exhausted'})
      elseif tag=='no' then
        return no(value)
      elseif tag=='more' then
        return 'more',solve
      else
        error('unexpected Worlds Question engine tag '..tostring(tag),2)
      end
    end
  end
  solve=setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds Question solve'})
  return solve
end

function M.is_refutation(x) return refutation_state(x)~=nil end
function RefutationMT:question() return assert(refutation_state(self),'Worlds Refutation required').question end
function RefutationMT:reason() return clone(assert(refutation_state(self),'Worlds Refutation required').reason) end
function RefutationMT:form() return self:question():form() end
function RefutationMT:parts() return self:question():parts() end
function RefutationMT:source() return self:question():source() end
function RefutationMT:target() return self:question():target() end

-- Directional matching -------------------------------------------------------

function M.match(source,target,spec)
  spec=check_spec(spec)
  local internal=source==target
  assert(W.is_geometry(source) and W.is_geometry(target),'Match Question ambient values must be Worlds Geometry')
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
  local required_sources={}
  if spec.required_sources~=nil then
    required_sources=canonical_subset(source_positions(),spec.required_sources,'Question required sources')
    for _,x in ipairs(required_sources) do assert(source_has(x),'Question required source is outside sources') end
  end
  local required_targets,required_all
  if spec.required_targets==nil then required_targets=nil; required_all=true
  else
    required_targets=canonical_subset(target_positions(),spec.required_targets,'Question required targets'); required_all=false
    for _,x in ipairs(required_targets) do assert(target_has(x),'Question required target is outside targets') end
  end
  local allowed_by_to,admissible_all,admissible
  if spec.admissible==nil then allowed_by_to=nil; admissible_all=true; admissible=nil
  else allowed_by_to,admissible_all,admissible=normal_relation(spec,source_has,target_has,source_positions(),target_positions()) end
  local seed_input=spec.seeds or {}; DENSE.length(seed_input,'Question seeds')
  local seeds={}
  if #seed_input>0 then seeds=normal_seeds(spec,source_has,target_has,allowed_by_to,admissible_all,target_positions()) end
  return question_value{
    kernel=W,form='match',source=source,target=target,internal=internal,
    sources=sources,targets=targets,required_sources=required_sources,required_targets=required_targets,required_all=required_all,seeds=seeds,
    admissible=admissible,allowed_by_to=allowed_by_to,admissible_all=admissible_all,
    full_sources=full_sources,full_targets=full_targets,
  }
end
function M.complete(source,target,seeds) return M.match(source,target,{seeds=seeds or {}}) end

-- Direct finite closure ------------------------------------------------------

local function closure_sections(parts)
  DENSE.length(parts,'Close Question parts'); assert(#parts>0,'Close Question requires at least one Geometry part')
  local normal,owner={},{}
  local source_pos,target_pos={},{}; local sources,targets={},{}
  local si,ti=0,0
  for pi,g in ipairs(parts) do
    assert(W.is_geometry(g),'Close Question parts must be Worlds Geometry')
    normal[pi]=g
    for _,m in ipairs(g:membranes()) do assert(not owner[m],'Close Question Geometry parts must be disjoint'); owner[m]=pi end
    for _,p in ipairs(g:points()) do assert(not owner[p],'Close Question Geometry parts must be disjoint'); owner[p]=pi end
    for _,s in ipairs(g:strands()) do assert(not owner[s],'Close Question Geometry parts must be disjoint'); owner[s]=pi end
    for _,f in ipairs(g:faces()) do assert(not owner[f],'Close Question Geometry parts must be disjoint'); owner[f]=pi end
    for _,s in ipairs(g:egress()) do si=si+1; source_pos[s]=si; sources[#sources+1]=s end
    for _,s in ipairs(g:ingress()) do ti=ti+1; target_pos[s]=ti; targets[#targets+1]=s end
  end
  return normal,source_pos,target_pos,sources,targets
end

function M.close(parts,spec)
  spec=check_spec(spec)
  local normal,source_pos,target_pos,all_sources,all_targets=closure_sections(parts)
  local sources,full_sources=canonical_subset(source_pos,spec.sources,'Question sources')
  local targets,full_targets=canonical_subset(target_pos,spec.targets,'Question targets')
  if full_sources then sources=all_sources end
  if full_targets then targets=all_targets end
  local source_set,target_set=membership(sources),membership(targets)
  local function source_has(x) return not not source_set[x] end
  local function target_has(x) return not not target_set[x] end
  local required_sources={}
  if spec.required_sources~=nil then
    required_sources=canonical_subset(source_pos,spec.required_sources,'Question required sources')
    for _,x in ipairs(required_sources) do assert(source_has(x),'Question required source is outside sources') end
  end
  local required_targets
  if spec.required_targets==nil then required_targets=array(targets)
  else
    required_targets=canonical_subset(target_pos,spec.required_targets,'Question required targets')
    for _,x in ipairs(required_targets) do assert(target_has(x),'Question required target is outside targets') end
  end
  local allowed_by_to,admissible_all,admissible=normal_relation(spec,source_has,target_has,source_pos,target_pos)
  local seeds=normal_seeds(spec,source_has,target_has,allowed_by_to,admissible_all,target_pos)
  return question_value{
    kernel=W,form='close',parts=normal,
    sources=sources,targets=targets,required_sources=required_sources,required_targets=required_targets,required_all=false,seeds=seeds,
    admissible=admissible,allowed_by_to=allowed_by_to,admissible_all=admissible_all,
    full_sources=full_sources,full_targets=full_targets,
  }
end

-- Public value ---------------------------------------------------------------

function M.is_question(x) return question_state(x)~=nil end
function QuestionMT:form() return assert(question_state(self),'Worlds Question required').form end
function QuestionMT:parts()
  local q=assert(question_state(self),'Worlds Question required')
  if q.form=='close' then return array(q.parts) end
  return q.internal and {q.target} or {q.source,q.target}
end
function QuestionMT:source()
  local q=assert(question_state(self),'Worlds Question required'); assert(q.form=='match','source() is defined only for Match Questions'); return q.source
end
function QuestionMT:target()
  local q=assert(question_state(self),'Worlds Question required'); assert(q.form=='match','target() is defined only for Match Questions'); return q.target
end
function QuestionMT:sources()
  local q=assert(question_state(self),'Worlds Question required')
  if q.form=='close' then return array(q.sources) end
  return array(q.sources or Compiled.view(q.source).egress)
end
function QuestionMT:targets()
  local q=assert(question_state(self),'Worlds Question required')
  if q.form=='close' then return array(q.targets) end
  return array(q.targets or Compiled.view(q.target).ingress)
end
function QuestionMT:required_sources() return array(assert(question_state(self),'Worlds Question required').required_sources or {}) end
function QuestionMT:required_targets()
  local q=assert(question_state(self),'Worlds Question required')
  if q.required_targets then return array(q.required_targets) end
  return self:targets()
end
function QuestionMT:seeds() return pairs_copy(assert(question_state(self),'Worlds Question required').seeds) end
function QuestionMT:admissible() local x=assert(question_state(self),'Worlds Question required').admissible; return x and pairs_copy(x) or nil end

function M.solve(question)
  local q=assert(question_state(question),'Worlds Question required')
  assert(q.kernel==W,'Worlds Question belongs to another kernel')
  local raw
  if q.form=='match' then
    raw=MatchEngine.solve{
      source=q.source,target=q.target,
      sources=q.sources and array(q.sources) or nil,
      targets=q.targets and array(q.targets) or nil,
      required=q.required_targets and array(q.required_targets) or nil,
      required_all=q.required_all,
      seeds=pairs_copy(q.seeds),
      allowed_by_to=q.allowed_by_to,admissible_all=q.admissible_all,
      full_sources=q.full_sources,full_targets=q.full_targets,
    }
  else
    raw=CloseEngine.solve{
      sources=array(q.sources),targets=array(q.targets),required_sources=array(q.required_sources),required=array(q.required_targets),
      seeds=pairs_copy(q.seeds),allowed_by_to=q.allowed_by_to,admissible_all=q.admissible_all,
    }
  end
  return wrap_solve(raw,question,nil)
end

-- Fast complete directional façade used by W.solve. ------------------------
local function complete_solve(source,target,seeds)
  assert(W.is_geometry(source) and W.is_geometry(target),'Question ambient values must be Worlds Geometry')
  local internal=source==target
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
  local raw=MatchEngine.complete(source,target,normal)
  return wrap_solve(raw,nil,{kernel=W,form='match',source=internal and target or source,target=target,seeds=normal,internal=internal})
end

return M,{complete_solve=complete_solve}
end
