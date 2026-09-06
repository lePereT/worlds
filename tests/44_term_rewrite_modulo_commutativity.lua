local S=require('tests.support')
local T=require('tests.process_theory_support')
local G,A=S.G,S.A

local function source(term)
  local b=G.builder(); local K=b:membrane(nil,'rewrite'); local p=b:point(K,'Expr'); b:strand(K,'Term',{p});
  return b:finish(),K,{[p]=term}
end
local p=G.builder(); local D=p:membrane(nil,'rewrite'); local x=p:point(D,'Expr'); local i=p:strand(D,'Term',{x}); local o=p:strand(D,'Reduced',{x}); p:face(D,'rewrite',{i},{o}); local pat=p:finish()
local target={op='add',a={atom='x'},b={atom='y'}}
for _,term in ipairs({target,{op='add',a={atom='y'},b={atom='x'}},{op='add',a={atom='x'},b={atom='z'}}}) do
  local g,K,val=source(term); local att=A.one(g,{K},pat); S.ok(att)
  local accepted=T.term_normal(val[att:point(x)])==T.term_normal(target)
  if term.b.atom=='z' then S.no(accepted) else S.ok(accepted) end
end
print('ok 44_term_rewrite_modulo_commutativity')
