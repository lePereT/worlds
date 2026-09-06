local S=require('tests.support')
local T=require('tests.process_theory_support')
local G,A=S.G,S.A
local b=G.builder(); local K=b:membrane(nil,'proc'); local p=b:point(K,'Fn'); b:strand(K,'Call',{p}); local g=b:finish()
local q=G.builder(); local D=q:membrane(nil,'proc'); local x=q:point(D,'Fn'); q:strand(D,'Call',{x}); local pat=q:finish()
local xs=A.all(g,{K},pat); S.eq(#xs,1)
local c=T.classify(xs,function() return 'unknown' end)
S.eq(#c.accepted,0); S.eq(#c.rejected,0); S.eq(#c.unknown,1)
print('ok 45_theory_unknown_admissibility')
