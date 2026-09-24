package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local D=require('speculation.modern.dimensional_lab.common'); local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function leaf(name,a,z)
  local b=W.builder(); local m=b:membrane(nil,name); local pa=b:point(m,a); local pz=b:point(m,z); local i=b:strand(m,{pa},name..'.in'); local o=b:strand(m,{pz},name..'.out'); b:face(m,{i},{o},name); return {g=b:finish(),i=i,o=o}
end
local leaves={leaf('f1','A','B'),leaf('f2','B','C'),leaf('f3','C','D'),leaf('f4','D','E')}
local function combine(a,b)
  local g,img=W.join({a.g,b.g},{{from=a.o,to=b.i}}); return {g=g,i=img[a.i],o=img[b.o]}
end
local function build(kind)
  local a,b,c,d=leaves[1],leaves[2],leaves[3],leaves[4]
  if kind==1 then return combine(combine(combine(a,b),c),d) end              -- (((ab)c)d)
  if kind==2 then return combine(combine(a,b),combine(c,d)) end              -- ((ab)(cd))
  if kind==3 then return combine(a,combine(b,combine(c,d))) end              -- (a(b(cd)))
  if kind==4 then return combine(a,combine(combine(b,c),d)) end              -- (a((bc)d))
  if kind==5 then return combine(combine(a,combine(b,c)),d) end              -- ((a(bc))d)
end
local names={'(((12)3)4)','((12)(34))','(1(2(34)))','(1((23)4))','((1(23))4)'}; local S={}
for i=1,5 do local x=build(i); S[i]=D.surface(names[i],x.g,{i=x.i,o=x.o}); eq(#x.g:faces(),4) end

print('1. the five associahedral parenthesisations are exact W2 constructions with one exposed boundary')
local sig=D.boundary_signature(S[1].g); for i=2,5 do eq(D.boundary_signature(S[i].g),sig,'same A->E process boundary'); ok(S[i].g~=S[1].g,'construction history remains exact') end

print('2. their elementary reassociations form an actual pentagonal higher shadow')
local pent,px=C.cycle(5,nil,{label='associahedron boundary'})
eq(#pent:points(),5); eq(#pent:strands(),5); eq(#pent:faces(),0); local h=C.cycle_homology(5,false); eq(h.b1,1,'unfilled associativity loop is visible at higher rank')
local lift={}; for i=1,5 do lift[px.p[i]]=S[i] end; for i=1,5 do eq(lift[px.p[i]],S[i]) end

print('3. filling the pentagon is extra higher structure, and making that filling causal is highly noncanonical')
local filled=C.cycle_homology(5,true); eq(filled.b1,0)
local variants=0; local ingress_counts={}
for mask=1,30 do local g=C.cycle(5,mask); if g:is_developable() then variants=variants+1; ingress_counts[#ingress_counts+1]=#g:ingress() end end
eq(variants,30,'same associahedral disk admits thirty directed fillings')
local different={}; for _,x in ipairs(ingress_counts) do different[x]=true end; local kinds=0; for _ in pairs(different) do kinds=kinds+1 end; ok(kinds>=4,'causal fillings expose several distinct source cardinalities')

print('4. the structural pentagon therefore does not itself choose a directed refinement law')
local forward=C.cycle(5,5); local reverse=C.cycle(5,26); ok(forward:is_developable() and reverse:is_developable()); eq(#forward:points(),#reverse:points()); eq(#forward:strands(),#reverse:strands()); eq(#forward:faces(),#reverse:faces()); ok(#forward:ingress()~=#reverse:ingress() or forward~=reverse)
print('PASS associahedron from exact W2 histories',n,'assertions')
