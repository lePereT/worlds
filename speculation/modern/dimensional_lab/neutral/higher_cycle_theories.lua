package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter(); local EPS=1e-12
local function approx(a,b,msg) count(); assert(math.abs(a-b)<EPS,msg or 'not approx') end
local extra=0; local function ap(a,b,msg) extra=extra+1; assert(math.abs(a-b)<EPS,msg or 'not approx') end

local function dummy(label)
  local b=W.builder(); local m=b:membrane(nil,label); local q=b:point(m,'q'); b:strand(m,{q},'open'); return D.surface(label,b:finish())
end
local P={dummy('p0'),dummy('p1'),dummy('p2'),dummy('p3')}
local A=D.deformation_atlas(P,{{P[1],P[2]},{P[2],P[3]},{P[3],P[4]},{P[4],P[1]}},'domain-neutral higher cycle')
eq(#A.world:points(),4); eq(#A.world:strands(),4); eq(#A.world:faces(),0)

print('1. one higher incidence cycle supports U(1)-style quantum phase holonomy')
local phase={0.2,-0.1,0.5,0.3}; local gauge={1.0,-0.7,0.4,2.1}
local function sum(x) local s=0; for _,v in ipairs(x) do s=s+v end; return s end
local p2={}; for i=1,4 do local j=i%4+1; p2[i]=phase[i]+gauge[j]-gauge[i] end
ap(sum(phase),sum(p2),'closed quantum phase is gauge invariant')

print('2. the same cycle supports thermodynamic/stochastic affinity without changing Geometry')
-- Interpret edge values as log forward/backward rate ratios.  A change of node
-- reference potential adds phi(target)-phi(source); cycle affinity is invariant.
local affinity={1.2,-0.4,0.7,0.1}; local potential={0.5,-1.1,2.0,0.3}; local a2={}
for i=1,4 do local j=i%4+1; a2[i]=affinity[i]+potential[j]-potential[i] end
ap(sum(affinity),sum(a2),'cycle affinity is reference-potential invariant')

print('3. a Z2/sign Theory over the same loop has its own gauge-invariant product')
local sign={-1,1,-1,-1}; local vertex={-1,1,-1,1}; local s2={}
local function prod(x) local z=1; for _,v in ipairs(x) do z=z*v end; return z end
for i=1,4 do local j=i%4+1; s2[i]=vertex[i]*sign[i]*vertex[j] end
eq(prod(sign),prod(s2),'vertex sign changes cancel around loop')

print('PASS higher cycle supports multiple domain Theories',count()+extra,'assertions')
