-- Event-shaped computation which genuinely passes through form/perform before entering ordinary choice.
local F=require('speculation.relay.computation.formed_computation.calculus')
local H=require('speculation.relay.computation.formed_computation.common')
local T=F.Equality()
local G=F.Geometry()
local Context=F.Context()
local M={}

function M.event(value,identity)
  identity=identity or 'selectable.formed.target'
  local g,p=G.operation(1,2)
  local target=H.package(identity,{Context.closed({geometry=g,
    theory={variables={'result'},equalities={T.eq(T.var('result'),value)}},
    authority={inputs=p.inputs,outputs=p.outputs},values={inputs={},outputs={'result'}}})})
  local root=target:root(identity)
  local form=F.form_package(root,1,identity..'.form')
  local perform=F.perform_package({authority={inputs=1,outputs=2},values={inputs=0,outputs=1}},
    nil,identity..'.perform')
  local linked=H.link({target,form,perform})
  local kind,result=F.perform(linked,form:root(identity..'.form'),perform:root(identity..'.perform'))
  assert(kind=='Hit','selectable formed event did not perform')
  return result
end

return M
