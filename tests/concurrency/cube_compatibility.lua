package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local T=require('support')

local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'vocabulary'); local roles={}
for i=1,5 do roles[i]=vb:point(vm,'R'..i) end
vb:finish()

local function factorial(n) local x=1; for i=2,n do x=x*i end; return x end
local function permutations(xs)
  local out={}
  local function rec(a,i)
    if i>#a then local r={}; for j,v in ipairs(a) do r[j]=v end; out[#out+1]=r; return end
    for j=i,#a do a[i],a[j]=a[j],a[i]; rec(a,i+1); a[i],a[j]=a[j],a[i] end
  end
  rec(xs,1); return out
end
local function subsets(n)
  local out={}
  for mask=0,2^n-1 do local xs={}; for i=1,n do if math.floor(mask/2^(i-1))%2==1 then xs[#xs+1]=i end end; out[#out+1]=xs end
  return out
end
local function vertex_key(boundary)
  local seen={}; for _,s in ipairs(boundary:offers()) do local p=W.Geometry.points(s)[1]; for i,r in ipairs(roles) do if p==r then seen[i]=true end end end
  local xs={}; for i=1,#roles do if seen[i] then xs[#xs+1]=tostring(i) end end; return table.concat(xs,',')
end
local function build(n)
  local b=W.Geometry.builder(); local root=b:membrane(nil,'state'); local authorities={}
  for i=1,n do authorities[i]=b:strand(root,{roles[i]},'authority') end
  local base=b:finish(); local proc,pin={}, {}
  for i=1,n do local p=W.Geometry.builder(); local m=p:membrane(nil,'action'); local input=p:strand(m,{roles[i]},'input'); p:face(m,{input},{},'consume'); proc[i]=p:finish(); pin[i]=input end
  return base,authorities,proc,pin
end

local function cube(n)
  local base,authority,proc,pin=build(n); local vertices={}; local executions=0; local complete=0
  for _,subset in ipairs(subsets(n)) do
    local expected=nil
    for _,order in ipairs(permutations(subset)) do
      local boundary=W.Operational.from_geometry(base)
      for _,i in ipairs(order) do
        local q=W.Operational.query(boundary,proc[i],{strands={[pin[i]]=authority[i]}})
        local k,w=q:step(10); T.eq(k,'Hit'); T.eq(q:stats().steps,1,'independent exact edge must be one Cut candidate')
        W.Operational.commit(w)
      end
      local key=vertex_key(boundary); if not expected then expected=key else T.eq(key,expected,'all linearisations of one subset must reach one cube vertex') end
      vertices[key]=true; executions=executions+1; if #subset==n then complete=complete+1 end
    end
  end
  local nv=0; for _ in pairs(vertices) do nv=nv+1 end
  T.eq(nv,2^n,n..'-cube must have 2^n vertices')
  T.eq(complete,factorial(n),n..'-cube complete linearisations')
  return executions
end

T.eq(cube(3),16,'3-cube all subset-order executions')
T.eq(cube(5),326,'5-cube all subset-order executions')
return T.count()
