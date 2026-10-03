local W=require('worlds')
local D=require('speculation.theory.occurrence_relative.development')
local T=require('speculation.theory.occurrence_relative.theory')
local function consume_rule(label)
  local b=W.builder();local m=b:membrane(nil,label);local i=b:strand(m,{},'in');local o=b:strand(m,{},'out');b:face(m,{i},{o},'advance')
  local K=T.var('K');return D.rule(b:finish(),{requires={T.fact('tag',K,i)},retracts={T.fact('tag',K,i)},asserts={T.fact('tag',K,o)}}),i
end
return function()
  local b=W.builder();local m=b:membrane(nil,'world');local s=b:strand(m,{},'s');local k=T.evar('k');local st=D.state(b:finish(),{T.fact('tag',k,s)})
  local a,ai=consume_rule('a');local z,zi=consume_rule('z')
  local pa=assert(D.prepare(st,a,{{from=s,to=ai}}));local pz=assert(D.prepare(st,z,{{from=s,to=zi}}))
  local s1=assert(D.commit(st,pa))
  local stale,why=D.commit(s1,pz)
  assert(not stale and why=='stale-exact-authority','second prepared use of consumed exact Strand should Retry')
  return 'Theory description never substitutes equal-looking authority: exact Worlds staleness remains authoritative'
end
