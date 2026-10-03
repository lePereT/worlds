local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local C=require('speculation.showcases.theory.knowledge_contract.corelation')
math.randomseed(424242)
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end

local function names(prefix,count) local o={}
 for i=1,count do o[i]=prefix..i end
 return o end
local function random_relation(ctx)
  return R.relation(ctx, function() return math.random() < 0.5 end)
end

-- Construction-like corelation: each source is either connected to one target
-- or to a hidden source-only class. Distinct targets are never identified.
local function random_corelation(source,target)
  local eqs={}
  local hidden={}
  local anchors={}
  for _,s in ipairs(source) do
    local choice=math.random(1,#target+2)
    if choice<=#target then
      eqs[#eqs+1]={s,target[choice]}
    else
      local h=choice-#target
      if anchors[h] then eqs[#eqs+1]={s,anchors[h]} else anchors[h]=s end
    end
  end
  return C.new(source,target,eqs)
end

for case=1,500 do
  local S=names('s'..case..'_',math.random(1,4))
  local M=names('m'..case..'_',math.random(1,3))
  local T=names('t'..case..'_',math.random(1,3))
  local a=random_corelation(S,M)
  local b=random_corelation(M,T)
  local k=random_relation(S)
  local staged=C.transport(C.transport(k,a),b)
  local direct=C.transport(k,C.compose(a,b))
  ok(R.equal(staged,direct),'corelation action not functorial at generated case '..case)
end

print('generated corelations: '..n..' assertions passed')
