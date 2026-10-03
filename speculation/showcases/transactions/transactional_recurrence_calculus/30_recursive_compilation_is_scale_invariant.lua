local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local root=p:root('loop')
local function direct(n)
  local base=H.FP.new({items={assert(H.Context.plug(H.authority_identity_context(),{}))},edges={}})
  if n==0 then return base end
  local xs={}
 for i=1,n do xs[i]=C.operation(1,1,{}, {}, {variables={},equalities={}}) end
  local x=base
  for i=n,1,-1 do x=C.bind(xs[i],x,{value_pairs={},captures={{from=1,to=1}}}) end
  return x
end
for n=0,7 do
  local approx=H.Unfold.package(p,root,n+1)
 local chosen=nil
  for _,a in ipairs(approx:family().items) do if #a.geometry.faces==n then chosen=a end end
  eq(H.Canonical.encode(chosen),H.Canonical.encode(direct(n):alternative(1)),
    'recursive residual differs from whole-region compilation at '..n)
end
ok(true)
print('PASS tr 30: recursive residuals are invariant under compilation scale ('..count()..')')
