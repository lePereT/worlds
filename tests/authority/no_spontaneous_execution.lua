local W=require('worlds'); local T=require('support')
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local out=p:strand(pm,{}); p:face(pm,{}, {out}); local proc=p:finish(); T.ok(not proc:grounded())
local b=W.Geometry.builder(); b:membrane(nil,'root'); local boundary=W.Operational.from_geometry(b:finish()); T.eq(W.Operational.one(boundary,proc,{offers={}}),nil)
return T.count()
