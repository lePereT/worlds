local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()

local function face_value_context(value)
  return H.Context.closed({
    geometry={membranes={{parent=0}},points={},strands={},
      faces={{membrane=1,inputs={},outputs={}}}},
    theory={variables={'y'},equalities={H.T.eq(H.T.var('y'),value)}},
    authority={inputs={},outputs={}},values={inputs={},outputs={'y'}}})
end

local inner=H.package('inner',{face_value_context('done')})
local ir=inner:root('inner')
-- Ordinary outer work happens, and its result is itself a formed computation.
local outer=H.package('outer',{face_value_context(ir)})
local form=H.C.form_package(outer:root('outer'),0,'outer_form')
local performer=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run')
local pr=performer:root('run')
local linked=H.link({inner,outer,form,performer})

local k,first=H.C.perform(linked,form:root('outer_form'),pr)
eq(k,'Hit')
eq(H.output_value(first),ir,'performing outer work flattened its returned formed computation')
eq(H.faces(first),1,'inner work executed while only the outer form was performed')

local pc=performer:definition(pr).family.items[1]
local k2,second=H.C.perform_family(linked,H.Family.new(first:family().items,first:family().edges),pc)
eq(k2,'Hit')
eq(H.output_value(second),'done')
eq(H.faces(second),2,'explicit second perform did not add exactly the inner work')
ok(true)
print('PASS tf 15: performed work may return a still-unperformed first-class computation ('..count()..')')
