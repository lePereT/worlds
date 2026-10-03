local W=require('worlds')
local Construction=require('worlds.construction')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local b=W.builder()
  local m=b:membrane(nil,'quotient')
  local a=b:strand(m,{},'a')
  local z=b:strand(m,{},'z')
  local g=b:finish()
  local th=T.state(g,{T.fact('name',a,'A'),T.fact('name',z,'Z')},{name={key={1}}})
  local c=Construction.join({g},{{from=a,to=z}})
  local ok,err=pcall(T.rebase,th,c)
  assert(not ok and tostring(err):match('functional%-conflict:name'),
      'carrier quotient failed to expose newly contradictory Theory')
  return 'exact quotienting can create a Theory contradiction, and ' ..
      'rebasing validates rather than silently retaining ' ..
      'inconsistent facts'
end
