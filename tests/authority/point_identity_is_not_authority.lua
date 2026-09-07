local W=require('worlds'); local T=require('support')
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local child=b:membrane(root,'child'); local cid=b:point(child,'child-id'); local Control=b:point(root,'Control'); local ctl=b:strand(root,{Control},'control'); local boundary=W.Operational.from_geometry(b:finish())
-- Merely importing exact child identity into an output does not map a process
-- locality onto that child. The only consumed authority is root Control, so a
-- new local child may be created under root, but the existing child is untouched.
local p=W.Geometry.builder(); local pr=p:membrane(nil,'pr'); local pc=p:membrane(pr,'pc'); local ci=p:strand(pr,{Control},'in'); local co=p:strand(pr,{Control},'out'); local out=p:strand(pc,{cid},'state'); p:face(pr,{ci},{co,out}); local proc=p:finish()
local w=W.Operational.one(boundary,proc,{strands={[ci]=ctl}}); T.ok(w)
local _,img=W.Operational.commit(w); local gs=img.strands[out]; T.ok(gs); T.eq(W.Geometry.points(gs)[1],cid,'exact Point identity is preserved'); T.ok(W.Geometry.membrane(gs)~=child,'identity alone does not select or authorise existing child locality'); T.eq(boundary:size(),2,'existing empty child contributes no authority; only control and fresh output are live')
return T.count()
