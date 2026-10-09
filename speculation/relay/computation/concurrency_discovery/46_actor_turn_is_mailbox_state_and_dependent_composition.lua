local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local turn=H.Actor.turn(H.MVar.full('actor.mailbox','inc'),H.MVar.full('actor.state',1))
eq(#turn:family().items,1,'known actor message/state did not specialise to one handler')
local a=turn:alternative(1)
eq(H.value(turn,1,1),2,'actor handler did not produce next state value')
local mailbox_empty,actor_full=false,false
for _,si in ipairs(a.authority.outputs) do
  local r=a.support and a.support.strands and a.support.strands[si]
  if r and r.protocol=='relay.state.owner' then
    local cell=H.T.value(a.theory,r.cell.var)
    if cell=='actor.mailbox' and r.state=='empty' then mailbox_empty=true end
    if cell=='actor.state' and r.state=='full' then
      actor_full=true
      eq(H.T.value(a.theory,r.payload.var),2,'actor state authority did not carry next value')
    end
  end
end
ok(mailbox_empty,'actor turn did not leave mailbox empty state')
ok(actor_full,'actor turn did not restore actor persistent state')
ok(H.no_runtime_words(turn:bytes()))
print('PASS cc 46: actor turn is mailbox + grounded state + dependent composition, not an Actor carrier ('..count()..')')
