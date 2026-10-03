-- Exact finite-model viability analysis for recursive ordered Development families.
-- This is Judgement analysis, not Theory semantics: union across explicit alternatives
-- is allowed here because OrderedFamily already supplies positive alternatives.
local K=require('speculation.showcases.transactions.transactional_recursive_judgement.knowledge')
local Context=require('speculation.showcases.transactions.transactional_recursive_judgement.context')
local Package=require('speculation.showcases.transactions.transactional_recursive_judgement.package')
local M={}

local function copy(xs) local out={}
 for i,x in ipairs(xs or {}) do out[i]=x end
 return out end
local function same_values(a,b)
  if #a~=#b then return false end
  local C=require('speculation.showcases.transactions.transactional_development_calculus.canonical')
  for i=1,#a do if C.encode(a[i])~=C.encode(b[i]) then return false end end
  return true
end

local function boundary_ctx_from_signature(sig)
  local ctx={}
  for i,d in ipairs(sig.values.inputs or {}) do ctx[#ctx+1]={point='i'..i,sort=d.sort,values=copy(d.values)} end
  for i,d in ipairs(sig.values.outputs or {}) do ctx[#ctx+1]={point='o'..i,sort=d.sort,values=copy(d.values)} end
  return K.context(ctx)
end
local function input_ctx_from_signature(sig)
  local ctx={}
 for i,d in ipairs(sig.values.inputs or {}) do ctx[#ctx+1]={point='i'..i,sort=d.sort,values=copy(d.values)} end
  return K.context(ctx)
end

function M.signature(package,root)
  assert(Package.is(package),'restrictive recurrence Package required')
  local d=assert(package:definition(root),'unknown recurrence root')
  local sig=nil
  for _,c in ipairs(d.family.items) do
    local s=Context.signature(c)
    if sig then
      assert(s.authority.inputs==sig.authority.inputs and s.authority.outputs==sig.authority.outputs)
      assert(#s.values.inputs==#sig.values.inputs and #s.values.outputs==#sig.values.outputs)
      for i,x in ipairs(s.values.inputs) do assert(x.sort==sig.values.inputs[i].sort and same_values(x.values,sig.values.inputs[i].values),'recursive input domain mismatch') end
      for i,x in ipairs(s.values.outputs) do assert(x.sort==sig.values.outputs[i].sort and same_values(x.values,sig.values.outputs[i].values),'recursive output domain mismatch') end
    else sig=s end
  end
  return sig
end
function M.boundary_context(package,root) return boundary_ctx_from_signature(M.signature(package,root)) end
function M.input_context(package,root) return input_ctx_from_signature(M.signature(package,root)) end

local function lift(rel,map,target_ctx)
  return K.rename(rel,map,target_ctx)
end

-- Evaluate one open Development context against the current root viability relations.
local function context_relation_for(package,root,context,root_behaviours)
  local c=Context.normal(context)
 local wk=K.from_spec(c.template.theory)
 local acc=wk
  for _,h in ipairs(c.holes) do
    local child=assert(root_behaviours[assert(h.target.root)],'missing child viability relation')
    local map={}
    for j,pos in ipairs(h.values.to_target) do map['i'..j]=c.template.values.outputs[pos] end
    for j,pos in ipairs(h.values.from_target) do map['o'..j]=c.template.values.inputs[pos] end
    acc=K.meet(acc,K.rename(child,map,wk.ctx))
  end
  local keep,map={},{}
  for j,pos in ipairs(c.outer.values.inputs) do local p=c.template.values.inputs[pos]
 keep[#keep+1]=p
 map[p]='i'..j end
  for j,pos in ipairs(c.outer.values.outputs) do local p=c.template.values.outputs[pos]
 keep[#keep+1]=p
 map[p]='o'..j end
  local projected=K.exists(acc,keep)
  return K.rename(projected,map,M.boundary_context(package,root))
end

function M.compute(package)
  assert(Package.is(package),'restrictive recurrence Package required')
  local definitions=package:definitions()
 local roots={}
 for _,d in ipairs(definitions) do roots[#roots+1]=d.root end
  local behaviour={}
  for _,r in ipairs(roots) do behaviour[r]=K.bottom(M.boundary_context(package,r)) end
  local changed=true
 local rounds=0
 local limit=1
  for _,r in ipairs(roots) do
    local top=K.top(M.boundary_context(package,r))
 local rows=0
 for _ in pairs(top.rows) do rows=rows+1 end
 limit=limit+rows
  end
  while changed do
    rounds=rounds+1
 assert(rounds<=limit+1,'finite viability lattice failed to converge')
    changed=false
 local nextb={}
    for _,r in ipairs(roots) do
      local d=assert(package:definition(r))
 local acc=K.bottom(M.boundary_context(package,r))
      for _,c in ipairs(d.family.items) do acc=K.join_rows(acc,context_relation_for(package,r,c,behaviour)) end
      nextb[r]=acc
 if not K.equal(acc,behaviour[r]) then changed=true end
    end
    behaviour=nextb
  end
  local alternatives={}
  for _,r in ipairs(roots) do
    local d=assert(package:definition(r))
 alternatives[r]={}
    for i,c in ipairs(d.family.items) do alternatives[r][i]=context_relation_for(package,r,c,behaviour) end
  end
  return {behaviour=behaviour,alternatives=alternatives,rounds=rounds}
end

function M.input_projection(package,root,rel)
  local keep={}
 local sig=M.signature(package,root)
 for i=1,#sig.values.inputs do keep[i]='i'..i end
  return K.exists(rel,keep)
end

function M.root_environment(package,root,input_knowledge)
  input_knowledge=K.normal(input_knowledge)
  local expected=M.input_context(package,root)
 assert(K.same_context(input_knowledge,K.top(expected)),'state knowledge context mismatch')
  local map={}
 for i=1,#expected do map['i'..i]='i'..i end
  return K.rename(input_knowledge,map,M.boundary_context(package,root))
end

return M
