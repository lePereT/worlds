local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local R=vb:point(vm,'R'); vb:finish()
local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'s'); local a=sb:point(sm,'a'); local b=sb:point(sm,'b'); local sa=sb:strand(sm,{R,a}); local sb2=sb:strand(sm,{R,b}); local source=sb:finish()
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local x=p:point(pm,'x'); local y=p:point(pm,'y'); local i1=p:strand(pm,{R,x}); local i2=p:strand(pm,{R,y}); local o=p:strand(pm,{R,x}); p:face(pm,{i1,i2},{o}); local pat=p:finish()
-- Cut itself can close only one selected ingress and leaves the other entirely
-- outside the relation.  This is the primitive used by detached composition.
local cuts=W.Cut.all(pat,{demands={i1},offers={sa,sb2}})
T.eq(#cuts,2); for _,c in ipairs(cuts) do T.ok(c:strand(i1)); T.eq(c:strand(i2),nil); T.ok(c:point(x)) end
-- Complete Live attachment uses the same Cut solver but demands every ingress.
local live=W.Operational.from_geometry(source)
local att=W.Operational.all(live,pat,{offers={sa,sb2}})
T.eq(#att,2,'two injective assignments for the two labelled demands')
for _,w in ipairs(att) do T.ok(w:cut()); T.ok(w:strand(i1)); T.ok(w:strand(i2)) end
return T.count()
