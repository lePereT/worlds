local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
local function token(n)
  local b=W.builder();local m=b:membrane(nil,'world'..n);local s=b:strand(m,{},'token');return D.state(b:finish(),{}),s
end
return function()
  local b=W.builder();local m=b:membrane(nil,'form');local i=b:strand(m,{},'in');local r=b:strand(m,{},'root');local x=b:strand(m,{},'member');b:face(m,{i},{r,x},'form');local K=T.var('K');local rule=D.rule(b:finish(),{asserts={T.fact('record',K,r,x)}})
  local seen={};for n=1,64 do local st,t=token(n);local next,d=D.apply(st,rule,{{from=t,to=i}});assert(next,d);local k=next:select('record')[1].args[1];assert(T.is_evar(k) and not seen[k],'fresh construction reused Theory-local existential');seen[k]=true end
  local count=0;for _ in pairs(seen) do count=count+1 end;assert(count==64)
  return '64 independent materialisations of one template create 64 fresh Theory-local relational witnesses'
end
