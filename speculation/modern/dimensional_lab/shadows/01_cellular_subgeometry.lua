package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('1. two-ended Strand cycles form an honest mod-2 cellular subgeometry')
for k=3,9 do
  local empty=C.cycle_homology(k,false); local filled=C.cycle_homology(k,true)
  eq(empty.b0,1); eq(empty.b1,1,'unfilled cycle has one H1 generator'); eq(empty.b2,0)
  eq(filled.b0,1); eq(filled.b1,0,'one Face kills the cycle'); eq(filled.b2,0)
end

print('2. general Worlds causality is additional structure on top of that cellular boundary')
for k=3,8 do
  local total,developable=0,0
  for mask=0,(1<<k)-1 do
    local good,g=pcall(function() return C.cycle(k,mask) end); ok(good,'every causal polarisation of a cycle is lawful')
    total=total+1; if g:is_developable() then developable=developable+1 end
  end
  eq(total,1<<k); eq(developable,(1<<k)-1,'only all-output/no-input filling is nondevelopable')
end

print('3. topology alone therefore does not determine causal polarity')
local a=C.cycle(5,5); local b=C.cycle(5,26)
eq(#a:points(),#b:points()); eq(#a:strands(),#b:strands()); eq(#a:faces(),#b:faces())
ok(#a:ingress()~=#b:ingress() or #a:egress()~=#b:egress() or a~=b,'same cellular disk admits exact-distinct causal fillings')
print('PASS cellular subgeometry',n,'assertions')
