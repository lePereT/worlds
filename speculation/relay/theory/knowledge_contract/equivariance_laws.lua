local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
math.randomseed(314159)
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function names(prefix,count) local o={}; for i=1,count do o[i]=prefix..i end; return o end
local function random_relation(ctx) return R.relation(ctx,function() return math.random()<0.5 end) end
for case=1,100 do
  local m=math.random(1,4)
  local A=names('a'..case..'_',m)
  local B=names('b'..case..'_',m)
  local f,g={},{}
  for i=1,m do f[A[i]]=B[i]; g[B[i]]=A[i] end
  local k=random_relation(A)
  local renamed=K.reindex(k,B,f)
  local restored=K.reindex(renamed,A,g)
  ok(K.equal(k,restored),'alpha/isomorphism transport changed knowledge at case '..case)
end
print('equivariance laws: '..n..' assertions passed')
