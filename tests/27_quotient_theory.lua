local S=require('tests.support')
local G=S.G
local b=G.builder(); local K=b:membrane(nil,'math')
local p1=b:point(K,'Mod3'); local p4=b:point(K,'Mod3'); local p7=b:point(K,'Mod3')
local g=b:finish()
local value={[p1]=1,[p4]=4,[p7]=7}
local function eq(a,b) return value[a]%3==value[b]%3 end
S.no(p1==p4); S.no(p4==p7)
S.ok(eq(p1,p4)); S.ok(eq(p4,p7)); S.ok(eq(p1,p7))
-- No canonical representative is required for the quotient to be meaningful.
S.eq(#g:points(),3)
print('ok 27_quotient_theory')
