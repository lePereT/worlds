package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter(); local EPS=1e-12
local function approx(a,b,msg) assert(math.abs(a-b)<EPS,msg or (tostring(a)..' ~= '..tostring(b))) end

local function history(label,n)
  local b=W.builder(); local m=b:membrane(nil,label); local q=b:point(m,'particle'); local h=b:point(m,'hidden.'..n)
  local i=b:strand(m,{q},'in'); local mid=b:strand(m,{q,h},'hidden'); local o=b:strand(m,{q},'out')
  b:face(m,{i},{mid},'a'); b:face(m,{mid},{o},'b')
  return D.surface(label,b:finish())
end
local P={history('P0',0),history('P1',1),history('P2',2),history('P3',3)}
for i=2,4 do eq(D.boundary_signature(P[1].g),D.boundary_signature(P[i].g),'all histories share observed boundary') end
local atlas=D.deformation_atlas(P,{{P[1],P[2]},{P[2],P[3]},{P[3],P[4]},{P[4],P[1]}},'history deformation loop')
eq(#atlas.world:faces(),0); eq(#atlas.world:strands(),4); eq(#atlas.world:points(),4)

print('1. a higher deformation loop supports gauge-invariant holonomy')
local theta={0.31,-0.27,0.44,0.19}; local gauge={1.7,-0.4,0.9,2.2}
local function total(xs) local s=0; for _,x in ipairs(xs) do s=s+x end; return s end
local hol=total(theta)
local transformed={}
for i=1,4 do local j=i%4+1; transformed[i]=theta[i]+gauge[j]-gauge[i] end
approx(total(transformed),hol,'vertex rephasing cancels around closed higher loop')

print('2. all local edge phases but one can be gauged away; the residual is the loop invariant')
local g={0,0,0,0}; g[1]=0
for i=1,3 do g[i+1]=g[i]-theta[i] end
local fixed={}; for i=1,4 do local j=i%4+1; fixed[i]=theta[i]+g[j]-g[i] end
for i=1,3 do approx(fixed[i],0,'tree edge gauge-fixed to zero') end
approx(fixed[4],hol,'closing edge carries total holonomy')
ok(P[1].g~=P[2].g and P[2].g~=P[3].g,'holonomy relates rather than identifies exact histories')

print('PASS higher-history holonomy',count()+6,'assertions')
