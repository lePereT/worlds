-- A formed-computation clause is one finite relative Development context with marked holes.
-- A hole may name a semantic root statically or obtain that root from an outer
-- value input. Either way the hole is semantic linkage, never an evaluator opcode.
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

local function target(x,value_input_count)
  assert(type(x)=='table','formed-computation hole target required')
  local d,r,v=x.definition,x.root,x.value_input
  local n=(d~=nil and 1 or 0)+(r~=nil and 1 or 0)+(v~=nil and 1 or 0)
  assert(n==1,'formed-computation target must be local definition, semantic root, or value input')
  if d~=nil then
    assert(type(d)=='string' and d~='','local formed-computation definition required')
    return {definition=d}
  end
  if r~=nil then
    assert(type(r)=='string' and r:match('^semantic:sha256:'),'external formed-computation root required')
    return {root=r}
  end
  assert(type(v)=='number' and v%1==0 and v>=1 and v<=value_input_count,
    'dynamic perform target value input outside interface')
  return {value_input=v}
end

local function claim(used,pos,label)
  assert(not used[pos],label..' interface position classified twice')
  used[pos]=true
end

local function complete(used,n,label)
  for i=1,n do assert(used[i],label..' interface position is neither outer nor a semantic hole') end
end

function M.normal(spec)
  assert(type(spec)=='table','formed-computation Development context required')
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
    assert(type(h)=='table','formed-computation hole required')
    local ha=h.authority or {}
 local hv=h.values or {}
    local row={target=target(h.target,#t.values.inputs),authority={},values={}}
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

local function combine_theory(parts,keep,extra)
  local variables,equalities,seen={},{},{}
  for _,p in ipairs(parts) do
    for _,v in ipairs(p.theory.variables or {}) do
      if not seen[v] then seen[v]=true
 variables[#variables+1]=v end
    end
    for _,e in ipairs(p.theory.equalities or {}) do equalities[#equalities+1]=T.eq(e.a,e.b) end
  end
  for _,e in ipairs(extra or {}) do equalities[#equalities+1]=e end
  return T.normal({variables=variables,equalities=equalities},keep)
end

function M.plug(spec,targets)
  local c=M.normal(spec)
  targets=targets or {}
  assert(#targets==#c.holes,'formed-computation hole target count mismatch')
  local parts={Template.rename_values(c.template,'w.')}
  for i,x in ipairs(targets) do parts[i+1]=Template.rename_values(Template.normal(x),'h'..i..'.') end
  local wrapper=parts[1]
  local geqs,teqs={},{}

  for hi,h in ipairs(c.holes) do
    local callee=parts[hi+1]
    assert(#h.authority.to_target==#callee.authority.inputs,'performed authority input arity mismatch')
    assert(#h.authority.from_target==#callee.authority.outputs,'performed authority output arity mismatch')
    assert(#h.values.to_target==#callee.values.inputs,'performed value input arity mismatch')
    assert(#h.values.from_target==#callee.values.outputs,'performed value output arity mismatch')
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
  for _,pos in ipairs(c.outer.authority.inputs) do
    local y=images[1].strands[wrapper.authority.inputs[pos]]
    if not y then return nil,'outer-authority-input-annihilated' end
    ain[#ain+1]=y
  end
  for _,pos in ipairs(c.outer.authority.outputs) do
    local y=images[1].strands[wrapper.authority.outputs[pos]]
    if not y then return nil,'outer-authority-output-annihilated' end
    aout[#aout+1]=y
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
  local theory=combine_theory(parts,keep,teqs)
  if not theory then return nil,'theory-contradiction' end
  return Template.normal({geometry=geometry,theory=theory,authority={inputs=ain,outputs=aout},
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
