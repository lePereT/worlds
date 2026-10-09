local H=require('speculation.relay.computation.geometry_viability.common')
 local ok,eq,count=H.counter()
 local p=H.one_root('f',{H.authority_identity_context(),H.unary_context({definition='f'})})
 local a=H.Analysis.compute(p)
local forbidden={effect=true,capability=true,permission=true,task=true,scheduler=true,consume=true,create=true,linear=true}
local function walk(x,seen)
  if type(x)~='table' then return end
 seen=seen or {}
 if seen[x] then return end
 seen[x]=true
  for k,v in pairs(x) do if type(k)=='string' then ok(not forbidden[k:lower()],'forbidden authority-effect field leaked into viability evidence: '..k) end
 walk(v,seen) end
end
walk(a)
print('PASS gv 35: authority viability is a quotient of Development, not a new effect/capability language ('..count()..')')
