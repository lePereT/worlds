local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local W=H.W
 local K=H.K
local function target(second_uses_first)
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={},faces={}}
  g.strands[1]={membrane=1,points={1,2}}
 g.strands[2]={membrane=1,points={second_uses_first and 1 or 2}}
  return H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1,2},outputs={1,2}},values={inputs={},outputs={}}})
end
local p=H.one_root('f',{target(false),target(true)},{{1,2}})
 local r=p:root('f')
local b=W.builder()
 local m=b:membrane(nil)
 local a=b:point(m)
 local z=b:point(m)
 local s1=b:strand(m,{a,z})
 local s2=b:strand(m,{a})
 local state=b:finish()
 local fam=H.Search.family(p,r,1)
-- Preferred uses the second point for port 2, which would force z=a and is impossible.
eq(H.Judgement.first_stable(p,r,state,H.empty_knowledge(),{s1,s2},fam),'Hit','ordered Point incidence/sharing was flattened in authority viability')
print('PASS gv 32: ordered Point incidence and cross-port Point sharing remain exact ('..count()..')')
