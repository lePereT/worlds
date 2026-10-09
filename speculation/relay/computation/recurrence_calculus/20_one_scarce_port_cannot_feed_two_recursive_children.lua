local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local g={membranes={{parent=0}},points={{membrane=1},{membrane=1},{membrane=1}},
  strands={{membrane=1,points={1}},{membrane=1,points={2}},{membrane=1,points={3}}},
  faces={{membrane=1,inputs={1},outputs={2}}}}
local spec={template={geometry=g,theory={variables={},equalities={}},authority={inputs={1,3},outputs={2,3}},
  values={inputs={},outputs={}}},outer={authority={inputs={1},outputs={2}},values={inputs={},outputs={}}},
  holes={
    {target={definition='a'},authority={to_target={1},from_target={2}},values={to_target={},from_target={}}},
    {target={definition='a'},authority={to_target={1},from_target={}},values={to_target={},from_target={}}},
  }}
ok(not pcall(H.Context.normal,spec),'one scarce wrapper output was duplicated across recursive holes')
eq(1,1)
print('PASS tr 20: recursive fan-out cannot duplicate scarce authority ('..count()..')')
