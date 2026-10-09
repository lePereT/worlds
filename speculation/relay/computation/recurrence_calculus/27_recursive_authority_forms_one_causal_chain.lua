local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.rec_package('loop',{H.authority_identity_context(),H.unary_context({definition='loop'})})
local f=H.Unfold.package(p,p:root('loop'),6)
for _,a in ipairs(f:family().items) do
  local n=#a.geometry.faces
  if n>1 then ok(H.C.Geometry().face_reaches(a.geometry,1,n),'recursive authority chain lost causal order') end
  eq(#a.authority.inputs,1)
 eq(#a.authority.outputs,1)
end
print('PASS tr 27: authority recurrence is ordinary exact causal composition ('..count()..')')
