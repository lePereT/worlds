local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local p=H.C.together({H.Cell.full('box',9),H.Cell.read_linear('box'),H.Cell.read_linear('box')})
eq(#p:family().items,2,'two linear reads should preserve their two lawful serial orders')
for i=1,2 do
  local a=p:alternative(i)
  eq(H.value(p,i,1),9)
  eq(H.value(p,i,2),9)
  eq(#a.geometry.faces,3)
  ok(H.G.face_reaches(a.geometry,1,2) and H.G.face_reaches(a.geometry,2,3),
    'linear cell reads failed to expose their deliberate state causality')
end
print('PASS cc 29: linear read is a stronger protocol than stable knowledge view ('..count()..')')
