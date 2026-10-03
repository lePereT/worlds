local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end

local function observe_value(k,var)
  local seen={}
  local idx=nil
 for i,v in ipairs(k.ctx) do if v==var then idx=i end end
  assert(idx,'variable absent')
  for row in pairs(k.rows) do seen[row:sub(idx,idx)]=true end
  if next(seen)==nil then return 'Retry' end
  if seen['0'] and seen['1'] then return 'Unknown' end
  local value=seen['1'] and 1 or 0
  local cert=R.relation(k.ctx,function(env) return env[var]==value end)
  assert(R.leq(k,cert),'observation certificate not entailed')
  return 'Hit',value,cert
end

local ctx={'x','y'}
local k=R.relation(ctx,function(v) return v.x==1 end)
local kind,value,cert=observe_value(k,'x')
ok(kind=='Hit' and value==1,'determinate observation failed')
ok(R.leq(k,cert),'observation lacked positive certificate')

-- Once an observation is established, any consistent strengthening preserves it.
local stronger=R.meet(k,R.relation(ctx,function(v) return v.y==0 end))
local k2,v2=observe_value(stronger,'x')
ok(k2=='Hit' and v2==value,'positive observation was not stable under strengthening')

-- Replay against contradictory knowledge cannot establish the same certificate.
local changed=R.relation(ctx,function(v) return v.x==0 end)
ok(not R.leq(changed,cert),'contradictory replay unexpectedly entailed old certificate')

-- Arbitrarily selecting one possible witness is not a valid observation.
local ambiguous=R.top(ctx)
local function bad_pick(rel,var)
  local idx=nil
 for i,v in ipairs(rel.ctx) do if v==var then idx=i end end
  local rows=R.rows(rel)
 if #rows==0 then return nil end
  return tonumber(rows[1]:sub(idx,idx))
end
local picked=bad_pick(ambiguous,'x')
local force_other=R.relation(ctx,function(v) return v.x==(1-picked) end)
ok(bad_pick(force_other,'x')~=picked,'arbitrary witness pick accidentally stable')

-- Absence is not positive knowledge: adding a fact may invalidate an absence answer.
local function bad_absence(rel)
  return next(rel.rows)==nil and 'empty' or 'nonempty'
end
ok(
  bad_absence(R.bottom(ctx)) ~= bad_absence(k),
  'absence-sensitive observation exposed non-monotone information'
)

print('observation laws: '..n..' assertions passed')
