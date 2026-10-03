local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local a=H.guarded_identity_context(1,false) -- Geometry fits, knowledge does not.
local b=H.guarded_identity_context(2,true)  -- Knowledge fits, Geometry does not.
local c=H.guarded_identity_context(1,true)  -- Only this complete case fits both.
local p=H.one_root('f',{a,b,c},{{1,3},{2,3}})
 local r=p:root('f')
local state,sources=H.state_one(1)
 local fam=H.Search.family(p,r,1)
local status,row=H.Judgement.first_stable(p,r,state,H.state_bool(true),sources,fam)
eq(status,'Hit','independent Geometry/Theory unions falsely manufactured a dominating completion')
ok(row and #row.value.geometry.points==2,'the correlated fallback was not selected')
print('PASS gv 07: authority and knowledge remain correlated as boundary Development cases ('..count()..')')
