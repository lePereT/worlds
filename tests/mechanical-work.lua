package.path='./src/?.lua;./src/?/init.lua;'..package.path

local W=require('worlds')

local n=0
local function ok(x,m) n=n+1; assert(x,m or 'expected truthy') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function le(a,b,m) n=n+1; assert(a<=b,(m or 'work budget exceeded')..': '..tostring(a)..' > '..tostring(b)) end

-- Mechanical ratchets use Lua VM instruction quanta, never elapsed time.  They
-- protect work-shape properties which live below the fuelled Question engine:
-- borrowed observations, identity construction, retained realisation reuse,
-- the trusted development Builder, and indexed local live advance.
local function instructions(fn)
  assert(debug and debug.sethook,'mechanical work tests require debug.sethook')
  local quanta=0
  local function hook() quanta=quanta+1 end
  debug.sethook(hook,'',1)
  local pass,a,b,c=pcall(fn)
  debug.sethook()
  assert(pass,a)
  return quanta,a,b,c
end

local function universe_point()
  local b=W.builder(); local m=b:membrane(nil,'ratchet.universe'); b:finish()
  return W.minter(m)('shared exact point')
end

local function imported_world(count,p)
  local b=W.builder(); local m=b:membrane(nil,'ratchet.world'); local strands={}
  for i=1,count do strands[i]=b:strand(m,{p},'s'..i) end
  return b:finish(),strands
end

local function single_face_development(p)
  local b=W.development_builder(); local m=b:membrane(nil,'ratchet.step')
  local input=b:strand(m,{p},'input'); local output=b:strand(m,{p},'output')
  b:face(m,{input},{output},'step')
  return b:finish(),input,output
end

local function chain_development(p,count)
  local b=W.development_builder(); local m=b:membrane(nil,'ratchet.chain')
  local input=b:strand(m,{p},'input'); local current=input
  for i=1,count do
    local output=b:strand(m,{p},'output'..i)
    b:face(m,{current},{output},'step'..i)
    current=output
  end
  return b:finish(),input,current
end

-- Authentic immutable observations are borrowed views.  Reading a complete
-- section or a Strand incidence array must not copy it or scale with its size.
do
  local p=universe_point()
  local small,ss=imported_world(10,p)
  local large,ls=imported_world(10000,p)
  eq(small:egress(),small:egress(),'egress must be a stable borrowed view')
  eq(large:egress(),large:egress(),'large egress must be a stable borrowed view')
  eq(W.points(ss[1]),W.points(ss[1]),'Strand incidence must be a stable borrowed view')

  local sw=instructions(function() for _=1,1000 do assert(small:egress()[1]) end end)
  local lw=instructions(function() for _=1,1000 do assert(large:egress()[1]) end end)
  le(lw,sw*2+128,'egress observation must remain independent of boundary size')

  local function incidence(width)
    local b=W.builder(); local m=b:membrane(nil,'ratchet.incidence'); local ps={}
    for i=1,width do ps[i]=b:point(m,'p'..i) end
    local s=b:strand(m,ps,'wide'); b:finish(); return s
  end
  local narrow,wide=incidence(10),incidence(10000)
  local sp=instructions(function() for _=1,1000 do assert(W.points(narrow)[1]) end end)
  local lp=instructions(function() for _=1,1000 do assert(W.points(wide)[1]) end end)
  le(lp,sp*2+128,'Point-incidence observation must remain independent of arity')
end

-- A one-part/no-equation join is identity evidence.  Its work must not depend
-- on the number of carriers in the already-authentic Geometry.
do
  local p=universe_point(); local small,ss=imported_world(10,p); local large,ls=imported_world(10000,p)
  local sw=instructions(function() local g,image=W.join({small},{}); assert(g==small and image[ss[1]]==ss[1]) end)
  local lw=instructions(function() local g,image=W.join({large},{}); assert(g==large and image[ls[1]]==ls[1]) end)
  le(lw,sw*2+128,'identity join must remain independent of Geometry size')
end

-- The trusted development Builder defers incidence validation to finish().
-- Merely attaching an already-authentic incidence array to a development
-- Strand must therefore be constant work in its width.
do
  local p=universe_point()
  local function points(width)
    local xs={}; for i=1,width do xs[i]=p end; return xs
  end
  local function strand_work(xs)
    local b=W.development_builder(); local m=b:membrane(nil,'ratchet.development')
    return instructions(function() b:strand(m,xs,'wide') end)
  end
  local sw=strand_work(points(10)); local lw=strand_work(points(10000))
  le(lw,sw*2+128,'development Builder must not eagerly revalidate every incidence coordinate')
end

-- A successful Question has already performed the strict join.  Commit must
-- reuse that retained exact realisation instead of materialising the same join
-- again, and the commit-side work must remain effectively frame-independent.
do
  local p=universe_point()
  local function commit_work(count)
    local world,sources=imported_world(count,p)
    local b=W.development_builder(); local m=b:membrane(nil,'ratchet.target'); local target=b:strand(m,{p},'target'); local d=b:finish()
    local source=sources[math.floor(count/2)]
    local solve=W.solve(world,d,{{from=source,to=target}}); local tag,equations
    repeat tag,equations=solve:step(1000) until tag~='more'
    assert(tag=='yes','ratchet Match must solve')
    return instructions(function() local nextw,image=W.advance(world,d,equations); assert(nextw and image[target]) end)
  end
  local sw=commit_work(100); local lw=commit_work(10000)
  le(lw,sw*2+512,'retained realisation commit must not rematerialise the whole frame')
end

-- Fibers-shaped direct evolution uses imported exact Points and an indexed live
-- boundary.  Replacing one open Strand by one open Strand must do work
-- proportional to the changed boundary, not to 100x more unrelated authority.
do
  local p=universe_point()
  local function advance_work(count)
    local world,sources=imported_world(count,p)
    local d,input,output=single_face_development(p)
    local source=sources[math.floor(count/2)]
    local q,nextw,image=instructions(function() return W.advance(world,d,{{from=source,to=input}}) end)
    assert(nextw and image[output] and #nextw:egress()==count)
    return q,nextw,image[output]
  end
  local sw=advance_work(100)
  local lw,world,current=advance_work(10000)
  le(lw,sw*2+1024,'indexed single-Face advance must remain independent of unrelated live frontier size')
  le(lw,10000,'indexed single-Face advance lost its local-work shape')

  -- The disposable boundary index must transfer to the successor.  A second
  -- local advance on the same 10k frontier must stay in the same work class.
  local d,input,output=single_face_development(p)
  local second,nextw,image=instructions(function() return W.advance(world,d,{{from=current,to=input}}) end)
  assert(nextw and image[output] and #nextw:egress()==10000)
  le(second,lw*2+512,'successor boundary lost transferred acceleration')
end


-- The same frame-local law applies to a small causal Development, not only to
-- the single-Face special case.  Four causally ordered Faces must remain local
-- on a 10k live frontier, and the transferred boundary index must keep the next
-- multi-Face advance in the same work class.
do
  local p=universe_point()
  local function advance_work(count)
    local world,sources=imported_world(count,p)
    local d,input,output=chain_development(p,4)
    local source=sources[math.floor(count/2)]
    local q,nextw,image=instructions(function() return W.advance(world,d,{{from=source,to=input}}) end)
    assert(nextw and image[output] and #nextw:egress()==count)
    return q,nextw,image[output]
  end
  local sw=advance_work(100)
  local lw,world,current=advance_work(10000)
  le(lw,sw*2+2048,'indexed multi-Face advance must remain independent of unrelated live frontier size')
  le(lw,30000,'indexed multi-Face advance lost its local-work shape')

  local d,input,output=chain_development(p,4)
  local second,nextw,image=instructions(function() return W.advance(world,d,{{from=current,to=input}}) end)
  assert(nextw and image[output] and #nextw:egress()==10000)
  le(second,lw*2+1024,'successor boundary lost transferred multi-Face acceleration')
end

print('PASS mechanical work ratchets',n,'assertions')
