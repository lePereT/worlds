local H=require('speculation.relay.computation.geometry_viability.common')
 local eq,count=select(2,H.counter())
 local K,W=H.K,H.W
local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
local ctx={{point=1,sort='bool',values={false,true}},{point=2,sort='bool',values={false,true}}}
local c=H.Context.closed({geometry=g,theory=K.spec(K.points_equal(ctx,1,2)),authority={inputs={1},outputs={1}},values={inputs={2},outputs={}}})
local p=H.one_root('f',{c},{})
 local r=p:root('f')
 local state,sources=H.state_one(1)
 local sp=W.points(sources[1])[1]
 local fam=H.Search.family(p,r,1)
local vctx={{point='i1',sort='bool',values={false,true}}}
 local octx={{point=sp,sort='bool',values={false,true}}}
for _,v in ipairs({false,true}) do for _,o in ipairs({false,true}) do
  local status=H.Judgement.first_stable(p,r,state,{values=K.point_value(vctx,'i1',v),occurrences=K.point_value(octx,sp,o)},sources,fam)
  eq(status,v==o and 'Hit' or 'Retry','joint value/authority truth matrix mismatch')
end end
print('PASS gv 49: generated value/authority correlation matrix is exact ('..count()..')')
