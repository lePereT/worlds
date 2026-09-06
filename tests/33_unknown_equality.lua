local S=require('tests.support'); local TS=require('tests.theory_support')
local G=S.G
local b=G.builder(); local K=b:membrane(nil,'functions')
local f=b:point(K,'Function'); local g=b:point(K,'Function'); b:finish()
local function undecidable(a,b)
  if a==b then return true end
  return nil
end
S.eq(TS.tri_eq(f,f,undecidable),'equal')
S.eq(TS.tri_eq(f,g,undecidable),'unknown')
S.no(f==g)
print('ok 33_unknown_equality')
