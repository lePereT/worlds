local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()

local inner=H.package('inner',{H.value_context('done',{authority_inputs=1,authority_outputs=0})})
local ir=inner:root('inner')
-- Outer work creates the exact authority which becomes the capture of the formed
-- computation returned as its value.
local outer=H.package('outer',{H.value_context(ir,{authority_inputs=0,authority_outputs=1})})
local outer_form=H.C.form_package(outer:root('outer'),0,'outer_form')
local run_outer=H.C.perform_package({authority={inputs=0,outputs=1},values={inputs=0,outputs=1}},nil,'run_outer')
local run_inner=H.C.perform_package({authority={inputs=1,outputs=0},values={inputs=0,outputs=1}},nil,'run_inner')
local linked=H.link({inner,outer,outer_form,run_outer,run_inner})

local k,passed=H.C.perform(linked,outer_form:root('outer_form'),run_outer:root('run_outer'))
eq(k,'Hit')
eq(H.output_value(passed),ir,'higher-order passage lost the inner semantic root')
eq(#passed:alternative(1).authority.outputs,1,'higher-order passage lost the exact capture boundary')

-- Instantiate the returned formed occurrence itself. Reusing its single exact
-- capture to feed two performances must be rejected by Worlds just as direct reuse is.
local exact_passed=passed:instantiate(1)
local inner_template=assert(H.Context.plug(inner:definition(ir).family.items[1],{}))
ok(H.C.exact_double_perform_rejected(exact_passed,inner_template),
  'passing a formed computation through another computation laundered scarce authority')

-- One lawful performance still succeeds and consumes the capture through ordinary
-- exact composition.
local pc=run_inner:definition(run_inner:root('run_inner')).family.items[1]
local k2,result=H.C.perform_family(linked,H.Family.new(passed:family().items,passed:family().edges),pc)
eq(k2,'Hit')
eq(H.output_value(result),'done')
ok(H.faces(result)>=2,'higher-order capture path lost ordinary causal work')
print('PASS tf 19: capture scarcity survives higher-order passage unchanged ('..count()..')')
