local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local defs={
  {identity='a',alternatives={H.closed_chain_context(0),H.closed_chain_context(1)}},
  {identity='b',alternatives={H.closed_chain_context(0),H.closed_chain_context(2)}},
}
local p=H.RP.new({definitions={defs[1],defs[2],
  {identity='pair',alternatives={H.zero_hole_context({{definition='a'},{definition='b'}})}}}})
local q=H.RP.new({definitions={defs[2],defs[1],
  {identity='pair2',alternatives={H.zero_hole_context({{definition='b'},{definition='a'}})}}}})
eq(p:root('pair'),q:root('pair2'),'independent recursive hole ordering changed semantic entry')
eq(H.Unfold.package(p,p:root('pair'),2):bytes(),H.Unfold.package(q,q:root('pair2'),2):bytes())
ok(true)
print('PASS tr 19: independent hole listing order is non-semantic ('..count()..')')
