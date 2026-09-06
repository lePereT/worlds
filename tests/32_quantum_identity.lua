local S=require('tests.support'); local TS=require('tests.theory_support')
local G=S.G
local b=G.builder(); local K=b:membrane(nil,'lab')
local q1=b:point(K,'QSystem'); local q2=b:point(K,'QSystem'); local q3=b:point(K,'QSystem'); b:finish()
local state={[q1]={1,0},[q2]={1,0},[q3]={-1,0}}
S.no(q1==q2,'distinct physical systems remain distinct Points')
S.ok(TS.projective_eq(state[q1],state[q2]),'same state on distinct systems')
S.ok(TS.projective_eq(state[q1],state[q3]),'global phase is a theory quotient')
print('ok 32_quantum_identity')
