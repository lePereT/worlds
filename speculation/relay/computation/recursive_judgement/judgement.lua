-- Stable commit eligibility for a discovered finite descendant of a recursive
-- ordered family. Discovery depth/order is irrelevant: blockers are decided from
-- the recursive least-fixed-point viability analysis.
local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local Context=require('speculation.relay.computation.recursive_judgement.context')
local Template=require('speculation.relay.computation.recursive_judgement.template')
local Analysis=require('speculation.relay.computation.recursive_judgement.analysis')
local Package=require('speculation.relay.computation.recursive_judgement.package')
local M={}

local function input_points(ctx)
  local out={}
 for i=1,#ctx do if tostring(ctx[i].point):match('^i%d+$') then out[#out+1]=ctx[i].point end end
  table.sort(out,function(a,b) return tonumber(a:sub(2))<tonumber(b:sub(2)) end)
 return out
end

local function boundary_relation(package,root,template)
  template=Template.normal(template)
 local k=K.from_spec(template.theory)
 local bctx=Analysis.boundary_context(package,root)
  local src={}
  for _,p in ipairs(template.values.inputs) do src[#src+1]=p end
  for _,p in ipairs(template.values.outputs) do src[#src+1]=p end
  assert(#src==#bctx,'candidate boundary arity does not match recurrence root')
  return K.select(k,src,bctx)
end

local function requirement(package,root,template)
  local b=boundary_relation(package,root,template)
 return K.exists(b,input_points(b.ctx))
end

local function lift_outer(context,env)
  local c=Context.normal(context)
 local wk=K.from_spec(c.template.theory)
 local map={}
  for j,pos in ipairs(c.outer.values.inputs) do map['i'..j]=c.template.values.inputs[pos] end
  for j,pos in ipairs(c.outer.values.outputs) do map['o'..j]=c.template.values.outputs[pos] end
  return K.rename(env,map,wk.ctx)
end

local function lift_child(package,h,proof,wctx)
  local rel=boundary_relation(package,proof.root,assert(proof.value))
 local map={}
  for j,pos in ipairs(h.values.to_target) do map['i'..j]=wctx.template.values.outputs[pos] end
  for j,pos in ipairs(h.values.from_target) do map['o'..j]=wctx.template.values.inputs[pos] end
  return K.rename(rel,map,K.from_spec(wctx.template.theory).ctx)
end

local function child_environment(package,context,env,children,skip)
  local c=Context.normal(context)
 local acc=K.meet(K.from_spec(c.template.theory),lift_outer(c,env))
  for j,h in ipairs(c.holes) do if j~=skip then acc=K.meet(acc,lift_child(package,h,children[j],c)) end end
  local h=c.holes[skip]
 local child=children[skip]
 local target=Analysis.boundary_context(package,child.root)
 local src={}
  for _,pos in ipairs(h.values.to_target) do src[#src+1]=c.template.values.outputs[pos] end
  for _,pos in ipairs(h.values.from_target) do src[#src+1]=c.template.values.inputs[pos] end
  assert(#src==#target,'hole boundary arity mismatch during stable Judgement')
  return K.select(acc,src,target)
end

local function dominators(definition,index)
  local out={}
 for _,e in ipairs(definition.family.edges or {}) do if e[2]==index then out[#out+1]=e[1] end end
  table.sort(out)
 return out
end

local function check_node(package,analysis,proof,env,seen)
  assert(proof and proof.root and proof.alternative and proof.value,'complete discovery proof required')
  local root=proof.root
 local definition=assert(package:definition(root))
 local chosen=assert(definition.family.items[proof.alternative])
  local candidate=boundary_relation(package,root,proof.value)
  if K.is_bottom(K.meet(env,candidate)) then return 'Retry','candidate boundary contradicts contextual knowledge' end
  local env_in=K.exists(env,input_points(env.ctx))
 local req=requirement(package,root,proof.value)
  local status=K.judge(env_in,req)
  if status~='Hit' then return status,'candidate input requirement is not established' end

  for _,di in ipairs(dominators(definition,proof.alternative)) do
    local blocker=assert(analysis.alternatives[root][di])
    if not K.is_bottom(K.meet(env,blocker)) then
      return 'Blocked','a dominating recursive alternative still has a finite viable completion'
    end
  end

  seen=seen or {}
 local marker=proof
  assert(not seen[marker],'finite discovery proof unexpectedly cyclic')
 seen[marker]=true
  for i,child in ipairs(proof.children or {}) do
    local cenv=child_environment(package,chosen,env,proof.children,i)
    local s,why=check_node(package,analysis,child,cenv,seen)
    if s~='Hit' then seen[marker]=nil
 return s,why end
  end
  seen[marker]=nil
  return 'Hit'
end

function M.check(package,root,state_knowledge,discovered,analysis)
  assert(Package.is(package),'restrictive recurrence Package required')
  local sig=Analysis.signature(package,root)
  if sig.authority.inputs>0 or sig.authority.outputs>0 then
    return 'Deferred','authority-rich recursive eligibility needs an exact boundary-Geometry viability summary'
  end
  assert(discovered and discovered.proof and discovered.value,'discovered finite candidate required')
  assert(discovered.proof.root==root,'candidate root mismatch')
  analysis=analysis or Analysis.compute(package)
  local env=Analysis.root_environment(package,root,state_knowledge)
  return check_node(package,analysis,discovered.proof,env,{})
end

function M.first_stable(package,root,state_knowledge,discovered_family,analysis)
  local sig=Analysis.signature(package,root)
  if sig.authority.inputs>0 or sig.authority.outputs>0 then return 'Deferred',nil,nil end
  analysis=analysis or Analysis.compute(package)
  for i,row in ipairs(discovered_family.items or {}) do
    local status,why=M.check(package,root,state_knowledge,row,analysis)
    if status=='Hit' then return 'Hit',row,i end
  end
  -- Distinguish semantically impossible root from merely not-yet-found or blocked.
  local env=Analysis.root_environment(package,root,state_knowledge)
  if K.is_bottom(K.meet(env,analysis.behaviour[root])) then return 'Retry',nil,nil end
  return 'Deferred',nil,nil
end

return M
