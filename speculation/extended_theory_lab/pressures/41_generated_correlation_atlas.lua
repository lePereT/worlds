local W=require('worlds')
local T=require('speculation.extended_theory_lab.theory')
local function permutations(n)
  local out,used,row={},{},{}
  local function go(k) if k>n then local p={}
  for i=1,n do p[i]=row[i] end
  out[#out+1]=p
  return end
  for x=1,n do if not used[x] then used[x]=true
  row[k]=x
  go(k+1)
  used[x]=nil end end end
  go(1)
  return out
end
return function()
  local b=W.builder()
  local m=b:membrane(nil,'correlation atlas')
  local roots,supports={},{}
  for i=1,4 do roots[i]=b:strand(m,{},'r'..i)
  supports[i]=b:strand(m,{},'s'..i) end
  local g=b:finish()
  local checks=0
  for _,p in ipairs(permutations(4)) do local facts={}
  for i=1,4 do facts[#facts+1]=T.fact('governs',roots[i],supports[p[i]]) end
  local st=T.state(g,facts)
  for i=1,4 do for j=1,4 do local hits=T.query(st,{T.fact('governs',roots[i],supports[j])})
  assert((#hits==1)==(j==p[i]),'pairing atlas confused permutation')
  checks=checks+1 end end end
  assert(checks==384)
  return '384 contextual correlation probes distinguish all 24 ' ..
      'root/support pairings over one identical exact Geometry'
end
