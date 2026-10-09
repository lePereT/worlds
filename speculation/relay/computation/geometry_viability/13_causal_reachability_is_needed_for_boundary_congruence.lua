local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
 local K=H.K
local function child(cross)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,4 do g.points[i]={membrane=1}
 g.strands[i]={membrane=1,points={i}} end
  g.faces[1]={membrane=1,inputs={1},outputs={cross and 4 or 3}}
  g.faces[2]={membrane=1,inputs={2},outputs={cross and 3 or 4}}
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1,2},outputs={3,4}},values={inputs={},outputs={}}}),{}))
end
local a,b=child(false),child(true)
local function support_key(t) local p=H.A.profile(t)
 return Canonical.encode({support=p.support,authority=p.authority,open=p.open}) end
eq(support_key(a),support_key(b),'test pair did not isolate causal reachability from exact boundary support')
ok(H.A.key(a)~=H.A.key(b),'straight and crossed causal authority behaviour collapsed together')
-- Both are ordinary rooted developments and match the same exact source support.
local state,sources=H.state_two(false,true)
local pa=H.one_root('a',{H.Context.closed(a)})
 local pb=H.one_root('b',{H.Context.closed(b)})
eq(H.Judgement.first_stable(pa,pa:root('a'),state,H.empty_knowledge(),sources,H.Search.family(pa,pa:root('a'),1)),'Hit')
eq(H.Judgement.first_stable(pb,pb:root('b'),state,H.empty_knowledge(),sources,H.Search.family(pb,pb:root('b'),1)),'Hit')
print('PASS gv 13: causal reachability is independent exact boundary behaviour, not reducible to support ('..count()..')')
