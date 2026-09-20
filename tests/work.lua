package.path='./src/?.lua;./src/?/init.lua;'..package.path

local W=require('worlds')
local Query=require('worlds.query')

local n=0
local function ok(x,m) n=n+1; assert(x,m) end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function le(a,b,m) n=n+1; assert(a<=b,(m or 'budget exceeded')..': '..tostring(a)..' > '..tostring(b)) end

-- Count the kernel's own deterministic solve-work quanta.  A unit of fuel is
-- deliberately not elapsed time: every fuelled structural/search operation
-- must pass through the retained query coroutine's work() gate.
local function decision_work(q,limit)
  limit=limit or 1000000
  local quanta=0
  while true do
    quanta=quanta+1
    assert(quanta<=limit,'work measurement exceeded guard limit')
    local tag,value=q:step(1)
    if tag~='more' then return quanta,tag,value end
  end
end

-- Question construction happens before the solve coroutine exists.  Count Lua
-- VM instructions there, rather than wall-clock time, so accidental O(n)
-- materialisation of symbolic complete sections is caught deterministically.
local function instruction_quanta(fn)
  assert(debug and debug.sethook,'work tests require debug.sethook')
  local quanta=0
  local function hook() quanta=quanta+1 end
  debug.sethook(hook,'',1)
  local ok_,a,b,c=pcall(fn)
  debug.sethook()
  assert(ok_,a)
  return quanta,a,b,c
end

local function rigid_world(count)
  local b=W.builder(); local m=b:membrane(nil,'world'); local ps={}
  for i=1,count do ps[i]=b:point(m,'p'..i); b:strand(m,{ps[i]},'s'..i) end
  return b:finish(),ps
end

local function rigid_pattern(point)
  local b=W.builder(); local m=b:membrane(nil,'pattern'); b:strand(m,{point},'d'); return b:finish()
end

local function shared_world(groups,per)
  local b=W.builder(); local m=b:membrane(nil,'world'); local ps={}
  for i=1,groups do
    local p=b:point(m,'p'..i); ps[i]=p
    for j=1,per do b:strand(m,{p},'s'..i..'-'..j) end
  end
  return b:finish(),ps
end

local function shared_pattern(count)
  local b=W.builder(); local m=b:membrane(nil,'pattern'); local p=b:point(m,'p')
  for i=1,count do b:strand(m,{p},'d'..i) end
  return b:finish()
end

local function independent_pattern(count)
  local b=W.builder(); local m=b:membrane(nil,'pattern')
  for i=1,count do local p=b:point(m,'p'..i); b:strand(m,{p},'d'..i) end
  return b:finish()
end

local function deep(depth,count)
  local b=W.builder(); local m=b:membrane(nil,'m1')
  for i=2,depth do m=b:membrane(m,'m'..i) end
  local p=b:point(m,'p'); for i=1,count do b:strand(m,{p},'s'..i) end
  return b:finish()
end

-- Complete Question defaults are symbolic.  Construction must not scale with
-- the number of unrelated source egress occurrences.  This catches the former
-- regression where Question construction copied and indexed all source egress.
do
  local small,sp=rigid_world(100)
  local large,lp=rigid_world(10000)
  local st=rigid_pattern(sp[50]); local lt=rigid_pattern(lp[5000])

  local qs=instruction_quanta(function() return Query.complete(small,st) end)
  local ql=instruction_quanta(function() return Query.complete(large,lt) end)
  le(ql,qs*2+256,'Query.complete must remain independent of complete source size')

  -- Warm W.solve's singleton factory before measuring façade construction.
  W.solve(small,st)
  local ws=instruction_quanta(function() return W.solve(small,st) end)
  local wl=instruction_quanta(function() return W.solve(large,lt) end)
  le(wl,ws*2+256,'W.solve construction must not enumerate complete source sections')
end

-- Multiple complete seeds are canonicalised by target order only.  Because
-- target injectivity has already been checked, source order is not a tie-break;
-- constructing W.solve/Query.complete must therefore not build an O(egress)
-- source-position map merely to sort two seed equations.
do
  local small,sp=rigid_world(100)
  local large,lp=rigid_world(10000)
  local function pair_pattern(a,b)
    local x=W.builder(); local m=x:membrane(nil,'pattern')
    local d1=x:strand(m,{a},'d1'); local d2=x:strand(m,{b},'d2')
    return x:finish(),{d1,d2}
  end
  local st,sd=pair_pattern(sp[10],sp[90]); local lt,ld=pair_pattern(lp[10],lp[9990])
  local ss=small:egress(); local ls=large:egress()
  local sseeds={{from=ss[10],to=sd[1]},{from=ss[90],to=sd[2]}}
  local lseeds={{from=ls[10],to=ld[1]},{from=ls[9990],to=ld[2]}}

  local qs=instruction_quanta(function() return Query.complete(small,st,sseeds) end)
  local ql=instruction_quanta(function() return Query.complete(large,lt,lseeds) end)
  le(ql,qs*2+256,'multi-seed Query.complete must not enumerate complete source sections')

  local ws=instruction_quanta(function() return W.solve(small,st,sseeds) end)
  local wl=instruction_quanta(function() return W.solve(large,lt,lseeds) end)
  le(wl,ws*2+256,'multi-seed W.solve must not build complete source positions')
end

-- Rigid posting lookup is indexed.  Solver work must depend on the selected
-- posting, not on unrelated structural rows in the source boundary.
do
  local sizes={100,1000,10000}; local baseline
  for _,size in ipairs(sizes) do
    local world,ps=rigid_world(size); local target=rigid_pattern(ps[math.floor(size/2)])
    local work,tag=decision_work(W.solve(world,target),100)
    eq(tag,'yes','rigid lookup must solve')
    le(work,12,'rigid lookup fixed work budget')
    if baseline then eq(work,baseline,'rigid lookup work must be source-size independent') else baseline=work end

    local public_work,public_tag=decision_work(Query.solve(Query.complete(world,target)),100)
    eq(public_tag,'yes','public complete Question must solve')
    le(public_work,work,'public complete Question must not exceed façade work quantum')
  end
end

-- Scarcity rejection may scan the candidate structural rows, but it must be
-- linear and must reject before exact permutation enumeration.
do
  local sizes={50,250,1000}
  for _,size in ipairs(sizes) do
    local world=shared_world(size,1); local target=shared_pattern(2)
    local work,tag=decision_work(W.solve(world,target),5000)
    eq(tag,'no','scarcity case must refute')
    le(work,4*size+20,'scarcity rejection must remain linear in candidate rows')
  end
end

-- Raw target ancestry may make first compilation proportional to depth.  Once
-- exact ancestry and ingress quotient data have been compiled, repeated solve
-- work must depend on the compressed boundary, not raw membrane depth.
do
  local cached
  for _,depth in ipairs({50,2000}) do
    local world,target=deep(depth,20),deep(depth,20)
    local first,tag1=decision_work(W.solve(world,target),10000); eq(tag1,'yes')
    local second,tag2=decision_work(W.solve(world,target),200); eq(tag2,'yes')
    le(second,60,'cached deep solve fixed work budget')
    ok(second<first,'deep solve should reuse compiled ancestry/ingress work')
    if depth>=1000 then le(second*10,first,'deep cache must remove raw-depth work') end
    if cached then eq(second,cached,'cached solve work must be raw-depth independent') else cached=second end
  end
end

-- Broad repeated matching still pays for the actual demands, but ingress
-- compilation must remain cached rather than being rebuilt by a fresh query
-- factory on every W.solve call.
do
  local count=500
  local world=shared_world(1,count); local target=independent_pattern(count)
  local first,tag1=decision_work(W.solve(world,target),5000); eq(tag1,'yes')
  local second,tag2=decision_work(W.solve(world,target),5000); eq(tag2,'yes')
  le(first,4*count+20,'first broad solve work budget')
  le(second,2*count+20,'cached broad solve work budget')
  le(second*3,first*2,'broad solve must retain compilation cache across W.solve calls')
end

-- Close and Match share one finite scarce-relation solver. Hall-deficient support
-- must be rejected polynomially rather than by enumerating injections, and
-- mandatory source coverage must not reintroduce optional-target subset search.
local function close_strands(count,prefix)
  local b=W.builder(); local m=b:membrane(nil,prefix); local xs={}
  for i=1,count do xs[i]=b:strand(m,{},prefix..i) end
  return b:finish(),xs
end

do
  for _,size in ipairs({10,20,50}) do
    local a,sources=close_strands(size,'close-source')
    local b,targets=close_strands(size,'close-target')
    local admissible={}
    for _,to in ipairs(targets) do for i=1,size-1 do admissible[#admissible+1]={from=sources[i],to=to} end end
    local work,tag=decision_work(Query.solve(Query.close({a,b},{sources=sources,targets=targets,required_targets=targets,admissible=admissible})),4*size*size+100)
    eq(tag,'no','Close Hall deficiency must refute')
    le(work,4*size*size+100,'Close Hall deficiency must stay polynomial in support size')
  end
end

do
  for _,size in ipairs({10,20,50}) do
    local a,sources=close_strands(size,'domain-source')
    local b,targets=close_strands(size,'domain-target')
    local work,tag=decision_work(Query.solve(Query.close({a,b},{sources=sources,targets=targets,required_sources=sources,required_targets={}})),3*size*size+100)
    eq(tag,'yes','Close required-source optional-target case must solve')
    le(work,3*size*size+100,'Close symmetric domain coverage must avoid subset explosion')
  end
end

-- Simultaneous mandatory domain/range is one relation problem, not two public
-- search modes.  One extra required source must be pulled into an otherwise
-- complete target matching without factorial fallback.
do
  for _,size in ipairs({10,20,50}) do
    local a,sources=close_strands(size+1,'mixed-source')
    local b,targets=close_strands(size,'mixed-target')
    local work,tag=decision_work(Query.solve(Query.close({a,b},{sources=sources,targets=targets,required_sources={sources[#sources]},required_targets=targets})),2*size*size+100)
    eq(tag,'yes','Close mixed required domain/range must solve')
    le(work,2*size*size+100,'Close mixed domain/range coverage must remain polynomial')
  end
end

print('PASS work constitution',n,'assertions')
