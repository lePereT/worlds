-- Exact live-input adapter for Judgement.  It pulls a Development's positive
-- input requirement back through ordinary Worlds Construction onto one joint
-- state knowledge context.  This is proof machinery, not semantic metadata.
local W=require('worlds')
local Construction=require('worlds.construction')
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local Template=require('speculation.relay.computation.recursive_judgement.template')
local OldAnalysis=require('speculation.relay.computation.recursive_judgement.analysis')
local M={}

local function copy(xs) local out={}
 for i,x in ipairs(xs or {}) do out[i]=x end
 return out end
local function scalar_key(x) return Canonical.encode(x) end
local function same_values(a,b)
  if #a~=#b then return false end
  for i=1,#a do if scalar_key(a[i])~=scalar_key(b[i]) then return false end end
  return true
end
local function ckey(p) return type(p)..':'..tostring(p) end
local function index_ctx(ctx)
  local out={}
  for _,c in ipairs(ctx) do out[ckey(c.point)]=c end
  return out
end

local function split_state_knowledge(package,root,value)
  if value and value.ctx then return {values=K.normal(value),occurrences=K.top({}),joint=nil} end
  value=value or {}
  local expected=OldAnalysis.input_context(package,root)
  local values=value.values and K.normal(value.values) or K.top(expected)
  assert(K.same_context(values,K.top(expected)),'state value knowledge context mismatch')
  return {values=values,
    occurrences=value.occurrences and K.normal(value.occurrences) or K.top({}),
    joint=value.joint and K.normal(value.joint) or nil}
end

function M.join(state,sources,template)
  local inst=Template.instantiate(template)
  if #sources~=#inst.authority.inputs then return nil,inst end
  local seeds={}
  for i,target in ipairs(inst.authority.inputs) do
    local from=sources[i]
    if not from or not state:owns_strand(from) or not state:is_terminal(from) then return nil,inst end
    seeds[i]={from=from,to=target}
  end
  local ok,c=pcall(Construction.join,{state,inst.geometry},seeds)
  if not ok then return nil,inst end
  return c,inst
end

local function project_rule_requirement(inst)
  local keep,seen,present={},{},{}
  local function add(p) if not seen[p] then seen[p]=true
 keep[#keep+1]=p end end
  for _,p in ipairs(inst.values.inputs) do add(p) end
  for _,s in ipairs(inst.authority.inputs) do for _,p in ipairs(W.points(s)) do add(p) end end
  for _,c in ipairs(K.normal(inst.theory).ctx) do present[c.point]=true end
  local actual={}
  for _,p in ipairs(keep) do if present[p] then actual[#actual+1]=p end end
  return K.exists(inst.theory,actual)
end

local function live_points(sources)
  local out,seen={},{ }
  for _,s in ipairs(sources) do
    for _,p in ipairs(W.points(s)) do if not seen[p] then seen[p]=true
 out[#out+1]=p end end
  end
  return out
end

local function domains(k)
  local out={}
  for _,c in ipairs(K.normal(k).ctx) do out[c.point]=c end
  return out
end

local function target_context(package,root,sources,req,corr,bundle)
  local ctx,by={},{}
  local function add(point,sort,values)
    local key=ckey(point)
 local old=by[key]
    if old then
      assert(old.sort==sort and same_values(old.values,values),'state input knowledge domain mismatch')
      return
    end
    local row={point=point,sort=sort,values=copy(values)}
    by[key]=row
    ctx[#ctx+1]=row
  end
  for _,c in ipairs(OldAnalysis.input_context(package,root)) do add(c.point,c.sort,c.values) end

  local req_by=domains(req)
 local rule_points={}
  for p in pairs(req_by) do rule_points[#rule_points+1]=p end
  for _,sp in ipairs(live_points(sources)) do
    local found=nil
    for _,rp in ipairs(rule_points) do if corr:source_equivalent(sp,rp) then
      local c=req_by[rp]
      if found then
        assert(found.sort==c.sort and same_values(found.values,c.values),
          'Construction identified incompatible Theory domains')
      else found=c end
    end end
    if found then add(sp,found.sort,found.values) end
  end

  for _,c in ipairs(K.normal(bundle.occurrences).ctx) do
    if by[ckey(c.point)] then add(c.point,c.sort,c.values) end
  end
  if bundle.joint then
    for _,c in ipairs(K.normal(bundle.joint).ctx) do
      if by[ckey(c.point)] then add(c.point,c.sort,c.values) end
    end
  end
  return K.context(ctx),by
end

local function current_relation(bundle,target_ctx)
  local by=index_ctx(target_ctx)
  if bundle.joint then
    local map={}
    for _,c in ipairs(K.normal(bundle.joint).ctx) do
      if by[ckey(c.point)] then map[c.point]=c.point end
    end
    return K.rename(bundle.joint,map,target_ctx)
  end

  local parts={}
 local vtarget={}
  for _,c in ipairs(target_ctx) do
    if type(c.point)=='string' and c.point:match('^i%d+$') then vtarget[#vtarget+1]=c end
  end
  if #vtarget>0 then
    local map={}
 for _,c in ipairs(K.normal(bundle.values).ctx) do map[c.point]=c.point end
    parts[#parts+1]=K.rename(bundle.values,map,vtarget)
  end
  local otarget={}
  for _,c in ipairs(target_ctx) do
    if type(c.point)~='string' or not c.point:match('^i%d+$') then otarget[#otarget+1]=c end
  end
  if #otarget>0 then
    local map={}
    for _,c in ipairs(K.normal(bundle.occurrences).ctx) do
      if by[ckey(c.point)] then map[c.point]=c.point end
    end
    parts[#parts+1]=K.rename(bundle.occurrences,map,otarget)
  end
  if #parts==0 then return K.top(target_ctx) end
  local product=K.product(parts)
  assert(K.same_context(product,K.top(target_ctx)),'joint state knowledge context mismatch')
  return product
end

local function pull_requirement(package,root,sources,construction,inst,bundle)
  local req=project_rule_requirement(inst)
  local corr=construction:correspondence()
  local target_ctx=target_context(package,root,sources,req,corr,bundle)
  if #req.ctx==0 then return current_relation(bundle,target_ctx),K.top(target_ctx) end

  local rctx,rname={},{}
  for i,c in ipairs(req.ctx) do
    local n='__rule_'..i
    rname[c.point]=n
    rctx[i]={point=n,sort=c.sort,values=copy(c.values)}
  end
  local combined=K.product({K.rename(req,rname,rctx),K.top(target_ctx)})
  local state_by,rule_by=index_ctx(target_ctx),domains(req)
  local function equate(rp,sp)
    local rc,sc=assert(rule_by[rp]),assert(state_by[ckey(sp)])
    assert(rc.sort==sc.sort and same_values(rc.values,sc.values),'Rule/state Theory domain mismatch')
    combined=K.meet(combined,K.points_equal(combined.ctx,rname[rp],sp))
  end

  for i,rp in ipairs(inst.values.inputs) do if rule_by[rp] then equate(rp,'i'..i) end end
  for _,sp in ipairs(live_points(sources)) do if state_by[ckey(sp)] then
    for rp in pairs(rule_by) do if corr:source_equivalent(sp,rp) then equate(rp,sp) end end
  end end

  local keep={}
 for _,c in ipairs(target_ctx) do keep[#keep+1]=c.point end
  return current_relation(bundle,target_ctx),K.exists(combined,keep)
end

function M.status(package,root,state_knowledge,sources,construction,inst)
  local bundle=split_state_knowledge(package,root,state_knowledge)
  local current,required=pull_requirement(package,root,sources,construction,inst,bundle)
  return K.judge(current,required),current,required
end

return M
