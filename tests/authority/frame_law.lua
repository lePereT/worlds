local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); vb:finish()
local hb=W.Geometry.builder(); local hm=hb:membrane(nil,'root'); local a=hb:strand(hm,{A}); local b=hb:strand(hm,{B}); local history=hb:finish(); local boundary=W.Operational.from_geometry(history)
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local ai=p:strand(pm,{A}); local ao=p:strand(pm,{A}); p:face(pm,{ai},{ao}); local proc=p:finish()
local w=W.Operational.one(boundary,proc,{strands={[ai]=a}}); T.ok(w); local _,img=W.Operational.commit(w)
T.ok(boundary:contains(img.strands[ao])); T.ok(boundary:contains(b),'untouched exact authority survives specialised execution unchanged'); T.ok(not boundary:contains(a)); T.eq(boundary:size(),2)
-- Exact-history closure has the same frame shape: B remains terminal while A is replaced.
local h2,himg=W.Algebra.close({history,proc},{{a,ai}}); T.eq(#h2:egress(),2); T.ok(h2:is_terminal(himg[1].strands[b])); T.ok(h2:is_terminal(himg[2].strands[ao]))
return T.count()
