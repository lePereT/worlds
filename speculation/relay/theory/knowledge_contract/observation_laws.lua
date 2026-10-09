local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end

-- Observation is deliberately outside the domain contract.  This observer uses
-- only the finite relation oracle and returns a positive Knowledge certificate.
local function observe_value(k,var)
  local ctx=K.context(k)
  local idx=nil; for i,v in ipairs(ctx) do if v==var then idx=i end end
  assert(idx,'variable absent')
  local rows=R.rows(k)
  if #rows==0 then return 'Retry' end
  local seen={}
  for _,row in ipairs(rows) do seen[row:sub(idx,idx)]=true end
  if seen['0'] and seen['1'] then return 'Unknown' end
  local value=seen['1'] and 1 or 0
  local cert=R.relation(ctx,function(env) return env[var]==value end)
  local yes=assert(K.entails(k,cert))
  assert(yes,'observation certificate not entailed')
  return 'Hit',value,cert
end

local ctx={'x','y'}
local k=R.relation(ctx,function(v) return v.x==1 end)
local kind,value,cert=observe_value(k,'x')
ok(kind=='Hit' and value==1,'determinate observation failed')
local entailed=K.entails(k,cert)
ok(entailed,'observation lacked positive certificate')

local stronger=K.meet(k,R.relation(ctx,function(v) return v.y==0 end))
local k2,v2=observe_value(stronger,'x')
ok(k2=='Hit' and v2==value,'positive observation was not stable under strengthening')

local changed=R.relation(ctx,function(v) return v.x==0 end)
local replay=K.entails(changed,cert)
ok(not replay,'contradictory replay unexpectedly entailed old certificate')

local ambiguous=K.top(ctx)
local function bad_pick(rel,var)
  local c=K.context(rel); local idx=nil; for i,v in ipairs(c) do if v==var then idx=i end end
  local rows=R.rows(rel); if #rows==0 then return nil end
  return tonumber(rows[1]:sub(idx,idx))
end
local picked=bad_pick(ambiguous,'x')
local force_other=R.relation(ctx,function(v) return v.x==(1-picked) end)
ok(bad_pick(force_other,'x')~=picked,'arbitrary witness pick accidentally stable')

-- Bottom/absence is not a positive observed value.
ok(observe_value(K.bottom(ctx),'x')=='Retry','contradiction was not observational Retry')

print('observation laws: '..n..' assertions passed')
