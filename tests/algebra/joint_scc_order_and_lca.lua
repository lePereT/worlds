local W=require('worlds'); local T=require('support')
local random=require('prng').new(3451)
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); local roles={}; for i=1,8 do roles[i]=vb:point(vm,'R'..i) end; vb:finish()
local parts,ins,outs,faces,controls={},{},{},{},{}
for i=1,8 do
  local b=W.Geometry.builder(); local root=b:membrane(nil,'root'..i); local zone=b:membrane(root,'zone'); local leaf=b:membrane(zone,'leaf'..i)
  ins[i]=b:strand(zone,{roles[(i-2)%8+1]}); local inputs={ins[i]}; if i==1 then controls[i]=b:strand(zone,{Control}); inputs[#inputs+1]=controls[i] end
  outs[i]=b:strand(zone,{roles[i]}); faces[i]=b:face(leaf,inputs,{outs[i]}); parts[i]=b:finish()
end
local links={}; for i=1,8 do links[i]={outs[i],ins[i%8+1]} end
for trial=1,50 do
  local ls={}; for i,e in ipairs(links) do ls[i]=e end; for i=#ls,2,-1 do local j=random(i); ls[i],ls[j]=ls[j],ls[i] end
  local g,img=W.Algebra.close(parts,ls); T.eq(#g:faces(),1); T.eq(#g:ingress(),1); local jf=img[1].faces[faces[1]]; T.ok(jf)
  -- Root and zone are unified by cuts; leaves remain distinct. LCA is the unified zone.
  local zone=img[1].membranes[W.Geometry.parent(W.Geometry.membrane(faces[1]))]; T.eq(W.Geometry.membrane(jf),zone)
  for i=2,8 do T.eq(img[i].faces[faces[i]],jf) end
end
return T.count()
