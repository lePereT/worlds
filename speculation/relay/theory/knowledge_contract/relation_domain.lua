-- Finite Boolean relational oracle for the thin Theory/Knowledge contract.
--
-- This file is a domain, not a Knowledge host.  Its semantic surface is exactly
-- the four effective regular-doctrine operations accepted by knowledge.lua:
-- equal, meet, reindex and exists.  Everything else below is test construction
-- or inspection convenience.

local K = require('speculation.relay.theory.knowledge')
local M = {}

local function copy(xs)
  local out = {}
  for i, x in ipairs(xs or {}) do out[i] = x end
  return out
end

local function index(ctx)
  local out = {}
  for i, x in ipairs(ctx) do out[x] = i end
  return out
end

local function bit(row, i)
  return row:sub(i, i) == '1' and 1 or 0
end

local function all_rows(n)
  local out = {}
  for number = 0, 2 ^ n - 1 do
    local x, bits = number, {}
    for i = n, 1, -1 do
      bits[i] = x % 2 == 1 and '1' or '0'
      x = math.floor(x / 2)
    end
    out[#out + 1] = table.concat(bits)
  end
  return out
end

local function row_set(rows)
  local out = {}
  for _, row in ipairs(rows or {}) do out[row] = true end
  return out
end

local function row_count(rows)
  local n = 0
  for _ in pairs(rows) do n = n + 1 end
  return n
end

local function normal(ctx, rows)
  local n = row_count(rows)
  if n == 0 then return K.BOTTOM end
  if n == 2 ^ #ctx then return K.TOP end
  return rows
end

local function equal_rows(a, b)
  for row in pairs(a) do if not b[row] then return false end end
  for row in pairs(b) do if not a[row] then return false end end
  return true
end

local Domain = K.domain {
  name = 'finite-boolean-relation',

  equal = function(_, a, b)
    return equal_rows(a, b)
  end,

  meet = function(ctx, a, b)
    local rows = {}
    for row in pairs(a) do if b[row] then rows[row] = true end end
    return normal(ctx, rows)
  end,

  reindex = function(source, raw, target, sigma)
    local target_index = index(target)
    local rows = {}
    for _, target_row in ipairs(all_rows(#target)) do
      local source_bits = {}
      for i, x in ipairs(source) do
        source_bits[i] = tostring(bit(target_row, assert(target_index[sigma[x]])))
      end
      if raw[table.concat(source_bits)] then rows[target_row] = true end
    end
    return normal(target, rows)
  end,

  exists = function(source, raw, keep)
    local source_index = index(source)
    local rows = {}
    for source_row in pairs(raw) do
      local bits = {}
      for i, x in ipairs(keep) do
        bits[i] = tostring(bit(source_row, assert(source_index[x])))
      end
      rows[table.concat(bits)] = true
    end
    return normal(keep, rows)
  end,
}

M.domain = Domain

function M.relation(ctx, predicate)
  local rows = {}
  for _, row in ipairs(all_rows(#ctx)) do
    local env = {}
    for i, x in ipairs(ctx) do env[x] = bit(row, i) end
    if predicate(env) then rows[row] = true end
  end
  return K.of(ctx, Domain, normal(ctx, rows))
end

function M.from_rows(ctx, rows)
  return K.of(ctx, Domain, normal(ctx, row_set(rows)))
end

function M.rows(k)
  local raw = K.component(k, Domain)
  if raw == K.BOTTOM then return {} end
  if raw == K.TOP then return all_rows(#K.context(k)) end
  local out = {}
  for row in pairs(raw) do out[#out + 1] = row end
  table.sort(out)
  return out
end

function M.copy_context(k)
  return copy(K.context(k))
end

return M
