local W=require('worlds'); local T=require('support')
local G=W.Geometry
local vb=G.builder(); local vm=vb:membrane(nil,'v'); local Need=vb:point(vm,'Need'); local Other=vb:point(vm,'Other'); vb:finish()
local sb=G.builder(); local sm=sb:membrane(nil,'s'); local offers={}
for i=1,100 do offers[i]=sb:strand(sm,{Other}) end
offers[101]=sb:strand(sm,{Need}); sb:finish()
local pb=G.builder(); local pm=pb:membrane(nil,'p'); local input=pb:strand(pm,{Need}); local pat=pb:finish()
local q=W.Cut.query(pat,{offers=offers})
local k=q:step(100); T.eq(k,'Unknown','100 incompatible examinations must consume the full work budget'); T.eq(q:stats().steps,100)
local k2,c=q:step(1); T.eq(k2,'Hit'); T.ok(c); T.eq(q:stats().steps,101)
return T.count()
