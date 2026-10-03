-- Worlds centre/edge architecture guard.
-- Behaviour belongs to the semantic and differential suites. This file protects only
-- dependency direction, authority ownership and a format-invariant centre-size ratchet.

local function read(path)
    local file = assert(io.open(path, 'rb'))
    local source = file:read('*a')
    file:close()
    return source
end

local function compact(source)
    return (source:gsub('%s+', ''))
end

local function contains(source, text)
    return source:find(text, 1, true) ~= nil
end

local function lacks(source, text, message)
    assert(not contains(source, text), message)
end

local facade = compact(read('src/worlds.lua'))
local core = compact(read('src/worlds/_kernel.lua'))
local query_edge = compact(read('src/worlds/_query.lua'))
local query_public = compact(read('src/worlds/query.lua'))
local judgement = compact(read('src/worlds/query_factory.lua'))
local query = compact(read('src/worlds/query_engine.lua'))
local closure = compact(read('src/worlds/query_closure_engine.lua'))
local relation = compact(read('src/worlds/query_relation.lua'))
local image = compact(read('src/worlds/_image.lua'))
local construction = compact(read('src/worlds/construction.lua'))
local presentation = compact(read('src/worlds/presentation.lua'))

local core_budget = 23150
local centre_budget = 23850
assert(#core <= core_budget,
    'verified centre exceeded compact-source budget: ' .. #core .. ' characters')
assert(#core + #image <= centre_budget,
    'centre plus exact-image evidence exceeded compact-source budget')

assert(contains(core, "require('worlds._array')"), 'kernel dense-array dependency missing')
assert(contains(core, "require('worlds._image')"), 'kernel exact-image dependency missing')
lacks(core, "require('worlds._fast')", 'verified centre depends on fast paths')
lacks(core, "require('worlds._compiled')", 'verified centre depends on compiled indexes')
lacks(core, 'query_factory', 'verified centre depends on matching policy')
lacks(core, 'worlds.history', 'optional History leaked into verified centre')
lacks(core, 'relay.', 'Relay leaked into Worlds')
assert(contains(core, 'functionW.boundary('), 'boundary projection missing')
assert(contains(core, 'functionW.join('), 'single join missing')
assert(contains(core, 'functionW.advance('), 'boundary-normal advance missing')
lacks(core, 'functionW.solve(', 'complete-query convenience leaked into the centre')

assert(contains(facade, "require('worlds._kernel')"), 'public facade lost verified centre')
assert(contains(facade, "require('worlds._compiled')"), 'public edge lost compiled indexes')
assert(contains(facade, "require('worlds._fast')"), 'public edge lost exact fast paths')
assert(contains(facade, "require('worlds._query')"), 'public edge lost query delegation')
assert(contains(facade, 'functionW.solve('), 'public solve missing')
lacks(facade, "require('worlds.construction')", 'facade imported Construction')
lacks(facade, "require('worlds.presentation')", 'facade imported Presentation')

assert(contains(query_edge, "require('worlds._kernel')"), 'query edge lost strict kernel')
assert(contains(query_edge, "require('worlds._fast')"), 'query edge lost fast validation')
assert(contains(query_edge, "require('worlds.query_factory')"), 'query factory edge missing')
assert(contains(query_public, "require('worlds._query').public"), 'public query edge diverged')

assert(contains(judgement, "require('worlds._compiled')"), 'Question layer lost indexes')
assert(contains(judgement, 'K.try_join'), 'Question layer must validate strict witnesses')
assert(contains(judgement, "require('worlds.query_engine')"), 'Match engine missing')
assert(contains(judgement, "require('worlds.query_closure_engine')"), 'Close engine missing')
lacks(query, 'K.try_join', 'replaceable Match engine owns quotient lawfulness')
lacks(closure, 'try_join', 'replaceable Close engine owns quotient lawfulness')
lacks(relation, "require('worlds._kernel')", 'finite relation search depends on kernel')
assert(contains(query, "require('worlds.query_relation')"), 'Match relation search missing')
assert(contains(closure, "require('worlds.query_relation')"), 'Close relation search missing')
for _, source in ipairs({ judgement, query, closure, relation }) do
    lacks(source, 'relay.', 'Worlds finite judgement depends on Relay')
end

assert(contains(construction, "require('worlds')"), 'Construction lost public Worlds view')
assert(contains(construction, "require('worlds._kernel')"),
    'Construction lost native quotient evidence from verified centre')
assert(contains(construction, 'K.construction_join('),
    'Construction correspondence must use the strict kernel join')
lacks(construction, 'W.join(', 'Construction duplicated strict join through public facade')
assert(contains(presentation, "require('worlds.construction')"),
    'Presentation transport must require Construction evidence')
assert(contains(presentation, 'construction:image('),
    'Presentation transport must follow exact Construction image')
lacks(presentation, 'W.join(', 'Presentation changes Geometry')
lacks(presentation, 'W.builder(', 'Presentation manufactures carriers')

print('PASS Worlds centre/edge architecture')
