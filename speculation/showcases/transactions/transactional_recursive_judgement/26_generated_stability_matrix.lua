local H=require('speculation.showcases.transactions.transactional_recursive_judgement.common')
 local n=0
local function eq(a,b,m) n=n+1
 assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local guards={false,true,'none'}
for _,g in ipairs(guards) do for _,flip in ipairs({false,true}) do for _,order in ipairs({'rec-first','base-first','unordered'}) do
  local guard=g=='none' and nil or g
  local rec=H.unary_bool_context({definition='f'},guard,flip)
 local base=H.base_bool_context(nil)
  local alts,edges
  if order=='rec-first' then alts={rec,base}
 edges={{1,2}}
  elseif order=='base-first' then alts={base,rec}
 edges={{1,2}}
  else alts={rec,base}
 edges={} end
  local p=H.rec_package('f',alts,edges)
 local r=p:root('f')
 local a=H.Analysis.compute(p)
  for _,state in ipairs({false,true}) do
    local f2=H.Search.family(p,r,2)
 local f3=H.Search.family(p,r,3)
    local s2,row2=H.Judgement.first_stable(p,r,H.state_bool(state),f2,a)
    local s3,row3=H.Judgement.first_stable(p,r,H.state_bool(state),f3,a)
    eq(s2,s3,'stable status changed with deeper discovery')
    if s2=='Hit' then eq(H.Canonical.encode(row2.value),H.Canonical.encode(row3.value),'stable meaning changed with deeper discovery') end
  end
end end end
print('PASS rj 26: generated recursive stability matrix ('..n..' assertions)')
