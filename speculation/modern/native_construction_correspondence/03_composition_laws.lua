package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local Oracle=require('speculation.modern.restrictive_theory_followup.correspondence')
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
local function all(g)
  local out={}
  for _,k in ipairs{'membranes','points','strands','faces'} do
    for _,x in ipairs(g[k](g)) do out[#out+1]=x end
  end
  return out
end
local function oracle_partition(native,oracle)
  local xs={}
  for _,g in ipairs(native:source_parts()) do
    for _,x in ipairs(all(g)) do xs[#xs+1]=x end
  end
  for i=1,#xs do for j=1,#xs do
    eq(native:source_equivalent(xs[i],xs[j]),oracle:source_equivalent(xs[i],xs[j]),
        'native source quotient differs from oracle')
  end end
end

local A,a=stage('A')
local B,b=stage('B')
local D,d=stage('D')
local E,e=stage('E')

print('1. staged correspondence composition admits fresh exact parts')
local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
local c2=Construction.join({c1:result(),D},{{from=c1:image(b.o),to=d.i}})
local n12=c1:correspondence():compose(c2:correspondence())
local o12=Oracle.compose(Oracle.from_construction(c1),Oracle.from_construction(c2))
local parts=n12:source_parts()
eq(#parts,3,'fresh exact source part was lost')
eq(parts[1],A)
eq(parts[2],B)
eq(parts[3],D)
oracle_partition(n12,o12)
local direct=Construction.join({A,B,D},{{from=a.o,to=b.i},{from=b.o,to=d.i}})
ok(n12:same_source_partition(direct:correspondence()),
    'fresh-part staged composition differs from one-shot Construction')
for _,x in ipairs(all(c2:result())) do
  eq(n12:mate(direct:correspondence(),x),Oracle.between(o12,Oracle.from_construction(direct))[x],
      'fresh-part endpoint mate differs from oracle')
end

print('2. native correspondence composition is associative')
local c3=Construction.join({c2:result(),E},{{from=c2:image(d.o),to=e.i}})
local n1,n2,n3=c1:correspondence(),c2:correspondence(),c3:correspondence()
local left=n1:compose(n2):compose(n3)
local right=n1:compose(n2:compose(n3))
ok(left:same_source_partition(right),'associative grouping changed source quotient')
for _,x in ipairs(all(left:target())) do eq(left:mate(right,x),x,'associativity changed target') end

print('3. native correspondence has left and right identity')
local id_target=Construction.join({left:target()},{})
local right_id=left:compose(id_target:correspondence())
ok(left:same_source_partition(right_id),'right identity changed source quotient')
for _,x in ipairs(all(left:target())) do
  eq(left:mate(right_id,x),x,'right identity changed target')
end
local id_A=Construction.join({A},{})
local one=Construction.join({A},{})
local left_id=id_A:correspondence():compose(one:correspondence())
ok(left_id:same_source_partition(one:correspondence()),'left identity changed source quotient')
for _,x in ipairs(all(A)) do
  eq(left_id:mate(one:correspondence(),x),x,'left identity changed target')
end

print('PASS native Construction correspondence composition laws',n,'assertions')
