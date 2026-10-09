local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K
local function recursive()
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,7 do g.points[i]={membrane=1} end
  g.strands={{membrane=1,points={1}},{membrane=1,points={2}},{membrane=1,points={3}}}
  g.faces={{membrane=1,inputs={1},outputs={2}}}
  local ctx={{point=4,sort='bool',values={false,true}},{point=5,sort='bool',values={false,true}},{point=6,sort='bool',values={false,true}},{point=7,sort='bool',values={false,true}}}
  local theory=K.relation(ctx,function(v) return v[4]==true and v[6]==false and v[7]==v[5] end)
  return H.Context.normal({template={geometry=g,theory=K.spec(theory),authority={inputs={1,3},outputs={2,3}},values={inputs={4,5},outputs={6,7}}},outer={authority={inputs={1},outputs={2}},values={inputs={1},outputs={2}}},holes={{target={definition='f'},authority={to_target={1},from_target={2}},values={to_target={1},from_target={2}}}}})
end
local function base()
  local g={membranes={{parent=0}},points={{membrane=1},{membrane=1},{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
  local ctx={{point=2,sort='bool',values={false,true}},{point=3,sort='bool',values={false,true}}}
 local theory=K.points_equal(ctx,2,3)
  return H.Context.closed({geometry=g,theory=K.spec(theory),authority={inputs={1},outputs={1}},values={inputs={2},outputs={3}}})
end
local p=H.one_root('f',{recursive(),base()},{{1,2}})
 local r=p:root('f')
 local state,sources=H.state_one(1)
 local fam=H.Search.family(p,r,2)
 local hits=0
for _,row in ipairs(fam.items) do if H.Judgement.check(p,r,state,H.state_bool(true),sources,row)=='Hit' then hits=hits+1 end end
eq(hits,1,'authority+knowledge transition did not expose exactly one stable recursive descendant')
print('PASS gv 30: restrictive knowledge transition and exact authority viability compose in one recursive Judgement ('..count()..')')
