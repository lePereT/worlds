local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'start');local r=b:strand(m,{},'r');local s=b:strand(m,{},'s');local k=T.evar('record');local st=D.state(b:finish(),{T.fact('slot',k,r,'member',s)})
  for n=1,1024 do
    local q=W.builder();local qm=q:membrane(nil,'renew');local ri=q:strand(qm,{},'ri');local si=q:strand(qm,{},'si');local ro=q:strand(qm,{},'ro');local so=q:strand(qm,{},'so');q:face(qm,{ri,si},{ro,so},'renew');local K=T.var('K')
    local rule=D.rule(q:finish(),{requires={T.fact('slot',K,ri,'member',si)},retracts={T.fact('slot',K,ri,'member',si)},asserts={T.fact('slot',K,ro,'member',so)}})
    local f=st:select('slot')[1];local next,detail=D.apply(st,rule,{{from=f.args[2],to=ri},{from=f.args[4],to=si}});assert(next,detail);st=next
    assert(st:count('slot')==1 and #st.geometry:egress()==2,'history growth at renewal '..n)
  end
  assert(st:select('slot')[1].args[1]==k,'stable relational provenance changed across renewal')
  return '1024 renewals retain fixed-size current Geometry and one Theory record with stable logical provenance'
end
