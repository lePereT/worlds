local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local P,C=H.P,H.C
local a=C.always(1):alternative(1)
 local b=C.each({C.always(1),C.always(2)}):alternative(1)
ok(not pcall(function() P.new({items={a,b},edges={}}) end))
print('PASS td 21: alternatives share one stable public interface ('..count()..')')
