local H=require('speculation.relay.computation.recursive_judgement.common')
 local ok,eq,count=H.counter()
local p=H.rec_package('f',{H.unary_bool_context({definition='f'}),H.base_bool_context(nil)},{{1,2}})
 local r=p:root('f')
 local a=H.Analysis.compute(p)
for depth=1,3 do
  local f=H.Search.family(p,r,depth)
 local frontier=H.Family.frontier(f)
 eq(#frontier,1,'finite search should expose one temporary frontier')
  local row=f.items[frontier[1]]
 eq(H.Judgement.check(p,r,H.state_bool(true),row,a),'Blocked','frontier position leaked into commit eligibility')
end
print('PASS rj 24: OrderedFamily frontier is discovery data, never recursive commit proof ('..count()..')')
