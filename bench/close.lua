package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Q=require('worlds.query')

local function timed(name,fn)
  collectgarbage('collect'); local t=os.clock(); local a,b=fn()
  print(string.format('%-28s %.6f  %s %s',name,os.clock()-t,tostring(a or ''),tostring(b or '')))
end
local function strands(n,prefix)
  local b=W.builder(); local m=b:membrane(nil,prefix); local xs={}
  for i=1,n do xs[i]=b:strand(m,{},prefix..i) end
  return b:finish(),xs
end
local function first(q)
  local s=Q.solve(q)
  while true do local k,v=s:step(math.huge); if k~='more' then return k,v end end
end

-- Complete broad support: satisfiable first witness should stay cheap.
do
  local a,ss=strands(24,'s'); local b,tt=strands(24,'t')
  timed('close-complete-24',function() return first(Q.close({a,b},{sources=ss,targets=tt,required_targets=tt})) end)
end

-- Pure scarcity deficiency.  A naive injection DFS is factorial here; the shared
-- Hall allocator should reject it before enumeration.
do
  local n=24; local a,ss=strands(n,'s'); local b,tt=strands(n,'t'); local adm={}
  for _,t in ipairs(tt) do for i=1,n-1 do adm[#adm+1]={from=ss[i],to=t} end end
  timed('close-hall-no-24',function() return first(Q.close({a,b},{sources=ss,targets=tt,required_targets=tt,admissible=adm})) end)
end

-- Every source is required but every target is optional.  Only the full target
-- subset can be a witness; cardinality bounds must avoid walking 2^N subsets.
do
  local n=20; local a,ss=strands(n,'s'); local b,tt=strands(n,'t')
  timed('close-domain-20',function() return first(Q.close({a,b},{sources=ss,targets=tt,required_sources=ss,required_targets={}})) end)
end

-- Deliberately unresolved frontier: support is broad but exact rigid incidence
-- admits only one reversed permutation.  This remains a benchmark for a future
-- monotone structural-support compiler; Close must not use partial join pruning.
do
  local n=7; local rb=W.builder(); local rm=rb:membrane(nil,'rigid'); local ps={}
  for i=1,n do ps[i]=rb:point(rm,'p'..i) end; rb:finish()
  local ab=W.builder(); local am=ab:membrane(nil,'a'); local ss={}; for i=1,n do ss[i]=ab:strand(am,{ps[i]},'s'..i) end; local a=ab:finish()
  local bb=W.builder(); local bm=bb:membrane(nil,'b'); local tt={}; for i=1,n do local j=n-i+1; tt[i]=bb:strand(bm,{ps[j]},'t'..j) end; local b=bb:finish()
  timed('close-rigid-reversed-7',function() return first(Q.close({a,b},{sources=ss,targets=tt,required_targets=tt})) end)
end
