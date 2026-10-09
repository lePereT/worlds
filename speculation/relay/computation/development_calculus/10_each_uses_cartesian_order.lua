local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C,T=H.C,H.T
local a=C.or_else(C.always('a1'),C.always('a2'))
 local b=C.or_else(C.always('b1'),C.always('b2'))
local p=C.each({a,b})
 local f=p:family()
 eq(#f.items,4)
local index={}
for i,x in ipairs(f.items) do index[H.out_value(p,i,1)..'/'..H.out_value(p,i,2)]=i end
ok(H.reach(f,index['a1/b1'],index['a2/b1']))
 ok(H.reach(f,index['a1/b1'],index['a1/b2']))
ok(not H.reach(f,index['a1/b2'],index['a2/b1']))
 ok(not H.reach(f,index['a2/b1'],index['a1/b2']))
print('PASS td 10: each lifts preference by true Cartesian product order ('..count()..')')
