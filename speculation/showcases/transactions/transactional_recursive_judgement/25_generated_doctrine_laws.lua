local H=require('speculation.showcases.transactions.transactional_recursive_judgement.common')
 local K=H.K
local n=0
 local function ok(x,m) n=n+1
 assert(x,m or 'generated law failed') end
local ctx=H.bool_context({'x','y'})
 local valuations={{false,false},{false,true},{true,false},{true,true}}
local rels={}
for mask=0,15 do local rows={} for i,r in ipairs(valuations) do if math.floor(mask/2^(i-1))%2==1 then rows[#rows+1]=r end end
 rels[#rels+1]=K.from_rows(ctx,rows) end
for _,a in ipairs(rels) do
  ok(K.equal(K.meet(a,a),a),'idempotence')
  ok(K.equal(K.meet(a,K.top(ctx)),a),'top identity')
  ok(K.is_bottom(K.meet(a,K.bottom(ctx))),'bottom absorption')
  for _,b in ipairs(rels) do
    ok(K.equal(K.meet(a,b),K.meet(b,a)),'commutativity')
    local both=K.meet(a,b)
 ok(K.leq(both,a) and K.leq(both,b),'meet lower bound')
    for _,c in ipairs(rels) do ok(K.equal(K.meet(K.meet(a,b),c),K.meet(a,K.meet(b,c))),'associativity') end
  end
end
local xctx=H.bool_context({'x'})
 local xrels={K.bottom(xctx),K.point_value(xctx,'x',false),K.point_value(xctx,'x',true),K.top(xctx)}
for _,a in ipairs(rels) do for _,b in ipairs(xrels) do
  local ex=K.exists(a,{'x'})
 local lift=K.rename(b,{x='x'},ctx)
  ok(K.leq(ex,b)==K.leq(a,lift),'existential/reindex adjunction')
  ok(K.equal(K.exists(K.meet(a,lift),{'x'}),K.meet(ex,b)),'Frobenius')
end end
print('PASS rj 25: generated regular-doctrine laws ('..n..' assertions)')
