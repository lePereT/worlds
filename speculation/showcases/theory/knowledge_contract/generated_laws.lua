local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
math.randomseed(24681357)
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
local function same(a,b,msg) ok(R.equal(a,b),msg) end

local function random_relation(ctx)
  return R.relation(ctx,function() return math.random(0,1)==1 end)
end

local function names(prefix,count)
  local out={}
 for i=1,count do out[i]=prefix..i end
 return out
end

-- Generated Beck-Chevalley squares for substitution followed by existential hiding.
for case=1,200 do
  local ny=math.random(1,2)
  local nz=math.random(1,2)
  local nx=math.random(1,2)
  local Y=names('y'..case..'_',ny)
  local Z=names('z'..case..'_',nz)
  local X=names('x'..case..'_',nx)
  local YZ={}
 for _,v in ipairs(Y) do YZ[#YZ+1]=v end
 for _,v in ipairs(Z) do YZ[#YZ+1]=v end
  local XZ={}
 for _,v in ipairs(X) do XZ[#XZ+1]=v end
 for _,v in ipairs(Z) do XZ[#XZ+1]=v end
  local phi=random_relation(YZ)
  local sigma={}
  for _,y in ipairs(Y) do sigma[y]=X[math.random(1,#X)] end
  local ex=R.exists(phi,Y)
  local lhs=R.reindex(ex,X,sigma)
  local ext={}
  for _,y in ipairs(Y) do ext[y]=sigma[y] end
  for _,z in ipairs(Z) do ext[z]=z end
  local rhs=R.exists(R.reindex(phi,XZ,ext),X)
  same(lhs,rhs,'generated Beck-Chevalley failed at case '..case)
end

-- Generated Frobenius instances.
for case=1,200 do
  local X={'x'..case}
 local Z={'z'..case}
 local XZ={X[1],Z[1]}
  local phi=random_relation(XZ)
  local psi=random_relation(X)
  local pb=R.reindex(psi,XZ,{[X[1]]=X[1]})
  same(R.exists(R.meet(phi,pb),X),R.meet(R.exists(phi,X),psi),
    'generated Frobenius failed at case '..case)
end

-- Partial carrier images are deliberately *not* compositional enough. Search
-- generated cases for a witness where an intermediate identification is later
-- hidden and therefore has a semantic effect not present in the final partial map.
local partial_failures=0
for case=1,300 do
  local S=names('s'..case..'_',math.random(1,3))
  local M=names('m'..case..'_',math.random(1,3))
  local T=names('t'..case..'_',math.random(1,2))
  local f,g={},{}
  for _,sv in ipairs(S) do if math.random()<0.75 then f[sv]=M[math.random(1,#M)] end end
  for _,mv in ipairs(M) do if math.random()<0.75 then g[mv]=T[math.random(1,#T)] end end
  local k=random_relation(S)
  local staged=R.transport(R.transport(k,M,f),T,g)
  local direct=R.transport(k,T,R.compose_image(f,g))
  if not R.equal(staged,direct) then partial_failures=partial_failures+1 end
end
ok(partial_failures>0,'generated search found no counterexample to partial-image composition')
print('  partial-image staged/direct mismatches: '..partial_failures..' / 300 generated cases')

print('generated doctrine laws: '..n..' assertions passed')
