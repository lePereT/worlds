local S=require('tests.support')
local G=S.G
local b=G.builder(); local K=b:membrane(nil,'logic')
local p=b:point(K,'ProofP'); local q=b:point(K,'ProofP'); b:finish()
local proposition={[p]='P',[q]='P'}
local proof_irrelevant=function(a,b) return proposition[a]==proposition[b] end
local proof_relevant=function(a,b) return a==b end
S.ok(proof_irrelevant(p,q)); S.no(proof_relevant(p,q))
print('ok 31_proof_relevance')
