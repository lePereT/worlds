local H=require('speculation.relay.computation.geometry_viability.common')
 local eq,count=select(2,H.counter())
local K,W=H.K,H.W
local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={{membrane=1,points={1}},{membrane=1,points={2}}},faces={}}
local ctx={{point=1,sort='bool',values={false,true}},{point=2,sort='bool',values={false,true}}}
local req=K.meet(K.point_value(ctx,1,true),K.point_value(ctx,2,false))
local c=H.Context.closed({geometry=g,theory=K.spec(req),authority={inputs={1,2},outputs={1,2}},values={inputs={},outputs={}}})
local p=H.one_root('f',{c},{})
 local r=p:root('f')
 local state,sources=H.state_two(true,true)
 local fam=H.Search.family(p,r,1)
local sp=W.points(sources[1])[1]
 local octx={{point=sp,sort='bool',values={false,true}}}
eq(H.Judgement.first_stable(p,r,state,{occurrences=K.top(octx)},sources,fam),'Retry','one live Point cannot satisfy incompatible facts on two Rule Points identified by exact source sharing')
print('PASS gv 45: exact source sharing constrains Theory without a separate alias analysis ('..count()..')')
