package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local n=0
local function ok(x,msg) n=n+1; if not x then error('FAIL '..n..': '..(msg or '?'),2) end end
local function eq(a,b,msg) ok(a==b,(msg or 'equality')..' expected '..tostring(b)..' got '..tostring(a)) end
local function neq(a,b,msg) ok(a~=b,msg or 'expected distinct values') end
local function pts(s) return W.points(s) end
local function kind(x) return W.kind(x) end

local function stage(label, external_role)
  local b=W.builder()
  local r=b:membrane(nil,label..'_r')
  local x=b:point(r,label..'_x')
  local ps=external_role and {external_role,x} or {x}
  local i=b:strand(r,ps,label..'_in')
  local o=b:strand(r,ps,label..'_out')
  local f=b:face(r,{i},{o},label..'_face')
  return b:finish(),r,x,i,o,f
end

print('1. downward congruence / induced lower-dimensional equality')
do
  local a=W.builder()
  local ar=a:membrane(nil,'SR'); local ac=a:membrane(ar,'SC')
  local p=a:point(ac,'p')
  local aout=a:strand(ac,{p,p},'source_pair')
  local A=a:finish()

  local b=W.builder()
  local br=b:membrane(nil,'TR'); local bc=b:membrane(br,'TC')
  local x=b:point(bc,'x'); local y=b:point(bc,'y')
  local bin=b:strand(bc,{x,y},'target_pair')
  local sx=b:strand(bc,{x},'sx')
  local sy=b:strand(bc,{y},'sy')
  local sxy=b:strand(bc,{x,y},'sxy')
  local B=b:finish()

  local G,img=W.join({A,B},{{from=aout,to=bin}})
  eq(img[br],ar,'target root maps to source root')
  eq(img[bc],ac,'target child maps to source child')
  eq(img[x],p,'first coordinate maps to repeated source point')
  eq(img[y],p,'second coordinate maps to same repeated source point')
  eq(img[x],img[y],'distinct target points collapse under induced equality')

  local isx,isy,isxy=img[sx],img[sy],img[sxy]
  neq(isx,sx,'non-frame sx is materialised')
  neq(isy,sy,'non-frame sy is materialised')
  eq(W.membrane(isx),ac,'sx follows membrane quotient')
  eq(W.membrane(isy),ac,'sy follows membrane quotient')
  eq(pts(isx)[1],p,'x quotient propagates sideways to sx')
  eq(pts(isy)[1],p,'y quotient propagates sideways to sy')
  eq(pts(isxy)[1],p,'sxy first coordinate propagated')
  eq(pts(isxy)[2],p,'sxy second coordinate propagated')
  eq(img[aout],aout,'reusable frame source is quotient representative')
  eq(img[bin],aout,'target ingress maps to frame source occurrence')
  ok(G:owns_strand(isx) and G:owns_strand(isy),'sideways-rematerialised strands are in result')

  -- Ordered incidence remains ordered: quotient propagation is coordinatewise.
  local c=W.builder(); local cr=c:membrane(nil,'CR'); local cc=c:membrane(cr,'CC')
  local q=c:point(cc,'q'); local r=c:point(cc,'r'); local so=c:strand(cc,{q,r},'qr'); local C=c:finish()
  local d=W.builder(); local dr=d:membrane(nil,'DR'); local dc=d:membrane(dr,'DC')
  local u=d:point(dc,'u'); local v=d:point(dc,'v'); local ti=d:strand(dc,{v,u},'vu'); local D=d:finish()
  local _,himg=W.join({C,D},{{from=so,to=ti}})
  eq(himg[v],q,'slot 1 maps coordinatewise')
  eq(himg[u],r,'slot 2 maps coordinatewise')
  neq(himg[u],q,'ordered Point incidence is not set-like')
end

print('2. join image as identity transport')
do
  local vb=W.builder(); local vm=vb:membrane(nil,'V'); local R=vb:point(vm,'R'); vb:finish()
  local A,ar,ax,ai,ao,af=stage('A',R)
  local B,br,bx,bi,bo,bf=stage('B',R)
  local C,cr,cx,ci,co,cf=stage('C',R)

  local AB,i1=W.join({A,B},{{from=ao,to=bi}})
  eq(i1[ao],ao,'unmodified frame strand remains exact through first transport')
  eq(i1[bi],ao,'closed target maps to source occurrence')
  eq(i1[bx],ax,'local Point identity is transported/identified')
  eq(i1[R],nil,'external unowned carrier is not in image domain')
  local abo=i1[bo]
  local ibf=i1[bf]

  local ABC,i2=W.join({AB,C},{{from=abo,to=ci}})
  eq(i2[i1[bx]],ax,'Point image composes along sequential construction')
  eq(i2[abo],abo,'existing B output becomes frame and survives second join')
  eq(i2[ci],abo,'second target ingress transports to prior exact output')
  eq(i2[ibf],ibf,'already materialised B Face is stable as unaffected frame structure')
  ok(kind(i2[cf])=='face','new C Face has resulting Face image')

  -- A direct three-part join is extensionally/structurally parallel but fresh
  -- non-frame materialisations are not canonical across separate join calls.
  local ABCd,id=W.join({A,B,C},{{from=ao,to=bi},{from=bo,to=ci}})
  eq(id[bx],ax,'direct path identifies B Point to the same exact frame Point')
  eq(id[cx],ax,'direct path identifies C Point transitively to frame Point')
  eq(i2[i1[bx]],id[bx],'persistent exact frame identity agrees across parenthesisations')
  neq(id[bo],abo,'non-frame B output has a fresh representative in an independent direct join')
  neq(id[bf],ibf,'non-frame B Face has a fresh representative in an independent direct join')
  eq(pts(id[bo])[1],R,'direct B output preserves rigid external role')
  eq(pts(abo)[1],R,'staged B output preserves rigid external role')
  eq(pts(id[bo])[2],ax,'direct B output points at exact frame value')
  eq(pts(abo)[2],ax,'staged B output points at exact frame value')
  eq(#ABC:faces(),#ABCd:faces(),'direct and staged constructions have same Face count')

  -- The image is allowed to be many-to-one: causal SCC normalisation maps
  -- several source Faces to one new joint Face.
  local x=W.builder(); local xm=x:membrane(nil,'X'); local xp=x:point(xm,'p')
  local xi=x:strand(xm,{xp},'xi'); local xo=x:strand(xm,{xp},'xo'); local xf=x:face(xm,{xi},{xo},'xf'); local X=x:finish()
  local y=W.builder(); local ym=y:membrane(nil,'Y'); local yp=y:point(ym,'p')
  local yi=y:strand(ym,{yp},'yi'); local yo=y:strand(ym,{yp},'yo'); local yf=y:face(ym,{yi},{yo},'yf'); local Y=y:finish()
  local cyc,cimg=W.join({X,Y},{{from=xo,to=yi},{from=yo,to=xi}})
  eq(cimg[xf],cimg[yf],'two cyclic Faces map to one joint Face')
  eq(#cyc:faces(),1,'SCC quotient has one Face')

  -- advance returns the full join image even though boundary immediately forgets
  -- the closed causal interior.
  local world=W.boundary(A)
  local eqs={{from=ao,to=bi}}
  local nextg,adv=W.advance(world,B,eqs)
  ok(not nextg:owns_face(adv[bf]),'advance image Face is provenance into forgotten joined interior')
  ok(nextg:owns_strand(adv[bo]),'advance image egress survives literally into next boundary')
end

print('3. frame/template polarity')
do
  local A,ar,ax,ai,ao,af=stage('FA',nil)
  local B,br,bx,bi,bo,bf=stage('FB',nil)

  -- Empty composition is already asymmetric in exact identity.
  local AB,iab=W.join({A,B},{})
  eq(iab[ar],ar,'first-part membrane survives empty join literally')
  eq(iab[ax],ax,'first-part Point survives empty join literally')
  eq(iab[ao],ao,'first-part Strand survives empty join literally')
  eq(iab[af],af,'first-part Face survives empty join literally')
  neq(iab[br],br,'later-part membrane is materialised')
  neq(iab[bx],bx,'later-part Point is materialised')
  neq(iab[bo],bo,'later-part Strand is materialised')
  neq(iab[bf],bf,'later-part Face is materialised')

  local BA,iba=W.join({B,A},{})
  eq(iba[br],br,'reversing parts makes B the exact frame')
  eq(iba[bf],bf,'B Face survives when B is frame')
  neq(iba[ar],ar,'A is now materialised instead')
  neq(iba[af],af,'A Face is now materialised instead')
  eq(#AB:faces(),#BA:faces(),'empty joins differ in representatives, not structural cardinality')

  -- Direction of the equation and choice of frame are independent.  The exact
  -- representative of the glued occurrence flips with frame order.
  local J1,j1=W.join({A,B},{{from=ao,to=bi}})
  local J2,j2=W.join({B,A},{{from=ao,to=bi}})
  eq(j1[ao],ao,'A-frame composition retains exact source occurrence')
  eq(j1[bi],ao,'A-frame target ingress maps to exact source occurrence')
  eq(j2[bi],bi,'B-frame composition retains exact target occurrence')
  eq(j2[ao],bi,'B-frame source egress maps to exact target occurrence')
  neq(j1[ao],j2[ao],'same directed gluing can choose different exact quotient representatives')
  eq(#J1:faces(),#J2:faces(),'frame selection does not change causal Face count here')
  eq(#J1:strands(),#J2:strands(),'frame selection does not change Strand count here')

  -- A development is genuinely reusable as a presentation because its exact
  -- carriers are never imported into the evolving world when it is non-frame.
  local vb=W.builder(); local vm=vb:membrane(nil,'roles'); local R=vb:point(vm,'R'); vb:finish()
  local D,dr,dx,di,do_,df=stage('D',R)
  local wb=W.builder(); local wr=wb:membrane(nil,'W'); local wx=wb:point(wr,'value'); local ws=wb:strand(wr,{R,wx},'live'); local W0=wb:finish()

  local W1,m1=W.advance(W0,D,{{from=ws,to=di}})
  local out1=m1[do_]; local face1=m1[df]
  neq(out1,do_,'first application materialises fresh output occurrence')
  neq(face1,df,'first application materialises fresh Face')
  ok(W1:owns_strand(out1),'first fresh output is live')
  ok(not W1:owns_face(face1),'boundary has forgotten first Face')

  local W2,m2=W.advance(W1,D,{{from=out1,to=di}})
  local out2=m2[do_]; local face2=m2[df]
  neq(out2,do_,'second application still does not consume template identity')
  neq(out2,out1,'reusing same exact Development creates a distinct output occurrence')
  neq(face2,df,'second application materialises rather than importing template Face')
  neq(face2,face1,'separate applications create distinct Face identities')
  ok(W2:owns_strand(out2),'second fresh output is live')
  eq(pts(out2)[1],R,'rigid external Point passes through repeated instantiation literally')
  eq(pts(out2)[2],wx,'local template Point repeatedly binds to same persistent world Point')
  ok(D:owns_face(df) and D:owns_strand(do_),'original presentation remains intact and reusable')
end


print('2b. image coverage and incidence compatibility')
do
  local vb=W.builder(); local vm=vb:membrane(nil,'V2'); local R=vb:point(vm,'R2'); vb:finish()
  local A,ar,ax,ai,ao,af=stage('IA',R)
  local B,br,bx,bi,bo,bf=stage('IB',R)
  local G,img=W.join({A,B},{{from=ao,to=bi}})
  local seen={}
  for _,part in ipairs({A,B}) do
    for _,m in ipairs(part:membranes()) do if img[m] then seen[img[m]]=true; eq(kind(img[m]),'membrane','membrane image preserves kind') end end
    for _,p in ipairs(part:points()) do
      ok(img[p]~=nil,'acyclic Point has image')
      seen[img[p]]=true
      eq(kind(img[p]),'point','Point image preserves kind')
      eq(W.membrane(img[p]),img[W.membrane(p)],'Point placement commutes with image')
    end
    for _,s in ipairs(part:strands()) do
      ok(img[s]~=nil,'acyclic Strand has image')
      seen[img[s]]=true
      eq(kind(img[s]),'strand','Strand image preserves kind')
      eq(W.membrane(img[s]),img[W.membrane(s)],'Strand placement commutes with image')
      local before,after=pts(s),pts(img[s]); eq(#before,#after,'Strand arity preserved')
      for i=1,#before do eq(after[i],img[before[i]] or before[i],'Point incidence commutes with image') end
    end
    for _,f in ipairs(part:faces()) do
      ok(img[f]~=nil,'acyclic Face has image')
      seen[img[f]]=true
      eq(kind(img[f]),'face','Face image preserves kind')
      eq(W.membrane(img[f]),img[W.membrane(f)],'acyclic Face placement commutes with image')
    end
  end
  for _,m in ipairs(G:membranes()) do ok(seen[m],'every resulting membrane is hit by some input image') end
  for _,p in ipairs(G:points()) do ok(seen[p],'every resulting Point is hit by some input image') end
  for _,s in ipairs(G:strands()) do ok(seen[s],'every resulting Strand is hit by some input image') end
  for _,f in ipairs(G:faces()) do ok(seen[f],'every resulting Face is hit by some input image') end

  -- In a causal SCC, internal Strand classes are not transported to surviving
  -- Strand carriers at all; only the contracted joint Face survives them.
  local x=W.builder(); local xm=x:membrane(nil,'CX'); local xp=x:point(xm,'p')
  local xi=x:strand(xm,{xp},'xi'); local xo=x:strand(xm,{xp},'xo'); local xf=x:face(xm,{xi},{xo},'xf'); local X=x:finish()
  local y=W.builder(); local ym=y:membrane(nil,'CY'); local yp=y:point(ym,'p')
  local yi=y:strand(ym,{yp},'yi'); local yo=y:strand(ym,{yp},'yo'); local yf=y:face(ym,{yi},{yo},'yf'); local Y=y:finish()
  local _,cimg=W.join({X,Y},{{from=xo,to=yi},{from=yo,to=xi}})
  eq(cimg[xf],cimg[yf],'SCC Faces coalesce')
  eq(cimg[xo],nil,'internal cyclic Strand has no surviving carrier image')
  eq(cimg[yi],nil,'its identified target also has no surviving carrier image')
  eq(cimg[yo],nil,'second internal cyclic Strand has no surviving carrier image')
  eq(cimg[xi],nil,'second identified target has no surviving carrier image')
end

print('3b. frame preservation is maximal, not absolute')
do
  -- One frame contains two distinct Points and three open Strands. Closing two
  -- frame Strands can force the Points equal, so a third frame Strand carrying
  -- the losing Point can no longer survive literally.
  local b=W.builder(); local m=b:membrane(nil,'F')
  local p=b:point(m,'p'); local q=b:point(m,'q')
  local sp=b:strand(m,{p},'sp'); local sq=b:strand(m,{q},'sq'); local witness=b:strand(m,{q},'witness')
  local F=b:finish()
  local G,img=W.join({F},{{from=sp,to=sq}})
  eq(img[p],p,'first frame Point chosen as exact representative')
  eq(img[q],p,'second frame Point collapses to first under same-frame closure')
  eq(img[sp],sp,'representative frame Strand survives')
  eq(img[sq],sp,'closed frame target maps to representative Strand')
  neq(img[witness],witness,'affected frame Strand is rematerialised when its Point changes')
  eq(pts(img[witness])[1],p,'rematerialised frame Strand carries quotient Point')
  ok(G:owns_strand(img[witness]),'rematerialised carrier belongs to result')
  ok(not G:owns_strand(witness),'old affected exact frame Strand is not part of result')
end

print('PASS '..n..' assertions')
