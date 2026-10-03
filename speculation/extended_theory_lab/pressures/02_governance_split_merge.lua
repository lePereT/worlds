local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
local C=require('speculation.extended_theory_lab.common')
return function()
  local wb=W.builder()
  local m=wb:membrane(nil,'world')
  local root=wb:strand(m,{},'root')
  local member=wb:strand(m,{},'member')
  local st=D.state(wb:finish(),{T.fact('governs',root,member)})

  local b=W.builder()
  local x=b:membrane(nil,'split')
  local ri=b:strand(x,{},'root.in')
  local mi=b:strand(x,{},'member.in')
  local ra=b:strand(x,{},'root.a')
  local ma=b:strand(x,{},'member.a')
  local rb=b:strand(x,{},'root.b')
  local mb=b:strand(x,{},'member.b')
  b:face(x,{ri,mi},{ra,ma,rb,mb},'split')
  local g=b:finish()
  local split=D.rule(g,{requires={T.fact('governs',ri,mi)},retracts={T.fact('governs',ri,mi)},
      asserts={T.fact('governs',ra,ma),T.fact('governs',rb,mb)}})
  local after,detail=D.apply(st,split,{{from=root,to=ri},{from=member,to=mi}})
  assert(after,detail)
  local im=detail.construction
  local RA,MA,RB,MB=im:image(ra),im:image(ma),im:image(rb),im:image(mb)
  assert(C.fact_exists(after,'governs',{RA,MA}) and C.fact_exists(after,'governs',{RB,MB}),
      'split pairing lost')
  assert(not C.fact_exists(after,'governs',{RA,MB}) and not C.fact_exists(after,'governs',{RB,
      MA}),'cross pairing invented')

  local q=W.builder()
  local qm=q:membrane(nil,'merge')
  local rai=q:strand(qm,{},'ra.in')
  local mai=q:strand(qm,{},'ma.in')
  local rbi=q:strand(qm,{},'rb.in')
  local mbi=q:strand(qm,{},'mb.in')
  local ro=q:strand(qm,{},'root.out')
  local mo=q:strand(qm,{},'member.out')
  q:face(qm,{rai,mai,rbi,mbi},{ro,mo},'merge')
  local mg=q:finish()
  local merge=D.rule(mg,{requires={T.fact('governs',rai,mai),T.fact('governs',rbi,mbi)},
      retracts={T.fact('governs',rai,mai),T.fact('governs',rbi,mbi)},asserts={T.fact('governs',
          ro,mo)}})
  local final,d2=D.apply(after,merge,{{from=RA,to=rai},{from=MA,to=mai},{from=RB,to=rbi},
      {from=MB,to=mbi}})
  assert(final,d2)
  assert(final:count('governs')==1,'merge should leave one current relation')
  return 'split/merge pairing is template Theory, not post-result grouping bookkeeping'
end
