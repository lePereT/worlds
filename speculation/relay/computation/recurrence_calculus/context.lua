-- A recursive clause is one finite relative Development context with marked holes.
-- Holes are Package linkage, not evaluator instructions: filling one is ordinary
-- Geometry composition plus positive Theory substitution/projection.
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local G=require('speculation.relay.computation.development_calculus.geometry')
local T=require('speculation.relay.computation.development_calculus.equality')
local Template=require('speculation.relay.computation.development_calculus.template')
local M={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function positions(xs,n,label)
  local out,seen={},{}
  for i,x in ipairs(xs or {}) do
    assert(type(x)=='number' and x%1==0 and x>=1 and x<=n,label..' position outside interface')
    assert(not seen[x],label..' position repeated')
    seen[x]=true
 out[i]=x
  end
  return out
end

local function target(x)
  assert(type(x)=='table','recurrence hole target required')
  local d,r=x.definition,x.root
  assert((d~=nil)~=(r~=nil),'recurrence target must be local definition or semantic root')
  if d~=nil then assert(type(d)=='string' and d~='','local recurrence definition required')
 return {definition=d} end
  assert(type(r)=='string' and r:match('^semantic:sha256:'),'external recurrence root required')
  return {root=r}
end

local function claim(used,pos,label)
  assert(not used[pos],label..' interface position classified twice')
  used[pos]=true
end

local function complete(used,n,label)
  for i=1,n do assert(used[i],label..' interface position is neither outer nor a recurrence hole') end
end

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
    assert(type(h)=='table','recurrence hole required')
    local ha=h.authority or {}
 local hv=h.values or {}
    local row={target=target(h.target),authority={},values={}}
    row.authority.to_target=positions(ha.to_target,#t.authority.outputs,
      'hole authority to-target')
    row.authority.from_target=positions(ha.from_target,#t.authority.inputs,
      'hole authority from-target')
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
  return {
    authority={inputs=#c.outer.authority.inputs,outputs=#c.outer.authority.outputs},
    values={inputs=#c.outer.values.inputs,outputs=#c.outer.values.outputs},
  }
end

function M.rewrite_targets(spec,fn)
  local c=M.normal(spec)
  local holes={}
  for i,h in ipairs(c.holes) do
    local nh={target=assert(fn(h.target)),authority={to_target=copy(h.authority.to_target),
      from_target=copy(h.authority.from_target)},values={to_target=copy(h.values.to_target),
      from_target=copy(h.values.from_target)}}
    holes[i]=nh
  end
  table.sort(holes,function(a,b) return Canonical.encode(a)<Canonical.encode(b) end)
  return {template=c.template,outer={authority={inputs=copy(c.outer.authority.inputs),
    outputs=copy(c.outer.authority.outputs)},values={inputs=copy(c.outer.values.inputs),
    outputs=copy(c.outer.values.outputs)}},holes=holes}
end

local function copy_term(x) return T.is_var(x) and T.var(x.var) or x end

-- Recurrence plugs use the same quotient law as finite composition: positive meaning is attached
-- to Strand occurrences, merged through Construction correspondence, then hidden only after all
-- identified knowledge has met.  A recursive hole is linkage, not a reason to discard support.
local function combine_theory(parts,images,authority_inputs,authority_outputs,keep,extra)
  local variables,equalities,seen={},{},{}
  for _,p in ipairs(parts) do
    for _,v in ipairs(p.theory.variables or {}) do
      if not seen[v] then seen[v]=true; variables[#variables+1]=v end
    end
    for _,e in ipairs(p.theory.equalities or {}) do equalities[#equalities+1]=T.eq(e.a,e.b) end
  end
  for _,e in ipairs(extra or {}) do equalities[#equalities+1]=e end

  local buckets={}
  for pi,p in ipairs(parts) do
    for si,record in pairs(p.support and p.support.strands or {}) do
      local class=images[pi].classes and images[pi].classes[si]
      if class then local row=buckets[class] or {}; buckets[class]=row; row[#row+1]=record end
    end
  end
  local merged={}
  for class,records in pairs(buckets) do
    local fields={}
    for _,record in ipairs(records) do for key,term in pairs(record) do
      if fields[key] then equalities[#equalities+1]=T.eq(copy_term(fields[key]),copy_term(term))
      else fields[key]=copy_term(term) end
    end end
    merged[class]=fields
  end

  local visible={}
  for _,si in ipairs(authority_inputs) do visible[si]=true end
  for _,si in ipairs(authority_outputs) do visible[si]=true end
  local support={}
  for class,record in pairs(merged) do
    local strand=images.target_strands and images.target_strands[class] or nil
    if strand and visible[strand] then
      support[strand]=record
      for _,term in pairs(record) do if T.is_var(term) then keep[term.var]=true end end
    end
  end
  local theory=T.normal({variables=variables,equalities=equalities},keep)
  if not theory then return nil,nil end
  return theory,next(support) and {strands=support} or nil
end

local function membership(xs)
  local out={}
  for _,x in ipairs(xs or {}) do out[x]=true end
  return out
end

function M.plug(spec,targets)
  local c=M.normal(spec)
  targets=targets or {}
  assert(#targets==#c.holes,'recurrence hole target count mismatch')
  local parts={Template.rename_values(c.template,'w.')}
  for i,x in ipairs(targets) do parts[i+1]=Template.rename_values(Template.normal(x),'h'..i..'.') end
  local wrapper=parts[1]
  local geqs,teqs={},{}

  for hi,h in ipairs(c.holes) do
    local callee=parts[hi+1]
    assert(#h.authority.to_target==#callee.authority.inputs,'recursive authority input arity mismatch')
    assert(#h.authority.from_target==#callee.authority.outputs,'recursive authority output arity mismatch')
    assert(#h.values.to_target==#callee.values.inputs,'recursive value input arity mismatch')
    assert(#h.values.from_target==#callee.values.outputs,'recursive value output arity mismatch')
    for j,pos in ipairs(h.authority.to_target) do
      geqs[#geqs+1]={from={part=1,strand=wrapper.authority.outputs[pos]},
        to={part=hi+1,strand=callee.authority.inputs[j]}}
    end
    for j,pos in ipairs(h.authority.from_target) do
      geqs[#geqs+1]={from={part=hi+1,strand=callee.authority.outputs[j]},
        to={part=1,strand=wrapper.authority.inputs[pos]}}
    end
    for j,pos in ipairs(h.values.to_target) do
      teqs[#teqs+1]=T.eq(T.var(wrapper.values.outputs[pos]),T.var(callee.values.inputs[j]))
    end
    for j,pos in ipairs(h.values.from_target) do
      teqs[#teqs+1]=T.eq(T.var(callee.values.outputs[j]),T.var(wrapper.values.inputs[pos]))
    end
  end

  local geometries={}
  for i,p in ipairs(parts) do geometries[i]=p.geometry end
  local ok,geometry,images=pcall(function()
    local g,m=G.compose(geometries,geqs)
    return g,m
  end)
  if not ok then return nil,'no-exact-closure' end

  local ain,aout={},{}
  local open={inputs={},outputs={}}
  local oi=membership(wrapper.authority.open and wrapper.authority.open.inputs)
  local oo=membership(wrapper.authority.open and wrapper.authority.open.outputs)
  local ro=membership(wrapper.authority.open and wrapper.authority.open.required_outputs)
  for _,pos in ipairs(c.outer.authority.inputs) do
    local y=images[1].strands[wrapper.authority.inputs[pos]]
    if not y then return nil,'outer-authority-input-annihilated' end
    ain[#ain+1]=y
    if oi[pos] then open.inputs[#open.inputs+1]=#ain end
  end
  for _,pos in ipairs(c.outer.authority.outputs) do
    local y=images[1].strands[wrapper.authority.outputs[pos]]
    if not y then return nil,'outer-authority-output-annihilated' end
    aout[#aout+1]=y
    if oo[pos] then open.outputs[#open.outputs+1]=#aout end
    if ro[pos] then open.required_outputs=open.required_outputs or {}; open.required_outputs[#open.required_outputs+1]=#aout end
  end

  local vin,vout,keep={}, {}, {}
  for _,pos in ipairs(c.outer.values.inputs) do
    local v=wrapper.values.inputs[pos]
 vin[#vin+1]=v
 keep[v]=true
  end
  for _,pos in ipairs(c.outer.values.outputs) do
    local v=wrapper.values.outputs[pos]
 vout[#vout+1]=v
 keep[v]=true
  end
  local theory,support=combine_theory(parts,images,ain,aout,keep,teqs)
  if not theory then return nil,'theory-contradiction' end
  local authority={inputs=ain,outputs=aout}
  if #open.inputs>0 or #open.outputs>0 then authority.open=open end
  return Template.normal({geometry=geometry,theory=theory,authority=authority,support=support,
    values={inputs=vin,outputs=vout}})
end

function M.closed(template)
  local t=Template.normal(template)
  local function all(n) local out={} for i=1,n do out[i]=i end return out end
  return M.normal({template=t,outer={authority={inputs=all(#t.authority.inputs),
    outputs=all(#t.authority.outputs)},values={inputs=all(#t.values.inputs),
    outputs=all(#t.values.outputs)}},holes={}})
end

return M
