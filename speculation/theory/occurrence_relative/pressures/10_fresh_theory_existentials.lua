local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
local function token(name)
  local b=W.builder();local m=b:membrane(nil,name);local s=b:strand(m,{},'token');return D.state(b:finish(),{}),s
end
return function()
  local b=W.builder();local m=b:membrane(nil,'form');local i=b:strand(m,{},'in');local r=b:strand(m,{},'root');local x=b:strand(m,{},'member');b:face(m,{i},{r,x},'form')
  local K=T.var('record');local rule=D.rule(b:finish(),{asserts={T.fact('record',K,r,x)}})
  local s1,t1=token('w1');local a,d1=D.apply(s1,rule,{{from=t1,to=i}});assert(a,d1)
  local s2,t2=token('w2');local c,d2=D.apply(s2,rule,{{from=t2,to=i}});assert(c,d2)
  local k1=a:select('record')[1].args[1];local k2=c:select('record')[1].args[1]
  assert(T.is_evar(k1) and T.is_evar(k2) and k1~=k2,'consequence-only Theory variables must freshen per exact occurrence')
  return 'Theory-local existentials freshen per construction without becoming Worlds authority or global identity'
end
