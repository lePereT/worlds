-- Atlas-derived quantum attack: identical-particle symmetry over exact occurrence fibres.
-- Exact Worlds occurrences remain causally individual. External quantum semantics may
-- carry representations of the permutation group acting on allocations within a row.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local wb=W.builder(); local wm=wb:membrane(nil,'mode')
local mode=wb:point(wm,'single-particle-state')
local s1=wb:strand(wm,{mode},'exact particle occurrence 1')
local s2=wb:strand(wm,{mode},'exact particle occurrence 2')
local s3=wb:strand(wm,{mode},'exact particle occurrence 3')
local world=wb:finish()

local tb=W.builder(); local tm=tb:membrane(nil,'requirements')
local X=tb:point(tm,'X')
local d1=tb:strand(tm,{X},'d1'); local d2=tb:strand(tm,{X},'d2'); local d3=tb:strand(tm,{X},'d3')
local target=tb:finish()

local q=W.solve(world,target)
local sols={}
while true do
  local tag,x=q:step(math.huge)
  if tag=='yes' then sols[#sols+1]=x
  elseif tag=='done' or tag=='no' then break end
end
eq(#sols,6,'three identical scarce demands have 3! exact allocations')

local source_index={[s1]=1,[s2]=2,[s3]=3}
local demand_index={[d1]=1,[d2]=2,[d3]=3}
local function permutation_of(eqs)
  local p={}
  for _,e in ipairs(eqs) do p[demand_index[e.to]]=source_index[e.from] end
  return p
end
local function sign(p)
  local inv=0
  for i=1,#p do for j=i+1,#p do if p[i]>p[j] then inv=inv+1 end end end
  return (inv%2==0) and 1 or -1
end
local boson,fermion=0,0
local even,odd=0,0
for _,es in ipairs(sols) do
  local p=permutation_of(es); local s=sign(p)
  boson=boson+1
  fermion=fermion+s
  if s==1 then even=even+1 else odd=odd+1 end
end
eq(even,3,'S3 has three even allocations')
eq(odd,3,'S3 has three odd allocations')
eq(boson,6,'trivial representation adds all exact allocations')
eq(fermion,0,'sign representation cancels repeated-state allocations')

-- Exact identity is nevertheless not quotiented away causally.
local function consume(which)
  local b=W.builder(); local m=b:membrane(nil,'consume'); local Y=b:point(m,'Y')
  local i=b:strand(m,{Y},'in'); local o=b:strand(m,{Y},'out'); b:face(m,{i},{o},'consume one'); local dev=b:finish()
  local sol=W.solve(world,dev,{{from=which,to=i}}); local tag,es=sol:step(math.huge); eq(tag,'yes')
  local live=W.advance(world,dev,es)
  return live
end
local l1=consume(s1); ok(not l1:owns_strand(s1),'selected exact occurrence is consumed'); ok(l1:owns_strand(s2) and l1:owns_strand(s3),'siblings in fibre survive')
local l2=consume(s2); ok(l2:owns_strand(s1) and not l2:owns_strand(s2),'different exact consumption gives different history')

print('permutation fibres: '..n..' assertions passed')
print('  exact allocation fibre carries an S3 action: trivial character sums to 6, sign character to 0')
print('  permutation quotient does not erase exact causal individuality')
