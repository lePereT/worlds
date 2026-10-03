local W=require('worlds')
local Q=require('worlds.query')
local C={}

function C.check(x,msg) assert(x,msg or 'check failed')
return true end
function C.eq(a,b,msg) assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b))
return true end
function C.decide(question)
  local e=Q.solve(question)
  while true do local k,x=e:step(math.huge)
  if k=='yes' or k=='no' then return k,x elseif k=='done' then return 'no',x end end
end
function C.match(source,target,seeds)
  
function C.roles(names,prefix)
  local b=W.builder()
  local m=b:membrane(nil,(prefix or 'ext')..'.roles')
  local out={}
  for _,name in ipairs(names) do out[name]=b:point(m,name) end
  b:strand(m,{},(prefix or 'ext')..'.anchor')
  out._geometry=b:finish()
  out._membrane=m
  return out
end
function C.depth(m) local n=0
while m do n=n+1
m=W.parent(m) end
return n end
function C.flatten(rows) local out={}
for _,row in ipairs(rows or {}) do for _,x in ipairs(row) do out[#out+1]=x end end
return out end
function C.match_seeded(source,target,source_rows,target_rows)
  local a,b=C.flatten(source_rows),C.flatten(target_rows)
  assert(#a==#b,'seed row arity mismatch')
  local seeds={}
  for i=1,#a do seeds[i]={from=a[i],to=b[i]} end
  return C.decide(Q.match(source,target,{seeds=seeds}))=='yes'
end
function C.face_reaches(g,a,b)
  if a==b then return true end
  local adj={}
  for _,f in ipairs(g:faces()) do adj[f]={} end
  for _,s in ipairs(g:strands()) do local p,c=g:producer(s),g:consumer(s)
  if p and c then adj[p][c]=true end end
  local seen={}
  local function walk(x) if x==b then return true end
  if seen[x] then return false end
  seen[x]=true
  for y in pairs(adj[x] or {}) do if walk(y) then return true end end
  return false end
  return walk(a)
end
return C.decide(Q.match(source,target,{seeds=seeds or {}}))
end
function C.named(xs,name) for _,x in ipairs(xs) do if W.name(x)==name then return x end end end
function C.carrier_fact(f,pred)
  return f.pred==pred and f.args or nil
end
function C.fact_exists(state,pred,args)
  for _,f in ipairs(state:select(pred)) do
    if #f.args==#args then local ok=true
    for i=1,#args do if f.args[i]~=args[i] then ok=false
    break end end
    if ok then return true end end
  end
  return false
end

function C.roles(names,prefix)
  local b=W.builder()
  local m=b:membrane(nil,(prefix or 'ext')..'.roles')
  local out={}
  for _,name in ipairs(names) do out[name]=b:point(m,name) end
  b:strand(m,{},(prefix or 'ext')..'.anchor')
  out._geometry=b:finish()
  out._membrane=m
  return out
end
function C.depth(m) local n=0
while m do n=n+1
m=W.parent(m) end
return n end
function C.flatten(rows) local out={}
for _,row in ipairs(rows or {}) do for _,x in ipairs(row) do out[#out+1]=x end end
return out end
function C.match_seeded(source,target,source_rows,target_rows)
  local a,b=C.flatten(source_rows),C.flatten(target_rows)
  assert(#a==#b,'seed row arity mismatch')
  local seeds={}
  for i=1,#a do seeds[i]={from=a[i],to=b[i]} end
  return C.decide(Q.match(source,target,{seeds=seeds}))=='yes'
end
function C.face_reaches(g,a,b)
  if a==b then return true end
  local adj={}
  for _,f in ipairs(g:faces()) do adj[f]={} end
  for _,s in ipairs(g:strands()) do local p,c=g:producer(s),g:consumer(s)
  if p and c then adj[p][c]=true end end
  local seen={}
  local function walk(x) if x==b then return true end
  if seen[x] then return false end
  seen[x]=true
  for y in pairs(adj[x] or {}) do if walk(y) then return true end end
  return false end
  return walk(a)
end
return C
