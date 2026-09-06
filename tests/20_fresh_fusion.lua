local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

local b=G.builder(); local K=b:membrane(nil,'place'); local GateP=b:point(K,'Gate'); b:strand(K,'Admission',{GateP}); local base=b:finish()

-- First geometry creates a fresh child carrying fresh identity/authority.
local p=G.builder(); local D=p:membrane(nil,'place'); local H=p:membrane(D,'worker'); local gp=p:point(D,'Gate'); local gate=p:strand(D,'Admission',{gp}); local hp=p:point(H,'Worker'); local ready=p:strand(H,'Ready',{hp}); p:face(D,'spawn',{gate},{ready}); local spawn=p:finish()
local w1=A.one(base,{K},spawn); S.ok(w1)
local g1,i1=A.glue(w1); local h1=i1.membranes[H]

-- Second geometry acts inside the fresh child.
local q=G.builder(); local U=q:membrane(nil,'worker'); local up=q:point(U,'Worker'); local rin=q:strand(U,'Ready',{up}); local rout=q:strand(U,'Running',{up}); q:face(U,'start',{rin},{rout}); local start=q:finish()
local w2=A.one(g1,{h1},start); S.ok(w2)
local sequential=A.glue(w2)

-- Same causal geometry supplied at once. No virtual/residual rule should be
-- necessary to make this agree with the sequential immutable development.
local f=G.builder(); local FD=f:membrane(nil,'place'); local FH=f:membrane(FD,'worker'); local fgp=f:point(FD,'Gate'); local fg=f:strand(FD,'Admission',{fgp}); local fp=f:point(FH,'Worker'); local fr=f:strand(FH,'Ready',{fp}); local run=f:strand(FH,'Running',{fp}); f:face(FD,'spawn',{fg},{fr}); f:face(FH,'start',{fr},{run}); local fused=f:finish()
local fw=A.one(base,{K},fused); S.ok(fw)
local once=A.glue(fw)
S.ok(Same(sequential,once),'fresh create/use fusion mismatch')

print('ok 20_fresh_fusion')
