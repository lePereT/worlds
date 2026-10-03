local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('nest',{H.authority_identity_context(),H.unary_context({definition='nest'},{suffix=true})})
local f=H.Unfold.package(p,p:root('nest'),5)
for _,a in ipairs(f:family().items) do
  ok(a.geometry and a.theory,'finite recursive descendant is not one relative Development')
  ok(a.holes==nil and a.trace==nil and a.state==nil,'recursive staging residue leaked after unfolding')
end
eq(#f:family().items,5)
print('PASS tr 29: every complete recursive descendant collapses to one Development ('..count()..')')
