local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local K=b:membrane(nil,'place'); local gatep=b:point(K,'Gate'); local y=b:point(K,'Y'); local gate=b:strand(K,'Gate',{gatep}); local base=b:finish()

-- Once Strand authority binds a membrane, Points in that pattern membrane are
-- identity demands. Point identity itself still does not determine locality.
local p=G.builder(); local D=p:membrane(nil,'place'); local pg=p:point(D,'Gate'); local py=p:point(D,'Y'); local gi=p:strand(D,'Gate',{pg}); local out=p:strand(D,'Out',{py}); p:face(D,'observe',{gi},{out}); local pat=p:finish()
local w=A.one(base,{K},pat); S.ok(w); S.eq(w:point(py),y)

-- Remove the visible Y identity: the same authority is insufficient.
local c=G.builder(); local K2=c:membrane(nil,'place'); local gp2=c:point(K2,'Gate'); c:strand(K2,'Gate',{gp2}); local missing=c:finish()
S.eq(#A.all(missing,{K2},pat),0)

-- Distinct Point nodes in a pattern are independent identity variables, not a
-- disequality assertion. They may bind to the same boundary Point. Reusing one
-- pattern Point is what asserts literal identity.
local d=G.builder(); local M=d:membrane(nil,'place'); local one=d:point(M,'Y'); local bind=d:point(M,'Gate'); d:strand(M,'Gate',{bind}); local onlyone=d:finish()
local q=G.builder(); local Q=q:membrane(nil,'place'); local qg=q:point(Q,'Gate'); local y1=q:point(Q,'Y'); local y2=q:point(Q,'Y'); q:strand(Q,'Gate',{qg}); local o1=q:strand(Q,'A',{y1}); local o2=q:strand(Q,'B',{y2}); q:face(Q,'f',{}, {o1,o2}); local two=q:finish()
S.eq(#A.all(onlyone,{M},two),1)

print('ok 15_identity')
