local W=require('worlds'); local T=require('support')

-- Exercise operational execution inside a disposable Lua frame.  The semantic
-- property under test is that Boundary retains only live egress, not closed
-- causal history.  Do not make the test depend on how aggressively a particular
-- VM clears dead stack slots or chains of weak-key state tables after one GC.
local function exercise(steps)
  local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local State=vb:point(vm,'State'); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); vb:finish()
  local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local current=b:strand(root,{State,A},'current'); local live=W.Operational.from_geometry(b:finish())
  local function transition(from,to)
    local p=W.Geometry.builder(); local m=p:membrane(nil,'p'); local i=p:strand(m,{State,from},'in'); local o=p:strand(m,{State,to},'out'); p:face(m,{i},{o},'step'); return p:finish(),i,o
  end
  local ab,abi,abo=transition(A,B); local ba,bai,bao=transition(B,A)
  local old=setmetatable({}, {__mode='k'})
  for step=1,steps do
    old[current]=true
    local pat,pi,po=step%2==1 and ab or ba, step%2==1 and abi or bai, step%2==1 and abo or bao
    local w=W.Operational.one(live,pat,{strands={[pi]=current}}); T.ok(w)
    local next_live,img=W.Operational.commit(w); live=next_live; current=img.strands[po]
    T.eq(live:size(),1)
  end
  -- `current` is the new live occurrence and was never inserted into `old`.
  return old,live
end

local old,live=exercise(2000)
T.eq(live:size(),1)

local function retained()
  local n=0; for _ in pairs(old) do n=n+1 end; return n
end

-- Worlds' bootstrap runtimes differ in weak-table/stack collection cadence.
-- LuaJIT follows Lua 5.1-style weak-table collection, so transient STATE chains
-- can require several complete cycles to drain after their owning frame dies.
-- The required property is convergence to zero with the live Boundary retained,
-- not an arbitrary object count after exactly two cycles.
local n=retained()
for _=1,16 do
  if n==0 then break end
  collectgarbage('collect')
  n=retained()
end
T.eq(n,0,'operational state retained obsolete live Strands after GC convergence; retained='..n)
return T.count()
