local H=require('speculation.showcases.transactions.transactional_recursive_judgement.common')
 local K=H.K
 local ok,eq,count=H.counter()
local a_ctx=H.bool_context({'a'})
 local b_ctx=H.bool_context({'b'})
 local a=K.point_value(a_ctx,'a',true)
 local b=K.top(b_ctx)
local function forced(rel,p,v) return K.judge(rel,K.point_value(rel.ctx,p,v))=='Hit' end
local rounds=0
while true do rounds=rounds+1
 local na,nb=a,b
  if forced(a,'a',true) then nb=K.meet(nb,K.point_value(b_ctx,'b',true)) end
  if forced(b,'b',true) then na=K.meet(na,K.point_value(a_ctx,'a',true)) end
  if K.equal(na,a) and K.equal(nb,b) then break end
 a,b=na,nb
end
ok(rounds<=3,'positive reduction did not converge')
 ok(forced(b,'b',true),'cross-domain positive consequence missing')
local empty_a,empty_b=K.top(a_ctx),K.top(b_ctx)
 ok(not forced(empty_a,'a',true) and not forced(empty_b,'b',true),'mutual cycle bootstrapped truth from absence')
print('PASS rj 08: cross-domain interaction is least monotone positive closure ('..count()..')')
