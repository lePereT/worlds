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
local A,a=stage('A')
local B,b=stage('B')
local D,d=stage('D')
local E,e=stage('E')
local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
local r1=c1:correspondence()
local c2=Construction.join({c1:result(),D},{{from=c1:image(b.o),to=d.i}})
local r2=c2:correspondence()
local c3=Construction.join({c2:result(),E},{{from=c2:image(d.o),to=e.i}})
local r3=c3:correspondence()

print('1. correspondence composition is associative with fresh parts')
local left=r1:compose(r2):compose(r3)
local right=r1:compose(r2:compose(r3))
ok(left:same_source_partition(right),'associative grouping changed source quotient')
local map={}
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(left:target()[k](left:target())) do map[x]=assert(left:mate(right,x)) end
end
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(left:target()[k](left:target())) do
    eq(map[x],x,'associativity changed exact target')
  end
end

print('2. right identity preserves the complete correspondence')
local rid=left:compose(Construction.join({left:target()},{ }):correspondence())
ok(left:same_source_partition(rid),'right identity changed source quotient')
local rmap={}
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(left:target()[k](left:target())) do rmap[x]=assert(left:mate(rid,x)) end
end
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(left:target()[k](left:target())) do
    eq(rmap[x],x,'right identity changed target')
  end
end

print('3. left identity works for an ordinary one-part Construction')
local X,x=stage('X')
local Y,y=stage('Y')
local c=Construction.join({X},{})
local rc=c:correspondence()
local lid=Construction.join({X},{ }):correspondence():compose(rc)
ok(lid:same_source_partition(rc),'left identity changed source quotient')
local lmap={}
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,z in ipairs(lid:target()[k](lid:target())) do lmap[z]=assert(lid:mate(rc,z)) end
end
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,z in ipairs(rc:target()[k](rc:target())) do eq(lmap[z],z,'left identity changed target') end
end
print('PASS Construction correspondence obeys identity and associativity',n,'assertions')
