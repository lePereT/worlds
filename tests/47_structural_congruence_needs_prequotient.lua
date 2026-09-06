local S=require('tests.support')
local G,A=S.G,S.A

-- A toy scope/structural-congruence process semantics. One process has a
-- semantically transparent membrane around Send; another is its flattened
-- representative. Exact Worlds keeps the membrane distinction.
local function scoped()
  local b=G.builder(); local R=b:membrane(nil,'proc'); local I=b:membrane(R,'transparent'); local c=b:point(R,'Chan')
  b:strand(I,'Send',{c}); b:strand(R,'Recv',{c}); return b:finish(),R,I
end
local function flat()
  local b=G.builder(); local R=b:membrane(nil,'proc'); local c=b:point(R,'Chan')
  b:strand(R,'Send',{c}); b:strand(R,'Recv',{c}); return b:finish(),R
end
local p=G.builder(); local D=p:membrane(nil,'proc'); local c=p:point(D,'Chan')
local s=p:strand(D,'Send',{c}); local r=p:strand(D,'Recv',{c}); local o=p:strand(D,'Done',{c}); p:face(D,'rendezvous',{s,r},{o}); local pat=p:finish()
local gs,R,I=scoped(); local gf,F=flat()
S.eq(#A.all(gs,{R,I},pat),0,'post-filter cannot recover a structurally absent candidate')
S.eq(#A.all(gf,{F},pat),1,'a Theory-normalised/congruent representative admits the process')
-- This is the counterexample to the strongest separation claim: some process
-- theories need equality/congruence around Att, not merely a predicate after it.
print('ok 47_structural_congruence_needs_prequotient')
