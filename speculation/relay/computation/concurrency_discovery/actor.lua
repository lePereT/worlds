-- One actor turn derived from an MVar mailbox, grounded state, and ordinary dependent composition.
-- This is deliberately not an Actor semantic carrier: mailbox and state are just two MVars, while
-- the handler is a finite relation which captures only the actor-state authority it advances.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local MVar=require('speculation.relay.computation.concurrency_discovery.mvar')
local M={}

local function owner_record(state,payload)
  local r={protocol='relay.state.owner',cell=T.var('cell'),state=state}
  if payload then r.payload=T.var(payload) end
  return r
end

local function handler(message,current,next_value)
  local g,p=G.operation(1,1)
  return C.atom({geometry=g,theory={variables={'cell','message','current','next'},equalities={
      T.eq(T.var('cell'),'actor.state'),T.eq(T.var('message'),message),T.eq(T.var('current'),current),
      T.eq(T.var('next'),next_value)}},
    support={strands={
      [p.inputs[1]]=owner_record('empty',false),
      [p.outputs[1]]=owner_record('full','next'),
    }},authority={inputs=p.inputs,outputs=p.outputs},
    values={inputs={'message','current'},outputs={'next'}}})
end

function M.turn(mailbox_state,actor_state)
  local msg=MVar.step(mailbox_state,MVar.take('actor.mailbox'))
  local st=MVar.step(actor_state,MVar.take('actor.state'))
  local pair=C.each({msg,st})
  -- In the current MVar boundary each taken state contributes three authority outputs and three
  -- value outputs.  The second state token is therefore authority output 4; payloads are values 3/6.
  local relation=C.choice(handler('inc',1,2),handler('reset',1,0))
  return C.and_then(pair,relation,{value_pairs={{from=3,to=1},{from=6,to=2}},captures={{from=4,to=1}}})
end
return M
