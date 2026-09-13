package.path='./src/?.lua;'..package.path
local W=require('worlds')
local function decided(q) while true do local k,x=q:step(math.huge); if k~='more' then return k,x end end end
local function timed(name,fn) collectgarbage('collect'); local t=os.clock(); local x=fn(); print(string.format('%-22s %.6f  %s',name,os.clock()-t,tostring(x or ''))) end
local function shared_world(groups,per)
  local b=W.builder(); local m=b:membrane(nil); local ps={}
  for i=1,groups do local p=b:point(m); ps[i]=p; for _=1,per do b:strand(m,{p}) end end
  return b:finish(),ps
end
local function independent(k) local b=W.builder(); local m=b:membrane(nil); for _=1,k do local p=b:point(m); b:strand(m,{p}) end; return b:finish() end
local function shared(k) local b=W.builder(); local m=b:membrane(nil); local p=b:point(m); for _=1,k do b:strand(m,{p}) end; return b:finish() end
local function bipartite(s)
  local b=W.builder(); local m=b:membrane(nil); local a,c={},{}
  for i=1,s do a[i]=b:point(m); c[i]=b:point(m) end
  for i=1,s do for j=1,s do b:strand(m,{a[i],c[j]}); b:strand(m,{c[j],a[i]}) end end
  return b:finish()
end
local function cycle(k) local b=W.builder(); local m=b:membrane(nil); local p={}; for i=1,k do p[i]=b:point(m) end; for i=1,k do b:strand(m,{p[i],p[i%k+1]}) end; return b:finish() end
local function deep(depth,k)
  local b=W.builder(); local m=b:membrane(nil); for _=2,depth do m=b:membrane(m) end
  local p=b:point(m); for _=1,k do b:strand(m,{p}) end; return b:finish()
end

local w1=shared_world(1,1000); local p1=independent(1000)
timed('broad-1000 first',function() return decided(W.solve(w1,p1)) end)
timed('broad-1000 cached',function() return decided(W.solve(w1,p1)) end)

local w2=shared_world(5000,1); local p2=shared(2)
timed('shared-unsat-5000',function() return decided(W.solve(w2,p2)) end)

local w3=bipartite(5); local p3=cycle(7)
timed('odd-C7-K5,5',function() return decided(W.solve(w3,p3)) end)

local w4=shared_world(1,10); local p4=independent(5)
timed('exact-10P5',function()
  local q=W.solve(w4,p4); local n=0
  while true do local k=q:step(math.huge); if k=='yes' then n=n+1 elseif k=='done' then return n elseif k~='more' then error(k) end end
end)

local w5,pts=shared_world(100000,1); local b=W.builder(); local m=b:membrane(nil); b:strand(m,{pts[77777]}); local p5=b:finish()
timed('rigid-100k',function() return decided(W.solve(w5,p5)) end)

local wd,pd=deep(3000,20),deep(3000,20)
timed('boundary-depth3000 first',function() return decided(W.solve(wd,pd)) end)
timed('boundary-depth3000 cached',function() return decided(W.solve(wd,pd)) end)
