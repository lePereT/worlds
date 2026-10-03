local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local checks=0
  for n=1,16 do
    local b=W.builder()
    local m=b:membrane(nil,'world')
    local a=b:strand(m,{},'a')
    local z=b:strand(m,{},'z')
    local st=D.state(b:finish(),{}, {f={key={1}}})
    local q=W.builder()
    local qm=q:membrane(nil,'consume')
    local ai=q:strand(qm,{},'a')
    local zi=q:strand(qm,{},'z')
    q:face(qm,{ai,zi},{},'consume')
    local K=T.var('K')
    local rule=D.rule(q:finish(),{schemas={f={key={1}}},asserts={T.fact('f',K,ai,'left'..n),
        T.fact('f',K,zi,'right'..n)}})
    local next,why=D.apply(st,rule,{{from=a,to=ai},{from=z,to=zi}})
    checks=checks+1
    assert(not next and why=='functional-conflict:f','hidden conflict escaped validation')
  end
  return tostring(checks)..' independently generated consumed contradictions are rejected ' ..
      'before boundary hiding'
end
