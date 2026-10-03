local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
local C=require('speculation.extended_theory_lab.common')
local perms={{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}}
local function edit()
  local b=W.builder()
  local m=b:membrane(nil,'edit A')
  local i=b:strand(m,{},'a.in')
  local o=b:strand(m,{},'a.out')
  b:face(m,{i},{o},'edit')
  local K,R=T.var('K'),T.var('R')
  return D.rule(b:finish(),{requires={T.fact('slot',K,R,'A',i)},retracts={T.fact('slot',K,R,'A',
      i)},asserts={T.fact('slot',K,R,'A',o)}}),i,o
end
return function()
  for _,order in ipairs(perms) do
    local b=W.builder()
    local m=b:membrane(nil,'records')
    local root=b:strand(m,{},'shared root')
    local as,bs,ks={},{},{}
    local facts={}
    for i=1,3 do as[i]=b:strand(m,{},'a'..i)
    bs[i]=b:strand(m,{},'b'..i)
    ks[i]=T.evar('record')
    facts[#facts+1]=T.fact('slot',ks[i],root,'A',as[i])
    facts[#facts+1]=T.fact('slot',ks[i],root,'B',bs[i]) end
    local st=D.state(b:finish(),facts)
    local ps,outs={},{},{}
    for i=1,3 do local r,ri,ro=edit()
    ps[i]=assert(D.prepare(st,r,{{from=as[i],to=ri}}))
    outs[i]=ro end
    local cur=st
    local anew={}
    for _,i in ipairs(order) do local n,d=D.commit(cur,ps[i])
    assert(n,d)
    cur=n
    anew[i]=d.construction:image(outs[i]) end
    for i=1,3 do assert(C.fact_exists(cur,'slot',{ks[i],root,'A',anew[i]}))
    assert(C.fact_exists(cur,'slot',{ks[i],root,'B',bs[i]})) end
    assert(cur:count('slot')==6,'same-root multi-record schedule changed record cardinality')
  end
  return 'all six schedules of three independently prepared same-root ' ..
      'record edits preserve each record provenance and untouched ' ..
      'sibling slot'
end
