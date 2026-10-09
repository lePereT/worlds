local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()
local ints=H.package('int',{H.value_context('int')})
local sockets=H.package('socket',{H.value_context('socket')})
local forms=H.package('forms',{H.C.form_context(ints:root('int'),0),H.C.form_context(sockets:root('socket'),0)})
local performer=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run')
local linked=H.link({ints,sockets,forms,performer})
local kind,result=H.C.perform(linked,forms:root('forms'),performer:root('run'))
eq(kind,'Hit')
eq(#result:family().items,2,'perform pruned an admitted runtime alternative')
local seen={}
for i=1,2 do seen[H.output_value(result,i,1)]=true end
ok(seen.int and seen.socket,'perform did not preserve correlated runtime outcomes')
print('PASS tf 05: permissive perform preserves every admitted outcome ('..count()..')')
