local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); local AO=vb:point(vm,'AO'); local BO=vb:point(vm,'BO'); vb:finish()
local function lane(ri,ro,name)
  local b=W.Geometry.builder(); local m=b:membrane(nil,name); local i=b:strand(m,{ri}); local o=b:strand(m,{ro}); b:face(m,{i},{o},name); return b:finish(),i,o
end
local ga,ai,ao=lane(A,AO,'a'); local gb,bi,bo=lane(B,BO,'b')
local t,img=W.Algebra.tensor({ga,gb})
T.eq(#t:faces(),2); T.eq(#t:membranes(),2); T.ok(t:is_input(img[1].strands[ai])); T.ok(t:is_input(img[2].strands[bi])); T.ok(t:is_terminal(img[1].strands[ao])); T.ok(t:is_terminal(img[2].strands[bo]))
-- Tensor adds no sibling supply: both parent requirements must be available.
local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'root'); local sa=sb:strand(sm,{A}); local live=W.Operational.from_geometry(sb:finish())
T.eq(W.Operational.one(live,t,{strands={[img[1].strands[ai]]=sa}}),nil)
local sb2=W.Geometry.builder(); local sm2=sb2:membrane(nil,'root'); local sa2=sb2:strand(sm2,{A}); local sbv=sb2:strand(sm2,{B}); local live2=W.Operational.from_geometry(sb2:finish())
local w=W.Operational.one(live2,t,{strands={[img[1].strands[ai]]=sa2,[img[2].strands[bi]]=sbv}}); T.ok(w)
return T.count()
