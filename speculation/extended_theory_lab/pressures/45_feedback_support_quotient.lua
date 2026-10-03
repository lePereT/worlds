local W=require('worlds')
local Construction=require('worlds.construction')
local T=require('speculation.extended_theory_lab.theory')
local C=require('speculation.extended_theory_lab.common')
return function()
  local b=W.builder()
  local root=b:membrane(nil,'root')
  local a=b:membrane(root,'a')
  local z=b:membrane(root,'z')
  local sin=b:strand(a,{},'in')
  local mid=b:strand(z,{},'mid')
  local sout=b:strand(z,{},'out')
  local f1=b:face(a,{sin},{mid},'f1')
  local f2=b:face(z,{mid},{sout},'f2')
  local g=b:finish()
  local th=T.state(g,{T.fact('event',f1,'work'),T.fact('event',f2,'work')})
  local c=Construction.join({g},{{from=sout,to=sin}})
  local final=c:result()
  assert(#final:faces()==1 and W.name(final:faces()[1])=='joint','feedback did not form one SCC')
  assert(C.depth(W.membrane(final:faces()[1]))==2,
      'feedback quotient should merge sibling supports before SCC locality is chosen')
  local rebased=T.rebase(th,c)
  assert(rebased:count('event')==1,'Theory did not follow post-quotient joint Face')
  return 'feedback may quotient support before SCC placement; retaining ' ..
      'exact Geometry handles this without a precomputed locality ' ..
      'Theory summary'
end
