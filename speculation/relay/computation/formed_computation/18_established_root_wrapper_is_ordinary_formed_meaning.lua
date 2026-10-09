local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()

local target=H.package('target',{H.value_context('done',{authority_inputs=1,authority_outputs=1})})
local tr=target:root('target')

-- Start from an actual formed value and observe only its positive semantic-root
-- knowledge. This observation chooses what Package meaning to wrap; it grants no
-- authority and introduces no causal edge.
local formed_template=assert(H.Context.plug(H.C.form_context(tr,1),{}))
local observed=H.T.value(formed_template.theory,formed_template.values.outputs[1])
eq(observed,tr,'formed value did not establish the wrapped semantic root')
eq(#formed_template.geometry.faces,0,'observing a formed root executed the target')

-- pre ; [target] ; post, expressed as one ordinary Context with a static semantic
-- hole. The two wrapper faces are ordinary Geometry, not handler/evaluator nodes.
local wrapper=H.Context.normal({
  template={
    geometry={membranes={{parent=0}},
      points={{membrane=1},{membrane=1},{membrane=1},{membrane=1}},
      strands={{membrane=1,points={1}},{membrane=1,points={2}},
        {membrane=1,points={3}},{membrane=1,points={4}}},
      faces={{membrane=1,inputs={1},outputs={2}},{membrane=1,inputs={3},outputs={4}}}},
    theory={variables={'ret'},equalities={}},
    authority={inputs={1,3},outputs={2,4}},values={inputs={'ret'},outputs={'ret'}}},
  outer={authority={inputs={1},outputs={2}},values={inputs={},outputs={1}}},
  holes={{target={root=observed},authority={to_target={1},from_target={2}},
    values={to_target={},from_target={1}}}}
})
local target_template=assert(H.Context.plug(target:definition(tr).family.items[1],{}))
local composed=assert(H.Context.plug(wrapper,{target_template}))
eq(#composed.geometry.faces,3,'ordinary wrapper composition did not produce pre/target/post Geometry')
ok(H.G.face_reaches(composed.geometry,1,2) and H.G.face_reaches(composed.geometry,2,3),
  'wrapper causality is not ordinary pre -> target -> post Geometry')

local wrapped=H.package('wrapped',{H.Context.closed(composed)})
local wr=wrapped:root('wrapped')
local wrapped_form=H.C.form_package(wr,1,'wrapped_form')
local performer=H.C.perform_package({authority={inputs=1,outputs=1},values={inputs=0,outputs=1}},nil,'run')
local linked=H.link({wrapped,wrapped_form,performer})
local pk,performed=H.C.perform(linked,wrapped_form:root('wrapped_form'),performer:root('run'))
local dk,direct=H.C.direct(linked,wr)
eq(pk,'Hit')
eq(dk,'Hit')
eq(H.Canonical.encode(performed:alternative(1)),H.Canonical.encode(direct:alternative(1)),
  'formed wrapper introduced semantics beyond ordinary Context composition')
eq(H.output_value(performed),'done')
ok(not performed:bytes():find('handler',1,true) and not performed:bytes():find('callback',1,true),
  'wrapper left a handler/evaluator object in finite meaning')

-- The stronger higher-order transformer remains honest: a generic wrapper can be
-- packaged and formed while its dynamic target is unknown, but this finite layer
-- must defer rather than synthesize a new closed Package root or smuggle an evaluator.
local generic_wrapper=H.Context.normal({
  template={
    geometry={membranes={{parent=0}},
      points={{membrane=1},{membrane=1},{membrane=1},{membrane=1}},
      strands={{membrane=1,points={1}},{membrane=1,points={2}},
        {membrane=1,points={3}},{membrane=1,points={4}}},
      faces={{membrane=1,inputs={1},outputs={2}},{membrane=1,inputs={3},outputs={4}}}},
    theory={variables={'op','ret'},equalities={}},
    authority={inputs={1,3},outputs={2,4}},values={inputs={'op','ret'},outputs={'ret'}}},
  outer={authority={inputs={1},outputs={2}},values={inputs={1},outputs={1}}},
  holes={{target={value_input=1},authority={to_target={1},from_target={2}},
    values={to_target={},from_target={2}}}}
})
local generic=H.package('generic_wrap',{generic_wrapper})
local generic_form=H.C.form_package(generic:root('generic_wrap'),1,'generic_wrap_form')
local generic_run=H.C.perform_package({authority={inputs=1,outputs=1},values={inputs=1,outputs=1}},nil,'generic_run')
local generic_linked=H.link({H.roundtrip(generic),H.roundtrip(generic_form),H.roundtrip(generic_run)})
local gk,gr,gd=H.C.perform(generic_linked,generic_form:root('generic_wrap_form'),generic_run:root('generic_run'))
eq(gk,'Deferred','finite layer guessed a generic value-targeted wrapper result')
ok(gr==nil)
eq(gd.reason,'formed-target-is-open')
print('PASS tf 18: established-root wrapping is ordinary Context composition plus form/perform ('..count()..')')
