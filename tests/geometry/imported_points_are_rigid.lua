local W=require('worlds'); local T=require('support')
-- Semantic vocabulary is an independently constructed geometry. Its Points are
-- exact identities when imported into another patch.
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'vocab'); local Req=vb:point(vm,'Request'); local Done=vb:point(vm,'Done'); vb:finish()
local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'state'); local x=sb:point(sm,'x'); local req=sb:strand(sm,{Req,x},'req'); local sg=sb:finish(); local live=W.Operational.from_geometry(sg)
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local px=p:point(pm,'x'); local i=p:strand(pm,{Req,px},'in'); local o=p:strand(pm,{Done,px},'out'); p:face(pm,{i},{o},'finish'); local pat=p:finish()
local w=W.Operational.one(live,pat,{offers={req}}); T.ok(w); T.eq(w:point(px),x)
local live2,img=W.Operational.commit(w); T.ok(not live2:contains(req)); local out=img.strands[o]; T.ok(live2:contains(out)); T.eq(W.Geometry.points(out)[1],Done); T.eq(W.Geometry.points(out)[2],x)
return T.count()
