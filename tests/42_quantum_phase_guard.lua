local S=require('tests.support')
local T=require('tests.process_theory_support')
local G,A=S.G,S.A

local function system(vec)
  local b=G.builder(); local K=b:membrane(nil,'lab'); local q=b:point(K,'QSystem'); b:strand(K,'Q',{q});
  return b:finish(),K,{[q]=vec}
end
local p=G.builder(); local D=p:membrane(nil,'lab'); local q=p:point(D,'QSystem'); local i=p:strand(D,'Q',{q}); local o=p:strand(D,'Accepted',{q}); p:face(D,'projective-guard',{i},{o}); local pat=p:finish()

for _,case in ipairs({{{1,0},true},{{-2,0},true},{{0,1},false}}) do
  local g,K,state=system(case[1]); local att=A.one(g,{K},pat); S.ok(att)
  local ok=T.projective_eq(state[att:point(q)],{1,0})
  S.eq(ok,case[2])
end
print('ok 42_quantum_phase_guard')
