local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'same-root records')
  local root=b:strand(m,{},'root');local a0=b:strand(m,{},'a0');local b0=b:strand(m,{},'b0');local a1=b:strand(m,{},'a1');local b1=b:strand(m,{},'b1')
  local k0,k1=T.evar('record'),T.evar('record')
  local facts={
    T.fact('slot',k0,root,1,a0),T.fact('slot',k0,root,2,b0),
    T.fact('slot',k1,root,1,a1),T.fact('slot',k1,root,2,b1),
  }
  local function op()
    local q=W.builder();local qm=q:membrane(nil,'use pair');local ai=q:strand(qm,{},'a');local bi=q:strand(qm,{},'b');local out=q:strand(qm,{},'out');q:face(qm,{ai,bi},{out},'use')
    local K,R=T.var('K'),T.var('R')
    return D.rule(q:finish(),{requires={T.fact('slot',K,R,1,ai),T.fact('slot',K,R,2,bi)}}),ai,bi
  end
  local rule,ai,bi=op()
  local g=b:finish()
  local okstate=D.state(g,facts)
  local good,why=D.apply(okstate,rule,{{from=a0,to=ai},{from=b0,to=bi}});assert(good,why)
  local badstate=D.state(g,facts)
  local bad,reason=D.apply(badstate,rule,{{from=a0,to=ai},{from=b1,to=bi}})
  assert(not bad and reason=='unsatisfied-theory-requirement','cross-record capture pairing was admitted: '..tostring(reason))
  return 'shared exact root does not permit ordered capture slots from different existential records to cross-pair'
end
