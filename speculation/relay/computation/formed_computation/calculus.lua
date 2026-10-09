-- First-class formed computation calculus over package-first Development meaning.
-- form introduces portable semantic-root knowledge plus ordinary captured authority.
-- perform is represented by a transportable open Context whose hole target comes
-- from that knowledge. Finite elimination leaves only ordinary Development meaning.
local Construction=require('worlds.construction')
local C=require('speculation.relay.computation.development_calculus.calculus')
local G=require('speculation.relay.computation.development_calculus.geometry')
local T=require('speculation.relay.computation.development_calculus.equality')
local Template=require('speculation.relay.computation.development_calculus.template')
local Family=require('speculation.relay.computation.development_calculus.family')
local FP=require('speculation.relay.computation.development_calculus.package')
local Context=require('speculation.relay.computation.formed_computation.context')
local Package=require('speculation.relay.computation.formed_computation.package')
local M={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function empty_geometry()
  return {membranes={},points={},strands={},faces={}}
end

local function preserved_authority(n)
  if n==0 then return empty_geometry(),{} end
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local ports={}
  for i=1,n do
    g.points[i]={membrane=1}
    g.strands[i]={membrane=1,points={i}}
    ports[i]=i
  end
  return g,ports
end

-- Laboratory encoding of the positive Form(value, root) knowledge relation.
-- The root string is semantic identity, not exact Worlds identity.
function M.form_context(root,capture_count)
  assert(type(root)=='string' and root:match('^semantic:sha256:'),'semantic root required for form')
  capture_count=capture_count or 0
  assert(type(capture_count)=='number' and capture_count%1==0 and capture_count>=0,
    'finite capture count required')
  local geometry,ports=preserved_authority(capture_count)
  return Context.closed({geometry=geometry,
    theory={variables={'op'},equalities={T.eq(T.var('op'),root)}},
    authority={inputs=ports,outputs=ports},values={inputs={},outputs={'op'}}})
end

function M.form_package(root,capture_count,identity)
  identity=identity or 'form'
  return Package.new({definitions={{identity=identity,
    alternatives={M.form_context(root,capture_count)}}}})
end

local function bridge_geometry(input_count,output_count)
  local n=input_count+output_count
  if n==0 then return empty_geometry(),{} end
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local ports={}
  for i=1,n do
    g.points[i]={membrane=1}
    g.strands[i]={membrane=1,points={i}}
    ports[i]=i
  end
  return g,ports
end

-- A transportable perform context. The dynamic hole target is the first outer
-- value input. Authority/value bridge positions expose the target interface,
-- but no call opcode or evaluator object is introduced.
function M.perform_context(interface,opts)
  interface=interface or {}
  opts=opts or {}
  local a=interface.authority or {}
  local v=interface.values or {}
  local ai,ao=a.inputs or 0,a.outputs or 0
  local vi,vo=v.inputs or 0,v.outputs or 0
  for _,n in ipairs({ai,ao,vi,vo}) do
    assert(type(n)=='number' and n%1==0 and n>=0,'perform interface arity must be finite')
  end

  local geometry,ports=bridge_geometry(ai,ao)
  local authority_inputs,authority_outputs={},{}
  for i=1,ai+ao do authority_inputs[i]=ports[i]
 authority_outputs[i]=ports[i] end

  local value_inputs={'op'}
  local value_outputs={}
  for i=1,vi do
    value_inputs[#value_inputs+1]='arg'..i
    value_outputs[#value_outputs+1]='arg'..i
  end
  for i=1,vo do
    value_inputs[#value_inputs+1]='ret'..i
    value_outputs[#value_outputs+1]='ret'..i
  end
  local variables={}
  for _,x in ipairs(value_inputs) do variables[#variables+1]=x end
  local seen={}
  local unique={}
  for _,x in ipairs(variables) do if not seen[x] then seen[x]=true
 unique[#unique+1]=x end end
  variables=unique
  local equalities={}
  for _,r in ipairs(opts.require_outputs or {}) do
    local pos=assert(r.position,'required output position needed')
    assert(type(pos)=='number' and pos%1==0 and pos>=1 and pos<=vo,
      'required output position outside perform result interface')
    equalities[#equalities+1]=T.eq(T.var('ret'..pos),r.value)
  end

  local outer_ai,outer_ao={},{}
  local hole_to_a,hole_from_a={},{}
  for i=1,ai do outer_ai[#outer_ai+1]=i
 hole_to_a[#hole_to_a+1]=i end
  for i=1,ao do local p=ai+i
 hole_from_a[#hole_from_a+1]=p
 outer_ao[#outer_ao+1]=p end

  local outer_vi={1}
  for i=1,vi do outer_vi[#outer_vi+1]=1+i end
  local outer_vo={}
  local hole_to_v={}
  for i=1,vi do hole_to_v[#hole_to_v+1]=i end
  local hole_from_v={}
  for i=1,vo do
    hole_from_v[#hole_from_v+1]=1+vi+i
    outer_vo[#outer_vo+1]=vi+i
  end

  return Context.normal({template={geometry=geometry,
    theory={variables=variables,equalities=equalities},
    authority={inputs=authority_inputs,outputs=authority_outputs},
    values={inputs=value_inputs,outputs=value_outputs}},
    outer={authority={inputs=outer_ai,outputs=outer_ao},
      values={inputs=outer_vi,outputs=outer_vo}},
    holes={{target={value_input=1},authority={to_target=hole_to_a,from_target=hole_from_a},
      values={to_target=hole_to_v,from_target=hole_from_v}}}})
end

function M.perform_package(interface,opts,identity)
  identity=identity or 'perform'
  return Package.new({definitions={{identity=identity,
    alternatives={M.perform_context(interface,opts)}}}})
end

local function zero_hole_template(context)
  context=Context.normal(context)
  if #context.holes~=0 then return nil,'open-context' end
  return assert(Context.plug(context,{}))
end

local function template_family(package,root)
  local d=assert(package:definition(root),'semantic root is not linked')
  local items={}
  for i,c in ipairs(d.family.items) do
    local t,why=zero_hole_template(c)
    if not t then return nil,why end
    items[i]=t
  end
  return Family.new(items,d.family.edges)
end

local function dynamic_performer(package,root)
  local d=assert(package:definition(root),'perform semantic root is not linked')
  assert(#d.family.items==1,'formed-computation lab performer must have one alternative')
  local c=Context.normal(d.family.items[1])
  assert(#c.holes==1 and c.holes[1].target.value_input,
    'perform definition must contain one value-targeted semantic hole')
  return c
end

local function root_from_form(template)
  assert(#template.values.outputs>=1,'formed computation must publish a value')
  local root=T.value(template.theory,template.values.outputs[1])
  if type(root)~='string' or not root:match('^semantic:sha256:') then
    return nil,'formed-root-unknown'
  end
  return root
end

local function bind_form_to_resolved(form,resolved)
  local left=FP.new({items={form},edges={}})
  local right=FP.new({items={resolved},edges={}})
  local captures={}
  assert(#form.authority.outputs==#resolved.authority.inputs,
    'formed capture arity does not match performed target interface')
  for i=1,#form.authority.outputs do captures[i]={from=i,to=i} end
  return C.bind(left,right,{value_pairs={{from=1,to=1}},captures=captures})
end

local function perform_one_form(package,form,performer)
  local root,why=root_from_form(form)
  if not root then return 'Unknown',nil,{reason=why} end
  local target=package:definition(root)
  if not target then return 'Deferred',nil,{reason='formed-root-not-linked',root=root} end

  local results,map={},{}
  for i,target_context in ipairs(target.family.items) do
    local target_template,twhy=zero_hole_template(target_context)
    if not target_template then
      return 'Deferred',nil,{reason='formed-target-is-open',root=root,detail=twhy}
    end
    local pok,resolved,rwhy=pcall(Context.plug,performer,{target_template})
    if not pok then
      return 'Retry',nil,{reason='perform-interface-mismatch',root=root,
        alternative=i,message=tostring(resolved)}
    end
    if not resolved then
      return 'Retry',nil,{reason='perform-continuation-not-total',root=root,
        alternative=i,detail=rwhy}
    end
    local bok,composed=pcall(bind_form_to_resolved,form,resolved)
    if not bok then
      return 'Retry',nil,{reason='perform-interface-mismatch',root=root,
        alternative=i,message=tostring(composed)}
    end
    local cf=composed:family()
    if #cf.items==0 then
      return 'Retry',nil,{reason='perform-continuation-not-total',root=root,alternative=i}
    end
    assert(#cf.items==1,'single finite form/target composition should yield one result')
    map[i]=#results+1
    results[#results+1]=cf.items[1]
  end
  local edges={}
  for _,e in ipairs(target.family.edges) do edges[#edges+1]={assert(map[e[1]]),assert(map[e[2]])} end
  return 'Hit',Family.new(results,edges)
end

-- Perform admits every current form alternative and every finite target outcome.
-- A failed continuation is therefore not pruned; it rejects the performance.
function M.perform_family(package,form_family,performer)
  assert(Package.is(package),'linked formed-computation Package required')
  performer=Context.normal(performer)
  local children={}
  for i,form in ipairs(form_family.items) do
    local kind,child,detail=perform_one_form(package,Template.normal(form),performer)
    if kind~='Hit' then return kind,nil,detail end
    children[i]=child
  end
  local result=Family.bind(form_family,function(_,i) return children[i] end)
  return 'Hit',FP.new(Family.spec(result))
end

function M.perform(package,form_root,perform_root)
  assert(Package.is(package),'linked formed-computation Package required')
  local forms,why=template_family(package,form_root)
  if not forms then return 'Deferred',nil,{reason='formed-value-definition-is-open',detail=why} end
  return M.perform_family(package,forms,dynamic_performer(package,perform_root))
end

function M.direct(package,root)
  local f,why=template_family(package,root)
  if not f then return 'Deferred',nil,{reason='target-is-open',detail=why} end
  return 'Hit',FP.new(Family.spec(f))
end

function M.instantiate_form_capture(package,form_root,index)
  local f=assert(template_family(package,form_root))
  local t=assert(f.items[index or 1])
  return Template.instantiate(t)
end

function M.exact_double_perform_rejected(form_instance,target_template)
  local target1=Template.instantiate(target_template)
  local target2=Template.instantiate(target_template)
  assert(#form_instance.authority.outputs==1,'double-perform pressure expects one capture')
  assert(#target1.authority.inputs==1 and #target2.authority.inputs==1,
    'double-perform pressure expects one target input')
  local ok=pcall(Construction.join,{form_instance.geometry,target1.geometry,target2.geometry},{
    {from=form_instance.authority.outputs[1],to=target1.authority.inputs[1]},
    {from=form_instance.authority.outputs[1],to=target2.authority.inputs[1]},
  })
  return not ok
end

function M.Package() return Package end
function M.Context() return Context end
function M.FinitePackage() return FP end
function M.Family() return Family end
function M.Equality() return T end
function M.Geometry() return G end
return M
