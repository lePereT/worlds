package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function build(hostname)
  local b=W.builder(); local root=b:membrane(nil,'root'); local a=b:membrane(root,'A'); local z=b:membrane(root,'B')
  local pa=b:point(a,'pa'); local pb=b:point(z,'pb')
  local ia=b:strand(a,{pa},'A.in'); local ib=b:strand(z,{pb},'B.in')
  local oa=b:strand(a,{pa},'A.out'); local ob=b:strand(z,{pb},'B.out')
  local host=hostname=='A' and a or hostname=='B' and z or root
  local f=b:face(host,{ia,ib},{oa,ob},'cross-local event')
  return b:finish(),{root=root,a=a,b=z,pa=pa,pb=pb,f=f}
end

print('1. a causal cell need not be hosted in a Membrane containing all of its boundary locality')
local A,a=build('A'); local B,b=build('B'); local R,r=build('root')
for _,g in ipairs{A,B,R} do ok(g:is_developable()); eq(#g:membranes(),3); eq(#g:faces(),1) end
eq(W.membrane(a.f),a.a); ok(W.membrane(a.f)~=a.b,'A-hosted Face acts on sibling B authority')
eq(W.membrane(b.f),b.b); ok(W.membrane(b.f)~=b.a,'B-hosted Face acts on sibling A authority')
eq(W.membrane(r.f),r.root)

print('2. identical cross-local incidence therefore has three lawful event loci on one support tree')
eq(#A:points(),#B:points()); eq(#A:strands(),#B:strands()); eq(#A:faces(),#B:faces())
ok(W.name(W.membrane(a.f))~=W.name(W.membrane(b.f)))
print('PASS cross-local Membrane host',n,'assertions')
