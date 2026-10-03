local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'state');local r=b:strand(m,{},'root');local s=b:strand(m,{},'child');local st=D.state(b:finish(),{T.fact('governs',r,s)})
  local q=W.builder();local qm=q:membrane(nil,'drop root');local ri=q:strand(qm,{},'root.in');q:face(qm,{ri},{},'drop');local next,detail=D.apply(st,D.rule(q:finish(),{}),{{from=r,to=ri}});assert(next,detail)
  assert(next.geometry:owns_strand(s),'surviving child authority disappeared')
  assert(next:count('governs')==0,'child was promoted or stale governance survived after root disappeared')
  return 'consuming a governed root does not promote a surviving child into a new root'
end
