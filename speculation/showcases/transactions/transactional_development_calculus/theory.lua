-- Tiny regular equality theory for package-level value relations.
-- Variables are bound semantic interface/existential names, never Worlds identity.
local M={}

local function literal_key(x)
  local t=type(x)
  assert(t=='boolean' or t=='number' or t=='string','Theory literal must be bool/int/string')
  return t..':'..tostring(x)
end

function M.var(name)
  assert(type(name)=='string' and name~='','Theory variable name required')
  return {var=name}
end

function M.is_var(x) return type(x)=='table' and type(x.var)=='string' end
function M.eq(a,b) return {a=a,b=b} end

local function term_key(x)
  if M.is_var(x) then return 'v:'..x.var end
  return 'l:'..literal_key(x)
end

local function copy_term(x)
  if M.is_var(x) then return {var=x.var} end
  return x
end

local function dsu()
  local p={}
  local D={}
  function D:find(x)
    if p[x]==nil then p[x]=x end
    if p[x]~=x then p[x]=self:find(p[x]) end
    return p[x]
  end
  function D:union(a,b)
    a,b=self:find(a),self:find(b)
    if a~=b then if a<b then p[b]=a else p[a]=b end end
  end
  return D
end

local function collect(spec)
  local D=dsu()
  local terms={}
  local literals={}
  for _,e in ipairs(spec.equalities or {}) do
    local ka,kb=term_key(e.a),term_key(e.b)
    terms[ka]=copy_term(e.a)
 terms[kb]=copy_term(e.b)
    if not M.is_var(e.a) then literals[ka]=e.a end
    if not M.is_var(e.b) then literals[kb]=e.b end
    D:union(ka,kb)
  end
  for _,name in ipairs(spec.variables or {}) do
    local k='v:'..name
    terms[k]={var=name}
 D:find(k)
  end
  local classes={}
  for k,t in pairs(terms) do
    local r=D:find(k)
    local c=classes[r] or {vars={},literals={}}
    classes[r]=c
    if M.is_var(t) then c.vars[#c.vars+1]=t.var else c.literals[literal_key(t)]=t end
  end
  for _,c in pairs(classes) do
    table.sort(c.vars)
    local n=0
    for _ in pairs(c.literals) do n=n+1 end
    if n>1 then return nil,'contradiction' end
  end
  return classes
end

local function normal_from_classes(classes,keep)
  local variables,equalities={},{}
  local kept={}
  for name in pairs(keep or {}) do kept[name]=true
 variables[#variables+1]=name end
  table.sort(variables)
  for _,c in pairs(classes) do
    local vars={}
    for _,v in ipairs(c.vars) do if kept[v] then vars[#vars+1]=v end end
    if #vars>0 then
      local lit=nil
      for _,x in pairs(c.literals) do lit=x break end
      if lit~=nil then
        for _,v in ipairs(vars) do equalities[#equalities+1]=M.eq(M.var(v),lit) end
      else
        local first=vars[1]
        for i=2,#vars do equalities[#equalities+1]=M.eq(M.var(first),M.var(vars[i])) end
      end
    end
  end
  table.sort(equalities,function(a,b)
    local aa,ab=term_key(a.a),term_key(a.b)
    local ba,bb=term_key(b.a),term_key(b.b)
    return aa<ba or (aa==ba and ab<bb)
  end)
  return {variables=variables,equalities=equalities}
end

function M.normal(spec,keep)
  spec=spec or {variables={},equalities={}}
  local classes,why=collect(spec)
  if not classes then return nil,why end
  if keep==nil then
    keep={}
    for _,name in ipairs(spec.variables or {}) do keep[name]=true end
    for _,e in ipairs(spec.equalities or {}) do
      if M.is_var(e.a) then keep[e.a.var]=true end
      if M.is_var(e.b) then keep[e.b.var]=true end
    end
  end
  return normal_from_classes(classes,keep)
end

function M.conjoin(a,b)
  local variables,equalities={},{}
  local seen={}
  local function add(x)
    for _,v in ipairs(x.variables or {}) do if not seen[v] then seen[v]=true
 variables[#variables+1]=v end end
    for _,e in ipairs(x.equalities or {}) do equalities[#equalities+1]=M.eq(copy_term(e.a),copy_term(e.b)) end
  end
  add(a or {})
 add(b or {})
  return M.normal({variables=variables,equalities=equalities})
end

function M.rename(spec,prefix)
  local variables,equalities={},{}
  local function rt(x) return M.is_var(x) and M.var(prefix..x.var) or x end
  for _,v in ipairs(spec.variables or {}) do variables[#variables+1]=prefix..v end
  for _,e in ipairs(spec.equalities or {}) do equalities[#equalities+1]=M.eq(rt(e.a),rt(e.b)) end
  return M.normal({variables=variables,equalities=equalities})
end

function M.substitute(spec,eqs,keep)
  local variables,equalities={},{}
  for _,v in ipairs(spec.variables or {}) do variables[#variables+1]=v end
  for _,e in ipairs(spec.equalities or {}) do equalities[#equalities+1]=M.eq(copy_term(e.a),copy_term(e.b)) end
  for _,e in ipairs(eqs or {}) do equalities[#equalities+1]=M.eq(copy_term(e.a),copy_term(e.b)) end
  return M.normal({variables=variables,equalities=equalities},keep)
end

function M.value(spec,name)
  local classes=assert(collect(spec))
  local target='v:'..name
  for _,c in pairs(classes) do
    local has=false
    for _,v in ipairs(c.vars) do if v==name then has=true break end end
    if has then for _,x in pairs(c.literals) do return x end end
  end
  return nil
end

function M.spec(spec)
  local n=assert(M.normal(spec))
  local eqs={}
  for i,e in ipairs(n.equalities) do
    local function out(x) return M.is_var(x) and {var=x.var} or x end
    eqs[i]={a=out(e.a),b=out(e.b)}
  end
  return {variables=n.variables,equalities=eqs}
end

return M
