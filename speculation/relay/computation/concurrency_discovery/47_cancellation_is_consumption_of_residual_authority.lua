local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local Construction=require('worlds.construction')
local Template=require('speculation.relay.computation.development_calculus.template')
local FC=require('speculation.relay.computation.formed_computation.calculus')
local FH=require('speculation.relay.computation.formed_computation.common')
-- Use a real formed computation capture: cancellation competes for the same exact residual authority
-- that a later performance would consume.
local target=FH.package('cancel.target',{FH.value_context('done',{authority_inputs=1,authority_outputs=0})})
local root=target:root('cancel.target')
local form=FC.form_package(root,1,'cancel.form')
local linked=FH.link({target,form})
local capture=FC.instantiate_form_capture(linked,form:root('cancel.form'))
local target_template=assert(FH.Context.plug(target:definition(root).family.items[1],{}))
local run=Template.instantiate(target_template)
local cancel_pkg=H.C.operation(1,0,{}, {'status'},{variables={'status'},equalities={H.T.eq(H.T.var('status'),'cancelled')}})
local cancel=Template.instantiate(cancel_pkg:alternative(1))
local source=capture.authority.outputs[1]
local both=pcall(Construction.join,{capture.geometry,run.geometry,cancel.geometry},{
  {from=source,to=run.authority.inputs[1]},
  {from=source,to=cancel.authority.inputs[1]},
})
ok(not both,'one residual continuation authority both ran and cancelled')
local cancelled=Construction.join({capture.geometry,cancel.geometry},{{from=source,to=cancel.authority.inputs[1]}})
eq(#cancelled:result():egress(),0,'cancellation left captured continuation authority available')
print('PASS cc 47: cancellation is exclusive consumption of residual exact authority ('..count()..')')
