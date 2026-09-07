local W=require('worlds'); local T=require('support')
-- Merely naming/viewing an empty membrane cannot authorise spontaneous birth.
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local g=b:finish(); local live=W.Operational.from_geometry(g)
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local x=p:point(pm,'x'); local o=p:strand(pm,{x},'out'); p:face(pm,{}, {o}, 'birth'); local pat=p:finish()
T.ok(not pat:grounded()); T.eq(W.Operational.one(live,pat,{offers={}}),nil)
return T.count()
