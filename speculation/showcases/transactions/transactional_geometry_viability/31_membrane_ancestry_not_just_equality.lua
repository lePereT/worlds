local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local W=H.W
 local K=H.K
local function ctx(nested)
  local g={membranes={{parent=0},{parent=nested and 1 or 0}},points={{membrane=1},{membrane=2}},strands={{membrane=1,points={1}},{membrane=2,points={2}}},faces={}}
  return H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1,2},outputs={1,2}},values={inputs={},outputs={}}})
end
local p=H.one_root('f',{ctx(true),ctx(false)},{{1,2}})
 local r=p:root('f')
local b=W.builder()
 local m1=b:membrane(nil)
 local m2=b:membrane(nil)
 local s1=b:strand(m1,{b:point(m1)})
 local s2=b:strand(m2,{b:point(m2)})
 local state=b:finish()
 local fam=H.Search.family(p,r,1)
eq(H.Judgement.first_stable(p,r,state,H.empty_knowledge(),{s1,s2},fam),'Hit','nested-locality dominator matched sibling live localities')
print('PASS gv 31: Membrane ancestry, not merely equality, belongs to exact authority-boundary support ('..count()..')')
