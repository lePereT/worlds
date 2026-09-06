local S=require('tests.support')
local G,A=S.G,S.A

local function pair(shared)
  local b=G.builder(); local K=b:membrane(nil,'term'); local p=b:point(K,'Atom'); local q=shared and p or b:point(K,'Atom')
  b:strand(K,'Left',{p}); b:strand(K,'Right',{q}); return b:finish(),K,{[p]=42,[q]=42}
end
local shared,Ks,vs=pair(true); local split,Kd,vd=pair(false)
-- Extensional pair observation forgets sharing.
local function observe(g,K,vals)
  local left,right
  for _,sid in ipairs(g:offers({K})) do local c=g:cell(sid); if c.sort=='Left' then left=vals[c.points[1]] elseif c.sort=='Right' then right=vals[c.points[1]] end end
  return tostring(left)..','..tostring(right)
end
S.eq(observe(shared,Ks,vs),observe(split,Kd,vd))

-- But an exact identity-sensitive context distinguishes them. Therefore this
-- extensional quotient is not a congruence for *all* Worlds contexts.
local p=G.builder(); local D=p:membrane(nil,'term'); local z=p:point(D,'Atom')
p:strand(D,'Left',{z}); p:strand(D,'Right',{z}); local identity_probe=p:finish()
S.eq(#A.all(shared,{Ks},identity_probe),1)
S.eq(#A.all(split,{Kd},identity_probe),0)
print('ok 46_extensional_quotient_not_global_congruence')
