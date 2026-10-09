-- Architectural ratchet for the thin Theory/Knowledge laboratory.
--
-- The point is negative: there is one generic host, domain adapters consume it,
-- and quotient/correspondence semantics are never reimplemented beside Worlds.

local n = 0
local function ok(x, msg)
  n = n + 1
  assert(x, msg or 'architecture assertion failed')
end

local function read(path)
  local f = io.open(path, 'rb')
  if not f then return nil end
  local s = f:read('*a')
  f:close()
  return s
end

local function absent(path)
  ok(read(path) == nil, 'obsolete Theory implementation reappeared: ' .. path)
end

absent('speculation/relay/computation/development_calculus/theory.lua')
absent('speculation/relay/theory/knowledge_contract/relation_doctrine.lua')
absent('speculation/relay/theory/knowledge_contract/corelation.lua')
absent('speculation/relay/theory/lifecycle_and_correspondence/relation_doctrine.lua')
absent('speculation/relay/theory/lifecycle_and_correspondence/correspondence.lua')

local host_name = "require('speculation.relay.theory.knowledge')"
local equality = assert(read('speculation/relay/computation/development_calculus/equality.lua'))
local recursive = assert(read('speculation/relay/computation/recursive_judgement/knowledge.lua'))
local host = assert(read('speculation/relay/theory/knowledge.lua'))

ok(equality:find(host_name, 1, true) ~= nil,
  'symbolic equality domain does not consume the thin Knowledge host')
ok(recursive:find(host_name, 1, true) ~= nil,
  'recursive finite relation adapter does not consume the thin Knowledge host')
ok(equality:find("require('worlds.construction')", 1, true) == nil,
  'symbolic equality domain imports Worlds Construction')
ok(recursive:find("require('worlds.construction')", 1, true) == nil,
  'recursive finite relation adapter imports Worlds Construction')
ok(host:find("require('worlds.construction')", 1, true) ~= nil,
  'thin Knowledge host no longer owns native correspondence transport')
ok(host:find(':correspondence()', 1, true) ~= nil,
  'thin Knowledge host stopped consuming native Construction correspondence')

print('knowledge architecture: ' .. n .. ' assertions passed')
