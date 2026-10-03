local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K

local function split_merge(target)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,10 do g.points[i]={membrane=1}
 g.strands[i]={membrane=1,points={i}} end
  -- two outer inputs -> merge -> split into the two recursive inputs
  g.faces[1]={membrane=1,inputs={1,2},outputs={3}}
  g.faces[2]={membrane=1,inputs={3},outputs={4,5}}
  -- recursive outputs -> merge -> split into two outer outputs
  g.faces[3]={membrane=1,inputs={6,7},outputs={8}}
  g.faces[4]={membrane=1,inputs={8},outputs={9,10}}
  return H.Context.normal({
    template={geometry=g,theory=K.spec(K.top({})),authority={inputs={1,2,6,7},outputs={4,5,9,10}},values={inputs={},outputs={}}},
    outer={authority={inputs={1,2},outputs={3,4}},values={inputs={},outputs={}}},
    holes={{target=target,authority={to_target={1,2},from_target={3,4}},values={to_target={},from_target={}}}}
  })
end

local base=assert(H.Context.plug(H.two_port_context(1,1),{}))
local once=assert(H.Context.plug(split_merge({definition='f'}),{base}))
local twice=assert(H.Context.plug(split_merge({definition='f'}),{once}))
-- After one split/merge shell every public input causally reaches every public output;
-- another identical recursive shell adds history but no new boundary behaviour.
eq(H.Case.key(once),H.Case.key(twice),'recursive split/merge history failed to saturate extensionally')
ok(H.Case.key(base)~=H.Case.key(once),'split/merge causal coupling was incorrectly erased')
local p=H.one_root('f',{split_merge({definition='f'}),H.two_port_context(1,1)},{})
 local r=p:root('f')
local a=H.Analysis.compute(p)
 eq(#H.Analysis.list(a.behaviour[r]),2,'split/merge recurrence should have exactly identity and coupled boundary cases')
print('PASS gv 55: split/merge across recurrence saturates at exact boundary behaviour ('..count()..')')
