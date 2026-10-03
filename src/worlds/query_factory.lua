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
local QSTATE=setmetatable({}, {__mode='k'})
local RSTATE=setmetatable({}, {__mode='k'})
local ZSTATE=setmetatable({}, {__mode='k'})
local EVIDENCE=setmetatable({}, {__mode='k'})
return function(W,K)
assert(type(W)=='table' and type(W.is_geometry)=='function','Worlds Question requires exact Worlds kernel')
K=K or require('worlds._kernel').private
local Compiled=require('worlds._compiled')(K)
local Boundary=require('worlds._boundary')(K)
local DENSE=require('worlds._array')
local Persistent=require('worlds._persistent')
local MatchEngine=require('worlds.query_engine')(W,K,Compiled)
local CloseEngine=require('worlds.query_closure_engine')
local M={}
local function immutable() error('Worlds values are immutable',2) end
local QuestionMT={__newindex=immutable,__metatable='Worlds Question'}; QuestionMT.__index=QuestionMT
local RefutationMT={__newindex=immutable,__metatable='Worlds Refutation'}; RefutationMT.__index=RefutationMT
local RealisationMT={__newindex=immutable,__metatable='Worlds Realisation'}; RealisationMT.__index=RealisationMT
local SPEC={sources=true,targets=true,required_sources=true,required_targets=true,admissible=true,seeds=true}
local function question_state(x) return type(x)=='table' and QSTATE[x] or nil end
local function refutation_state(x) return type(x)=='table' and RSTATE[x] or nil end
local function realisation_state(x) return type(x)=='table' and ZSTATE[x] or nil end
local function question_value(st)
  local x=setmetatable({},QuestionMT); QSTATE[x]=st; return x
end
local function refutation_value(st)
  local x=setmetatable({},RefutationMT); RSTATE[x]=st; return x
end
local function realisation_value(st)
  local x=st.public
  if x then return x end
  x=setmetatable({},RealisationMT); ZSTATE[x]=st; st.public=x; return x
end
local function retain_realisation(st) EVIDENCE[st.equations]=st; return st end
local function realisation_boundary(st)
  if st.boundary~=nil then return st.boundary or nil end
  if st.source and K.geometry(st.source).boundary_normal then
    st.boundary=Boundary.after(st.source,st.result)
  else st.boundary=false end
  return st.boundary or nil
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
local function refutation(question,reason)
  return refutation_value{question=question,reason=reason or {kind='exhausted'}}
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

local function join_parts(q) return q.parts end

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
      for _,source in ipairs(q.required_sources) do if not used[source] then return nil,'required source remains open' end end
    end
    local parts=join_parts(q)
    local geometry,image_or_why,source_position
    if q.form=='match' and not q.internal and Boundary.has(q.source) then source_position=function(from) return Boundary.position(q.source,'strand',from) end end
    if source_position then geometry,image_or_why=K.try_match_join(q.source,q.target,equations,source_position)
    else geometry,image_or_why=K.try_join(parts,equations) end
    if not geometry then return nil,image_or_why end
    return {parts=parts,equations=equations,result=geometry,image=image_or_why,source=(q.form=='match' and not q.internal and Boundary.has(q.source)) and q.source or nil}
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
        local realisation,why=lawful(value)
        if realisation then retain_realisation(realisation); valid_hits=valid_hits+1; return 'yes',value end
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

function M.is_realisation(x) return realisation_state(x)~=nil end
function RealisationMT:parts() return assert(realisation_state(self),'Worlds Realisation required').parts end
function RealisationMT:equations() return assert(realisation_state(self),'Worlds Realisation required').equations end
function RealisationMT:result() return assert(realisation_state(self),'Worlds Realisation required').result end
function RealisationMT:image(carrier) return assert(realisation_state(self),'Worlds Realisation required').image[carrier] end
function RealisationMT:boundary() return realisation_boundary(assert(realisation_state(self),'Worlds Realisation required')) end
function M.realisation_image(x) return assert(realisation_state(x),'Worlds Realisation required').image end
function M.realisation_boundary(x) return realisation_boundary(assert(realisation_state(x),'Worlds Realisation required')) end
function M.realisation_for(parts,equations)
  local st=EVIDENCE[equations]
  if not st or #parts~=#st.parts then return nil end
  for i=1,#parts do if parts[i]~=st.parts[i] then return nil end end
  return realisation_value(st)
end

function M.is_refutation(x) return refutation_state(x)~=nil end
function RefutationMT:question() return assert(refutation_state(self),'Worlds Refutation required').question end
function RefutationMT:reason() return assert(refutation_state(self),'Worlds Refutation required').reason end
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
  local sc,tc=K.geometry(source),K.geometry(target)
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
    kernel=W,form='match',source=source,target=target,internal=internal,parts=internal and {target} or {source,target},
    sources=sources,targets=targets,required_sources=required_sources,required_targets=required_targets,required_all=required_all,seeds=seeds,
    admissible=admissible,allowed_by_to=allowed_by_to,admissible_all=admissible_all,
    full_sources=full_sources,full_targets=full_targets,
  }
end
function M.complete(source,target,seeds) return M.match(source,target,{seeds=seeds or {}}) end

-- Direct finite closure ------------------------------------------------------

local function closure_sections(parts)
  DENSE.length(parts,'Close Question parts'); assert(#parts>0,'Close Question requires at least one Geometry part')
  local owner={}
  local source_pos,target_pos={},{}; local sources,targets={},{}
  local si,ti=0,0
  for pi,g in ipairs(parts) do
    assert(W.is_geometry(g),'Close Question parts must be Worlds Geometry')
    for _,m in ipairs(g:membranes()) do assert(not owner[m],'Close Question Geometry parts must be disjoint'); owner[m]=pi end
    for _,p in ipairs(g:points()) do assert(not owner[p],'Close Question Geometry parts must be disjoint'); owner[p]=pi end
    for _,s in ipairs(g:strands()) do assert(not owner[s],'Close Question Geometry parts must be disjoint'); owner[s]=pi end
    for _,f in ipairs(g:faces()) do assert(not owner[f],'Close Question Geometry parts must be disjoint'); owner[f]=pi end
    for _,s in ipairs(g:egress()) do si=si+1; source_pos[s]=si; sources[#sources+1]=s end
    for _,s in ipairs(g:ingress()) do ti=ti+1; target_pos[s]=ti; targets[#targets+1]=s end
  end
  return parts,source_pos,target_pos,sources,targets
end

-- Cheap monotone closure support: arity must agree, and any target Point not
-- owned by the closure parts is rigid and therefore must already be exact-equal
-- at the corresponding source coordinate.  This only removes impossible pairs.
local function closure_support(parts,sources,targets)
  local local_point,source_set={},{}
  for _,g in ipairs(parts) do for _,p in ipairs(g:points()) do local_point[p]=true end end
  local arity,useful=nil,false
  for _,from in ipairs(sources) do source_set[from]=true; local n=#W.points(from); arity=arity or n; if n~=arity then useful=true end end
  for _,to in ipairs(targets) do
    local tp=W.points(to); if source_set[to] or (arity~=nil and #tp~=arity) then useful=true end
    for _,p in ipairs(tp) do if not local_point[p] then useful=true; break end end
  end
  if not useful then return nil end
  local support={}
  for _,to in ipairs(targets) do
    local tp,pool=W.points(to),{}; support[to]=pool
    for _,from in ipairs(sources) do
      local fp=W.points(from); local ok=from~=to and #fp==#tp
      if ok then for i,p in ipairs(tp) do if not local_point[p] and fp[i]~=p then ok=false; break end end end
      if ok then pool[from]=true end
    end
  end
  return support
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
  if spec.required_targets==nil then required_targets=targets
  else
    required_targets=canonical_subset(target_pos,spec.required_targets,'Question required targets')
    for _,x in ipairs(required_targets) do assert(target_has(x),'Question required target is outside targets') end
  end
  local allowed_by_to,admissible_all,admissible=normal_relation(spec,source_has,target_has,source_pos,target_pos)
  local seeds=normal_seeds(spec,source_has,target_has,allowed_by_to,admissible_all,target_pos)
  local support_by_to=closure_support(normal,sources,targets)
  return question_value{
    kernel=W,form='close',parts=normal,
    sources=sources,targets=targets,required_sources=required_sources,required_targets=required_targets,required_all=false,seeds=seeds,
    admissible=admissible,allowed_by_to=allowed_by_to,admissible_all=admissible_all,support_by_to=support_by_to,
    full_sources=full_sources,full_targets=full_targets,
  }
end

-- Public value ---------------------------------------------------------------

function M.is_question(x) return question_state(x)~=nil end
function QuestionMT:form() return assert(question_state(self),'Worlds Question required').form end
function QuestionMT:parts() return assert(question_state(self),'Worlds Question required').parts end
function QuestionMT:source()
  local q=assert(question_state(self),'Worlds Question required'); assert(q.form=='match','source() is defined only for Match Questions'); return q.source
end
function QuestionMT:target()
  local q=assert(question_state(self),'Worlds Question required'); assert(q.form=='match','target() is defined only for Match Questions'); return q.target
end
function QuestionMT:sources()
  local q=assert(question_state(self),'Worlds Question required')
  return q.sources or Compiled.view(q.source).egress
end
function QuestionMT:targets()
  local q=assert(question_state(self),'Worlds Question required')
  return q.targets or Compiled.view(q.target).ingress
end
function QuestionMT:required_sources() return assert(question_state(self),'Worlds Question required').required_sources end
function QuestionMT:required_targets()
  local q=assert(question_state(self),'Worlds Question required')
  return q.required_targets or self:targets()
end
function QuestionMT:seeds() return assert(question_state(self),'Worlds Question required').seeds end
function QuestionMT:admissible() return assert(question_state(self),'Worlds Question required').admissible end

function M.solve(question)
  local q=assert(question_state(question),'Worlds Question required')
  assert(q.kernel==W,'Worlds Question belongs to another kernel')
  local raw
  if q.form=='match' then
    raw=MatchEngine.solve{
      source=q.source,target=q.target,
      sources=q.sources,targets=q.targets,required_targets=q.required_targets,
      required_all=q.required_all,seeds=q.seeds,
      allowed_by_to=q.allowed_by_to,admissible_all=q.admissible_all,
      full_sources=q.full_sources,full_targets=q.full_targets,
    }
  else
    raw=CloseEngine{
      sources=q.sources,targets=q.targets,required_sources=q.required_sources,required_targets=q.required_targets,
      seeds=q.seeds,allowed_by_to=q.allowed_by_to,admissible_all=q.admissible_all,support_by_to=q.support_by_to,
    }
  end
  return wrap_solve(raw,question,nil)
end

-- Fast complete directional façade used by W.solve. ------------------------
local function complete_solve(source,target,seeds)
  assert(W.is_geometry(source) and W.is_geometry(target),'Question ambient values must be Worlds Geometry')
  local internal=source==target
  source=W.boundary(source)
  local sc,tc=K.geometry(source),K.geometry(target)
  assert(tc.developable,'Question target must be a development connected to open ingress')
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
  local covered={}
  for _,e in ipairs(normal) do covered[e.to]=true end
  local fully_seeded=#normal==Persistent.length(tc.ingress)
  if fully_seeded then for _,to in Persistent.iter(tc.ingress) do if not covered[to] then fully_seeded=false; break end end end
  local raw
  if fully_seeded then
    local exact_sources={}; for i,e in ipairs(normal) do exact_sources[i]=e.from end
    raw=MatchEngine.solve{
      source=source,target=target,sources=exact_sources,targets=Persistent.array(tc.ingress),
      required_targets=nil,required_all=true,seeds=normal,
      allowed_by_to=nil,admissible_all=true,full_sources=false,full_targets=true,
    }
  else raw=MatchEngine.complete(source,target,normal) end
  local qsource=internal and target or source
  return wrap_solve(raw,nil,{kernel=W,form='match',source=qsource,target=target,seeds=normal,internal=internal,parts=internal and {target} or {qsource,target}})
end

local function take_realisation_state(parts,equations)
  local st=EVIDENCE[equations]
  if not st or #parts~=#st.parts then return nil end
  for i=1,#parts do if parts[i]~=st.parts[i] then return nil end end
  EVIDENCE[equations]=nil
  return st
end

return M,{
  complete_solve=complete_solve,
  take_realisation=take_realisation_state,
  realisation_boundary=realisation_boundary,
}
end
