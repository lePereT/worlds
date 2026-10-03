local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
local reps={assert(H.Context.plug(H.authority_step_context(),{})),assert(H.Context.plug(H.diamond_context(),{}))}
local t=reps[1]
 for i=1,5 do t=assert(H.Context.plug(H.unary_context({definition='x'}),{t}))
 reps[#reps+1]=t end
local k=H.Case.key(reps[1])
 for i=2,#reps do eq(H.Case.key(reps[i]),k,'generated representatives did not share one boundary case') end
local wrappers={{prefix=true},{prefix=true,suffix=true}}
for _,opts in ipairs(wrappers) do local w=H.unary_context({definition='x'},opts)
 local expected
  for i,r in ipairs(reps) do local x=assert(H.Context.plug(w,{r}))
 local q=H.Case.key(x)
 if expected then eq(q,expected,'same boundary case was distinguished by generated wrapper') else expected=q end end
end
print('PASS gv 27: generated distinct histories in one case are contextually congruent under tested wrappers ('..count()..')')
