local S=require('tests.support')
local G,A=S.G,S.A

-- Base authority uses an identity located in an enclosing membrane. Identity
-- does not locate authority.
local b=G.builder()
local Outer=b:membrane(nil,'place','outer')
local K=b:membrane(Outer,'place','K')
local X=b:point(Outer,'X','x')
local r=b:strand(K,'R',{X},'r')
local base=b:finish()

-- A direct local transition: no fresh World is needed for causal occurrence.
local p=G.builder()
local P=p:membrane(nil,'place','outer-pattern')
local D=p:membrane(P,'place','D')
local q=p:point(P,'X','q')
local i=p:strand(D,'R',{q},'in')
local o=p:strand(D,'R',{q},'out')
p:face(D,'step',{i},{o},'step')
local pat=p:finish()

local ws=A.all(base,{K},pat)
S.eq(#ws,1)
S.eq(ws[1]:membrane(D),K)
S.eq(ws[1]:point(q),X)
S.eq(ws[1]:strand(i),r)

local next,image=A.glue(ws[1])
S.eq(#base:faces(),0,'base is immutable')
S.eq(#next:faces(),1)
S.eq(next:cell(image.strands[o]).membrane,K)

-- Point demand alone cannot invent locality. A fresh membrane creates fresh identity.
local z=G.builder(); local Z=z:membrane(nil,'place'); z:point(Z,'X','fresh'); local zero=z:finish()
local w=A.one(base,{K},zero)
S.ok(w)
S.eq(w:membrane(Z),nil)
local gz,iz=A.glue(w)
local fresh=gz:cell(iz.points[zero:find('point','fresh')])
S.no(fresh.id==X)
print('ok 03_attachment')
