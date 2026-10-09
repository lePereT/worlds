local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local K,W=H.K,H.W
local g={membranes={{parent=0}},points={{membrane=1},{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
local ctx={{point=1,sort='bool',values={false,true}},{point=2,sort='bool',values={false,true}}}
local rel=K.points_equal(ctx,1,2)
local c=H.Context.closed({geometry=g,theory=K.spec(rel),authority={inputs={1},outputs={1}},values={inputs={2},outputs={}}})
local p=H.one_root('f',{c},{})
 local r=p:root('f')
 local state,sources=H.state_one(1)
 local sp=W.points(sources[1])[1]
local fam=H.Search.family(p,r,1)
 local vctx={{point='i1',sort='bool',values={false,true}}}
 local octx={{point=sp,sort='bool',values={false,true}}}
local function status(bundle) return H.Judgement.first_stable(p,r,state,bundle,sources,fam) end
eq(status({values=K.point_value(vctx,'i1',true),occurrences=K.point_value(octx,sp,true)}),'Hit','matching value and authority knowledge should establish relational requirement')
eq(status({values=K.point_value(vctx,'i1',true),occurrences=K.point_value(octx,sp,false)}),'Retry','cross-boundary relational contradiction must be visible')
eq(status({values=K.point_value(vctx,'i1',true),occurrences=K.top(octx)}),'Deferred','unknown authority side must not be guessed from the public value')
local jointctx={{point='i1',sort='bool',values={false,true}},{point=sp,sort='bool',values={false,true}}}
eq(status({joint=K.points_equal(jointctx,'i1',sp)}),'Hit','joint state knowledge must preserve correlation even when both marginals are individually unknown')
print('PASS gv 43: public values and authority occurrences share one positive knowledge relation ('..count()..')')
