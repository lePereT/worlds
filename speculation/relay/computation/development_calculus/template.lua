-- One portable relative Development alternative: symbolic Geometry + positive Theory.
--
-- `authority.open` is a non-authoritative presentation of selected open Strand occurrences.
-- `support.strands` attaches ordinary Theory terms to exact/symbolic Strand occurrences.  The
-- support is transported by Geometry composition; it is not a matcher, role tag or authority.
local G=require('speculation.relay.computation.development_calculus.geometry')
local T=require('speculation.relay.computation.development_calculus.equality')
local M={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function copy_term(x) return T.is_var(x) and T.var(x.var) or x end

local function positions(xs,count,label)
  local out,seen={},{}
  for _,i in ipairs(xs or {}) do
    assert(type(i)=='number' and i%1==0 and i>=1 and i<=count,label..' outside authority interface')
    assert(not seen[i],label..' contains duplicate position')
    seen[i]=true; out[#out+1]=i
  end
  table.sort(out)
  return out
end

local function open_value(open,nin,nout)
  open=open or {}
  local ins=positions(open.inputs,nin,'open input')
  local outs=positions(open.outputs,nout,'open output')
  local reqout=positions(open.required_outputs,nout,'required open output')
  local outset={}
  for _,i in ipairs(outs) do outset[i]=true end
  for _,i in ipairs(reqout) do assert(outset[i],'required open output must also be open') end
  if #ins==0 and #outs==0 then return nil end
  local out={inputs=ins,outputs=outs}
  if #reqout>0 then out.required_outputs=reqout end
  return out
end

local function authority_value(inputs,outputs,open)
  local a={inputs=inputs,outputs=outputs}
  if open then a.open=open end
  return a
end

local function support_value(strands)
  if not strands or next(strands)==nil then return nil end
  return {strands=strands}
end

local function normal_record(record)
  assert(type(record)=='table','Strand-supported knowledge record required')
  local out={}
  for k,v in pairs(record) do
    assert(type(k)=='string' and k~='','Strand-supported knowledge key must be string')
    assert(T.is_var(v) or type(v)=='boolean' or type(v)=='number' or type(v)=='string',
      'Strand-supported knowledge term must be Theory variable or literal')
    out[k]=copy_term(v)
  end
  assert(next(out)~=nil,'Strand-supported knowledge record must not be empty')
  return out
end

local function normal_support(raw,count)
  local out={}
  for si,record in pairs(raw or {}) do
    assert(type(si)=='number' and si%1==0 and si>=1 and si<=count,
      'Strand support outside symbolic Geometry')
    out[si]=normal_record(record)
  end
  return out
end

local function rename_theory(spec,map)
  local variables,equalities={},{}
  local seen={}
  local next_hidden=0
  local function rv(name)
    local x=map[name]
    if not x then
      repeat next_hidden=next_hidden+1; x='x'..tostring(next_hidden) until not seen[x]
      map[name]=x
    end
    if not seen[x] then seen[x]=true; variables[#variables+1]=x end
    return x
  end
  for _,name in ipairs(spec.variables or {}) do rv(name) end
  local function rt(x) return T.is_var(x) and T.var(rv(x.var)) or x end
  for _,e in ipairs(spec.equalities or {}) do equalities[#equalities+1]=T.eq(rt(e.a),rt(e.b)) end
  return assert(T.normal({variables=variables,equalities=equalities}))
end

local function map_record(record,mapping)
  local out={}
  for k,t in pairs(record) do
    out[k]=T.is_var(t) and T.var(assert(mapping[t.var],'supported variable absent from Theory')) or t
  end
  return out
end

function M.normal(a)
  assert(type(a)=='table','relative Development alternative required')
  local geometry=G.normal(a.geometry or G.empty())
  local rawa=a.authority or {}
  local ain,aout=copy(rawa.inputs),copy(rawa.outputs)
  local open=open_value(rawa.open,#ain,#aout)
  local raw_support=normal_support(a.support and a.support.strands,#geometry.strands)

  local values=a.values or {}
  local vin,vout=copy(values.inputs),copy(values.outputs)
  local mapping={}
  local function assign(old,new)
    if mapping[old] then assert(mapping[old]==new,'value variable occupies two public slots')
    else mapping[old]=new end
  end
  for i,name in ipairs(vin) do assign(name,'i'..i) end
  for i,name in ipairs(vout) do if not mapping[name] then assign(name,'o'..i) end end

  local cmap
  geometry,rawa,cmap=G.canonical(geometry,{inputs=ain,outputs=aout})
  ain,aout=rawa.inputs,rawa.outputs

  -- Supported hidden variables receive names from canonical Strand position and field name. Public
  -- value variables retain their interface names. Hence package identity does not depend on source
  -- variable spelling or pre-canonical Strand numbering.
  local rows={}
  for oldsi,record in pairs(raw_support) do
    local newsi=assert(cmap.S[oldsi])
    for key,t in pairs(record) do if T.is_var(t) then
      rows[#rows+1]={strand=newsi,key=key,name=t.var}
    end end
  end
  table.sort(rows,function(x,y)
    if x.strand~=y.strand then return x.strand<y.strand end
    if x.key~=y.key then return x.key<y.key end
    return x.name<y.name
  end)
  local n=0
  for _,row in ipairs(rows) do if not mapping[row.name] then
    n=n+1; assign(row.name,'s'..row.strand..'.'..tostring(n))
  end end

  local theory=rename_theory(a.theory or {variables={},equalities={}},mapping)
  local cin,cout={},{}
  for i,name in ipairs(vin) do cin[i]=assert(mapping[name]) end
  for i,name in ipairs(vout) do cout[i]=assert(mapping[name]) end

  local support={}
  for oldsi,record in pairs(raw_support) do
    support[assert(cmap.S[oldsi])]=map_record(record,mapping)
  end
  return {
    geometry=geometry,
    theory=T.spec(theory),
    authority=authority_value(ain,aout,open),
    support=support_value(support),
    values={inputs=cin,outputs=cout},
  }
end

function M.instantiate(a)
  a=M.normal(a)
  local geometry,map=G.instantiate(a.geometry)
  local ain,aout={},{}
  for i,si in ipairs(a.authority.inputs) do ain[i]=map.strands[si] end
  for i,si in ipairs(a.authority.outputs) do aout[i]=map.strands[si] end
  local support={}
  for si,record in pairs(a.support and a.support.strands or {}) do
    local out={}
    for k,t in pairs(record) do out[k]=copy_term(t) end
    support[map.strands[si]]=out
  end
  return {
    geometry=geometry,
    theory=T.spec(a.theory),
    authority=authority_value(ain,aout,open_value(a.authority.open,#ain,#aout)),
    support=support_value(support),
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
  local support={}
  for si,record in pairs(a.support and a.support.strands or {}) do
    local out={}
    for k,t in pairs(record) do out[k]=rt(t) end
    support[si]=out
  end
  return {
    geometry=a.geometry,
    theory=assert(T.normal({variables=variables,equalities=equalities})),
    authority=authority_value(copy(a.authority.inputs),copy(a.authority.outputs),
      open_value(a.authority.open,#a.authority.inputs,#a.authority.outputs)),
    support=support_value(support),
    values={inputs=rn(a.values.inputs),outputs=rn(a.values.outputs)},
  }
end

return M
