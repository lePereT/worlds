local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'choice');local token=b:strand(m,{},'token');local st=D.state(b:finish(),{T.fact('kind',token,'specific'),T.fact('kind',token,'generic')})
  local function alt(label,required)
    local q=W.builder();local qm=q:membrane(nil,label);local i=q:strand(qm,{},'in');local o=q:strand(qm,{},'out');q:face(qm,{i},{o},label);local rule=D.rule(q:finish(),{requires={T.fact('kind',i,required)}});return rule,i
  end
  local generic,gi=alt('generic','generic');local specific,si=alt('specific','specific')
  assert(D.prepare(st,generic,{{from=token,to=gi}}),'generic alternative should remain viable')
  assert(D.prepare(st,specific,{{from=token,to=si}}),'specific alternative should remain viable')
  return 'overlapping alternatives remain two external candidates; extended Theory does not collapse or rank them'
end
