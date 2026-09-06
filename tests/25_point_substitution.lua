local S=require('tests.support')
local G,A=S.G,S.A

local function base(shared)
  local b=G.builder(); local K=b:membrane(nil,'place')
  local x=b:point(K,'Value')
  local y=shared and x or b:point(K,'Value')
  b:strand(K,'Left',{x}); b:strand(K,'Right',{y})
  return b:finish(),K,x,y
end

-- Two distinct pattern Points are independent variables, not a disequality
-- assertion. A generic binary operation must accept both f(x,x) and f(x,y).
local p=G.builder(); local D=p:membrane(nil,'place')
local a=p:point(D,'Value'); local b=p:point(D,'Value')
p:strand(D,'Left',{a}); p:strand(D,'Right',{b})
local generic=p:finish()

local same,K,x=base(true)
local split,K2,u,v=base(false)
S.eq(#A.all(same,{K},generic),1)
S.eq(#A.all(split,{K2},generic),1)

-- Reusing one pattern Point *does* assert literal identity.
local q=G.builder(); local E=q:membrane(nil,'place'); local z=q:point(E,'Value')
q:strand(E,'Left',{z}); q:strand(E,'Right',{z})
local identity=q:finish()
S.eq(#A.all(same,{K},identity),1)
S.eq(#A.all(split,{K2},identity),0)

print('ok 25_point_substitution')
