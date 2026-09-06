local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

local function geom(reverse)
  local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X'); local Y=b:point(K,'Y');
  b:strand(K,'Pair',reverse and {Y,X} or {X,Y}); return b:finish()
end
S.no(Same(geom(false),geom(true)),'ordered Point boundary collapsed')

local base=geom(false); local K=base:membranes()[1]
local p=G.builder(); local D=p:membrane(nil,'p'); local X=p:point(D,'X'); local Y=p:point(D,'Y'); p:strand(D,'Pair',{Y,X}); local reversed=p:finish()
S.eq(#A.all(base,{K},reversed),0,'attachment ignored ordered Point incidence')

-- Face input order is also semantic.
local function facegeom(reverse)
  local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X');
  local a=b:strand(K,'A',{X}); local c=b:strand(K,'C',{X}); local o=b:strand(K,'O',{X});
  b:face(K,'join',reverse and {c,a} or {a,c},{o}); return b:finish()
end
S.no(Same(facegeom(false),facegeom(true)),'ordered Face input boundary collapsed')

print('ok 24_ordered_incidence')
