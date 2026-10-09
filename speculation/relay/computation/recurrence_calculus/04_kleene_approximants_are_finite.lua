local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local root=p:root('loop')
for depth=0,6 do
  local f=H.Unfold.package(p,root,depth)
  eq(#f:family().items,depth,'productive star approximant cardinality')
  local seen={}
 for _,a in ipairs(f:family().items) do seen[#a.geometry.faces]=true end
  for n=0,depth-1 do ok(seen[n],'approximant omitted finite unfolding '..n) end
end
print('PASS tr 04: cyclic Package denotes finite Kleene approximants ('..count()..')')
