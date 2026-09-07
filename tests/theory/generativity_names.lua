local T=require('support'); local H=require('theory_whole_support'); local W,G=H.W,H.G
local R=H.vocab{'Input','Output','Out1','Out2','Send','Recv','Done','Label','RecvName','UseName','Go','NameOut'}

-- 0.4/36 is intentionally strengthened in 0.5: fresh downstream Points in an
-- already-existing locality are legal existentials, rather than requiring a fresh membrane.
local b=G.builder(); local m=b:membrane(nil,'eval'); local exact=b:point(m,'exact'); local authority=b:strand(m,{R.Input,exact}); local base=b:finish(); local boundary=W.Operational.from_geometry(base)
local p=G.builder(); local pm=p:membrane(nil,'eval'); local x=p:point(pm,'x'); local fresh=p:point(pm,'fresh'); local pi=p:strand(pm,{R.Input,x}); local po=p:strand(pm,{R.Output,fresh}); p:face(pm,{pi},{po}); local proc=p:finish()
local w=W.Operational.one(boundary,proc,{strands={[pi]=authority}}); T.ok(w); local _,img=W.Operational.commit(w); local out=img.strands[po]; local realised=G.points(out)[2]
T.ok(realised~=fresh and realised~=exact,'fresh local existential must become new exact Point'); T.eq(G.membrane(realised),G.membrane(out))
-- Fresh child generativity remains available too.
local b2=G.builder(); local m2=b2:membrane(nil,'base'); local e=b2:point(m2,'e'); local auth=b2:strand(m2,{R.Input,e}); local bound2=W.Operational.from_geometry(b2:finish())
local p2=G.builder(); local r=p2:membrane(nil,'p'); local xx=p2:point(r,'x'); local ii=p2:strand(r,{R.Input,xx}); local child=p2:membrane(r,'fresh-values'); local a=p2:point(child,'a'); local c=p2:point(child,'c'); local o1=p2:strand(r,{R.Out1,a}); local o2=p2:strand(r,{R.Out2,c}); p2:face(r,{ii},{o1,o2}); local pr=p2:finish()
local ww=W.Operational.one(bound2,pr,{strands={[ii]=auth}}); T.ok(ww); local _,im=W.Operational.commit(ww); T.ok(im.points[a]~=im.points[c]); T.eq(G.parent(G.membrane(im.points[a])),G.membrane(auth))

-- 0.4/37: nominal rendezvous requires exact shared identity.
local function rendez_source(shared)
  local bb=G.builder(); local mm=bb:membrane(nil,'proc'); local c1=bb:point(mm,'c1'); local c2=shared and c1 or bb:point(mm,'c2'); bb:strand(mm,{R.Send,c1}); bb:strand(mm,{R.Recv,c2}); return bb:finish()
end
local rp=G.builder(); local rm=rp:membrane(nil,'r'); local ch=rp:point(rm,'c'); local si=rp:strand(rm,{R.Send,ch}); local ri=rp:strand(rm,{R.Recv,ch}); local done=rp:strand(rm,{R.Done,ch}); rp:face(rm,{si,ri},{done}); local rendez=rp:finish()
T.eq(#H.structural(rendez_source(true),rendez),1); T.eq(#H.structural(rendez_source(false),rendez),0)

-- 0.4/38: quotient rendezvous keeps distinct Point variables and lets Theory decide.
local function qsource(a0,b0)
  local bb=G.builder(); local mm=bb:membrane(nil,'q'); local a=bb:point(mm,'a'); local c=bb:point(mm,'b'); bb:strand(mm,{R.Send,a}); bb:strand(mm,{R.Recv,c}); return bb:finish(),{[a]=a0,[c]=b0}
end
local qp=G.builder(); local qm=qp:membrane(nil,'q'); local qa=qp:point(qm,'a'); local qb=qp:point(qm,'b'); local qs=qp:strand(qm,{R.Send,qa}); local qr=qp:strand(qm,{R.Recv,qb}); local qo=qp:strand(qm,{R.Done,qa}); qp:face(qm,{qs,qr},{qo}); local qpat=qp:finish()
for _,case in ipairs{{1,4,true},{1,2,false}} do local src,v=qsource(case[1],case[2]); local cut=H.structural(src,qpat)[1]; T.ok(cut); T.eq(((v[cut:point(qa)]-v[cut:point(qb)])%3)==0,case[3]) end

-- 0.4/39: exact received name propagates through ordinary Point substitution.
local nb=G.builder(); local nm=nb:membrane(nil,'names'); local n=nb:point(nm,'n'); local recv=nb:strand(nm,{R.RecvName,n}); local nbound=W.Operational.from_geometry(nb:finish())
local np=G.builder(); local npm=np:membrane(nil,'nproc'); local vx=np:point(npm,'x'); local ni=np:strand(npm,{R.RecvName,vx}); local no=np:strand(npm,{R.UseName,vx}); np:face(npm,{ni},{no}); local nproc=np:finish()
local nw=W.Operational.one(nbound,nproc,{strands={[ni]=recv}}); T.ok(nw); T.eq(nw:point(vx),n); local _,nim=W.Operational.commit(nw); T.eq(G.points(nim.strands[no])[2],n)

-- 0.4/40: fresh-name extrusion keeps exact freshness and exports it on live boundary.
local gb=G.builder(); local gm=gb:membrane(nil,'proc'); local u=gb:point(gm,'go'); local go=gb:strand(gm,{R.Go,u}); local initial=gb:finish()
local ep=G.builder(); local em=ep:membrane(nil,'proc'); local eu=ep:point(em,'u'); local ei=ep:strand(em,{R.Go,eu}); local nu=ep:membrane(em,'nu'); local name=ep:point(nu,'name'); local eo=ep:strand(em,{R.NameOut,name}); ep:face(em,{ei},{eo}); local eproc=ep:finish()
local function generate()
  local bd=W.Operational.from_geometry(initial); local ew=W.Operational.one(bd,eproc,{strands={[ei]=go}}); T.ok(ew); local _,eim=W.Operational.commit(ew); local en=G.points(eim.strands[eo])[2]; return en,G.membrane(en),eim.membranes[nu]
end
local n1,m1,nu1=generate(); local n2,m2,nu2=generate(); T.ok(n1~=n2); T.eq(m1,nu1); T.eq(m2,nu2); T.ok(nu1~=nu2)
return T.count()
