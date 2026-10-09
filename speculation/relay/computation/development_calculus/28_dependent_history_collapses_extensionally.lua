local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local flip=H.branch({{true,false},{false,true}})
local x=C.identity_value()
for i=1,20 do
  x=C.bind(x,flip)
  eq(#x:family().items,2,'dependent history leaked into alternatives')
  eq(#x:bytes(),689,'canonical finite relation grew with hidden history')
end
print('PASS td 28: dependent history contracts back to extensional family meaning ('..count()..')')
