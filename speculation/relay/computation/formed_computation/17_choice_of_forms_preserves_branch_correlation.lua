local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()

local function pair_context(a,b)
  return H.Context.closed({geometry={membranes={},points={},strands={},faces={}},
    theory={variables={'x','tag'},equalities={H.T.eq(H.T.var('x'),a),H.T.eq(H.T.var('tag'),b)}},
    authority={inputs={},outputs={}},values={inputs={},outputs={'x','tag'}}})
end

local ints=H.package('ints',{pair_context('int','PA')})
local sockets=H.package('sockets',{pair_context('socket','PB')})
local ir,sr=ints:root('ints'),sockets:root('sockets')
local forms=H.package('forms',{H.C.form_context(ir,0),H.C.form_context(sr,0)})
local permissive=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=2}},nil,'run')
local linked=H.link({ints,sockets,forms,permissive})
local kind,result=H.C.perform(linked,forms:root('forms'),permissive:root('run'))
eq(kind,'Hit')
eq(#result:family().items,2,'formed choice lost an admitted branch')
local seen={}
for i=1,2 do
  local a=result:alternative(i)
  local x=H.T.value(a.theory,a.values.outputs[1])
  local tag=H.T.value(a.theory,a.values.outputs[2])
  seen[x..':'..tag]=true
end
ok(seen['int:PA'] and seen['socket:PB'],'choice lost branch-correlated result knowledge')
ok(not seen['int:PB'] and not seen['socket:PA'],'choice manufactured cross-branch correlation')

local int_only=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=2}},
  {require_outputs={{position=1,value='int'}}},'run_int')
local linked2=H.link({ints,sockets,forms,int_only})
local k2,r2,d2=H.C.perform(linked2,forms:root('forms'),int_only:root('run_int'))
eq(k2,'Retry','post-perform integer requirement pruned the socket runtime branch')
ok(r2==nil)
eq(d2.reason,'perform-continuation-not-total')
print('PASS tf 17: choice of formed meanings preserves branch correlation through perform ('..count()..')')
