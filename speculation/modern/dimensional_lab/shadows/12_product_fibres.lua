package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function pentagon(mask,depth)
  local b=W.builder(); local root=b:membrane(nil,'root'); local host=root; for i=1,depth do host=b:membrane(host,'m'..i) end
  local p,e={},{}; for i=1,5 do p[i]=b:point(root,'v'..i) end; for i=1,5 do e[i]=b:strand(root,{p[i],p[i%5+1]},'e'..i) end
  local ins,outs={},{}; for i=1,5 do if (mask&(1<<(i-1)))~=0 then ins[#ins+1]=e[i] else outs[#outs+1]=e[i] end end
  b:face(host,ins,outs,'fill'); return b:finish()
end

print('1. causal polarisation and Membrane support depth vary independently over one filled pentagon')
local count=0
for depth=0,7 do for mask=1,30 do local g=pentagon(mask,depth); ok(g:is_developable()); eq(#g:points(),5); eq(#g:strands(),5); eq(#g:faces(),1); eq(#g:membranes(),depth+1); count=count+1 end end
eq(count,240,'already 240 lawful causal/support realisations over one cellular disk in the sampled fibre')

print('2. the hidden fibre is product-like before adding any domain Theory or exact W2 lift')
local shallow=pentagon(5,0); local deep=pentagon(5,7); local reversed=pentagon(26,0)
eq(#shallow:points(),#deep:points()); eq(#shallow:strands(),#deep:strands()); eq(#shallow:faces(),#deep:faces()); ok(#shallow:membranes()~=#deep:membranes()); ok(shallow~=reversed)
print('PASS product hidden fibres',n,'assertions')
