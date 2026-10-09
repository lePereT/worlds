local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local xs={H.authority_identity_context(),H.unary_context({definition='f'})}
local p=H.one_root('f',xs,{})
 local q=H.one_root('f',xs,{{1,2}})
 local ap,aq=H.Analysis.compute(p),H.Analysis.compute(q)
local rp,rq=p:root('f'),q:root('f')
 local function keys(m) local a={} for k in pairs(m) do a[#a+1]=k end
 table.sort(a)
 return table.concat(a,'\n') end
eq(keys(ap.behaviour[rp]),keys(aq.behaviour[rq]),'dominance changed positive recursive viability')
print('PASS gv 28: OrderedFamily dominance remains Judgement structure, not Geometry viability ('..count()..')')
