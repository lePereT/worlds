-- Fixed-arity barrier as ordinary directed open composition.
-- Participants publish arrival, the coordinator waits for all arrivals, then releases every lane.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}
local function seam(kind,slot)
  return {protocol='relay.barrier.'..kind,barrier=T.var('barrier'),slot=slot}
end
function M.coordinator(identity,n)
  local g,p=G.operation(n,n)
  local support={strands={}}
  local open={inputs={},outputs={}}
  for i=1,n do
    support.strands[p.inputs[i]]=seam('arrival',i); open.inputs[i]=i
    support.strands[p.outputs[i]]=seam('release',i); open.outputs[i]=i
  end
  return C.atom({geometry=g,theory={variables={'barrier'},equalities={T.eq(T.var('barrier'),identity)}},
    support=support,authority={inputs=p.inputs,outputs=p.outputs,open=open},values={inputs={},outputs={}}})
end
function M.participant(identity,slot)
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1},{membrane=1}},strands={},faces={}}
  g.strands[1]={membrane=1,points={1}} -- release in
  g.strands[2]={membrane=1,points={2}} -- arrival out
  g.strands[3]={membrane=1,points={3}} -- continuation out
  g.faces[1]={membrane=1,inputs={},outputs={2}}
  g.faces[2]={membrane=1,inputs={1},outputs={3}}
  return C.atom({geometry=g,theory={variables={'barrier'},equalities={T.eq(T.var('barrier'),identity)}},
    support={strands={[1]=seam('release',slot),[2]=seam('arrival',slot)}},
    authority={inputs={1},outputs={2,3},open={inputs={1},outputs={1}}},values={inputs={},outputs={}}})
end
return M
