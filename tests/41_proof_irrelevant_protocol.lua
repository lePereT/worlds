local S=require('tests.support')
local T=require('tests.process_theory_support')
local G,A=S.G,S.A

local b=G.builder(); local K=b:membrane(nil,'proc')
local pa=b:point(K,'Proof'); local pb=b:point(K,'Proof')
b:strand(K,'Offer',{pa}); b:strand(K,'Accept',{pb}); local g=b:finish(); local proposition={[pa]='P',[pb]='P'}

local p=G.builder(); local D=p:membrane(nil,'proc'); local a=p:point(D,'Proof'); local b2=p:point(D,'Proof')
local o=p:strand(D,'Offer',{a}); local r=p:strand(D,'Accept',{b2}); local d=p:strand(D,'Done',{a})
p:face(D,'proof-irrelevant-rendezvous',{o,r},{d}); local pat=p:finish()
local xs=A.all(g,{K},pat); S.eq(#xs,1)
local classified=T.classify(xs,function(att) return proposition[att:point(a)]==proposition[att:point(b2)] end)
S.eq(#classified.accepted,1)

-- Literal proof identity is a different process semantics and remains expressible.
local q=G.builder(); local E=q:membrane(nil,'proc'); local z=q:point(E,'Proof')
q:strand(E,'Offer',{z}); q:strand(E,'Accept',{z}); local exact=q:finish()
S.eq(#A.all(g,{K},exact),0)
print('ok 41_proof_irrelevant_protocol')
