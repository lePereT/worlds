local W=require('worlds'); local T=require('support')
-- Semantic vocabulary is ordinary imported Point identity.
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); local Tmp=vb:point(vm,'Tmp'); local Done=vb:point(vm,'Done'); local Permit=vb:point(vm,'Permit'); vb:finish()

-- P: consume Control, create a fresh identity x and provisional Tmp(x).
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local ci=p:strand(pm,{Control}); local co=p:strand(pm,{Control}); local x=p:point(pm,'x'); local mid=p:strand(pm,{Tmp,x}); p:face(pm,{ci},{co,mid},'first'); local P=p:finish()
-- Q: consume Tmp(y), produce Done(y).  y is local to Q and will be unified by cut.
local q=W.Geometry.builder(); local qm=q:membrane(nil,'q'); local y=q:point(qm,'y'); local qi=q:strand(qm,{Tmp,y}); local qo=q:strand(qm,{Done,y}); q:face(qm,{qi},{qo},'second'); local Q=q:finish()
local PQ,img=W.Algebra.cut(P,Q,{{left=mid,right=qi}})
T.ok(PQ:grounded(),'composite should remain grounded')
-- The cut Strand is internal: only Control is ingress and Done is egress.
local cci=img.left.strands[ci]; local cco=img.left.strands[co]; local cmid=img.left.strands[mid]; local cdone=img.right.strands[qo]
T.ok(PQ:is_input(cci)); T.ok(PQ:is_terminal(cco)); T.ok(not PQ:is_terminal(cmid)); T.ok(PQ:is_terminal(cdone)); T.eq(#PQ:faces(),2)
-- Q's y and P's x are one local Point in the composite.
T.eq(img.right.points[y],img.left.points[x])

-- Only the composite touches Live: no provisional Tmp authority ever appears.
local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'root'); local ctl=sb:strand(sm,{Control}); local live=W.Operational.from_geometry(sb:finish())
local w=W.Operational.one(live,PQ,{strands={[cci]=ctl}}); T.ok(w)
local _,out=W.Operational.commit(w); T.ok(out.strands[cdone]); T.ok(not out.strands[cmid]); local pts=W.Geometry.points(out.strands[cdone]); T.eq(pts[2],out.points[img.left.points[x]])
return T.count()
