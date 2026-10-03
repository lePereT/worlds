local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local d=assert(p:definition(p:root('loop')))
eq(#d.family.items,2)
 ok(d.family.items[1].template or d.family.items[2].template)
ok(not p:bytes():find('loop',1,true),'source recursive identity leaked into semantic bytes')
for _,a in ipairs(d.family.items) do
  ok(type(a.template.geometry)=='table' and type(a.template.theory)=='table','recursive node is not Geometry + Theory')
  for _,h in ipairs(a.holes) do ok(h.target.root and not h.target.definition,'resolved hole is not semantic-root linkage') end
end
print('PASS tr 01: recursive Package is finite cyclic Development data ('..count()..')')
