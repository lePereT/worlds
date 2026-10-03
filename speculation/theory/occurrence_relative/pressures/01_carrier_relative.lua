local W=require('worlds')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local r=b:membrane(nil,'root');local c=b:membrane(r,'child')
  local p=b:point(c,'value');local i=b:strand(c,{p},'in');local o=b:strand(c,{p},'out');local f=b:face(c,{i},{o},'step')
  local g=b:finish()
  local st=T.state(g,{
    T.fact('point_fact',p,'v'),T.fact('strand_fact',i,'authority'),
    T.fact('membrane_fact',c,'scope'),T.fact('face_fact',f,'event'),
  })
  assert(st:count()==4,'Theory should admit every exact Worlds carrier sort')
  return 'carrier-relative Theory refers to Point/Strand/Membrane/Face without granting authority'
end
