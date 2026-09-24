package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function build(depth)
  local b=W.builder(); local root=b:membrane(nil,'root'); local host=root
  for i=1,depth do host=b:membrane(host,'support.'..i) end
  local p,e={},{}; for i=1,4 do p[i]=b:point(root,'p'..i) end; for i=1,4 do e[i]=b:strand(root,{p[i],p[i%4+1]},'e'..i) end
  local f=b:face(host,{e[1],e[3]},{e[2],e[4]},'same cellular fill')
  return b:finish(),{root=root,host=host,f=f}
end

print('1. one fixed cellular 2-cell admits an independent unbounded support-depth coordinate')
for depth=0,12 do local g,x=build(depth); ok(g:is_developable()); eq(#g:points(),4); eq(#g:strands(),4); eq(#g:faces(),1); eq(#g:membranes(),depth+1); eq(W.membrane(x.f),x.host) end

print('2. support depth is therefore not reconstructible from point/strand/face incidence counts')
local a=build(0); local z=build(12); eq(#a:points(),#z:points()); eq(#a:strands(),#z:strands()); eq(#a:faces(),#z:faces()); ok(#a:membranes()~=#z:membranes())
print('PASS membrane depth fibre',n,'assertions')
