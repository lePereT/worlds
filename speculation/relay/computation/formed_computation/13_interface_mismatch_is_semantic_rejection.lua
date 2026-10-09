local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()
local target=H.Package.new({definitions={{identity='pair',alternatives={H.Context.closed({
  geometry={membranes={},points={},strands={},faces={}},
  theory={variables={'a','b'},equalities={H.T.eq(H.T.var('a'),'x'),H.T.eq(H.T.var('b'),'y')}},
  authority={inputs={},outputs={}},values={inputs={},outputs={'a','b'}}})}}}})
local form=H.C.form_package(target:root('pair'),0,'form')
local performer=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run_one')
local linked=H.link({target,form,performer})
local kind,result,detail=H.C.perform(linked,form:root('form'),performer:root('run_one'))
eq(kind,'Retry','incompatible perform interface was not rejected semantically')
ok(result==nil)
eq(detail.reason,'perform-interface-mismatch')
print('PASS tf 13: perform interface mismatch is semantic rejection, not a computation type ('..count()..')')
