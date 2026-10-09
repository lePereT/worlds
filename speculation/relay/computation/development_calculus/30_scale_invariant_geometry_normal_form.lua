local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local function chain_left(n)
  local x=H.identity_operation()
  for _=2,n do x=C.bind(x,H.identity_operation(),{value_pairs={},captures={{from=1,to=1}}}) end
  return x
end
local function chain_right(n)
  local xs={}
 for i=1,n do xs[i]=H.identity_operation() end
  local x=xs[n]
  for i=n-1,1,-1 do x=C.bind(xs[i],x,{value_pairs={},captures={{from=1,to=1}}}) end
  return x
end
for n=2,8 do
  local a,b=chain_left(n),chain_right(n)
  eq(a:root(),b:root(),'causal chain semantic root depends on compilation scale at '..n)
  eq(a:bytes(),b:bytes(),'causal chain bytes depend on compilation scale at '..n)
  eq(#a:alternative(1).geometry.faces,n,'causal chain face count')
end
ok(true)
print('PASS td 30: Geometry normal form is invariant across compilation scale ('..count()..')')
