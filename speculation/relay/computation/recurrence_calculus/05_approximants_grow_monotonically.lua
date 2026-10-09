local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local root=p:root('loop')
 local prev=H.Unfold.package(p,root,0)
for depth=1,8 do
  local nextp=H.Unfold.package(p,root,depth)
  ok(H.contains_items(prev,nextp),'finite recurrence approximant retracted Development meaning')
  prev=nextp
end
eq(#prev:family().items,8)
print('PASS tr 05: positive recurrence grows monotonically from empty meaning ('..count()..')')
