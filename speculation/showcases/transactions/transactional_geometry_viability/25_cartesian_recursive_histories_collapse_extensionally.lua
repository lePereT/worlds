local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K
local g={membranes={{parent=0}},points={},strands={},faces={}}
for i=1,6 do g.points[i]={membrane=1}
 g.strands[i]={membrane=1,points={i}} end
g.faces={{membrane=1,inputs={1},outputs={3}},{membrane=1,inputs={2},outputs={4}}}
local pair=H.Context.normal({template={geometry=g,theory=K.spec(K.top({})),authority={inputs={1,2,5,6},outputs={3,4,5,6}},values={inputs={},outputs={}}},outer={authority={inputs={1,2},outputs={3,4}},values={inputs={},outputs={}}},holes={
  {target={definition='loop'},authority={to_target={1},from_target={3}},values={to_target={},from_target={}}},
  {target={definition='loop'},authority={to_target={2},from_target={4}},values={to_target={},from_target={}}},
}})
local p=H.rec_package({{identity='loop',alternatives={H.authority_identity_context(),H.unary_context({definition='loop'})}},{identity='pair',alternatives={pair}}})
local a=H.Analysis.compute(p)
 local pr=p:root('pair')
 local n=0
 local only
for _,c in pairs(a.behaviour[pr]) do n=n+1
 only=c end
eq(n,1,'Cartesian recursive histories leaked despite identical external authority behaviour')
local profile=only.spec.authority
eq(#profile.causal,2,'pair boundary lost two authority inputs')
ok(profile.causal[1][1] and profile.causal[2][2] and not profile.causal[1][2] and not profile.causal[2][1],'independent authority channels were cross-serialised')
print('PASS gv 25: Cartesian recursive histories collapse to one extensional two-channel boundary case ('..count()..')')
