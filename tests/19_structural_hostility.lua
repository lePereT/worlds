local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

-- Causal self-cycle.
S.raises(function()
  local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X'); local s=b:strand(K,'R',{X}); b:face(K,'loop',{s},{s}); b:finish()
end,'causal Face/Strand incidence must be acyclic')

-- Two-Face causal cycle.
S.raises(function()
  local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X');
  local a=b:strand(K,'R',{X}); local c=b:strand(K,'R',{X});
  b:face(K,'f',{a},{c}); b:face(K,'g',{c},{a}); b:finish()
end,'causal Face/Strand incidence must be acyclic')

-- Scarcity is structural even inside one Face.
S.raises(function()
  local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X'); local s=b:strand(K,'R',{X}); b:face(K,'bad',{s,s},{}); b:finish()
end,'same Strand twice')

-- Geometry and exposed cell descriptions are immutable from the public API.
local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X'); b:strand(K,'R',{X}); local g=b:finish()
S.raises(function() g.foo=1 end,'immutable')
local c=g:cell(X); c.sort='changed'; S.eq(g:cell(X).sort,'X','cell() must return descriptive copy')
S.raises(function() b:point(K,'Y') end,'builder already finished')

-- Selection extension is monotone for an existing attachment: adding another
-- membrane cannot invalidate a complete attachment that used only K.
local e=G.builder(); local L=e:membrane(nil,'p'); local Y=e:point(L,'Y'); e:strand(L,'Other',{Y}); local extra=e:finish()
-- Build a two-membrane base directly rather than merging Geometries.
local z=G.builder(); local K2=z:membrane(nil,'p'); local L2=z:membrane(nil,'p'); local x2=z:point(K2,'X'); z:strand(K2,'R',{x2}); local y2=z:point(L2,'Y'); z:strand(L2,'Other',{y2}); local base=z:finish()
local p=G.builder(); local D=p:membrane(nil,'p'); local q=p:point(D,'X'); local i=p:strand(D,'R',{q}); local o=p:strand(D,'R2',{q}); p:face(D,'f',{i},{o}); local pat=p:finish()
local one=A.all(base,{K2},pat); S.eq(#one,1)
local more=A.all(base,{K2,L2},pat); S.eq(#more,1)
local g1=A.glue(one[1]); local g2=A.glue(more[1]); S.ok(Same(g1,g2),'irrelevant boundary exposure changed composition')

-- Names are explanatory only; colours and incidence are semantic.
local function tiny(label,sort)
  local x=G.builder(); local m=x:membrane(nil,'p',label); local q=x:point(m,'X',label); local r=x:strand(m,sort,{q},label); return x:finish()
end
S.ok(Same(tiny('left','R'),tiny('right','R')),'names must alpha-erase')
S.no(Same(tiny('left','R'),tiny('right','S')),'sort change must remain observable')

print('ok 19_structural_hostility')
