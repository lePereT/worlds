local W=require('worlds')
local Construction=require('worlds.construction')
local T=require('speculation.theory.occurrence_relative.theory')
return function()
  local b=W.builder();local m=b:membrane(nil,'loop');local i=b:strand(m,{},'in');local mid=b:strand(m,{},'mid');local o=b:strand(m,{},'out')
  local f1=b:face(m,{i},{mid},'f1');local f2=b:face(m,{mid},{o},'f2');local g=b:finish()
  local th=T.state(g,{T.fact('event',f1,'work'),T.fact('event',f2,'work')})
  local c=Construction.join({g},{{from=o,to=i}});local joint=c:result():faces()[1]
  assert(#c:result():faces()==1,'feedback should form one joint Face')
  assert(c:image(f1)==joint and c:image(f2)==joint,'Construction image should quotient both Faces to the joint Face')
  local rebased=T.rebase(th,c)
  assert(rebased:count('event')==1,'equal rebased facts should deduplicate after SCC quotient')
  assert(rebased:select('event')[1].args[1]==joint,'Theory did not follow exact Face quotient')
  return 'arbitrary carrier references rebase through the actual Worlds quotient, including SCC Face contraction'
end
