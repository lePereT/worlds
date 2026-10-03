local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local eq,count=select(2,H.counter())
 local K,W=H.K,H.W
local g={membranes={{parent=0}},points={{membrane=1}},strands={{membrane=1,points={1}},{membrane=1,points={1}}},faces={}}
local ctx={{point=1,sort='bool',values={false,true}}}
local c=H.Context.closed({geometry=g,theory=K.spec(K.point_value(ctx,1,true)),authority={inputs={1,2},outputs={1,2}},values={inputs={},outputs={}}})
local p=H.one_root('f',{c},{})
 local r=p:root('f')
 local state,sources=H.state_two(false,true)
 local fam=H.Search.family(p,r,1)
 local p1,p2=W.points(sources[1])[1],W.points(sources[2])[1]
local octx={{point=p1,sort='bool',values={false,true}},{point=p2,sort='bool',values={false,true}}}
for _,a in ipairs({false,true}) do for _,b in ipairs({false,true}) do
  local know=K.relation(octx,function(e) return e[p1]==a and e[p2]==b end)
  local status=H.Judgement.first_stable(p,r,state,{occurrences=know},sources,fam)
  eq(status,(a and b) and 'Hit' or 'Retry','Construction-sharing truth matrix mismatch')
end end
print('PASS gv 50: generated Construction-sharing occurrence matrix is exact ('..count()..')')
