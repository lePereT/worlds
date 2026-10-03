local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local C=require('speculation.showcases.theory.knowledge_contract.corelation')
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
local function same(a,b,msg) ok(R.equal(a,b),msg) end

-- The exact counterexample that defeats composition of partial carrier images.
local S={'s1','s2','s3'}
 local M={'m1','m2','m3'}
 local T={'t1','t2'}
local k=R.from_rows(S,{'001','010','011','100','111'})
local c1=C.new(S,M,{{'s1','m1'},{'s3','m1'},{'s2','m2'}})
-- m1 is hidden by the second stage; m2 survives as t1; m3 survives as t2.
local c2=C.new(M,T,{{'m2','t1'},{'m3','t2'}})
local staged=C.transport(C.transport(k,c1),c2)
local composite=C.compose(c1,c2)
local direct=C.transport(k,composite)
same(staged,direct,'corelation composition lost hidden quotient information')

-- The composite retains s1=s3 as a hidden equivalence class even though neither
-- has a target image. That is exactly what a partial map cannot express.
ok(composite.classes.s1==composite.classes.s3,'composite forgot hidden source equivalence')

-- Identity-like and simple quotient/hide examples.
local id=C.new(S,S,{{'s1','s1'},{'s2','s2'},{'s3','s3'}})
same(C.transport(k,id),k,'corelation identity changed knowledge')
local q=C.new({'a','b'},{'t'},{{'a','t'},{'b','t'}})
local conflict=R.relation({'a','b'},function(v) return v.a~=v.b end)
same(C.transport(conflict,q),R.bottom({'t'}),'corelation quotient did not expose contradiction')

print('corelation transport: '..n..' assertions passed')
