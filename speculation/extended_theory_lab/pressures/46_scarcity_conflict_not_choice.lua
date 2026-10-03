local W=require('worlds')
local Q=require('worlds.query')
local C=require('speculation.extended_theory_lab.common')
local R=C.roles({'TOKEN','A','B'},'scarcity-choice')
local function op(done)
  local b=W.builder()
  local m=b:membrane(nil,'op')
  local i=b:strand(m,{R.TOKEN},'token')
  local o=b:strand(m,{done},'done')
  b:face(m,{i},{o},'use')
  return b:finish()
end
return function()
  local a,z=op(R.A),op(R.B)
  local b=W.builder()
  local m=b:membrane(nil,'world')
  b:strand(m,{R.TOKEN},'token')
  local world=b:finish()
  assert(C.decide(Q.match(world,a))=='yes' and C.decide(Q.match(world,z))=='yes',
      'individual alternatives should each be prospectively admissible')
  local tensor=W.join({a,z},{})
  assert(C.decide(Q.match(world,tensor))=='no',
      'positive union illegally duplicated one exact token')
  return 'two prospectively viable alternatives sharing one exact ' ..
      'authority remain choice outside positive Geometry; their ' ..
      'tensor is scarcity-conflicting'
end
