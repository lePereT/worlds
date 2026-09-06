local S=require('tests.support')
local G,A=S.G,S.A

-- Equal/extentionally interchangeable values do not merge scarce authority.
local b=G.builder(); local K=b:membrane(nil,'proc'); local p=b:point(K,'Value')
local one=b:strand(K,'Token',{p}); local g=b:finish()

local q=G.builder(); local D=q:membrane(nil,'proc'); local x=q:point(D,'Value'); local y=q:point(D,'Value')
q:strand(D,'Token',{x}); q:strand(D,'Token',{y}); local needs_two=q:finish()
S.eq(#A.all(g,{K},needs_two),0,'one scarce Strand cannot satisfy two demands even if Point variables may alias')
print('ok 43_theory_does_not_merge_authority')
