local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
local C=require('speculation.theory.occurrence_relative.common')
local function recur_rule()
  local b=W.builder();local m=b:membrane(nil,'recur');local subject=b:point(m,'subject');local r=b:strand(m,{subject},'root');local c=b:strand(m,{},'capture');local nr=b:strand(m,{subject},'next-root');local nc=b:strand(m,{},'next-capture');local result=b:strand(m,{},'result');b:face(m,{r,c},{result,nr,nc},'invoke')
  local K=T.var('K');return D.rule(b:finish(),{requires={T.fact('capture',K,r,c)},retracts={T.fact('capture',K,r,c)},asserts={T.fact('capture',K,nr,nc)}}),r,c,nr,nc
end
return function()
  local b=W.builder();local m=b:membrane(nil,'two closures');local shared=b:point(m,'same semantic root');local r0=b:strand(m,{shared},'root0');local c0=b:strand(m,{},'cap0');local r1=b:strand(m,{shared},'root1');local c1=b:strand(m,{},'cap1');local k0,k1=T.evar('closure'),T.evar('closure')
  local st=D.state(b:finish(),{T.fact('capture',k0,r0,c0),T.fact('capture',k1,r1,c1)})
  local current=st;local root,cap=r0,c0
  for n=1,8 do local rule,ri,ci,nr,nc=recur_rule();local next,d=D.apply(current,rule,{{from=root,to=ri},{from=cap,to=ci}});assert(next,d);root,cap=d.construction:image(nr),d.construction:image(nc);current=next;assert(C.fact_exists(current,'capture',{k0,root,cap}),'recurrent closure lost its record provenance');assert(C.fact_exists(current,'capture',{k1,r1,c1}),'same-root sibling environment was disturbed') end
  assert(current:count('capture')==2,'recurrent use accumulated capture history')
  return 'eight recurrent uses preserve one environment while a same-semantic-root sibling remains exact and independent'
end
