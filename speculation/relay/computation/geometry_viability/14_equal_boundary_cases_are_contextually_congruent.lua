local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
local step=assert(H.Context.plug(H.authority_step_context(),{}))
 local once=assert(H.Context.plug(H.unary_context({definition='x'}),{step}))
eq(H.Case.key(step),H.Case.key(once),'precondition: causal chains did not collapse to one boundary case')
for _,opts in ipairs({{prefix=true},{prefix=true,suffix=true}}) do
  local wrap=H.unary_context({definition='x'},opts)
  local a=assert(H.Context.plug(wrap,{step}))
 local b=assert(H.Context.plug(wrap,{once}))
  eq(H.Case.key(a),H.Case.key(b),'boundary-case equality was not a congruence under wrapper composition')
end
print('PASS gv 14: distinct finite histories in one boundary case remain indistinguishable under tested contexts ('..count()..')')
