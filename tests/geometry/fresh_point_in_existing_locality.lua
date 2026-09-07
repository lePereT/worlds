local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); local Obj=vb:point(vm,'Obj'); vb:finish()
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local ctl=b:strand(root,{Control}); local live=W.Operational.from_geometry(b:finish())
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local i=p:strand(pm,{Control}); local o=p:strand(pm,{Control}); local x=p:point(pm,'fresh-x'); local a=p:strand(pm,{Obj,x}); local c=p:strand(pm,{Obj,x}); p:face(pm,{i},{o,a,c}); local pat=p:finish()
local w=W.Operational.one(live,pat,{strands={[i]=ctl}}); T.ok(w,'fresh identity in mapped existing locality should be lawful')
local _,img=W.Operational.commit(w); T.ok(img.points[x]); T.ok(img.strands[a] and img.strands[c]);
local ap=W.Geometry.points(img.strands[a]); local cp=W.Geometry.points(img.strands[c]); T.eq(ap[2],img.points[x]); T.eq(cp[2],img.points[x]); T.eq(ap[2],cp[2],'one local existential must realise as one exact identity')
return T.count()
