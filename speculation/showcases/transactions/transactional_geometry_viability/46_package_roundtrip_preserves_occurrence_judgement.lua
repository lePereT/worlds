local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local eq,count=select(2,H.counter())
local K,W=H.K,H.W
local function branch(guard)
  local g={membranes={{parent=0}},points={{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
  local ctx={{point=1,sort='bool',values={false,true}}}
 local k=guard==nil and K.top(ctx) or K.point_value(ctx,1,guard)
  return H.Context.closed({geometry=g,theory=K.spec(k),authority={inputs={1},outputs={1}},values={inputs={},outputs={}}})
end
local p=H.one_root('f',{branch(true),branch(nil)},{{1,2}})
 local q=H.RP.decode(p:bytes())
local r,qr=p:root('f'),q:definitions()[1].root
 local state,sources=H.state_one(1)
 local sp=W.points(sources[1])[1]
local ctx={{point=sp,sort='bool',values={false,true}}}
for _,k in ipairs({K.top(ctx),K.point_value(ctx,sp,false),K.point_value(ctx,sp,true)}) do
  local a=H.Judgement.first_stable(p,r,state,{occurrences=k},sources,H.Search.family(p,r,1))
  local b=H.Judgement.first_stable(q,qr,state,{occurrences=k},sources,H.Search.family(q,qr,1))
  eq(a,b,'Package roundtrip changed occurrence-relative authority Judgement')
end
print('PASS gv 46: Package roundtrip preserves occurrence-relative authority Judgement ('..count()..')')
