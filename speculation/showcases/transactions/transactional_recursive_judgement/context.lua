-- Recursive Development contexts over restrictive occurrence-relative Theory.
-- Holes connect authority by exact Strand cuts and public values by extensional
-- equality of knowledge carried on exact-distinct Points.
local Canonical=require('speculation.showcases.transactions.transactional_development_calculus.canonical')
local G=require('speculation.showcases.transactions.transactional_recursive_judgement.geometry')
local K=require('speculation.showcases.transactions.transactional_recursive_judgement.knowledge')
local Template=require('speculation.showcases.transactions.transactional_recursive_judgement.template')
local M={}

local function copy(xs) local out={}
 for i,x in ipairs(xs or {}) do out[i]=x end
 return out end
local function positions(xs,n,label)
  local out,seen={},{}
  for i,x in ipairs(xs or {}) do assert(type(x)=='number' and x%1==0 and x>=1 and x<=n,label..' position outside interface')
 assert(not seen[x],label..' repeated')
 seen[x]=true
 out[i]=x end
  return out
end
local function target(x)
  assert(type(x)=='table','recurrence hole target required')
 local d,r=x.definition,x.root
  assert((d~=nil)~=(r~=nil),'recurrence target must be local definition or semantic root')
  if d~=nil then assert(type(d)=='string' and d~='')
 return {definition=d} end
  assert(type(r)=='string' and r:match('^semantic:sha256:'))
 return {root=r}
end
local function claim(used,pos,label) assert(not used[pos],label..' classified twice')
 used[pos]=true end
local function complete(used,n,label) for i=1,n do assert(used[i],label..' is neither outer nor recurrence hole') end end

function M.normal(spec)
  assert(type(spec)=='table','recurrence Development context required')
  local t=Template.normal(assert(spec.template,'context template required'))
  local outer=spec.outer or {}
 local oa=outer.authority or {}
 local ov=outer.values or {}
  local out={template=t,outer={authority={},values={}},holes={}}
  out.outer.authority.inputs=positions(oa.inputs,#t.authority.inputs,'outer authority input')
  out.outer.authority.outputs=positions(oa.outputs,#t.authority.outputs,'outer authority output')
  out.outer.values.inputs=positions(ov.inputs,#t.values.inputs,'outer value input')
  out.outer.values.outputs=positions(ov.outputs,#t.values.outputs,'outer value output')
  local used={ai={},ao={},vi={},vo={}}
  for _,x in ipairs(out.outer.authority.inputs) do claim(used.ai,x,'authority input') end
  for _,x in ipairs(out.outer.authority.outputs) do claim(used.ao,x,'authority output') end
  for _,x in ipairs(out.outer.values.inputs) do claim(used.vi,x,'value input') end
  for _,x in ipairs(out.outer.values.outputs) do claim(used.vo,x,'value output') end
  for hi,h in ipairs(spec.holes or {}) do
    local ha=h.authority or {}
 local hv=h.values or {}
    local row={target=target(assert(h.target)),authority={},values={}}
    row.authority.to_target=positions(ha.to_target,#t.authority.outputs,'hole authority to-target')
    row.authority.from_target=positions(ha.from_target,#t.authority.inputs,'hole authority from-target')
    row.values.to_target=positions(hv.to_target,#t.values.outputs,'hole value to-target')
    row.values.from_target=positions(hv.from_target,#t.values.inputs,'hole value from-target')
    for _,x in ipairs(row.authority.to_target) do claim(used.ao,x,'authority output') end
    for _,x in ipairs(row.authority.from_target) do claim(used.ai,x,'authority input') end
    for _,x in ipairs(row.values.to_target) do claim(used.vo,x,'value output') end
    for _,x in ipairs(row.values.from_target) do claim(used.vi,x,'value input') end
    out.holes[hi]=row
  end
  complete(used.ai,#t.authority.inputs,'authority input')
 complete(used.ao,#t.authority.outputs,'authority output')
  complete(used.vi,#t.values.inputs,'value input')
 complete(used.vo,#t.values.outputs,'value output')
  return out
end

function M.interface(spec)
  local c=M.normal(spec)
  return {authority={inputs=#c.outer.authority.inputs,outputs=#c.outer.authority.outputs},values={inputs=#c.outer.values.inputs,outputs=#c.outer.values.outputs}}
end

function M.rewrite_targets(spec,fn)
  local c=M.normal(spec)
 local holes={}
  for i,h in ipairs(c.holes) do holes[i]={target=assert(fn(h.target)),authority={to_target=copy(h.authority.to_target),from_target=copy(h.authority.from_target)},values={to_target=copy(h.values.to_target),from_target=copy(h.values.from_target)}} end
  table.sort(holes,function(a,b) return Canonical.encode(a)<Canonical.encode(b) end)
  return {template=c.template,outer={authority={inputs=copy(c.outer.authority.inputs),outputs=copy(c.outer.authority.outputs)},values={inputs=copy(c.outer.values.inputs),outputs=copy(c.outer.values.outputs)}},holes=holes}
end

function M.plug(spec,targets)
  local c=M.normal(spec)
 targets=targets or {}
 assert(#targets==#c.holes,'recurrence hole target count mismatch')
  local parts={Template.normal(c.template)}
  for i,x in ipairs(targets) do parts[i+1]=Template.normal(x) end
  local wrapper=parts[1]
 local geqs,veqs={},{ }
  for hi,h in ipairs(c.holes) do
    local callee=parts[hi+1]
    assert(#h.authority.to_target==#callee.authority.inputs,'recursive authority input arity mismatch')
    assert(#h.authority.from_target==#callee.authority.outputs,'recursive authority output arity mismatch')
    assert(#h.values.to_target==#callee.values.inputs,'recursive value input arity mismatch')
    assert(#h.values.from_target==#callee.values.outputs,'recursive value output arity mismatch')
    for j,pos in ipairs(h.authority.to_target) do geqs[#geqs+1]={from={part=1,strand=wrapper.authority.outputs[pos]},to={part=hi+1,strand=callee.authority.inputs[j]}} end
    for j,pos in ipairs(h.authority.from_target) do geqs[#geqs+1]={from={part=hi+1,strand=callee.authority.outputs[j]},to={part=1,strand=wrapper.authority.inputs[pos]}} end
    for j,pos in ipairs(h.values.to_target) do veqs[#veqs+1]={a={part=1,point=wrapper.values.outputs[pos]},b={part=hi+1,point=callee.values.inputs[j]}} end
    for j,pos in ipairs(h.values.from_target) do veqs[#veqs+1]={a={part=hi+1,point=callee.values.outputs[j]},b={part=1,point=wrapper.values.inputs[pos]}} end
  end
  local geometries={}
 for i,p in ipairs(parts) do geometries[i]=p.geometry end
  local ok,geometry,images,corrinfo=pcall(function()
    local g,im,_,ci=G.compose(geometries,geqs)
 return g,im,ci
  end)
  if not ok then return nil,'no-exact-closure' end
  -- pcall returned third value as corrinfo because the Construction itself is intentionally discarded.
  local partk={}
 for i,p in ipairs(parts) do partk[i]=K.from_spec(p.theory) end
  local target_ctx=K.target_context(partk,corrinfo)
  local theory=K.transport_parts(partk,corrinfo,target_ctx,veqs)
  if K.is_bottom(theory) then return nil,'theory-contradiction' end
  local ain,aout,vin,vout={},{},{},{}
  for _,pos in ipairs(c.outer.authority.inputs) do local y=images[1].strands[wrapper.authority.inputs[pos]]
 if not y then return nil,'outer-authority-input-annihilated' end
 ain[#ain+1]=y end
  for _,pos in ipairs(c.outer.authority.outputs) do local y=images[1].strands[wrapper.authority.outputs[pos]]
 if not y then return nil,'outer-authority-output-annihilated' end
 aout[#aout+1]=y end
  for _,pos in ipairs(c.outer.values.inputs) do local y=images[1].points[wrapper.values.inputs[pos]]
 if not y then return nil,'outer-value-input-annihilated' end
 vin[#vin+1]=y end
  for _,pos in ipairs(c.outer.values.outputs) do local y=images[1].points[wrapper.values.outputs[pos]]
 if not y then return nil,'outer-value-output-annihilated' end
 vout[#vout+1]=y end
  return Template.normal({geometry=geometry,theory=K.spec(theory),authority={inputs=ain,outputs=aout},values={inputs=vin,outputs=vout}})
end

function M.closed(template)
  local t=Template.normal(template)
 local function all(n) local out={} for i=1,n do out[i]=i end return out end
  return M.normal({template=t,outer={authority={inputs=all(#t.authority.inputs),outputs=all(#t.authority.outputs)},values={inputs=all(#t.values.inputs),outputs=all(#t.values.outputs)}},holes={}})
end


-- Stable semantic interface signature.  Value positions are extensional domains on Points,
-- not Point identities, so separately compiled alternatives can use fresh Points.
function M.signature(spec)
  local c=M.normal(spec)
 local k=K.from_spec(c.template.theory)
 local by={}
  for _,q in ipairs(k.ctx) do by[q.point]=q end
  local function domains(positions,points)
    local out={}
    for i,pos in ipairs(positions) do local p=points[pos]
 local q=assert(by[p],'public value Point lacks domain')
      out[i]={sort=q.sort,values=copy(q.values)} end
    return out
  end
  return {authority={inputs=#c.outer.authority.inputs,outputs=#c.outer.authority.outputs},
    values={inputs=domains(c.outer.values.inputs,c.template.values.inputs),
      outputs=domains(c.outer.values.outputs,c.template.values.outputs)}}
end

return M
