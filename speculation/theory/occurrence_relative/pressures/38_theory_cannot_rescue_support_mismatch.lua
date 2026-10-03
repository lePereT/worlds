local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local root=b:membrane(nil,'root');local s=b:strand(root,{},'actual');local st=D.state(b:finish(),{T.fact('ok',s,true)})
  local q=W.builder();local qr=q:membrane(nil,'root');local child=q:membrane(qr,'required child');local i=q:strand(child,{},'in');local o=q:strand(child,{},'out');q:face(child,{i},{o},'op');local X=T.var('X');local rule=D.rule(q:finish(),{requires={T.fact('ok',i,X)}})
  local p,why=D.prepare(st,rule,{{from=s,to=i}});assert(not p and why=='no-worlds-match','Theory should never make a geometrically impossible support placement admissible')
  return 'true Theory premises cannot rescue an unlawful Worlds support match'
end
