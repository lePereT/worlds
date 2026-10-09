local H=require('speculation.relay.computation.geometry_viability.common')
 local eq,count=select(2,H.counter())
 local K=H.K

local function value_unary(target)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,6 do g.points[i]={membrane=1} end
  for i=1,4 do g.strands[i]={membrane=1,points={i}} end
  g.faces[1]={membrane=1,inputs={1},outputs={2}}
  g.faces[2]={membrane=1,inputs={3},outputs={4}}
  local ctx={{point=5,sort='bool',values={false,true}},{point=6,sort='bool',values={false,true}}}
  local theory=K.points_equal(ctx,5,6)
  return H.Context.normal({
    template={geometry=g,theory=K.spec(theory),authority={inputs={1,3},outputs={2,4}},values={inputs={5},outputs={6}}},
    outer={authority={inputs={1},outputs={2}},values={inputs={1},outputs={}}},
    holes={{target=target,authority={to_target={1},from_target={2}},values={to_target={1},from_target={}}}}
  })
end
-- A prefers entering B over its fallback.  B has one grounded alternative, but it
-- is guarded true.  Under false knowledge B has no finite viable descendant, so
-- A's fallback is stable; under true knowledge the preferred A->B path blocks it.
local p=H.rec_package({
  {identity='a',alternatives={value_unary({definition='b'}),H.bool_authority_context(1,nil)},prefers={{1,2}}},
  {identity='b',alternatives={H.guarded_identity_context(1,true)}},
})
local ar=p:root('a')
 local state,sources=H.state_one(1)
 local fam=H.Search.family(p,ar,2)
 local a=H.Analysis.compute(p)
eq(H.Judgement.first_stable(p,ar,state,H.state_bool(false),sources,fam,a),'Hit','refuted mutual preferred root did not release fallback')
eq(H.Judgement.first_stable(p,ar,state,H.state_bool(true),sources,fam,a),'Hit','expected preferred finite mutual descendant to yield a stable candidate')
-- Restrict discovery to the fallback candidate: under true knowledge it must be blocked.
local fallback=nil
 local def=assert(p:definition(ar))
for _,row in ipairs(fam.items) do if row.proof.root==ar and #def.family.items[row.proof.alternative].holes==0 then fallback=row
 break end end
assert(fallback,'fallback discovery missing')
eq(H.Judgement.check(p,ar,state,H.state_bool(true),sources,fallback,a),'Blocked','viable preferred mutual root failed to block fallback')
print('PASS gv 59: mixed mutual or_else uses paired recursive Geometry+Theory viability ('..count()..')')
