-- Minimal executable host for the Relay Theory/Knowledge contract.
--
-- This is speculation, not Worlds.  It deliberately mirrors the thin contract
-- established by the theory labs:
--
--   domain primitives: equal, meet, reindex, exists
--   host-derived:       top, bottom, entailment/judgement, product, transport
--
-- Exact identity belongs to Worlds.  Domains never receive a Construction;
-- generic transport acts through the exact Worlds Construction correspondence.

local W = require('worlds')
local Construction = require('worlds.construction')

local M = {}

local DOMAIN = setmetatable({}, { __mode = 'k' })
local KNOWLEDGE = setmetatable({}, { __mode = 'k' })

local function immutable()
  error('Theory-lab Knowledge values are immutable', 2)
end

local DMT = { __newindex = immutable, __metatable = 'Theory-lab knowledge domain' }
local KMT = { __newindex = immutable, __metatable = 'Theory-lab Knowledge' }

local function sentinel(name)
  return setmetatable({}, {
    __newindex = immutable,
    __metatable = 'Theory-lab Knowledge ' .. name,
    __tostring = function() return name end,
  })
end

M.TOP = sentinel('TOP')
M.BOTTOM = sentinel('BOTTOM')
M.DEFERRED = sentinel('DEFERRED')

local function dense(xs, what)
  assert(type(xs) == 'table', what .. ' must be a finite array')
  local n, count = #xs, 0
  for k in pairs(xs) do
    assert(type(k) == 'number' and k % 1 == 0 and k >= 1 and k <= n,
      what .. ' must be a dense finite array')
    count = count + 1
  end
  assert(count == n, what .. ' must be a dense finite array')
  return n
end

local function context(xs, what)
  dense(xs, what)
  local seen, out = {}, {}
  for i, x in ipairs(xs) do
    assert(x ~= nil, what .. ' contains nil')
    assert(not seen[x], what .. ' repeats one occurrence')
    seen[x] = true
    out[i] = x
  end
  return out
end

local function same_context(a, b)
  if #a ~= #b then return false end
  for i = 1, #a do if a[i] ~= b[i] then return false end end
  return true
end

local function context_set(xs)
  local out = {}
  for _, x in ipairs(xs) do out[x] = true end
  return out
end

local DOMAIN_FIELDS = {
  name = true,
  equal = true,
  meet = true,
  reindex = true,
  exists = true,
}

function M.domain(spec)
  assert(type(spec) == 'table', 'knowledge domain specification required')
  for k in pairs(spec) do
    assert(DOMAIN_FIELDS[k], 'knowledge domain has non-core operation: ' .. tostring(k))
  end
  for _, op in ipairs({ 'equal', 'meet', 'reindex', 'exists' }) do
    assert(type(spec[op]) == 'function', 'knowledge domain requires ' .. op)
  end
  if spec.name ~= nil then assert(type(spec.name) == 'string', 'domain name must be string') end
  local d = setmetatable({}, DMT)
  DOMAIN[d] = spec
  return d
end

local function dst(d)
  return type(d) == 'table' and DOMAIN[d] or nil
end

local function kst(k)
  return type(k) == 'table' and KNOWLEDGE[k] or nil
end

local function call(d, op, ...)
  local st = assert(dst(d), 'knowledge domain required')
  local out = st[op](...)
  assert(out ~= nil, 'knowledge domain ' .. op .. ' returned nil')
  return out
end

local function value(ctx, components, order, bottom)
  local k = setmetatable({}, KMT)
  KNOWLEDGE[k] = {
    context = ctx,
    components = components or {},
    order = order or {},
    bottom = not not bottom,
  }
  return k
end

function M.top(ctx)
  return value(context(ctx, 'knowledge context'), {}, {}, false)
end

function M.bottom(ctx)
  return value(context(ctx, 'knowledge context'), {}, {}, true)
end

function M.of(ctx, domain, raw)
  ctx = context(ctx, 'knowledge context')
  assert(dst(domain), 'knowledge domain required')
  assert(raw ~= M.DEFERRED, 'Deferred is not a semantic Knowledge value')
  if raw == M.TOP then return M.top(ctx) end
  if raw == M.BOTTOM then return M.bottom(ctx) end
  return value(ctx, { [domain] = raw }, { domain }, false)
end

function M.is_knowledge(x) return kst(x) ~= nil end
function M.context(k) return assert(kst(k), 'Knowledge required').context end
function M.is_bottom(k) return assert(kst(k), 'Knowledge required').bottom end

function M.component(k, domain)
  local st = assert(kst(k), 'Knowledge required')
  assert(dst(domain), 'knowledge domain required')
  if st.bottom then return M.BOTTOM end
  return st.components[domain] or M.TOP
end

local function add_component(components, order, domain, raw)
  if raw == M.TOP then return true end
  if raw == M.BOTTOM then return false, 'bottom' end
  if raw == M.DEFERRED then return false, 'deferred' end
  components[domain] = raw
  order[#order + 1] = domain
  return true
end

function M.equal(a, b)
  local A, B = assert(kst(a), 'Knowledge required'), assert(kst(b), 'Knowledge required')
  if not same_context(A.context, B.context) then return false end
  if A.bottom ~= B.bottom then return false end
  if A.bottom then return true end
  if #A.order ~= #B.order then return false end
  for _, d in ipairs(A.order) do
    local bv = B.components[d]
    if bv == nil then return false end
    local same = call(d, 'equal', A.context, A.components[d], bv)
    assert(type(same) == 'boolean', 'domain equal must return boolean')
    if not same then return false end
  end
  return true
end

function M.meet(a, b)
  local A, B = assert(kst(a), 'Knowledge required'), assert(kst(b), 'Knowledge required')
  assert(same_context(A.context, B.context), 'knowledge meet context mismatch')
  if A.bottom or B.bottom then return M.bottom(A.context) end

  local components, order, seen = {}, {}, {}
  for _, d in ipairs(A.order) do
    local av, bv = A.components[d], B.components[d]
    local raw = bv == nil and av or call(d, 'meet', A.context, av, bv)
    local ok, why = add_component(components, order, d, raw)
    if not ok then return why == 'bottom' and M.bottom(A.context) or M.DEFERRED end
    seen[d] = true
  end
  for _, d in ipairs(B.order) do
    if not seen[d] then
      local ok, why = add_component(components, order, d, B.components[d])
      if not ok then return why == 'bottom' and M.bottom(A.context) or M.DEFERRED end
    end
  end
  return value(A.context, components, order, false)
end

local function validate_sigma(source, target, sigma)
  assert(type(sigma) == 'table', 'knowledge reindex substitution required')
  local target_set = context_set(target)
  for _, x in ipairs(source) do
    assert(sigma[x] ~= nil and target_set[sigma[x]],
      'knowledge reindex substitution leaves target context')
  end
end

function M.reindex(k, target, sigma)
  local st = assert(kst(k), 'Knowledge required')
  target = context(target, 'knowledge reindex target')
  validate_sigma(st.context, target, sigma)
  if st.bottom then return M.bottom(target) end

  local components, order = {}, {}
  for _, d in ipairs(st.order) do
    local raw = call(d, 'reindex', st.context, st.components[d], target, sigma)
    local ok, why = add_component(components, order, d, raw)
    if not ok then return why == 'bottom' and M.bottom(target) or M.DEFERRED end
  end
  return value(target, components, order, false)
end

function M.exists(k, keep)
  local st = assert(kst(k), 'Knowledge required')
  keep = context(keep, 'knowledge existential context')
  local source = context_set(st.context)
  for _, x in ipairs(keep) do
    assert(source[x], 'knowledge existential context is not a source subset')
  end
  if st.bottom then return M.bottom(keep) end

  local components, order = {}, {}
  for _, d in ipairs(st.order) do
    local raw = call(d, 'exists', st.context, st.components[d], keep)
    local ok, why = add_component(components, order, d, raw)
    if not ok then return why == 'bottom' and M.bottom(keep) or M.DEFERRED end
  end
  return value(keep, components, order, false)
end

-- Entailment is deliberately not a domain operation.
function M.entails(a, b)
  local both = M.meet(a, b)
  if both == M.DEFERRED then return nil, 'Deferred' end
  return M.equal(both, a)
end

function M.judge(current, requirement)
  local both = M.meet(current, requirement)
  if both == M.DEFERRED then return 'Deferred' end
  if M.is_bottom(both) then return 'Retry' end
  if M.equal(both, current) then return 'Hit' end
  return 'Unknown'
end

local function union_context(parts)
  local out, seen = {}, {}
  for _, k in ipairs(parts) do
    local st = assert(kst(k), 'knowledge product expects Knowledge values')
    for _, x in ipairs(st.context) do
      if not seen[x] then seen[x] = true; out[#out + 1] = x end
    end
  end
  return out
end

local function combine(parts)
  dense(parts, 'knowledge product')
  local target = union_context(parts)
  local out = M.top(target)
  for _, k in ipairs(parts) do
    local sigma = {}
    for _, x in ipairs(M.context(k)) do sigma[x] = x end
    local lifted = M.reindex(k, target, sigma)
    if lifted == M.DEFERRED then return M.DEFERRED end
    out = M.meet(out, lifted)
    if out == M.DEFERRED or M.is_bottom(out) then return out end
  end
  return out
end

local function owns(g, x)
  local kind = W.kind(x)
  if kind == 'membrane' then return g:owns_membrane(x) end
  if kind == 'point' then return g:owns_point(x) end
  if kind == 'strand' then return g:owns_strand(x) end
  if kind == 'face' then return g:owns_face(x) end
  return false
end

local function correspondence(witness)
  if Construction.is_construction(witness) then return witness:correspondence() end
  assert(Construction.is_correspondence(witness),
    'knowledge transport requires Worlds Construction or correspondence')
  return witness
end

local function transformed(d, op, ...)
  local raw = call(d, op, ...)
  if raw == M.DEFERRED then return nil, 'deferred' end
  if raw == M.BOTTOM then return nil, 'bottom' end
  return raw
end

-- Generic exact transport.  Construction never enters a domain callback.
function M.transport(parts, witness)
  dense(parts, 'knowledge transport source')
  local corr = correspondence(witness)
  local source_parts = corr:source_parts()
  assert(#source_parts == #parts,
    'knowledge transport needs one Knowledge value per Construction source part')

  for i, k in ipairs(parts) do
    for _, x in ipairs(M.context(k)) do
      assert(owns(source_parts[i], x),
        'knowledge occurrence is outside its Construction source part')
    end
  end

  local joined = combine(parts)
  if joined == M.DEFERRED then return M.DEFERRED end
  local source = M.context(joined)

  local classes, seen, source_to_class, target_by_class = {}, {}, {}, {}
  for _, x in ipairs(source) do
    local class = assert(corr:source_class(x),
      'Construction correspondence omitted source occurrence')
    source_to_class[x] = class
    local y = corr:survivor(x)
    if not seen[class] then
      seen[class] = true
      classes[#classes + 1] = class
      target_by_class[class] = y
    else
      assert(target_by_class[class] == y,
        'one quotient class has inconsistent surviving targets')
    end
  end

  local retained, target, class_to_target = {}, {}, {}
  for _, class in ipairs(classes) do
    local y = target_by_class[class]
    if y then
      retained[#retained + 1] = class
      target[#target + 1] = y
      class_to_target[class] = y
    end
  end

  if M.is_bottom(joined) then return M.bottom(target) end

  local st = kst(joined)
  local components, order = {}, {}
  for _, d in ipairs(st.order) do
    local raw, why = transformed(d, 'reindex', source, st.components[d], classes, source_to_class)
    if why then return why == 'bottom' and M.bottom(target) or M.DEFERRED end
    if raw ~= M.TOP then
      raw, why = transformed(d, 'exists', classes, raw, retained)
      if why then return why == 'bottom' and M.bottom(target) or M.DEFERRED end
    end
    if raw ~= M.TOP then
      raw, why = transformed(d, 'reindex', retained, raw, target, class_to_target)
      if why then return why == 'bottom' and M.bottom(target) or M.DEFERRED end
    end
    if raw ~= M.TOP then components[d] = raw; order[#order + 1] = d end
  end
  return value(target, components, order, false)
end

return M
