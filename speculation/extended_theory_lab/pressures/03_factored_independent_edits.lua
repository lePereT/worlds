local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
local C=require('speculation.extended_theory_lab.common')

local function edit_rule(slot)
  local b=W.builder()
  local m=b:membrane(nil,'edit-'..slot)
  local i=b:strand(m,{},'in')
  local o=b:strand(m,{},'out')
  b:face(m,{i},{o},'edit')
  local K,R,X=T.var('K'),T.var('R'),T.var('X')
  return D.rule(b:finish(),{
    requires={T.fact('slot',K,R,slot,i)},
    retracts={T.fact('slot',K,R,slot,i)},
    asserts={T.fact('slot',K,R,slot,o)},
  }),i,o
end

return function()
  local b=W.builder()
  local m=b:membrane(nil,'records')
  local root=b:strand(m,{},'shared-root')
  local a0=b:strand(m,{},'a0')
  local b0=b:strand(m,{},'b0')
  local a1=b:strand(m,{},'a1')
  local b1=b:strand(m,{},'b1')
  local g=b:finish()
  local k0,k1=T.evar('record'),T.evar('record')
  local st=D.state(g,{
    T.fact('slot',k0,root,'A',a0),T.fact('slot',k0,root,'B',b0),
    T.fact('slot',k1,root,'A',a1),T.fact('slot',k1,root,'B',b1),
  })
  local ea,ai,ao=edit_rule('A')
  local eb,bi,bo=edit_rule('B')
  local pa=assert(D.prepare(st,ea,{{from=a0,to=ai}}))
  local pb=assert(D.prepare(st,eb,{{from=b0,to=bi}}))
  local s1,da=D.commit(st,pa)
  assert(s1,da)
  local Anew=da.construction:image(ao)
  local s2,db=D.commit(s1,pb)
  assert(s2,db)
  local Bnew=db.construction:image(bo)
  assert(C.fact_exists(s2,'slot',{k0,root,'A',Anew}),'A revision lost record provenance')
  assert(C.fact_exists(s2,'slot',{k0,root,'B',Bnew}),'B revision lost record provenance')
  assert(C.fact_exists(s2,'slot',{k1,root,'A',a1}) and C.fact_exists(s2,'slot',{k1,root,'B',
      b1}),'other same-root record changed')
  assert(not C.fact_exists(s2,'slot',{k0,root,'A',a1}) and not C.fact_exists(s2,'slot',{k1,root,
      'B',Bnew}),'crossed pairing admitted')
  return 'alpha-only Theory existentials preserve same-root record ' ..
      'pairing while independent member authorities revise ' ..
      'independently'
end
