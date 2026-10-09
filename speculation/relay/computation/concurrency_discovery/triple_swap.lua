-- Three-party swap built from ordinary finite alternatives and generic Strand-supported meaning.
-- There is no three-way primitive and no protocol-specific matcher.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}

local function port(protocol,channel,group,payload)
  return {protocol=protocol,channel=T.var('channel'),group=T.var('group'),payload=payload}
end

local function role(channel,ticket,value,name)
  assert(type(channel)=='string' and channel~='','triple-swap channel required')
  assert(type(ticket)=='string' and ticket~='','triple-swap ticket required')
  assert(name=='A' or name=='B' or name=='C','triple-swap role required')

  local geometry,ports=G.operation(2,2)
  local variables={'channel','group','offered','left','right'}
  local equalities={T.eq(T.var('channel'),channel),T.eq(T.var('offered'),value)}
  if name=='A' then equalities[#equalities+1]=T.eq(T.var('group'),ticket) end
  local ins,outs
  if name=='A' then ins={'relay.triple.BA','relay.triple.CA'}; outs={'relay.triple.AB','relay.triple.AC'}
  elseif name=='B' then ins={'relay.triple.AB','relay.triple.CB'}; outs={'relay.triple.BA','relay.triple.BC'}
  else ins={'relay.triple.AC','relay.triple.BC'}; outs={'relay.triple.CA','relay.triple.CB'} end
  local support={strands={}}
  support.strands[ports.inputs[1]]=port(ins[1],channel,T.var('group'),T.var('left'))
  support.strands[ports.inputs[2]]=port(ins[2],channel,T.var('group'),T.var('right'))
  support.strands[ports.outputs[1]]=port(outs[1],channel,T.var('group'),T.var('offered'))
  support.strands[ports.outputs[2]]=port(outs[2],channel,T.var('group'),T.var('offered'))
  return C.atom({geometry=geometry,theory={variables=variables,equalities=equalities},support=support,
    authority={inputs=ports.inputs,outputs=ports.outputs,open={inputs={1,2},outputs={1,2}}},
    values={inputs={},outputs={'left','right'}}})
end

function M.swap(channel,ticket,value)
  return C.choice(C.choice(role(channel,ticket,value,'A'),role(channel,ticket,value,'B')),
    role(channel,ticket,value,'C'))
end

return M
