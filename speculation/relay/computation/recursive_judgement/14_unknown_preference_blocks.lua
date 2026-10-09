local H=require('speculation.relay.computation.recursive_judgement.common')
 local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.unary_bool_context({definition='f'},true),H.base_bool_context(nil)},{{1,2}})
 local r=p:root('f')
 local a=H.Analysis.compute(p)
local f=H.Search.family(p,r,2)
 local s=H.Judgement.first_stable(p,r,H.state_bool(nil),f,a)
eq(s,'Deferred','Unknown preferred branch was treated as failure')

local saw_block=false
 for _,row in ipairs(f.items) do local x=H.Judgement.check(p,r,H.state_bool(nil),row,a)
 if x=='Blocked' then saw_block=true end end
ok(saw_block,'no lower candidate was blocked by merely viable preference')
print('PASS rj 14: semantic Unknown remains viable and blocks dominated commitment ('..count()..')')
