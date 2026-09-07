local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Give=vb:point(vm,'Give'); local Take=vb:point(vm,'Take'); local Unit=vb:point(vm,'Unit'); local Counter=vb:point(vm,'Counter'); vb:finish()
local g=W.Geometry.builder(); local gm=g:membrane(nil,'give'); local gi=g:strand(gm,{Give}); local go=g:strand(gm,{Give}); local made=g:strand(gm,{Unit,Counter}); g:face(gm,{gi},{go,made}); local GiveP=g:finish()
local t=W.Geometry.builder(); local tm=t:membrane(nil,'take'); local ti=t:strand(tm,{Take}); local need=t:strand(tm,{Unit,Counter}); local to=t:strand(tm,{Take}); t:face(tm,{ti,need},{to}); local TakeP=t:finish()
-- each is literally tensor: sibling output remains terminal and sibling demand remains open.
local each,eimg=W.Algebra.tensor({GiveP,TakeP}); local egi=eimg[1].strands[gi]; local eti=eimg[2].strands[ti]; local eneed=eimg[2].strands[need]; T.ok(each:is_terminal(eimg[1].strands[made])); T.ok(each:is_input(eneed))
-- together is the same parts with the compatible sibling boundary closed.
local together,timg=W.Algebra.close({GiveP,TakeP},{{from=made,to=need}}); local tgi=timg[1].strands[gi]; local tti=timg[2].strands[ti]; T.eq(timg[1].strands[made],timg[2].strands[need]); T.ok(not together:is_terminal(timg[1].strands[made]))
local function source(n)
  local b=W.Geometry.builder(); local m=b:membrane(nil,'root'); local gp=b:strand(m,{Give}); local tp=b:strand(m,{Take}); local units={}; for i=1,n do units[i]=b:strand(m,{Unit,Counter}) end; return W.Operational.from_geometry(b:finish()),gp,tp,units
end
local l0,g0,t0,u0=source(0); T.eq(W.Operational.one(l0,each,{strands={[egi]=g0,[eti]=t0},offers=u0}),nil); T.ok(W.Operational.one(l0,together,{strands={[tgi]=g0,[tti]=t0}}))
local l1,g1,t1,u1=source(1); T.ok(W.Operational.one(l1,each,{strands={[egi]=g1,[eti]=t1},offers=u1}))
return T.count()
