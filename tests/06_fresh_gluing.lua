local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

local b=G.builder(); local K=b:membrane(nil,'place','K'); local base=b:finish()

-- A closed geometry can be glued without inventing a host membrane: its
-- fresh root remains a fresh root. Placement must be stated geometrically.
local p=G.builder(); local F=p:membrane(nil,'place','fresh-root'); local P=p:point(F,'X'); local R=p:strand(F,'R',{P}); p:face(F,'create',{}, {R}); local closed=p:finish()
local w=A.one(base,{K},closed); S.ok(w)
local g1,i1=A.glue(w)
S.eq(g1:parent(i1.membranes[F]),nil)

-- Repeating the same possible geometry from the same base creates different
-- occurrences but alpha-equivalent exact geometry.
local w2=A.one(base,{K},closed)
local g2,i2=A.glue(w2)
S.no(i1.membranes[F]==i2.membranes[F])
S.ok(Same(g1,g2))

-- Fresh identity in an existing locality is expressed by a fresh generativity
-- membrane; authority may nevertheless live in the existing membrane.
local src=G.builder(); local M=src:membrane(nil,'place','M'); local gatep=src:point(M,'Gate'); local gate=src:strand(M,'Gate',{gatep}); local g=src:finish()
local q=G.builder(); local D=q:membrane(nil,'place','D'); local Fresh=q:membrane(D,'identity-space');
local gp=q:point(D,'Gate'); local gi=q:strand(D,'Gate',{gp}); local newp=q:point(Fresh,'NewIdentity'); local out=q:strand(D,'Handle',{newp}); q:face(D,'new',{gi},{out}); local make=q:finish()
local mw=A.one(g,{M},make); S.ok(mw)
local gn,im=A.glue(mw)
S.eq(gn:cell(im.strands[out]).membrane,M)
S.no(gn:cell(im.points[newp]).membrane==M)
S.eq(gn:parent(im.membranes[Fresh]),M)

print('ok 06_fresh_gluing')
