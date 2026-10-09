local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local K,W=H.K,H.W
local function guarded(guard)
  local g={membranes={{parent=0}},points={{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
  local ctx={{point=1,sort='bool',values={false,true}}}
  return H.Context.closed({geometry=g,theory=K.spec(K.point_value(ctx,1,guard)),authority={inputs={1},outputs={1}},values={inputs={},outputs={}}})
end
local p=H.one_root('f',{guarded(true)},{}) local r=p:root('f')
 local state,sources=H.state_one(1)
local sp=W.points(sources[1])[1]
 local ctx={{point=sp,sort='bool',values={false,true}}}
 local fam=H.Search.family(p,r,1)
local function judge(k) return H.Judgement.first_stable(p,r,state,{occurrences=k},sources,fam) end
eq(judge(K.point_value(ctx,sp,true)),'Hit','live occurrence fact should establish authority-Point requirement')
eq(judge(K.point_value(ctx,sp,false)),'Retry','contradictory live occurrence fact should refute authority-Point requirement')
eq(judge(K.top(ctx)),'Deferred','missing occurrence fact should be semantic Unknown, not Hit or Retry')
print('PASS gv 41: exact live occurrence knowledge governs authority-supported Theory ('..count()..')')
