local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

local b=G.builder(); local K=b:membrane(nil,'place','K'); local X=b:point(K,'X'); b:strand(K,'A',{X},'a'); local base=b:finish()

local function step(in_sort,out_sort,face_sort)
  local p=G.builder(); local D=p:membrane(nil,'place'); local Q=p:point(D,'X'); local i=p:strand(D,in_sort,{Q}); local o=p:strand(D,out_sort,{Q}); p:face(D,face_sort,{i},{o}); return p:finish(),o
end
local P,po=step('A','B','ab')
local Q,qo=step('B','C','bc')
local R,ro=step('C','D','cd')

local function apply(g,pat)
  local w=A.one(g,{K},pat); S.ok(w); return A.glue(w)
end
local seq=apply(apply(base,P),Q)

-- Fusing two causal steps into one open geometry must produce the same exact
-- occurrence geometry as composing them sequentially.
local f=G.builder(); local D=f:membrane(nil,'place'); local q=f:point(D,'X');
local a=f:strand(D,'A',{q}); local mid=f:strand(D,'B',{q}); local c=f:strand(D,'C',{q});
f:face(D,'ab',{a},{mid}); f:face(D,'bc',{mid},{c}); local fused=f:finish()
local once=apply(base,fused)
S.ok(Same(seq,once),'sequential composition must agree with fused geometry')

-- Three-step fusion is independent of grouping.
local seq3=apply(seq,R)
local h=G.builder(); local H=h:membrane(nil,'place'); local x=h:point(H,'X');
local a0=h:strand(H,'A',{x}); local b0=h:strand(H,'B',{x}); local c0=h:strand(H,'C',{x}); local d0=h:strand(H,'D',{x});
h:face(H,'ab',{a0},{b0}); h:face(H,'bc',{b0},{c0}); h:face(H,'cd',{c0},{d0}); local fused3=h:finish()
S.ok(Same(seq3,apply(base,fused3)),'three-step fusion mismatch')

-- Empty geometry is the identity extension.
local empty=G.builder():finish()
local ew=A.one(base,{K},empty); S.ok(ew)
local ident=A.glue(ew)
S.ok(Same(base,ident),'empty extension must be identity')

print('ok 17_composition_laws')
