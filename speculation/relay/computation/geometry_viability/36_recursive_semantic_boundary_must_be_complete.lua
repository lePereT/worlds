local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K
local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={{membrane=1,points={1}},{membrane=1,points={2}}},faces={}}
local incomplete=H.Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1},outputs={1}},values={inputs={},outputs={}}})
local p=H.one_root('f',{incomplete})
ok(not pcall(function() H.Analysis.compute(p) end),'recursive viability silently ignored open authority omitted from semantic boundary')
print('PASS gv 36: recursive semantic authority boundary is total even though client Presentation may later omit it ('..count()..')')
