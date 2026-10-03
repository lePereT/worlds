local W=require('worlds')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local b=W.builder()
  local m=b:membrane(nil,'alpha')
  local r=b:strand(m,{},'root')
  local a=b:strand(m,{},'a')
  local z=b:strand(m,{},'z')
  local g=b:finish()
  local k1,k2=T.evar('record'),T.evar('renamed')
  local s1=T.state(g,{T.fact('slot',k1,r,'A',a),T.fact('slot',k1,r,'B',z)})
  local s2=T.state(g,{T.fact('slot',k2,r,'A',a),T.fact('slot',k2,r,'B',z)})
  local K=T.var('K')
  local q={T.fact('slot',K,r,'A',a),T.fact('slot',K,r,'B',z)}
  assert(#T.query(s1,q)==1 and #T.query(s2,q)==1,
      'alpha-renamed existential changed relational query meaning')
  return 'Theory-local existential identity is alpha-only for ' ..
      'observation; only its sharing pattern matters'
end
