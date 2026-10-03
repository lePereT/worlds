local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local b=W.builder()
  local m=b:membrane(nil,'state')
  local r=b:strand(m,{},'root')
  local s=b:strand(m,{},'support')
  local st=D.state(b:finish(),{T.fact('governs',r,s)})
  local q=W.builder()
  local qm=q:membrane(nil,'root-only split')
  local ri=q:strand(qm,{},'root.in')
  local a=q:strand(qm,{},'a')
  local z=q:strand(qm,{},'z')
  q:face(qm,{ri},{a,z},'split')
  local rule=D.rule(q:finish(),{})
  local next,detail=D.apply(st,rule,{{from=r,to=ri}})
  assert(next,detail)
  assert(next:count('governs')==0,
      'root-only split silently guessed how unchanged hidden support should pair with successors')
  assert(next.geometry:owns_strand(s),'unrelated hidden support should remain exact open authority')
  return 'when a template does not state successor correlation, Theory ' ..
      'drops the dead relation and invents no grouping oracle'
end
