local H=require('speculation.relay.computation.geometry_viability.common')
 local eq,count=select(2,H.counter())
local K,W=H.K,H.W
local function branch(guard)
  local g={membranes={{parent=0}},points={{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
  local ctx={{point=1,sort='bool',values={false,true}}}
 local k=guard==nil and K.top(ctx) or K.point_value(ctx,1,guard)
  return H.Context.closed({geometry=g,theory=K.spec(k),authority={inputs={1},outputs={1}},values={inputs={},outputs={}}})
end
local p=H.one_root('f',{branch(true),branch(nil)},{{1,2}})
 local r=p:root('f')
 local state,sources=H.state_one(1)
local sp=W.points(sources[1])[1]
 local ctx={{point=sp,sort='bool',values={false,true}}}
 local fam=H.Search.family(p,r,1)
local function status(k) return H.Judgement.first_stable(p,r,state,{occurrences=k},sources,fam) end
eq(status(K.top(ctx)),'Deferred','unknown preferred occurrence guard must keep fallback blocked')
eq(status(K.point_value(ctx,sp,false)),'Hit','positive contradiction must release the lower-priority fallback')
eq(status(K.point_value(ctx,sp,true)),'Hit','established preferred branch should commit')
print('PASS gv 42: recursive priority is certified by exact occurrence knowledge ('..count()..')')
