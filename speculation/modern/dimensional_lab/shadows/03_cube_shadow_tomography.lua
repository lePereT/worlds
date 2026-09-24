package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('1. Worlds can carry a closed cubical 2-sphere as nondevelopable higher geometry')
local sphere,sc=C.cube(nil); eq(#sphere:points(),8); eq(#sphere:strands(),12); eq(#sphere:faces(),6); eq(#sphere:ingress(),0); eq(#sphere:egress(),0); ok(not sphere:is_developable(),'closed causal surface has no source')
local hs=C.homology(8,sc.edge_ends,sc.top_faces); eq(hs.b0,1); eq(hs.b1,0); eq(hs.b2,1,'closed cube boundary has one 2-dimensional cavity class')

print('2. puncturing the causal source face yields a developable disk without changing the 1-skeleton')
local disk,dc=C.cube('x0'); eq(#disk:points(),8); eq(#disk:strands(),12); eq(#disk:faces(),5); eq(#disk:ingress(),4); ok(disk:is_developable(),'source puncture seeds causal development')
local hd=C.homology(8,dc.edge_ends,dc.top_faces); eq(hd.b0,1); eq(hd.b1,0); eq(hd.b2,0,'puncture kills H2')

print('3. puncturing the causal sink is topologically the same disk but remains nondevelopable')
local reverse,rc=C.cube('x1'); local hr=C.homology(8,rc.edge_ends,rc.top_faces); eq(hr.b0,1); eq(hr.b1,0); eq(hr.b2,0); eq(#reverse:egress(),4); eq(#reverse:ingress(),0); ok(not reverse:is_developable(),'a sink puncture exposes future boundary but supplies no causal seed')

print('4. lower 1-skeleton tomography cannot distinguish sphere from either disk')
eq(#sphere:points(),#disk:points()); eq(#sphere:strands(),#disk:strands()); eq(#disk:points(),#reverse:points()); eq(#disk:strands(),#reverse:strands())
ok(hs.b2~=hd.b2,'higher filling carries information invisible to complete point/strand skeleton')
print('PASS cube shadow tomography/developability',n,'assertions')
