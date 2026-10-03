package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Q=require('worlds.query')
local Construction=require('worlds.construction')
local Kernel=require('worlds._kernel')
local Boundary=require('worlds._boundary')(Kernel.private)
local Fast=require('worlds._fast')(Kernel.private)
local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1
assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function large_boundary(count)
  local b=W.builder()
  local m=b:membrane(nil,'frame')
  local ss={}
  for i=1,count do ss[i]=b:strand(m,{},'frame.'..i) end
  return W.boundary(b:finish()),ss
end
local function step()
  local b=W.builder()
  local m=b:membrane(nil,'step')
  local i=b:strand(m,{},'step.in')
  local o=b:strand(m,{},'step.out')
  local f=b:face(m,{i},{o},'step.face')
  return b:finish(),{m=m,i=i,o=o,f=f}
end

print('1. prepare a large-boundary Match eligible for the local fast quotient')
local frame,ss=large_boundary(96)
local rule,r=step()
local seeds={{from=ss[37],to=r.i}}
local fast_result,fast_image,fast_provenance=Fast.try_match_join(frame,rule,seeds,
    function(from) return Boundary.position(frame,'strand',from) end,true)
ok(fast_result~=nil and fast_image~=nil,'large-boundary local Match fast path fell back')
ok(fast_provenance~=nil,'local Match fast path omitted native quotient provenance')
ok(fast_provenance.source_class(ss[37])==fast_provenance.source_class(r.i),
    'fast-path native quotient missed the touched cut')
local solve=Q.solve(Q.match(frame,rule,{seeds=seeds}))
local tag,equations
repeat
  tag,equations=solve:step(2000)
until tag~='more'
eq(tag,'yes','large-boundary Match did not produce exact evidence')
local realisation=assert(Q.realisation_for({frame,rule},equations),
    'exact Realisation was not retained')

print('2. Construction.from_realisation exposes native quotient provenance')
local c=Construction.from_realisation(realisation)
local corr=c:correspondence()
ok(Construction.is_correspondence(corr))
ok(corr:source_equivalent(ss[37],r.i),'touched fast-path cut lost quotient equality')
for _,i in ipairs{1,18,55,96} do
  local image=assert(c:image(ss[i]),'untouched frame authority did not survive')
  eq(image,ss[i],'fast path unexpectedly rematerialised untouched authority')
  eq(corr:source_class(ss[i]),corr:target_class(image),
      'untouched frame identity class was not retained')
  ok(not corr:source_equivalent(ss[i],ss[37]),'untouched frame authority joined touched class')
end

print('3. Construction.join reuses the same Realisation without losing correspondence')
local reused=Construction.join({frame,rule},equations)
eq(reused:result(),realisation:result(),'Construction did not reuse prepared exact result')
eq(reused:image(ss[37]),realisation:image(ss[37]),'reused exact image changed')
local rc=reused:correspondence()
ok(rc:source_equivalent(ss[37],r.i),'reused Realisation lost quotient correspondence')
for _,i in ipairs{1,18,55,96} do
  eq(rc:source_class(ss[i]),rc:target_class(ss[i]),'reused untouched identity class changed')
end

print('PASS native correspondence survives exact Match fast-path Realisation',n,'assertions')
