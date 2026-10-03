local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local eq,count=select(2,H.counter())
 local K,W=H.K,H.W
local raw=H.unary_context({definition='f'})
 local t=raw.template
local outer_s=t.authority.inputs[raw.outer.authority.inputs[1]]
local child_s=t.authority.outputs[raw.holes[1].authority.to_target[1]]
local p0=t.geometry.strands[outer_s].points[1]
 local p1=t.geometry.strands[child_s].points[1]
local ctx={{point=p0,sort='bool',values={false,true}},{point=p1,sort='bool',values={false,true}}}
local theory=K.relation(ctx,function(e) return e[p0]==true and e[p1]==false end)
local rec=H.Context.normal({template={geometry=t.geometry,theory=K.spec(theory),authority=t.authority,values=t.values},outer=raw.outer,holes=raw.holes})
local base=H.authority_identity_context()
 local pkg=H.one_root('f',{rec,base},{{1,2}})
 local root=pkg:root('f')
local state,sources=H.state_one(1)
 local sp=W.points(sources[1])[1]
 local octx={{point=sp,sort='bool',values={false,true}}}
local fam=H.Search.family(pkg,root,2)
eq(H.Judgement.first_stable(pkg,root,state,{occurrences=K.point_value(octx,sp,true)},sources,fam),'Hit','recursive authority step should become stable when its Theory transition refutes the preferred child recurrence')
print('PASS gv 53: occurrence knowledge can stabilise recursive authority through an ordinary Theory transition ('..count()..')')
