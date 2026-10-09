-- Tiny cell family as an ordinary open state protocol. No Cell runtime carrier exists here.
-- Empty/full are positive meanings on scarce state Strands; put/take are ordinary Faces.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}

local function state(protocol,cell,payload)
  local r={protocol='relay.cell.state',cell=T.var('cell'),state=protocol}
  if payload then r.payload=T.var('payload') end
  return r
end

function M.empty(cell)
  local g,p=G.operation(0,1)
  return C.atom({geometry=g,
    theory={variables={'cell'},equalities={T.eq(T.var('cell'),cell)}},
    support={strands={[p.outputs[1]]=state('empty',cell,false)}},
    authority={inputs={},outputs=p.outputs,open={outputs={1},required_outputs={1}}},values={inputs={},outputs={}}})
end

function M.full(cell,value)
  local g,p=G.operation(0,1)
  return C.atom({geometry=g,
    theory={variables={'cell','payload'},equalities={
      T.eq(T.var('cell'),cell),T.eq(T.var('payload'),value)}},
    support={strands={[p.outputs[1]]=state('full',cell,true)}},
    authority={inputs={},outputs=p.outputs,open={outputs={1},required_outputs={1}}},
    values={inputs={},outputs={'payload'}}})
end

local function put(cell,value,input_value)
  local g,p=G.operation(1,2)
  local eqs={T.eq(T.var('cell'),cell)}
  if not input_value then eqs[#eqs+1]=T.eq(T.var('payload'),value) end
  return C.atom({geometry=g,theory={variables={'cell','payload'},equalities=eqs},
    support={strands={
      [p.inputs[1]]=state('empty',cell,false),
      [p.outputs[1]]=state('full',cell,true)}},
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1},outputs={1}}},
    values={inputs=input_value and {'payload'} or {},outputs={}}})
end

function M.put(cell,value) return put(cell,value,false) end
function M.put_input(cell) return put(cell,nil,true) end

function M.take(cell)
  local g,p=G.operation(1,2)
  return C.atom({geometry=g,theory={variables={'cell','payload'},equalities={T.eq(T.var('cell'),cell)}},
    support={strands={
      [p.inputs[1]]=state('full',cell,true),
      [p.outputs[1]]=state('empty',cell,false)}},
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1},outputs={1}}},
    values={inputs={},outputs={'payload'}}})
end

function M.read_linear(cell)
  local g,p=G.operation(1,2)
  return C.atom({geometry=g,theory={variables={'cell','payload'},equalities={T.eq(T.var('cell'),cell)}},
    support={strands={
      [p.inputs[1]]=state('full',cell,true),
      [p.outputs[1]]=state('full',cell,true)}},
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1},outputs={1}}},
    values={inputs={},outputs={'payload'}}})
end

return M
