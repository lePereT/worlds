local H=require('speculation.showcases.transactions.transactional_development_calculus.common')
local ok,eq,count=H.counter()
 local C,T,P=H.C,H.T,H.P
local items={}
for n=0,3 do local g,ai,ao=H.fanout(n)
 items[#items+1]={geometry=g,
  theory={variables={'n','out'},equalities={T.eq(T.var('n'),n),T.eq(T.var('out'),'done')}},
  authority={inputs={ai},outputs={ao}},values={inputs={'n'},outputs={'out'}}} end
local fan=P.new({items=items,edges={}})
 eq(#fan:family().items,4)
for n=0,3 do local s=C.specialize(fan,{[1]=n})
 eq(#s:family().items,1)
 eq(H.out_value(s,1),'done') end
ok(not fan:bytes():find('fanout',1,true))
 ok(not fan:bytes():find('loop',1,true))
print('PASS td 16: bounded value-dependent shape is finite Development family ('..count()..')')
