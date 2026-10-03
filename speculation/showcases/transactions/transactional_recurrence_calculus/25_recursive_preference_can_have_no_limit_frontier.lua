local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.unary_context({definition='f'}),H.authority_identity_context()},{{1,2}})
local root=p:root('f')
 local last=-1
for depth=1,7 do
  local f=H.Unfold.package(p,root,depth):family()
 local frontier=H.Family.frontier(f)
  eq(#frontier,1,'finite approximant should have one temporary preferred descendant')
  local faces=#f.items[frontier[1]].geometry.faces
  eq(faces,depth-1,'recursive-preferred frontier did not move outward with approximant')
  ok(faces>last)
 last=faces
end
print('PASS tr 25: bounded recursive frontier is not semantic commit eligibility ('..count()..')')
