-- Productive cyclic presentation of persistent state ownership.
-- Each root exposes the current grounded state as a finite alternative and may advance to another
-- semantic root.  The cycle is Package topology; unfolding is observation of finite prefixes.
local R=require('speculation.relay.computation.recurrence_calculus.common')
local M={}

local function state_record(kind)
  return {protocol='relay.state.owner',state=kind}
end

local function base(kind)
  local c=R.authority_identity_context()
  local t=c.template
  t.support={strands={[t.authority.inputs[1]]=state_record(kind)}}
  return R.Context.normal({template=t,outer=c.outer,holes=c.holes})
end

local function advance(from,to,target,opts)
  local c=R.unary_context({definition=target},opts or {})
  local t=c.template
  t.support={strands={}}
  t.support.strands[t.authority.inputs[1]]=state_record(from)
  t.support.strands[t.authority.outputs[1]]=state_record(to)
  return R.Context.normal({template=t,outer=c.outer,holes=c.holes})
end

function M.package()
  return R.RP.new({definitions={
    {identity='empty',alternatives={
      base('empty'),
      advance('empty','full','full'),
    }},
    {identity='full',alternatives={
      base('full'),
      advance('full','empty','empty'),
      advance('full','full','full',{suffix=true}),
    }},
  }})
end

function M.unfold(p,state,depth)
  return R.Unfold.package(p,assert(p:root(state),'unknown recurrent owner state'),depth)
end

return M
