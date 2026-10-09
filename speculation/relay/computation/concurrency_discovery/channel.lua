-- Tiny synchronous channel as ordinary open Geometry plus positive meaning supported on the
-- open Strand occurrences themselves. The channel owns no composition vocabulary or matcher.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}

local function rec(protocol,channel,payload)
  local r={protocol=protocol,channel=T.var('channel')}
  if payload~=nil then r.payload=T.var('payload') end
  return r
end

local function value_action(kind,channel,value,input_value)
  assert(type(channel)=='string' and channel~='','channel name required')
  local geometry,ports=G.operation(1,2)
  local variables={'channel','payload'}
  local equalities={T.eq(T.var('channel'),channel)}
  if kind=='send' and not input_value then equalities[#equalities+1]=T.eq(T.var('payload'),value) end
  local support={strands={}}
  local authority={inputs=ports.inputs,outputs=ports.outputs,open={inputs={1},outputs={1}}}
  local values
  if kind=='send' then
    support.strands[ports.inputs[1]]=rec('relay.channel.ack',channel,nil)
    support.strands[ports.outputs[1]]=rec('relay.channel.offer',channel,true)
    values={inputs=input_value and {'payload'} or {},outputs={}}
  else
    support.strands[ports.inputs[1]]=rec('relay.channel.offer',channel,true)
    support.strands[ports.outputs[1]]=rec('relay.channel.ack',channel,nil)
    values={inputs={},outputs={'payload'}}
  end
  return C.atom({geometry=geometry,theory={variables=variables,equalities=equalities},
    support=support,authority=authority,values=values})
end

function M.send(channel,value) return value_action('send',channel,value,false) end
function M.send_input(channel) return value_action('send',channel,nil,true) end
function M.recv(channel) return value_action('recv',channel,nil,false) end

-- Same rendezvous, now carrying one exact scarce occurrence. The payload Point is pure Geometry;
-- protocol/channel descriptions remain Strand-supported positive meaning and disappear once the
-- corresponding seam is closed.
local function authority_action(kind,channel)
  assert(type(channel)=='string' and channel~='','channel name required')
  local g=G.empty()
  g.membranes[1]={parent=0}
  for i=1,4 do g.points[i]={membrane=1} end
  local support={strands={}}
  local authority
  if kind=='send' then
    g.strands[1]={membrane=1,points={1}} -- ack input
    g.strands[2]={membrane=1,points={4}} -- external resource input
    g.strands[3]={membrane=1,points={2}} -- offer output
    g.strands[4]={membrane=1,points={3}} -- continuation output
    g.strands[5]={membrane=1,points={4}} -- transfer output
    g.faces[1]={membrane=1,inputs={1,2},outputs={3,4,5}}
    support.strands[1]={protocol='relay.channel.ack',channel=T.var('channel')}
    support.strands[3]={protocol='relay.channel.offer',channel=T.var('channel')}
    support.strands[5]={protocol='relay.channel.resource',channel=T.var('channel')}
    authority={inputs={1,2},outputs={3,4,5},open={inputs={1},outputs={1,3}}}
  else
    g.strands[1]={membrane=1,points={1}} -- offer input
    g.strands[2]={membrane=1,points={4}} -- transfer input
    g.strands[3]={membrane=1,points={2}} -- ack output
    g.strands[4]={membrane=1,points={3}} -- continuation output
    g.strands[5]={membrane=1,points={4}} -- public resource output
    g.faces[1]={membrane=1,inputs={1,2},outputs={3,4,5}}
    support.strands[1]={protocol='relay.channel.offer',channel=T.var('channel')}
    support.strands[2]={protocol='relay.channel.resource',channel=T.var('channel')}
    support.strands[3]={protocol='relay.channel.ack',channel=T.var('channel')}
    authority={inputs={1,2},outputs={3,4,5},open={inputs={1,2},outputs={1}}}
  end
  return C.atom({geometry=g,theory={variables={'channel'},equalities={T.eq(T.var('channel'),channel)}},
    support=support,authority=authority,values={inputs={},outputs={}}})
end

function M.send_authority(channel) return authority_action('send',channel) end
function M.recv_authority(channel) return authority_action('recv',channel) end

return M
