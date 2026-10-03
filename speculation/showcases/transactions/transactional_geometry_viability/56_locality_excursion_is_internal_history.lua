local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K

local function direct()
  local g={membranes={{parent=0},{parent=1}},points={{membrane=2},{membrane=2}},strands={{membrane=2,points={1}},{membrane=2,points={2}}},faces={{membrane=1,inputs={1},outputs={2}}}}
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1},outputs={2}},values={inputs={},outputs={}}}),{}))
end
local function excursion()
  -- The intermediate Strand is hosted at the parent but still carries a Point
  -- in the child locality, so the child locality remains causally available for
  -- the second Face.  This is a lawful leave-and-return excursion in Worlds.
  local g={membranes={{parent=0},{parent=1}},points={{membrane=2},{membrane=2},{membrane=2}},strands={{membrane=2,points={1}},{membrane=1,points={2}},{membrane=2,points={3}}},faces={}}
  g.faces[1]={membrane=1,inputs={1},outputs={2}}
  g.faces[2]={membrane=1,inputs={2},outputs={3}}
  return assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1},outputs={3}},values={inputs={},outputs={}}}),{}))
end
local a,b=direct(),excursion()
eq(H.Case.key(a),H.Case.key(b),'temporary movement through ancestor locality leaked into boundary case')
-- The boundary itself is still nested; moving the public output to the parent must remain observable.
local g={membranes={{parent=0},{parent=1}},points={{membrane=2},{membrane=1}},strands={{membrane=2,points={1}},{membrane=1,points={2}}},faces={{membrane=1,inputs={1},outputs={2}}}}
local moved=assert(H.Context.plug(H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1},outputs={2}},values={inputs={},outputs={}}}),{}))
ok(H.Case.key(a)~=H.Case.key(moved),'public locality movement was incorrectly erased')
print('PASS gv 56: internal locality excursions erase, public locality movement remains exact ('..count()..')')
