local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()

-- The first rendezvous is still tentative semantic meaning: either payload can be
-- proffered. Nothing has committed merely because a sibling closure exists.
local offered=H.C.choice(H.Channel.send('route','red'),H.Channel.send('route','blue'))
local lhs=H.C.together({offered,H.Channel.recv('route')})
eq(#lhs:family().items,2,'first rendezvous did not preserve both tentative results')

-- The RHS is one ordinary relation which creates a different Form root depending
-- on the tentative LHS result. No Lua continuation is used to select the root.
local red=H.Formed.value_target('dependent_red','red-done',2)
local blue=H.Formed.value_target('dependent_blue','blue-done',2)
local selector=H.Formed.select({
  {value='red',root=red:root('dependent_red')},
  {value='blue',root=blue:root('dependent_blue')},
})
local forms=H.C.and_then(lhs,selector,{value_pairs={{from=1,to=1}}})
eq(#forms:family().items,2,'dependent form construction lost a tentative LHS result')

local roots={}
for i,a in ipairs(forms:family().items) do
  eq(#a.geometry.faces,1,'creating a Form from knowledge manufactured causality')
  eq(#a.authority.outputs,2,'residual exact authority was not carried as Form capture')
  roots[H.T.value(a.theory,a.values.outputs[1])]=true
end
ok(roots[red:root('dependent_red')] and roots[blue:root('dependent_blue')],
  'tentative LHS result did not select the corresponding Form root')

local kind,result=H.Formed.perform_selected(forms,{red,blue},
  {authority={inputs=2,outputs=0},values={inputs=0,outputs=1}})
eq(kind,'Hit','dependent formed continuation did not establish')
eq(#result:family().items,2,'perform pruned a still-admitted tentative result')
local seen={}
for i,a in ipairs(result:family().items) do
  seen[H.T.value(a.theory,a.values.outputs[1])]=true
  eq(#a.geometry.faces,2,'performed dependent form did not compose the continuation work')
  eq(#a.authority.outputs,0,'performed dependent form left captured authority open')
  local r12=H.G.face_reaches(a.geometry,1,2)
  local r21=H.G.face_reaches(a.geometry,2,1)
  ok(r12~=r21,'captured authority did not induce one-way continuation causality')
end
ok(seen['red-done'] and seen['blue-done'],'dependent form results lost branch correlation')

print('PASS cc 23: and_then forms a new RHS computation from tentative LHS knowledge ('..count()..')')
