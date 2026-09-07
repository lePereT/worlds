local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); local Handle=vb:point(vm,'Handle'); local Done=vb:point(vm,'Done'); vb:finish()
local hb=W.Geometry.builder(); local hm=hb:membrane(nil,'root'); local ctl=hb:strand(hm,{Control}); local history=hb:finish(); local boundary=W.Operational.from_geometry(history)
-- Create fresh identity.
local c=W.Geometry.builder(); local cm=c:membrane(nil,'c'); local ci=c:strand(cm,{Control}); local co=c:strand(cm,{Control}); local x=c:point(cm,'x'); local ho=c:strand(cm,{Handle,x}); c:face(cm,{ci},{co,ho}); local create=c:finish()
local w=W.Operational.one(boundary,create,{strands={[ci]=ctl}}); T.ok(w); local _,oi=W.Operational.commit(w); local op_handle=oi.strands[ho]; local op_x=oi.points[x]
local h2,hi=W.Algebra.close({history,create},{{ctl,ci}}); history=h2; local hist_handle=hi[2].strands[ho]; local hist_x=hi[2].points[x]
T.ok(op_x~=hist_x,'operational and exact-history realisations are independent exact occurrences'); T.eq(W.Geometry.points(op_handle)[2],op_x); T.eq(W.Geometry.points(hist_handle)[2],hist_x)
-- A second process consumes whichever exact handle exists; local y is inferred from authority.
local u=W.Geometry.builder(); local um=u:membrane(nil,'u'); local y=u:point(um,'y'); local ui=u:strand(um,{Handle,y}); local done=u:strand(um,{Done,y}); u:face(um,{ui},{done}); local use=u:finish()
local w2=W.Operational.one(boundary,use,{strands={[ui]=op_handle}}); T.ok(w2); local _,oi2=W.Operational.commit(w2); T.eq(W.Geometry.points(oi2.strands[done])[2],op_x)
local h3,hi2=W.Algebra.close({history,use},{{hist_handle,ui}}); T.eq(hi2[2].points[y],hi2[1].points[hist_x]); T.eq(W.Geometry.points(hi2[2].strands[done])[2],hi2[2].points[y]); T.eq(#h3:faces(),2)
return T.count()
