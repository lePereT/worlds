local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local b=W.builder()
  local m=b:membrane(nil,'world')
  local r=b:strand(m,{},'root')
  local s=b:strand(m,{},'member')
  local st=D.state(b:finish(),{})
  local q=W.builder()
  local qm=q:membrane(nil,'op')
  local ri=q:strand(qm,{},'ri')
  local si=q:strand(qm,{},'si')
  local ro=q:strand(qm,{},'ro')
  local so=q:strand(qm,{},'so')
  q:face(qm,{ri,si},{ro,so},'pretend')
  local rule=D.rule(q:finish(),{requires={T.fact('governs',ri,si)},asserts={T.fact('governs',ro,
      so)}})
  local next,why=D.apply(st,rule,{{from=r,to=ri},{from=s,to=si}})
  assert(not next and why=='unsatisfied-theory-requirement',
      'operation must not use its own assertion to justify its premise')
  return 'requirements are checked only against prior current Theory; ' ..
      'consequences cannot self-justify their operation'
end
