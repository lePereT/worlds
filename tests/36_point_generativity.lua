local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local K=b:membrane(nil,'eval'); local x=b:point(K,'Int'); local sin=b:strand(K,'Input',{x}); local base=b:finish()

-- A fresh Point cannot be silently inserted into an already-bound membrane: a
-- Point in mapped membrane D is an identity variable and must bind there.
local bad=G.builder(); local D=bad:membrane(nil,'eval'); local q=bad:point(D,'Int'); local z=bad:point(D,'FreshInt')
local bi=bad:strand(D,'Input',{q}); local bo=bad:strand(D,'Output',{z}); bad:face(D,'compute',{bi},{bo}); local badpat=bad:finish()
S.eq(#A.all(base,{K},badpat),0)

-- Fresh value witnesses are explicit generativity geometry. One fresh membrane
-- may host many produced witnesses while their authority remains in K.
local p=G.builder(); local E=p:membrane(nil,'eval'); local a=p:point(E,'Int'); local i=p:strand(E,'Input',{a})
local V=p:membrane(E,'values'); local r1=p:point(V,'Int'); local r2=p:point(V,'Int')
local o1=p:strand(E,'Out1',{r1}); local o2=p:strand(E,'Out2',{r2}); p:face(E,'compute',{i},{o1,o2}); local pat=p:finish()
local e=A.one(base,{K},pat); S.ok(e)
local nextg,image=A.glue(e)
local v=image.membranes[V]
S.eq(nextg:parent(v),K)
S.eq(nextg:cell(image.points[r1]).membrane,v)
S.eq(nextg:cell(image.points[r2]).membrane,v)
S.eq(nextg:cell(image.strands[o1]).membrane,K)
S.eq(nextg:cell(image.strands[o2]).membrane,K)
print('ok 36_point_generativity')
