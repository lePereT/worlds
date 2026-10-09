local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C=H.C
local p=C.bind(H.identity_operation(),H.branch({{true,'y'},{false,'n'}},{auth=true}),{captures={{from=1,to=1}}})
for _,a in ipairs(p:family().items) do
  local keys=0
 for k in pairs(a) do keys=keys+1
 ok(k=='geometry' or k=='theory' or k=='authority' or k=='values') end
  eq(keys,4)
end
ok(not p:bytes():find('trace',1,true))
 ok(not p:bytes():find('continuation',1,true))
print('PASS td 17: complete alternatives contain one Development, no staging residue ('..count()..')')
