local W=require('worlds'); local T=require('support')
local random=require('prng').new(99173)
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local R={}; for i=0,12 do R[i]=vb:point(vm,'R'..i) end; vb:finish()
local parts,ins,outs={},{},{}
for i=1,12 do local b=W.Geometry.builder(); local m=b:membrane(nil,'p'..i); ins[i]=b:strand(m,{R[i-1]}); outs[i]=b:strand(m,{R[i]}); b:face(m,{ins[i]},{outs[i]}); parts[i]=b:finish() end
local links={}; for i=1,11 do links[i]={outs[i],ins[i+1]} end
for trial=1,100 do
  local ls={}; for i,e in ipairs(links) do ls[i]=e end
  for i=#ls,2,-1 do local j=random(i); ls[i],ls[j]=ls[j],ls[i] end
  local g=W.Algebra.close(parts,ls)
  T.eq(#g:faces(),12); T.eq(#g:ingress(),1); T.eq(#g:egress(),1); T.eq(W.Geometry.points(g:ingress()[1])[1],R[0]); T.eq(W.Geometry.points(g:egress()[1])[1],R[12])
end
return T.count()
