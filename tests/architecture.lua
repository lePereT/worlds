package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0; local function ok(x,m) n=n+1; assert(x,m or ('architecture assertion '..n)) end
ok(W.Geometry and W.Cut and W.Algebra and W.Operational,'four public namespaces exist')
ok(W.Boundary==nil and W.Step==nil,'operational projection is not a semantic peer in the public API')
local keys={}; for k in pairs(W) do keys[k]=true end
ok(keys.Geometry and keys.Cut and keys.Algebra and keys.Operational)
local count=0; for _ in pairs(keys) do count=count+1 end; ok(count==4,'public API should remain deliberately small')
local b=W.Geometry.builder(); local m=b:membrane(nil,'m'); local p=b:point(m,'p'); local s=b:strand(m,{p},'s'); local g=b:finish()
ok(rawget(m,'sort')==nil and rawget(p,'sort')==nil and rawget(s,'sort')==nil,'semantic carriers expose no sort field')
local live=W.Operational.from_geometry(g); ok(type(live.offers)=='function' and type(live.contains)=='function' and type(live.size)=='function')
ok(live.select==nil and live.view==nil,'operational state has no membrane authority-discovery API')
print('PASS architecture',n,'assertions')
