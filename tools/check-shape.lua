local function read(path) local f=assert(io.open(path,'rb')); local s=f:read('*a'); f:close(); return s end
local facade=read('src/worlds.lua')
local core=read('src/worlds/_kernel.lua')
local queryedge=read('src/worlds/_query.lua')
local querypublic=read('src/worlds/query.lua')
local judgement=read('src/worlds/query_factory.lua')
local query=read('src/worlds/query_engine.lua')
local closure=read('src/worlds/query_closure_engine.lua')
local relation=read('src/worlds/query_relation.lua')
local compiled=read('src/worlds/_compiled.lua')

-- Sacred Geometry centre: no finite-question policy or acceleration/search
-- implementation.  It exports only public semantics plus a private read-only
-- observation capability consumed from the edge.
for _,x in ipairs{
  'optional_ingress','forbid','exact_restriction','counted_surface','ingress_section',
  'factorise','hall%-deficiency','SolveMT','candidate_groups','compile_relation',
  'Question sources','admissible','required target','worlds%.query.*new',
} do assert(not core:match(x),'query/search machinery leaked into Worlds centre: '..x) end
assert(not core:match("worlds%._compiled"),'verified centre must not depend on disposable acceleration')
assert(not core:match('%.attach%('),'verified centre must not attach acceleration state')
assert(not core:match('%.register%('),'verified centre must not register with acceleration')
assert(core:match('function W%.boundary'),'boundary projection missing')
assert(core:match('function W%.join'),'single join missing')
assert(not core:match('function W%.materialisable'),'materialisable must not become a public Geometry operation')
assert(core:match('function W%.advance'),'boundary-normal advance missing')
assert(not core:match('query_factory'),'verified centre must not depend on matching implementation')
assert(not core:match('function W%.solve'),'complete-query convenience belongs at the public edge')
assert(not core:match('HistoryMT'),'History must remain outside the centre')
assert(not core:match('worlds%.history'),'optional History must not be a centre dependency')
assert(core:match('function W%.builder%(%)%s+local membranes'),'Builder state must be lexical rather than exposed representation')
assert(not core:match('BuilderMT'),'Builder must not use a shared mutable-state registry/metatable implementation')
assert(core:match('PRIVATE%.geometry=function'),'private observation capability missing')
assert(core:match('local function is_boundary_normal'),'boundary normality must be a kernel fact')

-- Public edge may eagerly prepare disposable indexes, but it must do so outside
-- the verified centre and only after a Geometry has already been produced.
assert(facade:match("require%('worlds%._kernel'%)"),'public facade must expose the verified centre')
assert(facade:match("require%('worlds%._compiled'%)"),'public edge must own eager acceleration')
assert(facade:match('Compiled%.prepare%(g%)'),'builder installation boundary must prepare outgoing acceleration')
assert(facade:match('function W%.solve'),'complete-query convenience must live at the public edge')
assert(facade:match("require%('worlds%._query'%)"),'public solve must delegate to the disposable query edge')
assert(queryedge:match("require%('worlds%.query_factory'%)"),'shared query edge must construct the matching implementation')
assert(querypublic:match("require%('worlds%._query'%)%.public"),'worlds.query must share the same disposable query instance as W.solve')

-- Private compilation is acceleration only: no finite-Question policy belongs
-- here, no callback points back into Geometry construction, and all state is
-- derived from the injected observation capability.
assert(compiled:match('Private disposable acceleration'),'compiled sidecar must remain explicitly disposable')
assert(compiled:match('function M%.surface'),'compiled outgoing section missing')
assert(compiled:match('function M%.egress_positions'),'lazy exact egress positions missing')
assert(compiled:match('function M%.prepare'),'edge preparation hook missing')
assert(not compiled:match('function M%.attach'),'compiled acceleration must not attach itself to Geometry')
assert(not compiled:match('function M%.register'),'compiled acceleration must not register the kernel')
assert(not compiled:match('required target'),'Question policy leaked into compiled Geometry acceleration')
assert(not compiled:match('admissible'),'Question policy leaked into compiled Geometry acceleration')

-- Query owns the matching judgement and disposable engine.
assert(judgement:match('Match%(A,B; S,T,D,R,C,E0%)'),'Match Question normal form missing')
assert(judgement:match('Close%(P; S,T,D,R,C,E0%)'),'Close Question normal form missing')
assert(judgement:match('function M%.match'),'Match Question constructor missing')
assert(judgement:match('function M%.close'),'Close Question constructor missing')
assert(not judgement:match('function M%.new'),'vague Question.new constructor must remain absent')
assert(judgement:match('function M%.complete'),'complete Question constructor missing')
assert(judgement:match('function M%.solve'),'Question solve judgement missing')
assert(judgement:match('Worlds Refutation'),'Question layer must expose exact refutation evidence')
assert(not judgement:match('factorise'),'Question judgement must not contain search engine')
assert(not judgement:match('QSTATE=setmetatable'),'Question state must not use a weak registry')
assert(not judgement:match('RSTATE=setmetatable'),'Refutation state must not use a weak registry')
assert(not judgement:match('SOLVESTATE=setmetatable'),'public solve state must not use a weak registry')
assert(not judgement:match("setmetatable({}, {__mode='k'})"),'Question object state/factory must not use weak registries')
assert(judgement:match('if spec%.sources==nil then sources=nil; full_sources=true'),'complete source section must remain symbolic')
assert(judgement:match('if spec%.targets==nil then targets=nil; full_targets=true'),'complete target section must remain symbolic')
assert(query:match('local function ingress_section'),'declarative development-side matching analysis missing')
assert(query:match('endpoints={}'),'endpoint-thread quotient missing')
assert(query:match('local function counted_surface'),'query-local outgoing section missing')
assert(query:match("kind='and'"),'retained AND support missing')
assert(query:match("kind='or'"),'retained OR support missing')
assert(query:match('local function factorise'),'query factor engine missing')
assert(query:match('relation{'),'Match must use shared finite-relation search')
assert(closure:match('relation{'),'Close must use shared finite-relation search')
assert(relation:match('local function hall'),'shared Hall feasibility missing')
assert(relation:match('local function allocations'),'shared scarce allocation missing')
assert(relation:match('return function%(spec%)') and relation:match('required_sources') and relation:match('required_targets'),'shared finite relation must cover required domain and range')
assert(not relation:match('worlds%._kernel') and not relation:match('try_join'),'shared relation search must remain Geometry-free')
assert(judgement:match('K%.try_join'),'Question judgement must validate exact witnesses against strict join lawfulness')
assert(not query:match('K%.try_join'),'replaceable Match engine must not own quotient lawfulness')
assert(not closure:match('try_join'),'replaceable Close engine must not own quotient lawfulness')
assert(closure:match('return function%(spec%)'),'replaceable direct-closure engine missing')
assert(not closure:match('worlds%._kernel'),'Close engine must not retain Geometry/kernel state')
assert(not query:match('SSTATE=setmetatable'),'engine solve state must be closure-owned')
assert(query:match('coroutine%.create'),'retained query engine missing')
assert(query:match('function M%.complete'),'complete hot-path constructor missing')
assert(query:match('function M%.solve'),'replaceable query engine missing')
assert(not query:match('relay%.'),'Worlds Query must remain Relay-neutral')
print('PASS shape 0.6.1 centre/edge split')
