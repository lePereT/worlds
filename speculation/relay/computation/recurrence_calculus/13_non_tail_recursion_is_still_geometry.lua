local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('nest',{H.authority_identity_context(),H.unary_context({definition='nest'},{suffix=true})})
local root=p:root('nest')
for depth=1,6 do
  local f=H.Unfold.package(p,root,depth)
  eq(#f:family().items,depth)
  local seen={}
 for _,a in ipairs(f:family().items) do seen[#a.geometry.faces]=true end
  for n=0,depth-1 do ok(seen[2*n],'non-tail unfolding lost prefix/suffix Geometry') end
end
print('PASS tr 13: non-tail recursion is finite context plugging, not a stack object ('..count()..')')
