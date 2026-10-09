package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1
assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function stage(name)
  local b=W.builder()
  local m=b:membrane(nil,name)
  local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i')
  local o=b:strand(m,{p},name..'.o')
  local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end
local function all(g) local o={}
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(g[k](g)) do o[#o+1]=x end end
  return o end

local A,a=stage('A')
local B,b=stage('B')
local D,d=stage('D')
print('1. first Construction closes A into B')
local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
local r1=c1:correspondence()
print('2. second Construction introduces a fresh Rule/part and closes B into D')
local bo=c1:image(b.o)
local c2=Construction.join({c1:result(),D},{{from=bo,to=d.i}})
local r2=c2:correspondence()
local staged=r1:compose(r2)
local parts=staged:source_parts()
eq(#parts,3,'composed correspondence did not retain fresh source part')
eq(parts[1],A)
eq(parts[2],B)
eq(parts[3],D)

print('3. one-shot multi-part Construction has the same source quotient')
local direct=Construction.join({A,B,D},{{from=a.o,to=b.i},{from=b.o,to=d.i}})
local rd=direct:correspondence()
ok(staged:same_source_partition(rd),'fresh-part staged composition changed source quotient')

print('4. common marked source still induces an exact endpoint map')
local map={}
for _,x in ipairs(all(c2:result())) do
  map[x]=assert(staged:mate(rd,x))
  ok(map[x]~=nil,'staged target carrier has no one-shot mate')
end
for _,s in ipairs(c2:result():strands()) do
  local ps,qs=W.points(s),W.points(map[s])
  eq(#ps,#qs)
  for i=1,#ps do eq(map[ps[i]],qs[i],'fresh-part Point incidence not preserved') end
end
print('PASS correspondence composition admits fresh exact parts',n,'assertions')
