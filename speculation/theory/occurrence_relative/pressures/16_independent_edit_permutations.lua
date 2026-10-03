local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
local C=require('speculation.theory.occurrence_relative.common')
local perms={{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}}
local slots={'A','B','C'}
local function edit(slot)
  local b=W.builder();local m=b:membrane(nil,'edit '..slot);local i=b:strand(m,{},'in');local o=b:strand(m,{},'out');b:face(m,{i},{o},'edit')
  local K,R=T.var('K'),T.var('R')
  return D.rule(b:finish(),{requires={T.fact('slot',K,R,slot,i)},retracts={T.fact('slot',K,R,slot,i)},asserts={T.fact('slot',K,R,slot,o)}}),i,o
end
return function()
  for _,order in ipairs(perms) do
    local b=W.builder();local m=b:membrane(nil,'record');local root=b:strand(m,{},'root');local members={}
    for i=1,3 do members[i]=b:strand(m,{},slots[i]..'0') end
    local k=T.evar('record');local facts={};for i=1,3 do facts[#facts+1]=T.fact('slot',k,root,slots[i],members[i]) end
    local st=D.state(b:finish(),facts);local prepared={};local outs={}
    for i=1,3 do local r,ri,ro=edit(slots[i]);prepared[i]=assert(D.prepare(st,r,{{from=members[i],to=ri}}));outs[i]=ro end
    local current=st;local actual={}
    for _,i in ipairs(order) do local next,detail=D.commit(current,prepared[i]);assert(next,detail);current=next;actual[i]=detail.construction:image(outs[i]) end
    for i=1,3 do assert(C.fact_exists(current,'slot',{k,root,slots[i],actual[i]}),'edit order lost slot '..slots[i]) end
    assert(current:count('slot')==3,'independent edits accumulated or lost facts')
  end
  return 'all six commit orders of three independently prepared members preserve one correlated record'
end
