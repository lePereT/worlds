local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local a=H.authority_identity_context()
 local b=H.unary_context({definition='f'})
local p=H.one_root('f',{a,b})
 local q=H.one_root('g',{H.unary_context({definition='g'}),H.authority_identity_context()})
local ap,aq=H.Analysis.compute(p),H.Analysis.compute(q)
 local function keys(m) local x={} for k in pairs(m) do x[#x+1]=k end
 table.sort(x)
 return table.concat(x,'\n') end
eq(keys(ap.behaviour[p:root('f')]),keys(aq.behaviour[q:root('g')]),'source alternative order changed boundary-case denotation')
print('PASS gv 29: recursive boundary viability is invariant under source alternative order and alpha-renaming ('..count()..')')
