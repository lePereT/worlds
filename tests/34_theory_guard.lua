local S=require('tests.support')
local G,A=S.G,S.A

local function source(n)
  local b=G.builder(); local K=b:membrane(nil,'eval'); local p=b:point(K,'Int'); b:strand(K,'Value',{p});
  return b:finish(),K,p,{[p]=n}
end

-- Structural geometry for a guard candidate. It says only "consume an Int value".
local p=G.builder(); local D=p:membrane(nil,'eval'); local x=p:point(D,'Int'); local s=p:strand(D,'Value',{x});
local out=p:strand(D,'Passed',{x}); p:face(D,'guard42',{s},{out}); local guard=p:finish()

local g41,K41,p41,t41=source(41); local g42,K42,p42,t42=source(42)
local e41=A.one(g41,{K41},guard); local e42=A.one(g42,{K42},guard)
S.ok(e41 and e42,'exact geometry alone admits both structurally compatible candidates')
local function integer_guard(attachment,table_)
  return table_[attachment:point(x)]==42
end
S.no(integer_guard(e41,t41)); S.ok(integer_guard(e42,t42))

-- Therefore extensional admissibility is a Theory judgement over an exact
-- geometric candidate; canonical Point identity is one possible quotient that
-- can compile this judgement away, not a law of Worlds.
print('ok 34_theory_guard')
