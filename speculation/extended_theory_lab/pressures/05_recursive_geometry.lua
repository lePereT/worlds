local W=require('worlds')
local function component(chain)
  local b=W.builder()
  local r=b:membrane(nil,'root')
  local c=b:membrane(r,'work')
  local i=b:strand(c,{},'in')
  local prev=i
  for n=1,chain do local o=b:strand(c,{},n==chain and 'out' or ('mid'..n))
  b:face(c,{prev},{o},'f'..n)
  prev=o end
  return b:finish(),i,prev,c
end
return function()
  for _,n in ipairs{1,3} do
    local g,i,o,c=component(n)
    local closed=W.join({g},{{from=o,to=i}})
    assert(#closed:faces()==1,'feedback SCC should contract private segmentation')
    assert(W.membrane(closed:faces()[1])==c,'joint Face should remain at actual causal support')
  end
  return 'recursive feedback stays exact open Geometry; no ' ..
      'reachability/LCA Theory summary is needed'
end
