local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local n=0
local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function judge(k,r)
  local both=R.meet(k,r)
  if R.equal(both,R.bottom(k.ctx)) then return 'Retry' end
  if R.equal(both,k) then return 'Hit' end
  return 'Unknown'
end
local ctx={'x','y'}
local k=R.relation(ctx,function(v) return v.x==1 end)
local entailed=R.relation(ctx,function(v) return v.x==1 or v.y==0 end)
local conflict=R.relation(ctx,function(v) return v.x==0 end)
local stronger=R.relation(ctx,function(v) return v.x==1 and v.y==1 end)
eq(judge(k,entailed),'Hit','entailed requirement was not Hit')
eq(judge(k,conflict),'Retry','inconsistent requirement was not Retry')
eq(judge(k,stronger),'Unknown','consistent refinement was not Unknown')
eq(judge(R.bottom(ctx),entailed),'Retry','inconsistent knowledge did not remain contradiction')
eq(judge(R.top(ctx),R.top(ctx)),'Hit','top requirement was not trivially established')
print('judgement laws: '..n..' assertions passed')
