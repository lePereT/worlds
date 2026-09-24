package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('1. the unfilled structural loop leaves every edge simultaneously open on both sides')
local open=C.cycle(5,nil); eq(#open:faces(),0); eq(#open:ingress(),5); eq(#open:egress(),5)

print('2. every possible Face filling necessarily causalises every boundary edge')
for mask=0,31 do
  local g=C.cycle(5,mask); eq(#g:faces(),1)
  local both=0; for _,s in ipairs(g:strands()) do if g:is_input(s) and g:is_terminal(s) then both=both+1 end end
  eq(both,0,'no filled edge remains neutral/open on both sides')
  eq(#g:ingress()+#g:egress(),5,'every edge is forced onto exactly one causal side')
end

print('3. hence no ordinary Worlds Face can fill the pentagon while preserving its structural open boundary')
local same=0
for mask=0,31 do local g=C.cycle(5,mask); if #g:ingress()==5 and #g:egress()==5 then same=same+1 end end
eq(same,0,'pure coherence filling is not expressible as a causally neutral Face')
print('PASS neutral higher-fill impossibility',n,'assertions')
