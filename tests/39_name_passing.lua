local S=require('tests.support')
local G,A=S.G,S.A

-- A π-like name-passing skeleton. The received name is an exact Point and is
-- propagated into later authority by ordinary substitution/gluing.
local b=G.builder(); local K=b:membrane(nil,'proc'); local n=b:point(K,'Name')
b:strand(K,'RecvName',{n}); local g=b:finish()

local p=G.builder(); local D=p:membrane(nil,'proc'); local x=p:point(D,'Name')
local i=p:strand(D,'RecvName',{x}); local o=p:strand(D,'UseName',{x}); p:face(D,'receive',{i},{o}); local pat=p:finish()
local att=A.one(g,{K},pat); S.ok(att); S.eq(att:point(x),n)
local g2,image=A.glue(att); S.eq(g2:cell(image.strands[o]).points[1],n)
print('ok 39_name_passing')
