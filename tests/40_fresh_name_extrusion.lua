local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local K=b:membrane(nil,'proc'); local trig=b:point(K,'Unit'); b:strand(K,'Go',{trig}); local g=b:finish()

-- Fresh name generated under a fresh membrane, then extruded through an output
-- Strand in the existing process membrane.
local p=G.builder(); local D=p:membrane(nil,'proc'); local u=p:point(D,'Unit'); local go=p:strand(D,'Go',{u})
local V=p:membrane(D,'nu'); local name=p:point(V,'Name'); local out=p:strand(D,'NameOut',{name}); p:face(D,'new',{go},{out}); local pat=p:finish()
local a1=A.one(g,{K},pat); local g1,i1=A.glue(a1)
local out1=g1:cell(i1.strands[out]); local n1=out1.points[1]
S.ok(n1); S.no(n1==name); S.eq(g1:cell(n1).membrane,i1.membranes[V])

-- A second generation from an isomorphic fresh base produces a different exact
-- name, but the two resulting geometries are alpha-isomorphic.
local a2=A.one(g,{K},pat); local g2,i2=A.glue(a2); local n2=g2:cell(i2.strands[out]).points[1]
S.no(n1==n2); S.ok(G.same(g1,g2))
print('ok 40_fresh_name_extrusion')
