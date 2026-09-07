local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local R=vb:point(vm,'R'); vb:finish()
local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'s'); local p1=sb:point(sm,'p1'); local p2=sb:point(sm,'p2'); local s1=sb:strand(sm,{R,p1}); local s2=sb:strand(sm,{R,p2}); local source=sb:finish(); local live=W.Operational.from_geometry(source)
local pb=W.Geometry.builder(); local pm=pb:membrane(nil,'p'); local x=pb:point(pm,'x'); local y=pb:point(pm,'y'); local i1=pb:strand(pm,{R,x}); local i2=pb:strand(pm,{R,y}); local o=pb:strand(pm,{R,x}); pb:face(pm,{i1,i2},{o}); local pat=pb:finish()
local cuts=W.Cut.all(pat,{offers={s1,s2}}); local atts=W.Operational.all(live,pat,{offers={s1,s2}})
T.eq(#cuts,#atts); T.eq(#cuts,2)
for _,w in ipairs(atts) do local c=w:cut(); T.ok(c:strand(i1)); T.ok(c:strand(i2)); T.ok(c:point(x)); T.ok(c:point(y)) end
return T.count()
