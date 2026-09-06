local S=require('tests.support')
local G=S.G
local b=G.builder(); local K=b:membrane(nil,'heap')
local c1=b:point(K,'Cell'); local c2=b:point(K,'Cell')
local v1=b:point(K,'Int'); local v2=b:point(K,'Int')
b:strand(K,'State',{c1,v1}); b:strand(K,'State',{c2,v2})
local g=b:finish(); local intval={[v1]=42,[v2]=42}
S.no(c1==c2,'separate cells are separate names')
S.ok(intval[v1]==intval[v2],'their extensional contents may coincide')
S.eq(#g:points(),4)
print('ok 28_nominal_and_cells')
