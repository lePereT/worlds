local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local R=require('speculation.relay.computation.recurrence_calculus.common')
local function record(lane) return {protocol='relay.progress.turn',lane=lane} end
local function base(lane)
  local c=R.authority_identity_context(); local t=c.template
  t.support={strands={[t.authority.inputs[1]]=record(lane)}}
  return R.Context.normal({template=t,outer=c.outer,holes=c.holes})
end
local function next_turn(from,to,target)
  local c=R.unary_context({definition=target}); local t=c.template
  t.support={strands={
    [t.authority.inputs[1]]=record(from),
    [t.authority.outputs[1]]=record(to),
  }}
  return R.Context.normal({template=t,outer=c.outer,holes=c.holes})
end
local p=R.RP.new({definitions={
  {identity='a',alternatives={base('A'),next_turn('A','B','b')}},
  {identity='b',alternatives={base('B'),next_turn('B','A','a')}},
}})
ok(p:root('a')~=p:root('b'),'A/B turn roots collapsed despite occurrence meaning')
local f=R.Unfold.package(p,p:root('a'),5)
ok(#f:family().items>=5,'alternating cyclic topology did not expose finite prefixes')
local sawA,sawB=false,false
for _,a in ipairs(f:family().items) do
  local out=a.support and a.support.strands and a.support.strands[a.authority.outputs[1]]
  if out and out.lane=='A' then sawA=true elseif out and out.lane=='B' then sawB=true end
end
ok(sawA and sawB,'finite observations did not retain alternating turn boundary meaning')
ok(H.no_runtime_words(p:bytes()))
-- This establishes static turn topology only. Eventual progress through the infinite cycle is a
-- liveness obligation; finite Development prefixes deliberately do not pretend to prove it.
print('PASS cc 49: known fair turn-taking can be cyclic topology; eventuality remains a liveness obligation ('..count()..')')
