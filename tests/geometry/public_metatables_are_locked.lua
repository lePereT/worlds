local W=require('worlds'); local T=require('support')
local G=W.Geometry
local b=G.builder(); local m=b:membrane(nil); local p=b:point(m); local s=b:strand(m,{p}); local g=b:finish()
T.eq(type(getmetatable(p)),'string','carrier metatable must be protected')
T.eq(type(getmetatable(g)),'string','Geometry metatable must be protected')
local q=W.Cut.query(g,{offers={s}}); T.eq(type(getmetatable(q)),'string','Cut Query metatable must be protected')
local live=W.Operational.from_geometry(g); T.eq(type(getmetatable(live)),'string','Boundary metatable must be protected')
return T.count()
