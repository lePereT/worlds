local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); vb:finish()
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local child=b:membrane(root,'child'); local cid=b:point(child,'cid'); local ctl=b:strand(root,{Control},'ctl'); local h=b:strand(root,{cid},'handle'); local live=W.Operational.from_geometry(b:finish())
-- Control causally grounds the Face.  The child handle is deliberately only a
-- dangling open input: mentioning it must not grant reusable modification
-- authority over child without consuming/reissuing that authority.
local p=W.Geometry.builder(); local pr=p:membrane(nil,'pr'); local pc=p:membrane(pr,'pc'); local x=p:point(pc,'x'); local ci=p:strand(pr,{Control},'ci'); local co=p:strand(pr,{Control},'co'); local dangling=p:strand(pr,{x},'dangling'); local st=p:strand(pc,{x},'st'); p:face(pr,{ci},{co,st},'make'); local pat=p:finish()
local w=W.Operational.one(live,pat,{strands={[ci]=ctl,[dangling]=h}})
T.eq(w,nil,'unconsumed boundary mention must not authorise child modification')
T.ok(live:contains(h),'handle remains live')
return T.count()
