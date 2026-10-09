local H=require('speculation.relay.computation.recursive_judgement.common')
 local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.base_bool_context(nil),H.unary_bool_context({definition='f'})},{{1,2}})
 local r=p:root('f')
 local a=H.Analysis.compute(p)
local roots={}
for depth=1,3 do local f=H.Search.family(p,r,depth)
 local s,row=H.Judgement.first_stable(p,r,H.state_bool(true),f,a)
 eq(s,'Hit')
 roots[#roots+1]=H.Canonical.encode(row.value) end
for i=2,#roots do eq(roots[i],roots[1],'deeper discovery changed selected stable meaning') end
print('PASS rj 16: search depth does not participate in stable semantic eligibility ('..count()..')')
