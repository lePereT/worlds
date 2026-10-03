local W=require('worlds')
local D=require('speculation.extended_theory_lab.development')
local T=require('speculation.extended_theory_lab.theory')
return function()
  local b=W.builder()
  local m=b:membrane(nil,'overlap')
  local r1=b:strand(m,{},'r1')
  local r2=b:strand(m,{},'r2')
  local x=b:strand(m,{},'shared')
  local st=D.state(b:finish(),{T.fact('governs',r1,x),T.fact('governs',r2,x)})
  local gs=st:select('governs')
  local conflict=false
  for i=1,#gs do for j=i+1,#gs do if gs[i].args[2]==gs[j].args[2] and
      gs[i].args[1]~=gs[j].args[1] then conflict=true end end end
  assert(conflict,'shared exact authority should be visible as overlap')
  return 'overlap/conflict is derived from occurrence-relative facts; ' ..
      'no effect/conflict carrier is stored'
end
