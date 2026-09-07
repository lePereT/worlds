local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local R=vb:point(vm,'R'); vb:finish()
local b=W.Geometry.builder(); local m=b:membrane(nil,'root'); for _=1,60 do b:strand(m,{R}) end; local live=W.Operational.from_geometry(b:finish())
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local a=p:strand(pm,{R}); local b2=p:strand(pm,{R}); local c=p:strand(pm,{R}); local out=p:strand(pm,{R}); p:face(pm,{a,b2,c},{out}); local pat=p:finish()
local q=W.Operational.query(live,pat,{offers=live:offers()}); local k=q:step(1); T.eq(k,'Unknown'); local hit
while true do local kk,w=q:step(4); if kk=='Hit' then hit=w; break elseif kk=='Retry' then break end end
T.ok(hit); T.ok(q:stats().steps < 100)
return T.count()
