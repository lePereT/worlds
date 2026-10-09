local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()
local target=H.roundtrip(H.package('target',{H.value_context('done')}))
local tr=target:definitions()[1].root
local form=H.roundtrip(H.C.form_package(tr,0,'form'))
local fr=form:definitions()[1].root
local performer=H.roundtrip(H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run'))
local pr=performer:definitions()[1].root
local linked=H.link({performer,form,target})
local k,result=H.C.perform(linked,fr,pr)
eq(k,'Hit')
eq(H.output_value(result),'done')
ok(linked:definition(tr) and linked:definition(fr) and linked:definition(pr),'content-addressed link lost a component')
print('PASS tf 09: separately transported target, form and performer link semantically ('..count()..')')
