local W=require('worlds')
local C=require('speculation.extended_theory_lab.common')
local R=C.roles({'A','B','C'},'point-scope')
local parts={{1,1,1},{1,1,2},{1,2,1},{1,2,2},{1,2,3}}
local function build(part)
  local b=W.builder()
  local m=b:membrane(nil,'scope')
  local ps={}
  for _,k in ipairs(part) do if not ps[k] then ps[k]=b:point(m,nil) end end
  local a=b:strand(m,{R.A,ps[part[1]]})
  local z=b:strand(m,{R.B,ps[part[2]]})
  local c=b:strand(m,{R.C,ps[part[3]]})
  return b:finish(),{{a,z,c}}
end
return function()
  local cases={}
  for i,p in ipairs(parts) do local g,r=build(p)
  cases[i]={g=g,r=r} end
  local yes=0
  for i=1,#cases do for j=1,#cases do if C.match_seeded(cases[i].g,cases[j].g,cases[i].r,
      cases[j].r) then yes=yes+1 end end end
  assert(yes>0 and yes<25,'point partition oracle degenerated')
  return 'all 25 three-coordinate equality/refinement cases are decided ' ..
      'by ordinary local Point incidence ('..yes..' lawful directions)'
end
