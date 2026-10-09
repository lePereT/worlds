-- Integration glue only: reuse the promoted form/perform finding from the concurrency
-- discovery arena. Nothing here is a concurrency semantic object.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local F=require('speculation.relay.computation.formed_computation.calculus')
local H=require('speculation.relay.computation.formed_computation.common')
local M={}

function M.value(value)
  local target=H.package('value_target',{H.value_context(value)})
  local root=target:root('value_target')
  local form=F.form_package(root,0,'value_form')
  local performer=F.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'value_perform')
  local linked=H.link({target,form,performer})
  local kind,result=F.perform(linked,form:root('value_form'),performer:root('value_perform'))
  assert(kind=='Hit','formed value did not establish')
  return result
end

-- A tiny target used by dependent-form pressures. Captures are ordinary target
-- authority inputs; the Form relation itself contains only the target semantic root.
function M.value_target(identity,result,captures)
  assert(type(identity)=='string' and identity~='','formed target identity required')
  return H.package(identity,{H.value_context(result,{authority_inputs=captures or 0})})
end

-- Build ordinary relational meaning input -> Form(root). The returned object is a
-- finite Development Package, so generic and_then may specialise it using tentative
-- positive knowledge without invoking a Lua continuation callback.
function M.select(rows)
  assert(type(rows)=='table' and #rows>0,'formed selector needs rows')
  local out=nil
  for _,row in ipairs(rows) do
    assert(row.value~=nil and type(row.root)=='string','formed selector row needs value/root')
    local one=C.atom({geometry=G.empty(),
      theory={variables={'input','op'},equalities={
        T.eq(T.var('input'),row.value),T.eq(T.var('op'),row.root)}},
      authority={inputs={},outputs={}},values={inputs={'input'},outputs={'op'}}})
    out=out and C.choice(out,one) or one
  end
  return out
end

-- Eliminate a finite family of already-selected forms using the promoted generic
-- performer. Search/glue disappears; the result is again an ordinary finite Package.
function M.perform_selected(forms,targets,interface)
  local linked=H.link(targets)
  return F.perform_family(linked,forms:family(),F.perform_context(interface))
end

return M
