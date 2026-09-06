local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local K=b:membrane(nil,'place'); local X=b:point(K,'X'); local r=b:strand(K,'R',{X}); local base=b:finish()

-- Explicit copy is just causal geometry. Worlds does not need a Copy carrier/kind.
local c=G.builder(); local D=c:membrane(nil,'place'); local Q=c:point(D,'X'); local i=c:strand(D,'R',{Q}); local o1=c:strand(D,'R',{Q}); local o2=c:strand(D,'R',{Q}); c:face(D,'duplicate',{i},{o1,o2}); local copy=c:finish()
local cw=A.one(base,{K},copy); S.ok(cw)
local gc,im=A.glue(cw)
S.ok(gc:is_terminal(im.strands[o1])); S.ok(gc:is_terminal(im.strands[o2])); S.no(gc:is_terminal(r))

-- But there is no implicit copy: two demanded Strands cannot bind one scarce offer.
local d=G.builder(); local D1=d:membrane(nil,'place'); local D2=d:membrane(nil,'place'); local P1=d:point(D1,'X'); local P2=d:point(D2,'X'); d:strand(D1,'R',{P1}); d:strand(D2,'R',{P2}); local twice=d:finish()
S.eq(#A.all(base,{K},twice),0)

-- Discard is likewise ordinary geometry: a Face with no outputs.
local x=G.builder(); local XD=x:membrane(nil,'place'); local XP=x:point(XD,'X'); local xi=x:strand(XD,'R',{XP}); x:face(XD,'discard',{xi},{}); local discard=x:finish()
local dw=A.one(base,{K},discard); S.ok(dw)
local gd=A.glue(dw)
S.no(gd:is_terminal(r))

-- Shared Point identity does not create conflict between distinct authority.
local j=G.builder(); local J=j:membrane(nil,'place'); local Joint=j:point(J,'Joint'); local a=j:strand(J,'A',{Joint}); local bb=j:strand(J,'B',{Joint}); local joint=j:finish()
local function op(sort)
  local p=G.builder(); local m=p:membrane(nil,'place'); local q=p:point(m,'Joint'); local i=p:strand(m,sort,{q}); local o=p:strand(m,sort,{q}); p:face(m,'op',{i},{o}); return p:finish()
end
local OA,OB=op('A'),op('B')
local ja=A.glue(A.one(joint,{J},OA))
local jab=A.glue(A.one(ja,{J},OB))
local jb=A.glue(A.one(joint,{J},OB))
local jba=A.glue(A.one(jb,{J},OA))
S.ok(S.Worlds.same(jab,jba))

print('ok 08_resources')
