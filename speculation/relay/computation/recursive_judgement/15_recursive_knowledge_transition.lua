local H=require('speculation.relay.computation.recursive_judgement.common')
 local ok,eq,count=H.counter()
-- Preferred recursion is lawful only on true and flips the recursive input to false.
-- At the child, the preferred branch is then refuted, so the base becomes stable.
local p=H.rec_package('f',{H.unary_bool_context({definition='f'},true,true),H.base_bool_context(nil)},{{1,2}})
 local r=p:root('f')
 local a=H.Analysis.compute(p)
local f=H.Search.family(p,r,2)
 local hits=0
for _,row in ipairs(f.items) do if H.Judgement.check(p,r,H.state_bool(true),row,a)=='Hit' then hits=hits+1 end end
eq(hits,1,'knowledge transition did not expose exactly one stable recursive descendant')
local s=H.Judgement.first_stable(p,r,H.state_bool(true),f,a)
 eq(s,'Hit')
print('PASS rj 15: stable eligibility follows occurrence-relative knowledge through recursive context ('..count()..')')
