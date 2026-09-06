local S=require('tests.support')
local G=S.G
local b=G.builder(); local K=b:membrane(nil,'float')
local pz=b:point(K,'F64'); local nz=b:point(K,'F64'); local g=b:finish()
local bits={[pz]='0000000000000000',[nz]='8000000000000000'}
local number={[pz]=0.0,[nz]=-0.0}
S.ok(number[pz]==number[nz],'numeric observation identifies signed zero')
S.no(bits[pz]==bits[nz],'bit observation distinguishes signed zero')
S.no(pz==nz,'Worlds preserves witness identity independently of either observation')
print('ok 30_float_observations')
