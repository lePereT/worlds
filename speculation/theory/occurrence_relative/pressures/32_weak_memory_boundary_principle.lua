local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'retained writes');local w1=b:strand(m,{},'write1');local w2=b:strand(m,{},'write2');local st=D.state(b:finish(),{T.fact('value',w1,1),T.fact('value',w2,2)})
  assert(#st.geometry:egress()==2 and st:count('value')==2,'future-observable suffix not retained')
  local q=W.builder();local qm=q:membrane(nil,'retire old write');local old=q:strand(qm,{},'old');q:face(qm,{old},{},'retire');local rule=D.rule(q:finish(),{retracts={T.fact('value',old,1)}})
  local next,detail=D.apply(st,rule,{{from=w1,to=old}});assert(next,detail)
  assert(#next.geometry:egress()==1 and next.geometry:owns_strand(w2),'retirement removed current write')
  assert(next:count('value')==1 and next:select('value')[1].args[1]==w2,'closed write history remained in Theory')
  return 'a future-observable write suffix stays exact Geometry+Theory until explicit retirement; closed history then disappears'
end
