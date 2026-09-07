local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Role=vb:point(vm,'Role'); vb:finish()
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local child=b:membrane(root,'child'); local hidden=b:strand(child,{Role},'hidden'); local live=W.Operational.from_geometry(b:finish())
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local i=p:strand(pm,{Role},'in'); local pat=p:finish()
-- There is deliberately no membrane-selection input to attachment. Knowledge of
-- `child` cannot enumerate its authority. With no offered/anchored Strand the
-- open input is unsatisfied.
T.eq(W.Operational.one(live,pat,{}),nil)
-- Explicit live authority is sufficient, without any membrane capability.
local w=W.Operational.one(live,pat,{strands={[i]=hidden}}); T.ok(w)
return T.count()
