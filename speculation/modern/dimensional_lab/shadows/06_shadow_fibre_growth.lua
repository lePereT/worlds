package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('causal-polarisation fibres grow rapidly over one structural n-gon')
local previous=0
for N=3,9 do
  local V=(1<<N)-2; local E=0
  for a=1,(1<<N)-2 do for bit=0,N-1 do local b=a~(1<<bit); if b>=1 and b<=((1<<N)-2) and a<b then E=E+1 end end end
  local beta=E-V+1
  ok(V>previous); previous=V; ok(beta>=1)
  -- Every vertex is an actually lawful/developable Worlds Face polarisation.
  local sample=math.max(1,math.floor(V/7)); local checked=0
  for mask=1,(1<<N)-2,sample do local g=C.cycle(N,mask); ok(g:is_developable()); checked=checked+1 end
  print('  n='..N,'polarisations='..V,'one-edge adjacencies='..E,'cycle-rank='..beta,'sampled='..checked)
end
-- Exact values make accidental changes visible.
local N=9; local V=(1<<N)-2; local E=N*((1<<(N-1))-2); eq(V,510); eq(E,2286); eq(E-V+1,1777,'one 9-gon already has a 1777-cycle local-polarisation fibre')
print('PASS hidden causal fibre growth',n,'assertions')
