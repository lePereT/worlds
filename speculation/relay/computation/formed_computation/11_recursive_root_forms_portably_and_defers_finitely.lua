local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()
local base=H.value_context('base')
local recur=H.Context.normal({
  template={geometry={membranes={},points={},strands={},faces={}},
    theory={variables={'return','y'},equalities={H.T.eq(H.T.var('return'),H.T.var('y'))}},
    authority={inputs={},outputs={}},values={inputs={'return'},outputs={'y'}}},
  outer={authority={inputs={},outputs={}},values={inputs={},outputs={1}}},
  holes={{target={definition='loop'},authority={to_target={},from_target={}},
    values={to_target={},from_target={1}}}}})
local rec=H.Package.new({definitions={{identity='loop',alternatives={base,recur}}}})
local rr=rec:root('loop')
local form=H.C.form_package(rr,0,'form')
local performer=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run')
local linked=H.link({rec,H.roundtrip(form),H.roundtrip(performer)})
local k,result,detail=H.C.perform(linked,form:root('form'),performer:root('run'))
eq(k,'Deferred','finite performer guessed a recursive semantic answer')
ok(result==nil)
eq(detail.reason,'formed-target-is-open')
eq(H.T.value(assert(H.Context.plug(form:definition(form:root('form')).family.items[1],{})).theory,'o1'),rr,
  'recursive semantic root did not survive form transport')
print('PASS tf 11: recursive root is first-class form meaning; finite elimination defers ('..count()..')')
