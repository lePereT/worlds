package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter()

local function gate(name,a,b)
  local x=W.builder(); local m=x:membrane(nil,name)
  local pa=x:point(m,a); local pb=x:point(m,b)
  local i=x:strand(m,{pa},name..'.in'); local o=x:strand(m,{pb},name..'.out')
  x:face(m,{i},{o},name)
  return {g=x:finish(),i=i,o=o}
end

local function surface_one_shot(label)
  local f=gate(label..'.f','A','B'); local h=gate(label..'.h','B','E')
  local g=gate(label..'.g','C','D'); local k=gate(label..'.k','D','F')
  local world=W.join({f.g,g.g,h.g,k.g},{{from=f.o,to=h.i},{from=g.o,to=k.i}})
  return D.surface(label,world)
end

local function surface_lane_first(label)
  local f=gate(label..'.f','A','B'); local h=gate(label..'.h','B','E')
  local g=gate(label..'.g','C','D'); local k=gate(label..'.k','D','F')
  local l1=W.join({f.g,h.g},{{from=f.o,to=h.i}})
  local l2=W.join({g.g,k.g},{{from=g.o,to=k.i}})
  local world=W.join({l1,l2},{})
  return D.surface(label,world)
end

local function surface_pair_first(label)
  local f=gate(label..'.f','A','B'); local h=gate(label..'.h','B','E')
  local g=gate(label..'.g','C','D'); local k=gate(label..'.k','D','F')
  local left=W.join({f.g,g.g},{})
  local right=W.join({h.g,k.g},{})
  -- locate egress/ingress by role names after the pairwise tensors
  local function role_strand(xs,name)
    for _,s in ipairs(xs) do local ps=W.points(s); if #ps==1 and W.name(ps[1])==name then return s end end
  end
  local world=W.join({left,right},{
    {from=assert(role_strand(left:egress(),'B')),to=assert(role_strand(right:ingress(),'B'))},
    {from=assert(role_strand(left:egress(),'D')),to=assert(role_strand(right:ingress(),'D'))},
  })
  return D.surface(label,world)
end

print('1. monoidal interchange gives exact-distinct W2 histories with one exposed process interface')
local P=surface_one_shot('P')
local Q=surface_lane_first('Q')
local R=surface_pair_first('R')
eq(#P.g:faces(),4); eq(#Q.g:faces(),4); eq(#R.g:faces(),4)
eq(D.boundary_signature(P.g),D.boundary_signature(Q.g),'P/Q interface')
eq(D.boundary_signature(Q.g),D.boundary_signature(R.g),'Q/R interface')
ok(P.g~=Q.g and Q.g~=R.g and P.g~=R.g,'histories remain exact-distinct')

print('2. W3-style deformation incidence relates histories without identifying them')
local atlas=D.deformation_atlas({P,Q,R},{{P,Q},{Q,R},{P,R}},'interchange atlas')
eq(#atlas.world:faces(),0,'deformation adjacency is non-causal')
eq(#atlas.world:points(),3); eq(#atlas.world:strands(),3)
ok(atlas.point[P]~=atlas.point[Q] and atlas.point[Q]~=atlas.point[R],'higher coordinates preserve exact alternatives')

print('3. direct and staged higher rewrites retain distinct higher histories')
local pq=D.higher_rewrite(P,Q,'P=>Q')
local qr=D.higher_rewrite(Q,R,'Q=>R')
local pr=D.higher_rewrite(P,R,'P=>R')
local staged=D.path_rewrites({pq,qr})
local direct=pr.world
eq(#staged:faces(),2,'staged coherence has two higher events')
eq(#direct:faces(),1,'direct coherence has one higher event')
eq(D.boundary_signature(staged),D.boundary_signature(direct),'higher paths share exposed source/target surface kinds')
ok(staged~=direct,'coherence does not quotient exact higher history')

print('PASS cross-domain process interchange',count(),'assertions')
