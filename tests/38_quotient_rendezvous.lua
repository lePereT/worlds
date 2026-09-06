local S=require('tests.support')
local T=require('tests.process_theory_support')
local G,A=S.G,S.A

local function source(a,b)
  local x=G.builder(); local K=x:membrane(nil,'proc')
  local p=x:point(K,'Label'); local q=x:point(K,'Label')
  x:strand(K,'Send',{p}); x:strand(K,'Recv',{q})
  return x:finish(),K,{[p]=a,[q]=b}
end

-- Extensional rendezvous modulo 3: two independent Point variables plus a
-- Theory equality predicate. Exact Point identity is deliberately irrelevant.
local p=G.builder(); local D=p:membrane(nil,'proc')
local a=p:point(D,'Label'); local b=p:point(D,'Label')
local s=p:strand(D,'Send',{a}); local r=p:strand(D,'Recv',{b}); local o=p:strand(D,'Done',{a})
p:face(D,'rendezvous.mod3',{s,r},{o}); local pat=p:finish()

local g1,K1,v1=source(1,4); local xs1=A.all(g1,{K1},pat); S.eq(#xs1,1)
local c1=T.classify(xs1,function(att) return T.mod_eq(v1[att:point(a)],v1[att:point(b)],3) end)
S.eq(#c1.accepted,1); S.eq(#c1.rejected,0)

local g2,K2,v2=source(1,2); local xs2=A.all(g2,{K2},pat); S.eq(#xs2,1)
local c2=T.classify(xs2,function(att) return T.mod_eq(v2[att:point(a)],v2[att:point(b)],3) end)
S.eq(#c2.accepted,0); S.eq(#c2.rejected,1)
print('ok 38_quotient_rendezvous')
