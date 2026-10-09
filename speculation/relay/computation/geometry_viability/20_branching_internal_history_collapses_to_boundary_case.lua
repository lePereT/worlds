local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local step=assert(H.Context.plug(H.authority_step_context(),{}))
 local diamond=assert(H.Context.plug(H.diamond_context(),{}))
eq(H.Case.key(step),H.Case.key(diamond),'internal split/merge history leaked into boundary Development case')
for _,opts in ipairs({{prefix=true},{prefix=true,suffix=true}}) do
  local w=H.unary_context({definition='x'},opts)
 local a=assert(H.Context.plug(w,{step}))
 local b=assert(H.Context.plug(w,{diamond}))
  eq(H.Case.key(a),H.Case.key(b),'split/merge history became observable through enclosing boundary composition')
end
print('PASS gv 20: closed branching history is erased when its exact boundary behaviour agrees ('..count()..')')
