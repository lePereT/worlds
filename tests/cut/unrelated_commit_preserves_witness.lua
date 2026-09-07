local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); vb:finish()
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local ma=b:membrane(root,'a'); local mb=b:membrane(root,'b'); local sa=b:strand(ma,{A}); local sb=b:strand(mb,{B}); local live=W.Operational.from_geometry(b:finish())
local function step(role)
  local p=W.Geometry.builder(); local m=p:membrane(nil,'p'); local i=p:strand(m,{role}); local o=p:strand(m,{role}); p:face(m,{i},{o}); return p:finish(),i,o
end
local pa,ia,oa=step(A); local pb,ib,ob=step(B)
local wa=W.Operational.one(live,pa,{strands={[ia]=sa}}); local wb=W.Operational.one(live,pb,{strands={[ib]=sb}}); T.ok(wa and wb)
W.Operational.commit(wa); local ok=pcall(function() W.Operational.commit(wb) end); T.ok(ok,'unrelated commit should not stale exact witness')
return T.count()
