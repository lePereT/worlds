local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local lib=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local lr=lib:root('loop')
local app=H.RP.new({definitions={{identity='wrap',alternatives={H.unary_context({root=lr},{suffix=true})}}}})
local linked=H.RP.link({lib,app})
local joint=H.RP.new({definitions={
  {identity='loop',alternatives={H.authority_identity_context(),H.unary_context({definition='loop'})}},
  {identity='wrap',alternatives={H.unary_context({definition='loop'},{suffix=true})}},
}})
eq(lr,joint:root('loop'),'separate compilation changed library recursive root')
eq(app:root('wrap'),joint:root('wrap'),'separate compilation changed dependent recursive root')
for d=1,6 do
  eq(H.Unfold.package(linked,app:root('wrap'),d):bytes(),
    H.Unfold.package(joint,joint:root('wrap'),d):bytes(),
    'separate versus joint recursive compilation differs at depth '..d)
end
ok(true)
print('PASS tr 32: separate and larger-scale recursive compilation agree ('..count()..')')
