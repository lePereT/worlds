local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local root=p:root('loop')
local step=C.operation(1,1,{}, {}, {variables={},equalities={}})
local base=H.FP.new({items={assert(H.Context.plug(H.authority_identity_context(),{}))},edges={}})
local manual=base
for n=0,6 do
  local approx=H.Unfold.package(p,root,n+1)
 local found=nil
  for _,a in ipairs(approx:family().items) do if #a.geometry.faces==n then found=a end end
  ok(found,'missing recurrence unfolding '..n)
  eq(H.Canonical.encode(found),H.Canonical.encode(manual:alternative(1)),
    'recursive unfolding differs from finite compilation at scale '..n)
  manual=C.bind(step,manual,{value_pairs={},captures={{from=1,to=1}}})
end
print('PASS tr 06: finite unfolding equals direct finite Development compilation ('..count()..')')
