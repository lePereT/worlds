local T=require('support'); local H=require('theory_whole_support'); local W,G=H.W,H.G
local R=H.vocab{'Offer','Accept','Done','Q','Accepted','Token','Term','Reduced','Call'}

-- 0.4/41 proof-irrelevant protocol: exact structure is generic; Theory may identify propositions.
local b=G.builder(); local m=b:membrane(nil,'logic'); local pa=b:point(m,'pa'); local pb=b:point(m,'pb'); b:strand(m,{R.Offer,pa}); b:strand(m,{R.Accept,pb}); local src=b:finish(); local prop={[pa]='P',[pb]='P'}
local p=G.builder(); local pm=p:membrane(nil,'p'); local a=p:point(pm,'a'); local q=p:point(pm,'b'); local oi=p:strand(pm,{R.Offer,a}); local ai=p:strand(pm,{R.Accept,q}); local od=p:strand(pm,{R.Done,a}); p:face(pm,{oi,ai},{od}); local pat=p:finish(); local cuts=H.structural(src,pat); T.eq(#cuts,1); T.eq(prop[cuts[1]:point(a)],prop[cuts[1]:point(q)])
local exact=G.builder(); local exm=exact:membrane(nil,'e'); local z=exact:point(exm,'z'); exact:strand(exm,{R.Offer,z}); exact:strand(exm,{R.Accept,z}); T.eq(#H.structural(src,exact:finish()),0)

-- 0.4/42 quantum projective guard.
local function qsystem(vec) local x=G.builder(); local mm=x:membrane(nil,'lab'); local sys=x:point(mm,'q'); x:strand(mm,{R.Q,sys}); return x:finish(),{[sys]=vec} end
local qp=G.builder(); local qm=qp:membrane(nil,'lab'); local qv=qp:point(qm,'q'); local qi=qp:strand(qm,{R.Q,qv}); local qo=qp:strand(qm,{R.Accepted,qv}); qp:face(qm,{qi},{qo}); local qpat=qp:finish()
for _,case in ipairs{{{1,0},true},{{-2,0},true},{{0,1},false}} do local s,v=qsystem(case[1]); local c=H.structural(s,qpat)[1]; T.ok(c); T.eq(H.projective_eq(v[c:point(qv)],{1,0}),case[2]) end

-- 0.4/43 extensional equality never merges scarce Strand authority.
local sb=G.builder(); local sm=sb:membrane(nil,'scarce'); local sv=sb:point(sm,'v'); sb:strand(sm,{R.Token,sv}); local scarce=sb:finish()
local sp=G.builder(); local sM=sp:membrane(nil,'needs2'); local x=sp:point(sM,'x'); local y=sp:point(sM,'y'); sp:strand(sM,{R.Token,x}); sp:strand(sM,{R.Token,y}); T.eq(#H.structural(scarce,sp:finish()),0)

-- 0.4/44 term rewrite modulo commutativity.
local function termsource(term) local x=G.builder(); local mm=x:membrane(nil,'term'); local e=x:point(mm,'e'); x:strand(mm,{R.Term,e}); return x:finish(),{[e]=term} end
local tp=G.builder(); local tm=tp:membrane(nil,'rewrite'); local tx=tp:point(tm,'x'); local ti=tp:strand(tm,{R.Term,tx}); local to=tp:strand(tm,{R.Reduced,tx}); tp:face(tm,{ti},{to}); local tpat=tp:finish(); local target={op='add',a={atom='x'},b={atom='y'}}
for _,term in ipairs{target,{op='add',a={atom='y'},b={atom='x'}},{op='add',a={atom='x'},b={atom='z'}}} do local s,v=termsource(term); local c=H.structural(s,tpat)[1]; T.ok(c); local accepted=H.term_normal(v[c:point(tx)])==H.term_normal(target); T.eq(accepted,term.b.atom~='z') end

-- 0.4/45 Theory admissibility Unknown remains distinct.
local ub=G.builder(); local um=ub:membrane(nil,'fn'); local f=ub:point(um,'f'); ub:strand(um,{R.Call,f}); local us=ub:finish(); local up=G.builder(); local upm=up:membrane(nil,'p'); local ux=up:point(upm,'x'); up:strand(upm,{R.Call,ux}); local uc=H.structural(us,up:finish()); local class=H.classify(uc,function() return 'unknown' end); T.eq(#class.accepted,0); T.eq(#class.rejected,0); T.eq(#class.unknown,1)
return T.count()
