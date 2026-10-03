local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K
local a=assert(H.Context.plug(H.authority_step_context(),{}))
local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={{membrane=1,points={2}},{membrane=1,points={1}}},faces={{membrane=1,inputs={2},outputs={1}}}}
local b=assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={2},outputs={1}},values={inputs={},outputs={}}}),{}))
eq(H.Case.key(a),H.Case.key(b),'symbolic carrier numbering leaked into boundary-case identity')
print('PASS gv 37: authority boundary cases are alpha-invariant over symbolic Worlds carriers ('..count()..')')
