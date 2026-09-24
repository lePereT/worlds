package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter()

local function arrow(label,a,b)
  local x=W.builder(); local m=x:membrane(nil,label); local pa=x:point(m,a); local pb=x:point(m,b)
  local i=x:strand(m,{pa},a); local o=x:strand(m,{pb},b); x:face(m,{i},{o},label); return {g=x:finish(),i=i,o=o}
end
local function one_shot(label)
  local f=arrow(label..'.f','A','B'); local g=arrow(label..'.g','B','C'); local h=arrow(label..'.h','D','E'); local k=arrow(label..'.k','E','F')
  return D.surface(label,W.join({f.g,g.g,h.g,k.g},{{from=f.o,to=g.i},{from=h.o,to=k.i}}))
end
local function left_cut_first(label)
  local f=arrow(label..'.f','A','B'); local g=arrow(label..'.g','B','C'); local h=arrow(label..'.h','D','E'); local k=arrow(label..'.k','E','F')
  local l=W.join({f.g,g.g},{{from=f.o,to=g.i}}); local r=W.join({h.g,k.g},{{from=h.o,to=k.i}})
  return D.surface(label,W.join({l,r},{}))
end
local function right_cut_first(label)
  local h=arrow(label..'.h','D','E'); local k=arrow(label..'.k','E','F'); local f=arrow(label..'.f','A','B'); local g=arrow(label..'.g','B','C')
  local r=W.join({h.g,k.g},{{from=h.o,to=k.i}}); local l=W.join({f.g,g.g},{{from=f.o,to=g.i}})
  return D.surface(label,W.join({r,l},{}))
end

print('1. independent cut construction orders retain exact histories but one sequent boundary')
local P=one_shot('simultaneous cuts'); local L=left_cut_first('left first'); local R=right_cut_first('right first')
eq(D.boundary_signature(P.g),D.boundary_signature(L.g)); eq(D.boundary_signature(L.g),D.boundary_signature(R.g))
eq(#P.g:faces(),4); eq(#L.g:faces(),4); eq(#R.g:faces(),4)
ok(P.g~=L.g and L.g~=R.g,'proof/process histories are exact-distinct')
local pi,po=D.boundary_multiset(P.g); eq(pi.A,1); eq(pi.D,1); eq(po.C,1); eq(po.F,1)

print('2. higher coherence relates cut permutations without turning exchange into a W2 rule')
local atlas=D.deformation_atlas({P,L,R},{{P,L},{P,R},{L,R}},'cut coherence')
eq(#atlas.world:faces(),0,'coherence atlas adds no proof rule at W2')
eq(#atlas.world:points(),3); eq(#atlas.world:strands(),3)

print('3. two higher coherence routes can remain exact-distinct')
local pl=D.higher_rewrite(P,L,'permute cuts 1')
local lr=D.higher_rewrite(L,R,'permute cuts 2')
local pr=D.higher_rewrite(P,R,'direct cut permutation')
local staged=D.path_rewrites({pl,lr}); local direct=pr.world
eq(D.boundary_signature(staged),D.boundary_signature(direct),'same higher source/target proof surfaces')
eq(#staged:faces(),2); eq(#direct:faces(),1); ok(staged~=direct)

print('PASS logical cut-coherence pressure',count(),'assertions')
