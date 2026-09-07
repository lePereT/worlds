local W=require('worlds'); local T=require('support')
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local child=b:membrane(root,'child'); local cid=b:point(child,'id'); local h=b:strand(root,{cid},'handle'); local live=W.Operational.from_geometry(b:finish())
local p=W.Geometry.builder(); local pr=p:membrane(nil,'pr'); local pc=p:membrane(pr,'pc'); local x=p:point(pc,'x'); local hi=p:strand(pr,{x}); local ho=p:strand(pr,{x}); local st=p:strand(pc,{x}); p:face(pr,{hi},{ho,st}); local pat=p:finish()
local w=W.Operational.one(live,pat,{strands={[hi]=h}}); T.ok(w); local live2,img=W.Operational.commit(w); local h2,s2=img.strands[ho],img.strands[st]
local q=W.Geometry.builder(); local qr=q:membrane(nil,'qr'); local qc=q:membrane(qr,'qc'); local y=q:point(qc,'y'); local qh=q:strand(qr,{y}); local qs=q:strand(qc,{y}); q:face(qr,{qh,qs},{},'finish'); local fin=q:finish()
local wf=W.Operational.one(live2,fin,{strands={[qh]=h2,[qs]=s2}}); T.ok(wf); local live3=W.Operational.commit(wf)
T.eq(live3:size(),0,'all live responsibility is retired')
return T.count()
