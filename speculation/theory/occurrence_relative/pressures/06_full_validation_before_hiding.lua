local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'world');local a=b:strand(m,{},'a');local z=b:strand(m,{},'z');local st=D.state(b:finish(),{}, {denotes={key={1}}})
  local q=W.builder();local qm=q:membrane(nil,'consume');local ai=q:strand(qm,{},'a.in');local zi=q:strand(qm,{},'z.in');q:face(qm,{ai,zi},{},'consume');local g=q:finish()
  local K=T.var('fresh-key')
  local rule=D.rule(g,{schemas={denotes={key={1}}},asserts={T.fact('denotes',K,ai),T.fact('denotes',K,zi)}})
  local next,why=D.apply(st,rule,{{from=a,to=ai},{from=z,to=zi}})
  assert(not next and why=='functional-conflict:denotes','conflict must be rejected before consumed assertions disappear at boundary')
  return 'Theory validates the complete construction before hiding; consumed incoherence cannot vanish into an empty boundary'
end
