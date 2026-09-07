local W=require('worlds'); local T=require('support')
local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local child=b:membrane(root,'child'); local cid=b:point(child,'child-id'); local h=b:strand(root,{cid},'handle'); local g=b:finish(); local live=W.Operational.from_geometry(g)
local p=W.Geometry.builder(); local pr=p:membrane(nil,'pr'); local pc=p:membrane(pr,'pc'); local x=p:point(pc,'x'); local hi=p:strand(pr,{x},'in'); local ho=p:strand(pr,{x},'out'); local st=p:strand(pc,{x},'state'); p:face(pr,{hi},{ho,st},'enter'); local pat=p:finish()
-- No membrane selection or Point anchor. Exact live authority induces parent,
-- child and Point mapping through incidence.
local w=W.Operational.one(live,pat,{strands={[hi]=h}}); T.ok(w); T.eq(w:point(x),cid); T.eq(w:membrane(pr),root); T.eq(w:membrane(pc),child)
local live2,img=W.Operational.commit(w); T.ok(live2:contains(img.strands[ho])); T.ok(live2:contains(img.strands[st])); T.eq(W.Geometry.membrane(img.strands[st]),child)
return T.count()
