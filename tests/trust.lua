package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local Construction=require('worlds.construction')
local Presentation=require('worlds.presentation')
local History=require('worlds.history')

local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function decided(q) while true do local k,x=q:step(math.huge); if k~='more' then return k,x end end end

-- Trusted finite arrays are borrowed/read-only. Worlds validates their semantic
-- use but does not clone them merely to defend against a cooperating caller.
do
  local b=W.builder(); local m=b:membrane(nil,'m'); local p=b:point(m,'p')
  local ps={p}; local i=b:strand(m,ps,'i'); local outs={}; local o=b:strand(m,ps,'o'); outs[1]=o
  local ins={i}; local f=b:face(m,ins,outs,'f'); local g=b:finish()
  eq(W.points(i),ps,'Strand incidence is the borrowed input array')
  eq(W.inputs(f),ins,'Face inputs are the borrowed input array')
  eq(W.outputs(f),outs,'Face outputs are the borrowed input array')
  eq(g:membranes(),g:membranes(),'Geometry membrane view is stable')
  eq(g:points(),g:points(),'Geometry Point view is stable')
  eq(g:strands(),g:strands(),'Geometry Strand view is stable')
  eq(g:faces(),g:faces(),'Geometry Face view is stable')
  eq(g:ingress(),g:ingress(),'Geometry ingress view is stable')
  eq(g:egress(),g:egress(),'Geometry egress view is stable')
end

-- Edge evidence keeps stable borrowed views; semantic normalisation may still
-- allocate once where it changes representation.
do
  local a=W.builder(); local am=a:membrane(nil,'a'); local ao=a:strand(am,{},'ao'); local A=a:finish()
  local b=W.builder(); local bm=b:membrane(nil,'b'); local bi=b:strand(bm,{},'bi'); local B=b:finish()
  local parts={A,B}; local equations={{ao,bi}}
  local c=Construction.join(parts,equations)
  eq(c:parts(),parts,'Construction borrows parts')
  eq(c:equations(),c:equations(),'Construction normalised equations are a stable view')
  local rows={{c:image(ao)}}; local p=Presentation.new(c:result(),rows)
  eq(p:rows(),rows,'Presentation borrows rows')
  eq(p:row(1),rows[1],'Presentation row is the borrowed row')
end

-- Question canonicalisation is retained, but accessors do not clone the
-- canonical finite relation on every observation.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'w'); local ws=wb:strand(wm,{},'w'); local world=wb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil,'p'); local ps=pb:strand(pm,{},'p'); local pat=pb:finish()
  local q=Query.match(world,pat,{sources={ws},targets={ps},admissible={{from=ws,to=ps}},seeds={{from=ws,to=ps}}})
  eq(q:parts(),q:parts(),'Question parts view is stable')
  eq(q:sources(),q:sources(),'Question source view is stable')
  eq(q:targets(),q:targets(),'Question target view is stable')
  eq(q:required_sources(),q:required_sources(),'Question required-source view is stable')
  eq(q:required_targets(),q:required_targets(),'Question required-target view is stable')
  eq(q:seeds(),q:seeds(),'Question seed view is stable')
  eq(q:admissible(),q:admissible(),'Question admissibility view is stable')

  local empty=W.builder(); empty:membrane(nil,'empty'); local none=empty:finish()
  local no_q=Query.match(none,pat,{})
  local tag,no=decided(Query.solve(no_q)); eq(tag,'no')
  eq(no:reason(),no:reason(),'Refutation reason is a stable borrowed view')
end

-- Optional history is likewise an in-process observation; callers that retain
-- it receive the exact record array rather than a fresh shallow copy each time.
do
  local h=History.new()
  eq(h:events(),h:events(),'History events view is stable')
end

-- Private-state identity is not a protected-metatable label.
do
  ok(not Construction.is_construction(setmetatable({}, {__metatable='Worlds Construction'})))
  ok(not Presentation.is_presentation(setmetatable({}, {__metatable='Worlds Presentation'})))
  ok(not Query.is_question(setmetatable({}, {__metatable='Worlds Question'})))
end

print('PASS trust model',n,'assertions')
