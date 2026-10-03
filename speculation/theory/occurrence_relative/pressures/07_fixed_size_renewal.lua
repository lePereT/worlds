local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'start');local r=b:strand(m,{},'root0');local s=b:strand(m,{},'member0');local st=D.state(b:finish(),{T.fact('governs',r,s)})
  for n=1,128 do
    local q=W.builder();local qm=q:membrane(nil,'renew');local ri=q:strand(qm,{},'ri');local si=q:strand(qm,{},'si');local ro=q:strand(qm,{},'ro');local so=q:strand(qm,{},'so');q:face(qm,{ri,si},{ro,so},'renew')
    local rule=D.rule(q:finish(),{requires={T.fact('governs',ri,si)},retracts={T.fact('governs',ri,si)},asserts={T.fact('governs',ro,so)}})
    local f=st:select('governs')[1];local next,detail=D.apply(st,rule,{{from=f.args[1],to=ri},{from=f.args[2],to=si}});assert(next,detail);st=next
    assert(st:count('governs')==1,'renewal retained relational history at step '..n)
    assert(#st.geometry:egress()==2,'renewal retained causal history at step '..n)
  end
  return '128 renewals leave one current relation and two live authorities: no hidden history chain'
end
