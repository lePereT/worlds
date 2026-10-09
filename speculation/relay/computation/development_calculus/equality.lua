-- Symbolic equality domain used by the early Relay computation laboratories.
--
-- This is not a Theory host.  It is one extensional domain over symbolic value
-- coordinates, implemented through the thin host in relay/theory/knowledge.lua.
-- Its effective semantic operations are exactly equal, meet, reindex, exists.

local K = require('speculation.relay.theory.knowledge')

local M = {}

local TOKENS = {}
local NAMES = setmetatable({}, { __mode = 'k' })

local function token(name)
  local t = TOKENS[name]
  if t then return t end
  t = {}
  TOKENS[name] = t
  NAMES[t] = name
  return t
end

local function literal_key(x)
  local t = type(x)
  assert(t == 'boolean' or t == 'number' or t == 'string',
    'Theory literal must be bool/int/string')
  return t .. ':' .. tostring(x)
end

function M.var(name)
  assert(type(name) == 'string' and name ~= '', 'Theory variable name required')
  return { var = name }
end

function M.is_var(x)
  return type(x) == 'table' and type(x.var) == 'string'
end

function M.eq(a, b)
  return { a = a, b = b }
end

local function copy_term(x)
  return M.is_var(x) and M.var(x.var) or x
end

local function dsu()
  local parent = {}
  local D = {}
  function D:find(x)
    if parent[x] == nil then parent[x] = x end
    if parent[x] ~= x then parent[x] = self:find(parent[x]) end
    return parent[x]
  end
  function D:union(a, b)
    a, b = self:find(a), self:find(b)
    if a ~= b then parent[b] = a end
  end
  return D
end

local function term_key(x)
  if M.is_var(x) then return token(x.var) end
  return 'literal:' .. literal_key(x)
end

local function context_index(ctx)
  local out = {}
  for i, x in ipairs(ctx) do out[x] = i end
  return out
end

local function normal_raw(ctx, equations)
  local index = context_index(ctx)
  local D = dsu()
  local literals = {}

  for _, x in ipairs(ctx) do D:find(x) end
  for _, e in ipairs(equations or {}) do
    local a, b = term_key(e.a), term_key(e.b)
    if type(a) == 'table' then assert(index[a], 'equality variable leaves context') end
    if type(b) == 'table' then assert(index[b], 'equality variable leaves context') end
    if type(a) == 'string' then literals[a] = e.a end
    if type(b) == 'string' then literals[b] = e.b end
    D:union(a, b)
  end

  local classes = {}
  for _, x in ipairs(ctx) do
    local root = D:find(x)
    local c = classes[root] or { vars = {}, literals = {} }
    classes[root] = c
    c.vars[#c.vars + 1] = x
  end
  for key, value in pairs(literals) do
    local root = D:find(key)
    local c = classes[root] or { vars = {}, literals = {} }
    classes[root] = c
    c.literals[key] = value
  end

  local out = {}
  for _, c in pairs(classes) do
    local n = 0
    local lit = nil
    for _, value in pairs(c.literals) do n = n + 1; lit = value end
    if n > 1 then return K.BOTTOM end
    table.sort(c.vars, function(a, b) return index[a] < index[b] end)
    if #c.vars > 1 or (#c.vars == 1 and lit ~= nil) then
      out[#out + 1] = { vars = c.vars, literal = lit }
    end
  end
  table.sort(out, function(a, b)
    return index[a.vars[1]] < index[b.vars[1]]
  end)
  if #out == 0 then return K.TOP end
  return out
end

local function raw_equations(raw)
  local out = {}
  for _, c in ipairs(raw) do
    if c.literal ~= nil then
      for _, x in ipairs(c.vars) do
        out[#out + 1] = M.eq(M.var(assert(NAMES[x])), c.literal)
      end
    else
      for i = 2, #c.vars do
        out[#out + 1] = M.eq(M.var(assert(NAMES[c.vars[1]])), M.var(assert(NAMES[c.vars[i]])))
      end
    end
  end
  return out
end

local function mapped_raw(source, raw, target, sigma)
  local equations = {}
  for _, e in ipairs(raw_equations(raw)) do
    local function map_term(x)
      if not M.is_var(x) then return x end
      return M.var(assert(NAMES[assert(sigma[token(x.var)])]))
    end
    equations[#equations + 1] = M.eq(map_term(e.a), map_term(e.b))
  end
  return normal_raw(target, equations)
end

local Domain = K.domain {
  name = 'development-calculus-symbolic-equality',

  equal = function(ctx, a, b)
    local function signature(raw)
      local index = context_index(ctx)
      local rows = {}
      for _, c in ipairs(raw) do
        local vars = {}
        for _, x in ipairs(c.vars) do vars[#vars + 1] = index[x] end
        local lit = c.literal == nil and '' or literal_key(c.literal)
        rows[#rows + 1] = table.concat(vars, ',') .. '=' .. lit
      end
      return table.concat(rows, ';')
    end
    return signature(a) == signature(b)
  end,

  meet = function(ctx, a, b)
    local equations = raw_equations(a)
    for _, e in ipairs(raw_equations(b)) do equations[#equations + 1] = e end
    return normal_raw(ctx, equations)
  end,

  reindex = function(source, raw, target, sigma)
    return mapped_raw(source, raw, target, sigma)
  end,

  exists = function(_, raw, keep)
    local retained = {}
    for _, x in ipairs(keep) do retained[x] = true end
    local equations = {}
    for _, c in ipairs(raw) do
      local vars = {}
      for _, x in ipairs(c.vars) do if retained[x] then vars[#vars + 1] = x end end
      if c.literal ~= nil then
        for _, x in ipairs(vars) do
          equations[#equations + 1] = M.eq(M.var(assert(NAMES[x])), c.literal)
        end
      elseif #vars > 1 then
        for i = 2, #vars do
          equations[#equations + 1] = M.eq(
            M.var(assert(NAMES[vars[1]])), M.var(assert(NAMES[vars[i]])))
        end
      end
    end
    return normal_raw(keep, equations)
  end,
}

local function names_of(spec)
  local seen = {}
  for _, name in ipairs(spec.variables or {}) do seen[name] = true end
  for _, e in ipairs(spec.equalities or {}) do
    if M.is_var(e.a) then seen[e.a.var] = true end
    if M.is_var(e.b) then seen[e.b.var] = true end
  end
  local names = {}
  for name in pairs(seen) do names[#names + 1] = name end
  table.sort(names)
  return names
end

local function context_of_names(names)
  local out = {}
  for i, name in ipairs(names) do out[i] = token(name) end
  return out
end

local function knowledge(spec)
  spec = spec or { variables = {}, equalities = {} }
  local names = names_of(spec)
  local ctx = context_of_names(names)
  local raw = normal_raw(ctx, spec.equalities)
  return K.of(ctx, Domain, raw)
end

local function spec_of(k)
  if K.is_bottom(k) then return nil, 'contradiction' end
  local variables = {}
  for i, x in ipairs(K.context(k)) do variables[i] = assert(NAMES[x]) end
  local raw = K.component(k, Domain)
  local equalities = raw == K.TOP and {} or raw_equations(raw)
  return { variables = variables, equalities = equalities }
end

local function lift(k, target)
  local sigma = {}
  for _, x in ipairs(K.context(k)) do sigma[x] = x end
  return K.reindex(k, target, sigma)
end

function M.normal(spec, keep)
  local k = knowledge(spec)
  if K.is_bottom(k) then return nil, 'contradiction' end
  if keep ~= nil then
    local names = {}
    for name in pairs(keep) do names[#names + 1] = name end
    table.sort(names)
    local retained = context_of_names(names)
    local present = context_index(K.context(k))
    for _, x in ipairs(retained) do assert(present[x], 'kept Theory variable absent') end
    k = K.exists(k, retained)
  end
  return spec_of(k)
end

function M.conjoin(a, b)
  local ka, kb = knowledge(a or {}), knowledge(b or {})
  if K.is_bottom(ka) or K.is_bottom(kb) then return nil, 'contradiction' end
  local names, seen = {}, {}
  for _, k in ipairs({ ka, kb }) do
    for _, x in ipairs(K.context(k)) do
      if not seen[x] then seen[x] = true; names[#names + 1] = assert(NAMES[x]) end
    end
  end
  table.sort(names)
  local target = context_of_names(names)
  local out = K.meet(lift(ka, target), lift(kb, target))
  return spec_of(out)
end

function M.rename(spec, prefix)
  local k = knowledge(spec)
  if K.is_bottom(k) then return nil, 'contradiction' end
  local target, sigma = {}, {}
  for i, x in ipairs(K.context(k)) do
    local y = token(prefix .. assert(NAMES[x]))
    target[i] = y
    sigma[x] = y
  end
  return spec_of(K.reindex(k, target, sigma))
end

function M.substitute(spec, eqs, keep)
  local combined, why = M.conjoin(spec, { equalities = eqs or {} })
  if not combined then return nil, why end
  return M.normal(combined, keep)
end

function M.value(spec, name)
  local k = knowledge(spec)
  if K.is_bottom(k) then return nil end
  local raw = K.component(k, Domain)
  if raw == K.TOP then return nil end
  local target = token(name)
  for _, c in ipairs(raw) do
    if c.literal ~= nil then
      for _, x in ipairs(c.vars) do if x == target then return c.literal end end
    end
  end
  return nil
end

function M.spec(spec)
  local normal, why = M.normal(spec)
  assert(normal, why)
  local equalities = {}
  for i, e in ipairs(normal.equalities) do
    equalities[i] = { a = copy_term(e.a), b = copy_term(e.b) }
  end
  return { variables = normal.variables, equalities = equalities }
end

return M
