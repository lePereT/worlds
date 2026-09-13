package.path='./src/?.lua;./src/?/init.lua;'..package.path

-- The semantic centre must load and execute Geometry laws without loading the
-- disposable acceleration layer.  This is an architectural release gate: the
-- edge may be deleted and the centre still has a complete Geometry meaning.
package.loaded['worlds._compiled']=nil
package.loaded['worlds.query_factory']=nil
package.loaded['worlds.query_engine']=nil
local Kernel=require('worlds._kernel')
local W=Kernel.public
assert(package.loaded['worlds._compiled']==nil,'verified centre loaded disposable acceleration')
assert(package.loaded['worlds.query_factory']==nil,'verified centre eagerly loaded matching implementation')

local b=W.builder(); local m=b:membrane(nil,'m'); local p=b:point(m,'p'); local s=b:strand(m,{p},'s'); local g=b:finish()
assert(package.loaded['worlds._compiled']==nil,'Geometry construction loaded acceleration')
assert(g:is_terminal(s) and g:is_input(s),'centre Geometry incidence failed')
assert(W.boundary(g)==g,'already-normal boundary must be idempotent')
assert(package.loaded['worlds._compiled']==nil,'boundary loaded acceleration')

local c=W.builder(); local n=c:membrane(nil,'n'); local q=c:point(n,'q'); local t=c:strand(n,{q},'t'); local h=c:finish()
local joined=W.join({g,h},{})
assert(W.is_geometry(joined),'centre join failed')
assert(#joined:egress()==2,'centre join changed open boundary')
assert(package.loaded['worlds._compiled']==nil,'join loaded acceleration')

print('PASS verified centre without acceleration')
