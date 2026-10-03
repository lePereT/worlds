local unpack = table.unpack or unpack
-- Research positive occurrence-relative Theory with no semantic retraction.
--
-- This is speculation, not part of Worlds.  Theory facts are non-authoritative:
-- mentioning an exact Strand/Face/Membrane/Point never grants authority to alter it.
-- A Theory-local existential variable is alpha-only relational provenance, it is
-- neither a Worlds carrier nor programme authority.

local W=require('worlds')
local T={}

local VAR_MT={}
local EVAR_MT={}
local next_evar=0

local function is_var(x) return type(x)=='table' and getmetatable(x)==VAR_MT end
local function is_evar(x) return type(x)=='table' and getmetatable(x)==EVAR_MT end

function T.var(name)
  return setmetatable({name=name or '_'},VAR_MT)
end

function T.evar(name)
  next_evar=next_evar+1
  return setmetatable({name=name or 'e',id=next_evar},EVAR_MT)
end

function T.is_var(x) return is_var(x) end
function T.is_evar(x) return is_evar(x) end

function T.fact(pred,...)
  assert(type(pred)=='string' and pred~='','predicate name required')
  local args={...}
  return {pred=pred,args=args}
end

local function carrier_kind(x)
  local k=W.kind(x)
  if k=='point' or k=='strand' or k=='membrane' or k=='face' then return k end
  return nil
end

local function owns(g,x)
  local k=carrier_kind(x)
  if k=='point' then return g:owns_point(x)
  elseif k=='strand' then return g:owns_strand(x)
  elseif k=='membrane' then return g:owns_membrane(x)
  elseif k=='face' then return g:owns_face(x)
  end
  return false
end
T.owns=owns

local function literal(x)
  local ty=type(x)
  return ty=='string' or ty=='number' or ty=='boolean'
end

local function valid_term(g,x,pattern)
  if carrier_kind(x) then return owns(g,x) end
  if is_evar(x) then return not pattern end
  if is_var(x) then return pattern end
  return literal(x)
end

local function clone_fact(f)
  local args={}
  for i,x in ipairs(f.args) do args[i]=x end
  return {pred=f.pred,args=args}
end

local function validate_fact(g,f,pattern)
  assert(type(f)=='table' and type(f.pred)=='string' and type(f.args)=='table','bad Theory fact')
  for _,x in ipairs(f.args) do assert(valid_term(g,x,pattern),
      'invalid Theory term for '..f.pred) end
end

local function same_term(a,b) return a==b end
local function same_fact(a,b)
  if a.pred~=b.pred or #a.args~=#b.args then return false end
  for i=1,#a.args do if not same_term(a.args[i],b.args[i]) then return false end end
  return true
end
T.same_fact=same_fact

local function dedup(facts)
  local out={}
  for _,f in ipairs(facts) do
    local seen=false
    for _,g in ipairs(out) do if same_fact(f,g) then seen=true
    break end end
    if not seen then out[#out+1]=f end
  end
  return out
end

local function fact_string(f)
  local xs={}
  for i,x in ipairs(f.args) do
    local k=carrier_kind(x)
    if k then xs[i]=k..':'..(W.name(x) or tostring(x))
    elseif is_evar(x) then xs[i]='$'..x.name..'#'..x.id
    elseif is_var(x) then xs[i]='?'..x.name
    else xs[i]=tostring(x) end
  end
  return f.pred..'('..table.concat(xs,',')..')'
end
T.fact_string=fact_string

-- schemas[pred] = {arity=N, key={positions...}}
-- key declares a functional dependency from those positions to the full tuple.
local function validate_functionals(facts,schemas)
  for pred,schema in pairs(schemas or {}) do
    if schema.key then
      local rows={}
      for _,f in ipairs(facts) do if f.pred==pred then
        local key={}
        for _,i in ipairs(schema.key) do key[#key+1]=f.args[i] end
        for _,old in ipairs(rows) do
          local match=true
          for j=1,#key do if old.key[j]~=key[j] then match=false
          break end end
          if match and not same_fact(old.fact,f) then return false,'functional-conflict:'..pred end
        end
        rows[#rows+1]={key=key,fact=f}
      end end
    end
  end
  return true
end

local State={}
State.__index=State
function T.state(geometry,facts,schemas)
  assert(W.is_geometry(geometry),'Theory state requires Geometry')
  local fs={}
  for i,f in ipairs(facts or {}) do validate_fact(geometry,f,false)
  fs[i]=clone_fact(f) end
  fs=dedup(fs)
  local ok,why=validate_functionals(fs,schemas)
  assert(ok,why)
  return setmetatable({geometry=geometry,facts=fs,schemas=schemas or {}},State)
end
function State:all()
  local out={}
  for i,f in ipairs(self.facts) do out[i]=clone_fact(f) end
  return out
end
function State:count(pred)
  local n=0
  for _,f in ipairs(self.facts) do if not pred or f.pred==pred then n=n+1 end end
  return n
end
function State:has(f)
  for _,g in ipairs(self.facts) do if same_fact(f,g) then return true end end
  return false
end
function State:select(pred)
  local out={}
  for _,f in ipairs(self.facts) do if f.pred==pred then out[#out+1]=clone_fact(f) end end
  return out
end

local function copy_rule_facts(xs)
  local out={}
  for i,f in ipairs(xs or {}) do out[i]=clone_fact(f) end
  return out
end

function T.rule(geometry,spec)
  assert(W.is_geometry(geometry),'Theory rule requires Geometry')
  spec=spec or {}
  local r={
    geometry=geometry,
    requires=copy_rule_facts(spec.requires),
    asserts=copy_rule_facts(spec.asserts),
    schemas=spec.schemas or {},
  }
  assert(spec.retracts==nil,'positive Theory has no retract channel')
  for _,xs in ipairs{r.requires,r.asserts} do
    for _,f in ipairs(xs) do validate_fact(geometry,f,true) end
  end
  return r
end

local function map_term(x,construction,allow_dead)
  if carrier_kind(x) then
    local y=construction:image(x)
    if y then return y end
    if allow_dead then return false end
    return nil
  end
  return x
end

local function map_fact(f,construction,allow_dead)
  local args={}
  for i,x in ipairs(f.args) do
    local y=map_term(x,construction,allow_dead)
    if y==nil or y==false then return nil end
    args[i]=y
  end
  return {pred=f.pred,args=args}
end

function T.rebase(state,construction)
  local result=construction:result()
  local out={}
  for _,f in ipairs(state.facts) do
    local g=map_fact(f,construction,true)
    if g then out[#out+1]=g end
  end
  return T.state(result,out,state.schemas)
end

-- Rebase an open Theory rule through an exact Construction without discharging
-- its premises.  This is useful for residual/open composition: exact carrier
-- references follow Worlds, while logical variables remain logical variables.
function T.rebase_rule(rule,construction)
  local result=construction:result()
  local function maps(xs)
    local out={}
    for _,f in ipairs(xs or {}) do
      local g=map_fact(f,construction,false)
      if not g then return nil end
      out[#out+1]=g
    end
    return out
  end
  local requires=maps(rule.requires)
  if not requires then return nil,'dead-theory-requirement' end
  local asserts=maps(rule.asserts)
  if not asserts then return nil,'dead-theory-assertion' end
  return T.rule(result,{requires=requires,asserts=asserts,schemas=rule.schemas})
end

local function bind_term(pattern,value,subst)
  if is_var(pattern) then
    local old=subst[pattern]
    if old~=nil then return old==value end
    subst[pattern]=value
    return true
  end
  return pattern==value
end

local function unify_fact(pattern,fact,subst)
  if pattern.pred~=fact.pred or #pattern.args~=#fact.args then return false end
  local touched={}
  for i=1,#pattern.args do
    local p=pattern.args[i]
    local old=is_var(p) and subst[p] or nil
    if not bind_term(p,fact.args[i],subst) then
      for _,v in ipairs(touched) do subst[v]=nil end
      return false
    end
    if is_var(p) and old==nil then touched[#touched+1]=p end
  end
  return true
end

local function copy_subst(s)
  local out={}
  for k,v in pairs(s) do out[k]=v end
  return out
end

local function match_patterns(patterns,facts,i,subst,chosen,out)
  if i>#patterns then out[#out+1]={subst=copy_subst(subst),chosen={unpack(chosen)}}
  return end
  local p=patterns[i]
  for fi,f in ipairs(facts) do
    local s=copy_subst(subst)
    if unify_fact(p,f,s) then
      chosen[i]=fi
      match_patterns(patterns,facts,i+1,s,chosen,out)
      chosen[i]=nil
    end
  end
end

local function mapped_pattern_fact(f,construction)
  local args={}
  for i,x in ipairs(f.args) do
    if carrier_kind(x) then
      local y=construction:image(x)
      if not y then return nil end
      args[i]=y
    else args[i]=x end
  end
  return {pred=f.pred,args=args}
end

local function instantiate_fact(f,construction,subst,fresh)
  local args={}
  for i,x in ipairs(f.args) do
    if carrier_kind(x) then
      local y=construction:image(x)
      if not y then return nil end
      args[i]=y
    elseif is_var(x) then
      local y=subst[x]
      if y==nil then
        y=fresh[x]
        if y==nil then y=T.evar(x.name)
        fresh[x]=y end
      end
      args[i]=y
    else args[i]=x end
  end
  return {pred=f.pred,args=args}
end

local function projected_to_boundary(f,boundary)
  for _,x in ipairs(f.args) do
    if carrier_kind(x) and not owns(boundary,x) then return false end
  end
  return true
end

-- Apply one rule against a frame Theory through an exact Worlds Construction.
-- Requirements are checked on the FULL construction result before hiding.
-- The rule cannot satisfy its own requirements: only rebased frame facts are
-- available for matching. Consequence-only variables become fresh existentials.
function T.apply(frame,rule,construction)
  assert(frame.geometry==construction:parts()[1],
      'frame Theory must correspond to construction frame')
  assert(rule.geometry==construction:parts()[2],
      'rule Theory must correspond to construction development')
  local full=construction:result()
  local base={}
  for _,f in ipairs(frame.facts) do local g=map_fact(f,construction,true)
  if g then base[#base+1]=g end end

  local req={}
  for i,f in ipairs(rule.requires) do
    local g=mapped_pattern_fact(f,construction)
    if not g then return nil,'dead-requirement' end
    req[i]=g
  end
  local matches={}
  match_patterns(req,base,1,{}, {},matches)
  if #matches==0 then return nil,'unsatisfied-theory-requirement' end
  if #matches>1 then return nil,'ambiguous-theory-requirement' end
  local subst=matches[1].subst
  local out={}
  for i,f in ipairs(base) do out[i]=f end

  local fresh={}
  for _,f in ipairs(rule.asserts) do
    local g=instantiate_fact(f,construction,subst,fresh)
    if not g then return nil,'dead-theory-assertion' end
    out[#out+1]=g
  end
  out=dedup(out)

  local schemas={}
  for k,v in pairs(frame.schemas or {}) do schemas[k]=v end
  for k,v in pairs(rule.schemas or {}) do schemas[k]=v end

  -- Crucial order: validate the complete relational result before boundary
  -- projection can erase consumed evidence.
  local ok,why=validate_functionals(out,schemas)
  if not ok then return nil,why end

  local boundary=W.boundary(full)
  local visible={}
  for _,f in ipairs(out) do if projected_to_boundary(f,boundary) then visible[#visible+1]=f end end
  return T.state(boundary,visible,schemas),{subst=subst,fresh=fresh,full_facts=out}
end

-- Query a state with a pattern, vars are ordinary query variables.
function T.query(state,patterns)
  local out={}
  match_patterns(patterns,state.facts,1,{}, {},out)
  return out
end

return T
