local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()

-- Red is locally preferred and its first rendezvous is perfectly lawful.
local offered=H.C.or_else(H.Channel.send('route-pref','red'),H.Channel.send('route-pref','blue'))
local lhs=H.C.together({offered,H.Channel.recv('route-pref')})
local lf=lhs:family()
eq(#lf.items,2,'preferred first rendezvous did not preserve fallback descendant')
eq(#lf.edges,1,'preferred first rendezvous lost dominance')
local edge=lf.edges[1]
eq(H.value(lhs,edge[1],1),'red','dominance no longer points from preferred red branch')
eq(H.value(lhs,edge[2],1),'blue','dominance no longer points to blue fallback')

-- Each tentative route creates a different first-class computation on the RHS.
local red=H.Formed.value_target('preferred_red','red-done',2)
local blue=H.Formed.value_target('fallback_blue','blue-done',2)
local selector=H.Formed.select({
  {value='red',root=red:root('preferred_red')},
  {value='blue',root=blue:root('fallback_blue')},
})
local forms=H.C.and_then(lhs,selector,{value_pairs={{from=1,to=1}}})
eq(#forms:family().edges,1,'and_then failed to lift LHS preference through dynamic Form creation')
local kind,performed=H.Formed.perform_selected(forms,{red,blue},
  {authority={inputs=2,outputs=0},values={inputs=0,outputs=1}})
eq(kind,'Hit','dynamic forms did not perform')
eq(#performed:family().edges,1,'perform lost tentative preference correlation')

-- The complete continuation accepts only blue. The preferred red rendezvous cannot
-- commit early: once its dynamically-created descendant is refuted, blue survives.
local guard=H.C.atom({geometry=H.G.empty(),
  theory={variables={'x','y'},equalities={
    H.T.eq(H.T.var('x'),'blue-done'),H.T.eq(H.T.var('y'),'complete')}},
  authority={inputs={},outputs={}},values={inputs={'x'},outputs={'y'}}})
local final=H.C.and_then(performed,guard,{value_pairs={{from=1,to=1}}})
eq(#final:family().items,1,'refuted preferred dependent continuation did not expose fallback')
eq(#final:family().edges,0,'resolved fallback retained dead dominance evidence')
eq(H.value(final,1,1),'complete','fallback dependent continuation produced wrong result')
ok(H.no_runtime_words(final:bytes()),'dynamic dependent continuation leaked runtime scheduler state')

print('PASS cc 24: or_else waits for the complete dynamically-formed descendant before preference commits ('..count()..')')
