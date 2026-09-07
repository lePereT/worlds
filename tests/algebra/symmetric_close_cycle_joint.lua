local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); local RA=vb:point(vm,'A'); local RB=vb:point(vm,'B'); local RC=vb:point(vm,'C'); vb:finish()
local function lane(ins,out,name,with_control)
  local b=W.Geometry.builder(); local m=b:membrane(nil,name); local x=b:point(m,'x'); local cyc=b:strand(m,{ins,x}); local inputs={cyc}; local ctl
  if with_control then ctl=b:strand(m,{Control}); inputs[#inputs+1]=ctl end
  local outst=b:strand(m,{out,x}); local f=b:face(m,inputs,{outst},name); return b:finish(),cyc,outst,ctl,f,x
end
local A,ai,ao,actl,af,ax=lane(RC,RA,'A',true)
local B,bi,bo,_,bf,bx=lane(RA,RB,'B',false)
local Cg,ci,co,_,cf,cx=lane(RB,RC,'C',false)
local g,img,meta=W.Algebra.close({A,B,Cg},{{ao,bi},{bo,ci},{co,ai}})
T.eq(#g:faces(),1,'cyclic support SCC contracts to one joint Face'); T.eq(#g:membranes(),1); T.eq(img[1].faces[af],img[2].faces[bf]); T.eq(img[2].faces[bf],img[3].faces[cf]); T.eq(img[1].points[ax],img[2].points[bx]); T.eq(img[2].points[bx],img[3].points[cx]); T.ok(g:grounded(),'external Control grounds the joint occurrence')
local ctl=img[1].strands[actl]; T.ok(ctl and g:is_input(ctl)); T.eq(#g:strands(),1,'all cycle support Strands disappear inside joint occurrence')
local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'root'); local live_ctl=sb:strand(sm,{Control}); local live=W.Operational.from_geometry(sb:finish())
local w=W.Operational.one(live,g,{strands={[ctl]=live_ctl}}); T.ok(w); W.Operational.commit(w); T.ok(not live:contains(live_ctl))
return T.count()
