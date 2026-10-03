-- One portable relative Development alternative: symbolic Geometry + positive Theory.
local G=require('speculation.showcases.transactions.transactional_development_calculus.geometry')
local T=require('speculation.showcases.transactions.transactional_development_calculus.theory')
local M={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function rename_theory(spec,map)
  local variables,equalities={},{}
  local seen={}
  local function rv(name)
    local x=map[name]
    if not x then x='x'..tostring(#variables+1)
 map[name]=x end
    if not seen[x] then seen[x]=true
 variables[#variables+1]=x end
    return x
  end
  for _,name in ipairs(spec.variables or {}) do rv(name) end
  local function rt(x) return T.is_var(x) and T.var(rv(x.var)) or x end
  for _,e in ipairs(spec.equalities or {}) do equalities[#equalities+1]=T.eq(rt(e.a),rt(e.b)) end
  return assert(T.normal({variables=variables,equalities=equalities}))
end

function M.normal(a)
  assert(type(a)=='table','relative Development alternative required')
  local geometry=G.normal(a.geometry or G.empty())
  local authority=a.authority or {}
  local ain,aout=copy(authority.inputs),copy(authority.outputs)
  geometry,authority=G.canonical(geometry,{inputs=ain,outputs=aout})
  ain,aout=authority.inputs,authority.outputs
  local exact=G.instantiate(geometry)
  for _,si in ipairs(ain) do assert(exact:is_input(exact:strands()[si]),
    'authority input must be symbolic Geometry ingress') end
  for _,si in ipairs(aout) do assert(exact:is_terminal(exact:strands()[si]),
    'authority output must be symbolic Geometry egress') end

  local values=a.values or {}
  local vin,vout=copy(values.inputs),copy(values.outputs)
  local mapping={}
  local used={}
  local function assign(old,new)
    if mapping[old] then assert(mapping[old]==new,'value variable occupies two public slots')
    else mapping[old]=new end
    used[new]=true
  end
  for i,name in ipairs(vin) do assign(name,'i'..i) end
  for i,name in ipairs(vout) do
    if not mapping[name] then assign(name,'o'..i) end
  end
  local theory=rename_theory(a.theory or {variables={},equalities={}},mapping)
  local cin,cout={},{}
  for i,name in ipairs(vin) do cin[i]=assert(mapping[name]) end
  for i,name in ipairs(vout) do cout[i]=assert(mapping[name]) end
  return {
    geometry=geometry,
    theory=T.spec(theory),
    authority={inputs=ain,outputs=aout},
    values={inputs=cin,outputs=cout},
  }
end

function M.instantiate(a)
  a=M.normal(a)
  local geometry,map=G.instantiate(a.geometry)
  local ain,aout={},{}
  for i,si in ipairs(a.authority.inputs) do ain[i]=map.strands[si] end
  for i,si in ipairs(a.authority.outputs) do aout[i]=map.strands[si] end
  return {
    geometry=geometry,
    theory=T.spec(a.theory),
    authority={inputs=ain,outputs=aout},
    values={inputs=copy(a.values.inputs),outputs=copy(a.values.outputs)},
  }
end

function M.rename_values(a,prefix)
  a=M.normal(a)
  local map={}
  for _,name in ipairs(a.theory.variables) do map[name]=prefix..name end
  local function rn(xs)
    local out={}
    for i,x in ipairs(xs) do out[i]=assert(map[x]) end
    return out
  end
  local equalities={}
  local function rt(x) return T.is_var(x) and T.var(assert(map[x.var])) or x end
  for _,e in ipairs(a.theory.equalities) do equalities[#equalities+1]=T.eq(rt(e.a),rt(e.b)) end
  local variables={}
  for _,x in ipairs(a.theory.variables) do variables[#variables+1]=map[x] end
  return {
    geometry=a.geometry,
    theory=assert(T.normal({variables=variables,equalities=equalities})),
    authority={inputs=copy(a.authority.inputs),outputs=copy(a.authority.outputs)},
    values={inputs=rn(a.values.inputs),outputs=rn(a.values.outputs)},
  }
end

return M
