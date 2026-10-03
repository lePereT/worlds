local H=require('speculation.showcases.transactions.transactional_recursive_judgement.common')
 local K=H.K
 local ok,eq,count=H.counter()
local productive=H.rec_package('f',{H.base_bool_context(nil),H.unary_bool_context({definition='f'})},{})
local r=productive:root('f')
 local a=H.Analysis.compute(productive)
 eq(H.row_count(a.behaviour[r]),2,'productive bool relation should realise every input/output pair allowed by identity chain')
ok(a.rounds>=2,'recursive viability did not require fixed-point closure')
-- A pure self cycle has no finite descendant, hence empty viability.
local dead=H.rec_package('g',{H.unary_bool_context({definition='g'})},{})
 local gr=dead:root('g')
 local da=H.Analysis.compute(dead)
ok(K.is_bottom(da.behaviour[gr]),'nonproductive recursive cycle acquired finite viability')
print('PASS rj 10: finite viability is the least fixed point, not bounded search frontier ('..count()..')')
