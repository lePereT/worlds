-- Stable recursive Judgement over paired boundary Development cases. Search discovers
-- finite witnesses; this module proves their stable eligibility independently.
local W=require('worlds')
local Context=require('speculation.relay.computation.recursive_judgement.context')
local Analysis=require('speculation.relay.computation.geometry_viability.analysis')
local Input=require('speculation.relay.computation.geometry_viability.input')
local Package=require('speculation.relay.computation.recursive_judgement.package')
local M={}

local function dominators(definition,index)
  local out={}
  for _,e in ipairs(definition.family.edges or {}) do if e[2]==index then out[#out+1]=e[1] end end
  table.sort(out)
  return out
end

local function consistent(package,root,state,state_k,sources,template)
  local c,inst=Input.join(state,sources,template)
  if not c then return false end
  return Input.status(package,root,state_k,sources,c,inst)~='Retry'
end

local function candidate_hit(package,root,state,state_k,sources,template)
  local c,inst=Input.join(state,sources,template)
  if not c then return false,'candidate boundary contradicts exact state','Retry' end
  local status=Input.status(package,root,state_k,sources,c,inst)
  if status=='Retry' then
    return false,'candidate input requirement contradicts occurrence knowledge','Retry'
  end
  if status~='Hit' then return false,'candidate input requirement is not established',status end
  return true
end

local function rebuild(proof,target,replacement)
  if proof==target then return replacement,true end
  local children,changed={},false
  for i,ch in ipairs(proof.children or {}) do
    local t,c=rebuild(ch,target,replacement)
    children[i]=t
    changed=changed or c
  end
  if not changed then return proof.value,false end
  return Context.plug(proof.context,children),true
end

local function nodes(proof,out)
  out=out or {}
  out[#out+1]=proof
  for _,ch in ipairs(proof.children or {}) do nodes(ch,out) end
  return out
end

function M.check(package,root,state,state_knowledge,sources,discovered,analysis)
  assert(Package.is(package),'restrictive recurrence Package required')
  assert(W.is_geometry(state),'exact live state Geometry required')
  assert(discovered and discovered.proof and discovered.value,'discovered finite candidate required')
  assert(discovered.proof.root==root,'candidate root mismatch')
  analysis=analysis or Analysis.compute(package)
  local hit,why,status=candidate_hit(package,root,state,state_knowledge,sources,discovered.value)
  if not hit then return status or 'Retry',why end

  for _,node in ipairs(nodes(discovered.proof)) do
    local d=assert(package:definition(node.root))
    for _,di in ipairs(dominators(d,node.alternative)) do
      for _,case in ipairs(Analysis.list(assert(analysis.alternatives[node.root][di]))) do
        local whole,changed=rebuild(discovered.proof,node,case.representative)
        assert(changed,'blocker replacement failed to reach discovery node')
        if whole and consistent(package,root,state,state_knowledge,sources,whole) then
          return 'Blocked','a dominating recursive alternative still has a finite Geometry+Theory completion'
        end
      end
    end
  end
  return 'Hit'
end

function M.first_stable(package,root,state,state_knowledge,sources,discovered_family,analysis)
  analysis=analysis or Analysis.compute(package)
  for i,row in ipairs(discovered_family.items or {}) do
    local status=M.check(package,root,state,state_knowledge,sources,row,analysis)
    if status=='Hit' then return 'Hit',row,i end
  end
  for _,case in ipairs(Analysis.list(assert(analysis.behaviour[root]))) do
    if consistent(package,root,state,state_knowledge,sources,case.representative) then
      return 'Deferred',nil,nil
    end
  end
  return 'Retry',nil,nil
end

return M
