local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local p=H.one_root('f',{H.authority_identity_context(),H.unary_context({definition='f'}),H.unary_context({definition='f'},{suffix=true})})
local r=p:root('f')
 local a=H.Analysis.compute(p)
 local seen={}
for depth=1,6 do
  local f=H.Search.family(p,r,depth)
  for _,row in ipairs(f.items) do local k=H.Case.key(row.value)
 seen[k]=true
 ok(a.behaviour[r][k]~=nil,'finite discovered case absent from least fixed point') end
end
local n,m=0,0
 for _ in pairs(a.behaviour[r]) do n=n+1 end
 for _ in pairs(seen) do m=m+1 end
eq(m,n,'bounded unfoldings did not cover the finite boundary quotient in this pressure')
print('PASS gv 22: boundary-case fixed point agrees with explicit finite unfoldings ('..count()..')')
