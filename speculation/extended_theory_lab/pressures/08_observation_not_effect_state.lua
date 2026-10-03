local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
local function member_for(st,k,slot)
  for _,f in ipairs(st:select('slot')) do if f.args[1]==k and f.args[3]==slot then return
      f.args[4] end end
end
return function()
  local b=W.builder()
  local m=b:membrane(nil,'state')
  local root=b:strand(m,{},'root')
  local visible=b:strand(m,{},'visible')
  local hidden=b:strand(m,{},'hidden0')
  local k=T.evar('extent')
  local before=D.state(b:finish(),{T.fact('slot',k,root,'visible',visible),T.fact('slot',k,root,
      'hidden',hidden)})
  local q=W.builder()
  local qm=q:membrane(nil,'advance-hidden')
  local hi=q:strand(qm,{},'hidden.in')
  local ho=q:strand(qm,{},'hidden.out')
  q:face(qm,{hi},{ho},'advance')
  local K,R=T.var('K'),T.var('R')
  local rule=D.rule(q:finish(),{requires={T.fact('slot',K,R,'hidden',hi)},
      retracts={T.fact('slot',K,R,'hidden',hi)},asserts={T.fact('slot',K,R,'hidden',ho)}})
  local after,detail=D.apply(before,rule,{{from=hidden,to=hi}})
  assert(after,detail)
  assert(member_for(before,k,'visible')==member_for(after,k,'visible'),
      'visible member unexpectedly changed')
  assert(member_for(before,k,'hidden')~=member_for(after,k,'hidden'),'hidden state did not advance')
  local classification=(member_for(before,k,'visible')==member_for(after,k,'visible') and
      member_for(before,k,'hidden')~=member_for(after,k,'hidden')) and 'advancing' or 'other'
  assert(classification=='advancing')
  return 'the effect-like answer is a query over complete before/after ' ..
      'Theory, not retained effect state'
end
