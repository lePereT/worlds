local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
math.randomseed(24681357)
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function same(a,b,msg) ok(K.equal(a,b),msg) end

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
  local ny,nz,nx=math.random(1,2),math.random(1,2),math.random(1,2)
  local Y,Z,X=names('y'..case..'_',ny),names('z'..case..'_',nz),names('x'..case..'_',nx)
  local YZ={}; for _,v in ipairs(Y) do YZ[#YZ+1]=v end; for _,v in ipairs(Z) do YZ[#YZ+1]=v end
  local XZ={}; for _,v in ipairs(X) do XZ[#XZ+1]=v end; for _,v in ipairs(Z) do XZ[#XZ+1]=v end
  local phi=random_relation(YZ)
  local sigma={}; for _,y in ipairs(Y) do sigma[y]=X[math.random(1,#X)] end
  local ex=K.exists(phi,Y)
  local lhs=K.reindex(ex,X,sigma)
  local ext={}; for _,y in ipairs(Y) do ext[y]=sigma[y] end; for _,z in ipairs(Z) do ext[z]=z end
  local rhs=K.exists(K.reindex(phi,XZ,ext),X)
  same(lhs,rhs,'generated Beck-Chevalley failed at case '..case)
end

-- Generated Frobenius instances.
for case=1,200 do
  local X={'x'..case}; local Z={'z'..case}; local XZ={X[1],Z[1]}
  local phi=random_relation(XZ)
  local psi=random_relation(X)
  local pb=K.reindex(psi,XZ,{[X[1]]=X[1]})
  same(K.exists(K.meet(phi,pb),X),K.meet(K.exists(phi,X),psi),
    'generated Frobenius failed at case '..case)
end

-- A deliberately wrong *partial-image* transport model.  This remains in the
-- lab only as a falsifier: it is not a Knowledge/domain operation.  It hides nil
-- images first and therefore forgets source identifications that disappear later.
local function partial_transport(k,target,image)
  local visible,sigma={},{}
  for _,x in ipairs(K.context(k)) do
    local y=image[x]
    if y~=nil then visible[#visible+1]=x; sigma[x]=y end
  end
  return K.reindex(K.exists(k,visible),target,sigma)
end
local function compose_image(first,second)
  local out={}
  for x,y in pairs(first) do out[x]=y and second[y] or nil end
  return out
end

local partial_failures=0
for case=1,300 do
  local S=names('s'..case..'_',math.random(1,3))
  local M=names('m'..case..'_',math.random(1,3))
  local T=names('t'..case..'_',math.random(1,2))
  local f,g={},{}
  for _,sv in ipairs(S) do if math.random()<0.75 then f[sv]=M[math.random(1,#M)] end end
  for _,mv in ipairs(M) do if math.random()<0.75 then g[mv]=T[math.random(1,#T)] end end
  local k=random_relation(S)
  local staged=partial_transport(partial_transport(k,M,f),T,g)
  local direct=partial_transport(k,T,compose_image(f,g))
  if not K.equal(staged,direct) then partial_failures=partial_failures+1 end
end
ok(partial_failures>0,'generated search found no counterexample to partial-image composition')
print('  partial-image staged/direct mismatches: '..partial_failures..' / 300 generated cases')

print('generated doctrine laws: '..n..' assertions passed')
