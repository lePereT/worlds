package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter()
local EPS=1e-12
local function approx(a,b,msg) count(); assert(math.abs(a-b)<EPS,msg or (tostring(a)..' ~= '..tostring(b))) end
-- local counter-compatible approx
local n_extra=0; local function ap(a,b,msg) n_extra=n_extra+1; assert(math.abs(a-b)<EPS,msg or 'not approx') end

local function route(label,x)
  local b=W.builder(); local m=b:membrane(nil,label); local q=b:point(m,'particle'); local hidden=b:point(m,'x='..x)
  local i=b:strand(m,{q},'in'); local mid=b:strand(m,{q,hidden},'hidden'); local o=b:strand(m,{q},'out')
  b:face(m,{i},{mid},'segment 1'); b:face(m,{mid},{o},'segment 2')
  return D.surface(label,b:finish(),{x=x})
end
local function action(x) local x0,x1,t1,t2=0,1,1,3; return (x-x0)^2/t1+(x1-x)^2/t2 end
local xstar=0.25

print('1. exact W2 paths with one boundary form a higher deformation neighbourhood')
local surfaces={route('x=-0.25',-0.25),route('x=0.25',0.25),route('x=0.75',0.75)}
eq(D.boundary_signature(surfaces[1].g),D.boundary_signature(surfaces[2].g))
eq(D.boundary_signature(surfaces[2].g),D.boundary_signature(surfaces[3].g))
local atlas=D.deformation_atlas(surfaces,{{surfaces[1],surfaces[2]},{surfaces[2],surfaces[3]}},'local path variations')
eq(#atlas.world:points(),3); eq(#atlas.world:strands(),2); eq(#atlas.world:faces(),0)

print('2. Theory action is stationary at the central history relative to W3 adjacency')
local sm,sc,sp=action(-0.25),action(0.25),action(0.75)
ap(sm,sp,'symmetric neighbouring variations have equal action')
ap((sp-sm)/(1.0),0,'centred first variation vanishes')
ok(sc<sm and sc<sp,'stationary history is local action minimum')
ap((sp-2*sc+sm)/(0.5*0.5),2+2/3,'higher adjacency recovers expected second variation')

print('3. stationarity persists as the deformation neighbourhood is refined')
local all={surfaces[2]}; local edges={}
for _,h in ipairs{0.25,0.125,0.0625} do
  local a=route('x='..(xstar-h),xstar-h); local c=route('x='..(xstar+h),xstar+h)
  all[#all+1]=a; all[#all+1]=c; edges[#edges+1]={a,surfaces[2]}; edges[#edges+1]={surfaces[2],c}
  ap(action(xstar-h),action(xstar+h),'symmetric finite variations agree')
  ap((action(xstar+h)-action(xstar-h))/(2*h),0,'refined first variation remains zero')
end
local refined=D.deformation_atlas(all,edges,'refined variations')
eq(#refined.world:faces(),0); eq(#refined.world:strands(),6)

print('PASS higher path-variation pressure',count()+n_extra,'assertions')
