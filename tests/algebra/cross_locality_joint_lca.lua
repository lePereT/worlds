local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Arole=vb:point(vm,'A'); local Brole=vb:point(vm,'B'); local Control=vb:point(vm,'Control'); vb:finish()
local function lane(name,rin,rout,control)
  local b=W.Geometry.builder(); local root=b:membrane(nil,name); local child=b:membrane(root,name..'-face'); local i=b:strand(root,{rin}); local ins={i}; local c
  if control then c=b:strand(root,{Control}); ins[#ins+1]=c end
  local o=b:strand(root,{rout}); local f=b:face(child,ins,{o}); return b:finish(),root,child,i,o,c,f
end
local A,ar,ac,ai,ao,ctl,af=lane('A',Brole,Arole,true)
local B,br,bc,bi,bo,_,bf=lane('B',Arole,Brole,false)
local g,img=W.Algebra.close({A,B},{{ao,bi},{bo,ai}})
T.eq(#g:faces(),1,'cross-locality support SCC contracts to one joint occurrence')
local jf=img[1].faces[af]; T.eq(jf,img[2].faces[bf]); T.ok(jf)
local jr=img[1].membranes[ar]; T.eq(W.Geometry.membrane(jf),jr,'joint occurrence lives at least common enclosing membrane')
T.eq(jr,img[2].membranes[br],'cut unifies roots')
T.ok(img[1].membranes[ac]~=img[2].membranes[bc],'sibling face localities remain distinct below joint context')
T.ok(g:grounded())
return T.count()
