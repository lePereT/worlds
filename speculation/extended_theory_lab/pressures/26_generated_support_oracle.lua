local W=require('worlds')
local C=require('speculation.extended_theory_lab.common')
local function parent_arrays(n)
  local out,row={},{}
  local function go(i) if i>n then local x={}
  for k=1,n do x[k]=row[k] end
  out[#out+1]=x
  return end
  for p=0,i-1 do row[i]=p
  go(i+1) end end
  go(1)
  return out
end
local R=C.roles({'A','B'},'support-census')
local function make(parents,pa,pb)
  local b=W.builder()
  local ms={}
  for i=1,#parents do ms[i]=b:membrane(parents[i]==0 and nil or ms[parents[i]],nil) end
  local a=b:strand(ms[pa],{R.A})
  local z=b:strand(ms[pb],{R.B})
  return b:finish(),{{a,z}}
end
return function()
  local xs={}
  for n=1,3 do for _,parents in ipairs(parent_arrays(n)) do for pa=1,n do for pb=1,n do local g,
      r=make(parents,pa,pb)
  xs[#xs+1]={g=g,r=r,parents=parents,pa=pa,pb=pb} end end end end
  local comparisons=0
  for _,s in ipairs(xs) do for _,t in ipairs(xs) do local tg,tr=make(t.parents,t.pa,t.pb)
  local _=C.match_seeded(s.g,tg,s.r,tr)
  comparisons=comparisons+1 end end
  assert(comparisons==3969,'unexpected support census size')
  return '3969 directional support Match judgements execute directly on ' ..
      'retained Geometry; no support Theory summary is required'
end
