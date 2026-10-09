local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C,T,G,P=H.C,H.T,H.G,H.P
local g,p=G.operation(1,0)
local function consumer(v) return C.atom({geometry=g,theory={variables={'o'},equalities={T.eq(T.var('o'),v)}},authority={inputs=p.inputs,outputs={}},values={inputs={},outputs={'o'}}}) end
local a,b=consumer('a'),consumer('b')
 local state,x=H.live(1)
local kind=C.prepare(state,C.or_(a,b),{x[1]})
 eq(kind,'Many')
local both=C.each({a,b})
 local kind2=C.prepare(state,both,{x[1],x[1]})
 eq(kind2,'Retry')
print('PASS td 14: alternatives may share scarcity; positive siblings may not duplicate it ('..count()..')')
