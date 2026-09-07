local T=require('support'); local H=require('theory_whole_support'); local W,G=H.W,H.G
local R=H.vocab{'Left','Right','Result','Value','CellState','Term'}

-- 0.4/26: extensional values coexist with exact sharing identity.
local function pair(shared)
  local b=G.builder(); local m=b:membrane(nil,'eval'); local p=b:point(m,'p'); local q=shared and p or b:point(m,'q')
  b:strand(m,{R.Left,p}); b:strand(m,{R.Right,q}); return b:finish(),{[p]=42,[q]=42},p,q
end
local p=G.builder(); local pm=p:membrane(nil,'op'); local x=p:point(pm,'x'); local y=p:point(pm,'y')
local l=p:strand(pm,{R.Left,x}); local r=p:strand(pm,{R.Right,y}); local z=p:point(pm,'z'); local o=p:strand(pm,{R.Result,z}); p:face(pm,{l,r},{o}); local add=p:finish()
local fresh,fa=pair(false); local canon,ca=pair(true); local ef=H.structural(fresh,add)[1]; local ec=H.structural(canon,add)[1]
T.ok(ef and ec); T.eq(fa[ef:point(x)]+fa[ef:point(y)],84); T.eq(ca[ec:point(x)]+ca[ec:point(y)],84)
T.ok(ef:point(x)~=ef:point(y),'fresh pair remains exact-distinct'); T.eq(ec:point(x),ec:point(y),'shared pair preserves exact sharing')
-- An exact-sharing context distinguishes the two.
local q=G.builder(); local qm=q:membrane(nil,'probe'); local same=q:point(qm,'same'); q:strand(qm,{R.Left,same}); q:strand(qm,{R.Right,same}); local identity=q:finish()
T.eq(#H.structural(canon,identity),1); T.eq(#H.structural(fresh,identity),0)

-- 0.4/27: quotient equality needs no canonical Point representative.
local b=G.builder(); local m=b:membrane(nil,'math'); local p1=b:point(m,'1'); local p4=b:point(m,'4'); local p7=b:point(m,'7'); b:finish()
local val={[p1]=1,[p4]=4,[p7]=7}; local function mod3(a,b) return val[a]%3==val[b]%3 end
T.ok(p1~=p4 and p4~=p7); T.ok(mod3(p1,p4) and mod3(p4,p7) and mod3(p1,p7))

-- 0.4/28: nominal cells are distinct while contents may be extensionally equal.
local cb=G.builder(); local cm=cb:membrane(nil,'heap'); local c1=cb:point(cm,'c1'); local c2=cb:point(cm,'c2'); local v1=cb:point(cm,'v1'); local v2=cb:point(cm,'v2')
cb:strand(cm,{R.CellState,c1,v1}); cb:strand(cm,{R.CellState,c2,v2}); cb:finish(); local iv={[v1]=42,[v2]=42}
T.ok(c1~=c2); T.eq(iv[v1],iv[v2])

-- 0.4/29: exact sharing remains observable, extensional term observation may forget it.
local function termgraph(shared)
  local b2=G.builder(); local mm=b2:membrane(nil,'term'); local a=b2:point(mm,'a'); local bb=shared and a or b2:point(mm,'b'); local ls=b2:strand(mm,{R.Left,a}); local rs=b2:strand(mm,{R.Right,bb}); return b2:finish(),{[a]='a',[bb]='a'},ls,rs
end
local sg,sa,sl,sr=termgraph(true); local cg,ca2,cl,cr=termgraph(false)
T.eq(G.points(sl)[2],G.points(sr)[2]); T.ok(G.points(cl)[2]~=G.points(cr)[2]); T.eq(sa[G.points(sl)[2]]..','..sa[G.points(sr)[2]],ca2[G.points(cl)[2]]..','..ca2[G.points(cr)[2]])

-- 0.4/30: float observations may quotient differently from exact identity.
local fb=G.builder(); local fm=fb:membrane(nil,'float'); local pz=fb:point(fm,'+0'); local nz=fb:point(fm,'-0'); fb:finish(); local bits={[pz]='0000',[nz]='8000'}; local num={[pz]=0.0,[nz]=-0.0}
T.eq(num[pz],num[nz]); T.ok(bits[pz]~=bits[nz]); T.ok(pz~=nz)

-- 0.4/31: proof relevance is Theory, not Point identity policy.
local pb=G.builder(); local lm=pb:membrane(nil,'logic'); local pr=pb:point(lm,'p'); local qr=pb:point(lm,'q'); pb:finish(); local proposition={[pr]='P',[qr]='P'}
T.eq(proposition[pr],proposition[qr]); T.ok(pr~=qr)

-- 0.4/32: exact quantum-system identity and projective state equality coexist.
local qb=G.builder(); local qmm=qb:membrane(nil,'lab'); local q1=qb:point(qmm,'q1'); local q2=qb:point(qmm,'q2'); local q3=qb:point(qmm,'q3'); qb:finish(); local state={[q1]={1,0},[q2]={1,0},[q3]={-1,0}}
T.ok(q1~=q2); T.ok(H.projective_eq(state[q1],state[q2])); T.ok(H.projective_eq(state[q1],state[q3]))

-- 0.4/33: Theory equality may honestly be Unknown.
local ub=G.builder(); local um=ub:membrane(nil,'fn'); local f=ub:point(um,'f'); local g=ub:point(um,'g'); ub:finish(); local function undec(a,b) if a==b then return true end return nil end
T.eq(H.tri_eq(f,f,undec),'equal'); T.eq(H.tri_eq(f,g,undec),'unknown'); T.ok(f~=g)

-- 0.4/34: structural candidate first, Theory guard afterwards.
local function source(n)
  local s=G.builder(); local sm=s:membrane(nil,'eval'); local pnt=s:point(sm,'n'); s:strand(sm,{R.Value,pnt}); return s:finish(),{[pnt]=n}
end
local gp=G.builder(); local gm=gp:membrane(nil,'guard'); local gx=gp:point(gm,'x'); local gi=gp:strand(gm,{R.Value,gx}); local go=gp:strand(gm,{R.Result,gx}); gp:face(gm,{gi},{go}); local guard=gp:finish()
for _,n in ipairs{41,42} do local src,ann=source(n); local cut=H.structural(src,guard)[1]; T.ok(cut); T.eq(ann[cut:point(gx)]==42,n==42) end

-- 0.4/35: nominal disequality is an admissibility judgement over generic variables.
local sameSrc=select(1,pair(true)); local splitSrc=select(1,pair(false));
local np=G.builder(); local nm=np:membrane(nil,'names'); local nx=np:point(nm,'x'); local ny=np:point(nm,'y'); np:strand(nm,{R.Left,nx}); np:strand(nm,{R.Right,ny}); local generic=np:finish()
local cs=H.structural(sameSrc,generic)[1]; local cd=H.structural(splitSrc,generic)[1]; T.ok(cs and cd); T.ok(cs:point(nx)==cs:point(ny)); T.ok(cd:point(nx)~=cd:point(ny))
return T.count()
