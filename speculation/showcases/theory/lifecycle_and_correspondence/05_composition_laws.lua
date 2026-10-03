package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local C=require('speculation.showcases.theory.lifecycle_and_correspondence.correspondence')
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
local r1=C.from_construction(c1)
local c2=Construction.join({c1:result(),D},{{from=c1:image(b.o),to=d.i}})
local r2=C.from_construction(c2)
local c3=Construction.join({c2:result(),E},{{from=c2:image(d.o),to=e.i}})
local r3=C.from_construction(c3)

print('1. correspondence composition is associative with fresh parts')
local left=C.compose(C.compose(r1,r2),r3)
local right=C.compose(r1,C.compose(r2,r3))
ok(C.same_source_partition(left,right),'associative grouping changed source quotient')
local map=C.between(left,right)
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(left:target()[k](left:target())) do
    eq(map[x],x,'associativity changed exact target')
  end
end

print('2. right identity preserves the complete correspondence')
local rid=C.compose(left,C.identity(left:target()))
ok(C.same_source_partition(left,rid),'right identity changed source quotient')
local rmap=C.between(left,rid)
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,x in ipairs(left:target()[k](left:target())) do
    eq(rmap[x],x,'right identity changed target')
  end
end

print('3. left identity works for an ordinary one-part Construction')
local X,x=stage('X')
local Y,y=stage('Y')
local c=Construction.join({X},{})
local rc=C.from_construction(c)
local lid=C.compose(C.identity(X),rc)
ok(C.same_source_partition(lid,rc),'left identity changed source quotient')
local lmap=C.between(lid,rc)
for _,k in ipairs{'membranes','points','strands','faces'} do
  for _,z in ipairs(rc:target()[k](rc:target())) do eq(lmap[z],z,'left identity changed target') end
end
print('PASS Construction correspondence obeys identity and associativity',n,'assertions')
