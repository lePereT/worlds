local function read(p) local f=assert(io.open(p,'rb')); local s=f:read('*a'); f:close(); return s end
local centre,edge,facade=read('src/worlds/_centre.lua'),read('src/worlds/_edge.lua'),read('src/worlds.lua')
local fast,index=read('src/worlds/_fast.lua'),read('src/worlds/_index.lua')
local judgement,engine,relation=read('src/worlds/query_factory.lua'),read('src/worlds/query_engine.lua'),read('src/worlds/query_relation.lua')
local construction=read('src/worlds/_construction.lua')

-- Centre: exact Geometry only.
for _,x in ipairs{'worlds%._fast','worlds%._index','query_factory','query_engine','factorise','hall%-deficiency','required target'} do
  assert(not centre:match(x),'edge/search leaked into centre: '..x)
end
assert(centre:match('function W%.boundary') and centre:match('function W%.join'),'centre must own boundary and join')
assert(not centre:match('function W%.advance') and not centre:match('function W%.solve'),'derived live/search operations belong at edge')
assert(centre:match('PRIVATE%.geometry=function'),'edge observation capability missing')

-- Edge: disposable acceleration only.
assert(edge:match("require%('worlds%._centre'%)") and edge:match("require%('worlds%._fast'%)"),'edge must wrap centre with fast paths')
assert(facade:match("require%('worlds%._edge'%)") and facade:match("require%('worlds%._index'%)"),'public facade must own acceleration')
assert(fast:match("return nil,'fallback'"),'fast paths must expose reference fallback')
for _,x in ipairs{'required target','admissible','Question sources'} do assert(not index:match(x),'query policy leaked into index: '..x) end
assert(index:match('function M%.surface') and index:match('function M%.boundary_after'),'shared disposable index incomplete')

-- One exact materialisation witness.
assert(construction:match('Worlds Construction') and construction:match('function MT:image'),'Construction witness missing')
assert(not construction:match('Worlds Realisation'),'Realisation must not be a second witness type')
assert(judgement:match('Construction=require'),'Question must retain the shared Construction witness')

-- Judgement/search split.
assert(judgement:match('function M%.match') and judgement:match('function M%.close'),'finite Question forms missing')
assert(judgement:match('K%.try_join'),'Question must validate exact witnesses with centre join')
assert(not engine:match('K%.try_join'),'search engine must not own quotient lawfulness')
assert(engine:match('coroutine%.create') and engine:match('local function factorise'),'replaceable finite search missing')
assert(relation:match('local function hall') and relation:match('local function allocations'),'scarce relation solver missing')
assert(not relation:match('worlds%._centre') and not relation:match('try_join'),'relation solver must remain Geometry-free')
print('PASS shape 0.6.5 centre / disposable edge')
