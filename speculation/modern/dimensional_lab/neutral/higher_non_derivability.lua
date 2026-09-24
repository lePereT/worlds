package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter()

local function history(label)
  local b=W.builder(); local m=b:membrane(nil,label); local q=b:point(m,'q'); local i=b:strand(m,{q},'in'); local o=b:strand(m,{q},'out'); b:face(m,{i},{o},label); return D.surface(label,b:finish())
end
local P,Q,R,S=history('P'),history('Q'),history('R'),history('S')
local surfaces={P,Q,R,S}; local sig=D.boundary_signature(P.g)
for _,x in ipairs(surfaces) do eq(D.boundary_signature(x.g),sig,'all W2 histories expose same W1 boundary') end

print('1. identical W2/W1 data admits inequivalent higher adjacency structures')
local path=D.deformation_atlas(surfaces,{{P,Q},{Q,R},{R,S}},'path adjacency')
local cycle=D.deformation_atlas(surfaces,{{P,Q},{Q,R},{R,S},{S,P}},'cycle adjacency')
local complete=D.deformation_atlas(surfaces,{{P,Q},{P,R},{P,S},{Q,R},{Q,S},{R,S}},'complete adjacency')
eq(#path.world:points(),4); eq(#cycle.world:points(),4); eq(#complete.world:points(),4)
eq(#path.world:strands(),3); eq(#cycle.world:strands(),4); eq(#complete.world:strands(),6)
ok(path.world~=cycle.world and cycle.world~=complete.world,'higher structure is additional semantic choice, not boundary reconstruction')

print('2. bare higher Geometry does not recover which W2 surface a higher Point denotes')
local A=D.deformation_atlas({P,Q},{{P,Q}},'lift A')
local B=D.deformation_atlas({Q,P},{{Q,P}},'lift B')
eq(#A.world:points(),#B.world:points()); eq(#A.world:strands(),#B.world:strands()); eq(#A.world:faces(),#B.world:faces())
-- Both have one ordered two-Point row.  The exact source meaning differs only in
-- the graded lift; names are intentionally nonsemantic.
local ar=W.points(A.arcs[1]); local br=W.points(B.arcs[1]); eq(#ar,2); eq(#br,2)
eq(A.lift[ar[1]],P); eq(A.lift[ar[2]],Q); eq(B.lift[br[1]],Q); eq(B.lift[br[2]],P)
ok(A.lift[ar[1]]~=B.lift[br[1]],'same local higher shape can denote different source histories')

print('PASS higher non-derivability/lift pressure',count(),'assertions')
