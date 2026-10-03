local W=require('worlds')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local root=b:membrane(nil,'root');local left=b:membrane(root,'left');local right=b:membrane(root,'right');local s=b:strand(root,{},'one exact denotation');local k1,k2=T.evar('view'),T.evar('view')
  local st=T.state(b:finish(),{T.fact('view',k1,s,left),T.fact('view',k2,s,right)})
  assert(st:count('view')==2,'same denotation collapsed independent relational locality')
  assert(W.parent(left)==root and W.parent(right)==root and left~=right,'Theory relation changed Geometry locality')
  return 'one exact occurrence may participate in distinct non-scarce relational views without identifying their Membrane terms'
end
