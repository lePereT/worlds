local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
local C=require('speculation.theory.occurrence_relative.common')
local function state(label)
  local b=W.builder();local m=b:membrane(nil,label);local root=b:strand(m,{},'routine');local cap=b:strand(m,{},'capture');local input=b:strand(m,{},'input');local ready=b:strand(m,{},'ready');local k=T.evar('routine')
  return D.state(b:finish(),{T.fact('slot',k,root,'capture',cap)}),k,root,cap,input,ready
end
local function continue_rule()
  local b=W.builder();local m=b:membrane(nil,'continue');local r=b:strand(m,{},'r');local c=b:strand(m,{},'c');local i=b:strand(m,{},'i');local rd=b:strand(m,{},'ready');local result=b:strand(m,{},'result');local nr=b:strand(m,{},'next-r');local nc=b:strand(m,{},'next-c');b:face(m,{r,c,i,rd},{result,nr,nc},'resume')
  local K=T.var('K');return D.rule(b:finish(),{requires={T.fact('slot',K,r,'capture',c)},retracts={T.fact('slot',K,r,'capture',c)},asserts={T.fact('slot',K,nr,'capture',nc)}}),r,c,i,rd,nr,nc
end
local function complete_rule()
  local b=W.builder();local m=b:membrane(nil,'complete');local r=b:strand(m,{},'r');local c=b:strand(m,{},'c');local i=b:strand(m,{},'i');local rd=b:strand(m,{},'ready');local result=b:strand(m,{},'result');b:face(m,{r,c,i,rd},{result},'complete')
  local K=T.var('K');return D.rule(b:finish(),{requires={T.fact('slot',K,r,'capture',c)},retracts={T.fact('slot',K,r,'capture',c)}}),r,c,i,rd
end
return function()
  do
    local st,k,r,c,i,rd=state('continue state');local rule,ri,ci,ii,rdi,nr,nc=continue_rule();local next,d=D.apply(st,rule,{{from=r,to=ri},{from=c,to=ci},{from=i,to=ii},{from=rd,to=rdi}});assert(next,d)
    assert(C.fact_exists(next,'slot',{k,d.construction:image(nr),'capture',d.construction:image(nc)}),'continuing routine lost retained responsibility')
    assert(next:count('slot')==1,'continuation retained historical routine relation')
  end
  do
    local st,_,r,c,i,rd=state('complete state');local rule,ri,ci,ii,rdi=complete_rule();local next,d=D.apply(st,rule,{{from=r,to=ri},{from=c,to=ci},{from=i,to=ii},{from=rd,to=rdi}});assert(next,d);assert(next:count('slot')==0,'completed routine retained spent responsibility')
  end
  return 'yield/resume and completion are ordinary occurrence-relative transitions with no Routine/stack state machine'
end
