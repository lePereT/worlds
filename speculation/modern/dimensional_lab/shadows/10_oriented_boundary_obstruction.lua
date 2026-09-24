package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

-- Give every n-gon Strand its intrinsic Point-row orientation vi -> v(i+1).
-- If Face polarity were an ordinary oriented cellular boundary, outputs would
-- contribute +edge and inputs -edge.  Compute d1 d2 over Z.
local function dd(nv,mask)
  local coeff={}; for i=1,nv do coeff[i]=((mask & (1<<(i-1)))~=0) and -1 or 1 end
  local v={}; for i=1,nv do v[i]=0 end
  for i=1,nv do local j=i%nv+1; v[i]=v[i]-coeff[i]; v[j]=v[j]+coeff[i] end
  return v
end
local function zero(v) for _,x in ipairs(v) do if x~=0 then return false end end return true end

print('1. mod-2 cellularity does not lift to the obvious integer orientation from causal polarity')
for N=3,9 do
  local z=0; local nontrivial=0
  for mask=0,(1<<N)-1 do
    local g=C.cycle(N,mask); if zero(dd(N,mask)) then z=z+1 end
    if mask~=0 and mask~=((1<<N)-1) and zero(dd(N,mask)) then nontrivial=nontrivial+1 end
    ok(g~=nil)
  end
  eq(z,2,'only uniform all-input/all-output signs have d^2=0 over Z')
  eq(nontrivial,0,'no genuine input/output rewrite is an oriented cellular 2-cell under intrinsic Strand orientation')
end

print('2. forgetting signs restores the mod-2 2-complex for every causal polarisation')
for N=3,8 do local h=C.cycle_homology(N,true); eq(h.b1,0); eq(h.b2,0) end
print('PASS oriented-boundary obstruction',n,'assertions')
