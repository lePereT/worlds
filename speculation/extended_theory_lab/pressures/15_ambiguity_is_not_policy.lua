local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local b=W.builder()
  local m=b:membrane(nil,'ambiguous')
  local root=b:strand(m,{},'root')
  local a=b:strand(m,{},'a')
  local z=b:strand(m,{},'z')
  local st=D.state(b:finish(),{T.fact('candidate',root,a),T.fact('candidate',root,z)})
  local q=W.builder()
  local qm=q:membrane(nil,'op')
  local ri=q:strand(qm,{},'root.in')
  local out=q:strand(qm,{},'out')
  q:face(qm,{ri},{out},'op')
  local X=T.var('X')
  local rule=D.rule(q:finish(),{requires={T.fact('candidate',ri,X)}})
  local next,why=D.apply(st,rule,{{from=root,to=ri}})
  assert(not next and why=='ambiguous-theory-requirement',
      'ambiguous Theory match became implicit enumeration policy')
  return 'multiple relational witnesses remain ambiguous rather than ' ..
      'acquiring policy from search order'
end
