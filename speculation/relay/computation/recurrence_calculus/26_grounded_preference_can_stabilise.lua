local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.authority_identity_context(),H.unary_context({definition='f'})},{{1,2}})
local root=p:root('f')
for depth=1,7 do
  local f=H.Unfold.package(p,root,depth):family()
 local frontier=H.Family.frontier(f)
  eq(#frontier,1)
 eq(#f.items[frontier[1]].geometry.faces,0,'grounded preferred base lost stable frontier')
end
ok(true)
print('PASS tr 26: grounded dominance remains stable across deeper unfolding ('..count()..')')
