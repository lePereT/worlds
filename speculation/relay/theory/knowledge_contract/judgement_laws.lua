local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
local n=0
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local ctx={'x','y'}
local k=R.relation(ctx,function(v) return v.x==1 end)
local entailed=R.relation(ctx,function(v) return v.x==1 or v.y==0 end)
local conflict=R.relation(ctx,function(v) return v.x==0 end)
local stronger=R.relation(ctx,function(v) return v.x==1 and v.y==1 end)
eq(K.judge(k,entailed),'Hit','entailed requirement was not Hit')
eq(K.judge(k,conflict),'Retry','inconsistent requirement was not Retry')
eq(K.judge(k,stronger),'Unknown','consistent refinement was not Unknown')
eq(K.judge(K.bottom(ctx),entailed),'Retry','inconsistent knowledge did not remain contradiction')
eq(K.judge(K.top(ctx),K.top(ctx)),'Hit','top requirement was not trivially established')
print('judgement laws: '..n..' assertions passed')
