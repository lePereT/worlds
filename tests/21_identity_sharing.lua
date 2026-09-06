local S=require('tests.support')
local G,A=S.G,S.A

-- Base: two independent authority occurrences share one semantic identity.
local b=G.builder(); local K=b:membrane(nil,'p'); local X=b:point(K,'X'); local a=b:strand(K,'A',{X}); local c=b:strand(K,'C',{X}); local base=b:finish()

-- Pattern explicitly shares one Point: it must match the shared identity.
local p=G.builder(); local D=p:membrane(nil,'p'); local Q=p:point(D,'X'); p:strand(D,'A',{Q}); p:strand(D,'C',{Q}); local shared=p:finish()
S.eq(#A.all(base,{K},shared),1)

-- Two distinct pattern Points are independent variables and may alias X.
local q=G.builder(); local E=q:membrane(nil,'p'); local Q1=q:point(E,'X'); local Q2=q:point(E,'X'); q:strand(E,'A',{Q1}); q:strand(E,'C',{Q2}); local distinct=q:finish()
S.eq(#A.all(base,{K},distinct),1)

-- Conversely distinct actual identities cannot satisfy a shared pattern Point.
local c0=G.builder(); local M=c0:membrane(nil,'p'); local Y1=c0:point(M,'X'); local Y2=c0:point(M,'X'); c0:strand(M,'A',{Y1}); c0:strand(M,'C',{Y2}); local split=c0:finish()
S.eq(#A.all(split,{M},shared),0)

print('ok 21_identity_sharing')
