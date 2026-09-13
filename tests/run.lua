package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local n=0; local function ok(x,m) n=n+1; assert(x,m) end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function decided(q,budget) while true do local k,x=q:step(budget or math.huge); if k~='more' then return k,x end end end

local function token_world(count)
  local b=W.builder(); local m=b:membrane(nil,'root'); local p=b:point(m,'p'); local s={}; for i=1,count do s[i]=b:strand(m,{p},'s'..i) end; return b:finish(),s,p,m
end
local function pattern(count,faceit)
  local b=W.builder(); local m=b:membrane(nil,'p'); local x=b:point(m,'x'); local d={}; for i=1,count do d[i]=b:strand(m,{x},'d'..i) end; local out
  if faceit then out=b:strand(m,{x},'out'); b:face(m,d,{out},'act') end
  return b:finish(),d,out,x,m
end

-- solve returns equations, and join alone performs the development.
do
  local world,ss=token_world(1); local pat,d,out=pattern(1,true); local q=W.solve(world,pat); local k,es=decided(q,10); eq(k,'yes')
  eq(es[1].from,ss[1]); eq(es[1].to,d[1])
  local nextg,img=W.join({world,pat},es); eq(#nextg:egress(),1); eq(img[ss[1]],ss[1],'consumed frame occurrence remains exact in history'); ok(img[out]~=out,'template output is fresh'); eq(nextg:producer(img[ss[1]]),nil) -- original world token had no producer
  ok(nextg:consumer(img[ss[1]])~=nil,'joined exact authority is now consumed')
end

-- Pure scarcity is constructive and branch free.
do
  local world=token_world(9); local pat=pattern(10,false); local q=W.solve(world,pat); local k,no=decided(q,1); eq(k,'no'); ok(Query.is_refutation(no)); eq(no:reason().kind,'fibre-capacity')
end

-- Exact seed equations are the same thing eventually returned by solve.
do
  local world,ss=token_world(4); local pat,d=pattern(4,false); local seeds={}; for i=1,4 do seeds[i]={from=ss[i],to=d[i]} end
  local q=W.solve(world,pat,seeds); local k,es=decided(q,10); eq(k,'yes'); for i=1,4 do local found=false; for _,e in ipairs(es) do if e.from==ss[i] and e.to==d[i] then found=true end end; ok(found) end
end

-- Causal provenance is a Geometry law: a dangling open identity cannot be used
-- by a Face to mutate an already-present child it did not consume.
do
  local v=W.builder(); local vm=v:membrane(nil,'v'); local Control=v:point(vm,'Control'); v:finish()
  local good=W.builder(); local pr=good:membrane(nil,'pr'); local pc=good:membrane(pr,'pc'); local x=good:point(pc,'x'); local ci=good:strand(pr,{x}); local co=good:strand(pr,{x}); local st=good:strand(pc,{x}); good:face(pr,{ci},{co,st}); ok(good:finish())
  local bad=W.builder(); local br=bad:membrane(nil,'br'); local bc=bad:membrane(br,'bc'); local y=bad:point(bc,'y'); local ctl=bad:strand(br,{Control}); local dangling=bad:strand(br,{y}); local out=bad:strand(bc,{y}); bad:face(br,{ctl},{out})
  local yes=pcall(function() bad:finish() end); ok(not yes,'invalid authority geometry rejected at construction')
end

-- Exact rigid identity alone does not select fresh locality.
do
  local vb=W.builder(); local vm=vb:membrane(nil,'v'); local Control=vb:point(vm,'Control'); vb:finish()
  local wb=W.builder(); local root=wb:membrane(nil,'root'); local child=wb:membrane(root,'child'); local cid=wb:point(child,'cid'); local ctl=wb:strand(root,{Control}); local world=wb:finish()
  local p=W.builder(); local pr=p:membrane(nil,'pr'); local pc=p:membrane(pr,'pc'); local ci=p:strand(pr,{Control}); local co=p:strand(pr,{Control}); local o=p:strand(pc,{cid}); p:face(pr,{ci},{co,o}); local pat=p:finish()
  local q=W.solve(world,pat,{{from=ctl,to=ci}}); local k,es=decided(q,10); eq(k,'yes'); local g,img=W.join({world,pat},es); ok(img[pc]~=child,'rigid Point identity does not equate locality'); eq(W.points(img[o])[1],cid)
end

-- A genuine causal handle does induce locality by incidence equality.
do
  local wb=W.builder(); local root=wb:membrane(nil,'root'); local child=wb:membrane(root,'child'); local cid=wb:point(child,'cid'); local h=wb:strand(root,{cid}); local world=wb:finish()
  local p=W.builder(); local pr=p:membrane(nil,'pr'); local pc=p:membrane(pr,'pc'); local x=p:point(pc,'x'); local i=p:strand(pr,{x}); local o=p:strand(pc,{x}); p:face(pr,{i},{o}); local pat=p:finish()
  local q=W.solve(world,pat,{{from=h,to=i}}); local k,es=decided(q,10); eq(k,'yes'); local g,img=W.join({world,pat},es); eq(img[pc],child); eq(img[x],cid); eq(W.membrane(img[o]),child)
end

-- Cyclic causality is equality forced by mutual reachability.
do
  local a=W.builder(); local am=a:membrane(nil); local ap=a:point(am); local ai=a:strand(am,{ap}); local ao=a:strand(am,{ap}); a:face(am,{ai},{ao}); a=a:finish()
  local b=W.builder(); local bm=b:membrane(nil); local bp=b:point(bm); local bi=b:strand(bm,{bp}); local bo=b:strand(bm,{bp}); b:face(bm,{bi},{bo}); b=b:finish()
  local g=W.join({a,b},{{from=ao,to=bi},{from=bo,to=ai}}); eq(#g:faces(),1); eq(#g:ingress(),0); eq(#g:egress(),0)
end


-- Fresh descendants are construction, not a permission exception.
do
  local vb=W.builder(); local vm=vb:membrane(nil); local Control=vb:point(vm,'Control'); local Value=vb:point(vm,'Value'); vb:finish()
  local wb=W.builder(); local root=wb:membrane(nil,'root'); local ctl=wb:strand(root,{Control}); local world=wb:finish()
  local p=W.builder(); local pr=p:membrane(nil,'pr'); local fresh=p:membrane(pr,'fresh'); local i=p:strand(pr,{Control}); local o=p:strand(pr,{Control}); local x=p:point(fresh,'x'); local value=p:strand(pr,{Value,x}); p:face(fresh,{i},{o,value}); local pat=p:finish()
  local q=W.solve(world,pat,{{from=ctl,to=i}}); local k,es=decided(q,10); eq(k,'yes'); local g,img=W.join({world,pat},es); local fm=img[fresh]; ok(fm~=fresh); eq(W.parent(fm),root); eq(W.membrane(img[x]),fm); eq(#g:egress(),2)
end

-- A development with no open causal past is Geometry, but cannot be solved as
-- an execution; closed geometry remains useful after causal quotienting.
do
  local p=W.builder(); local pm=p:membrane(nil); local o=p:strand(pm,{}); p:face(pm,{}, {o}); local spontaneous=p:finish()
  local world=token_world(0); local okcall=pcall(function() W.solve(world,spontaneous) end); ok(not okcall,'closed/unrooted fragment is not an executable development')
end

-- Frame law follows from join's first-part identity rule, not special commit code.
do
  local vb=W.builder(); local vm=vb:membrane(nil); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); vb:finish()
  local wb=W.builder(); local wm=wb:membrane(nil); local a=wb:strand(wm,{A}); local b=wb:strand(wm,{B}); local world=wb:finish()
  local p=W.builder(); local pm=p:membrane(nil); local ai=p:strand(pm,{A}); local ao=p:strand(pm,{A}); p:face(pm,{ai},{ao}); local pat=p:finish()
  local q=W.solve(world,pat,{{from=a,to=ai}}); local k,es=decided(q,10); eq(k,'yes'); local g,img=W.join({world,pat},es); eq(img[b],b); ok(g:is_terminal(b)); ok(not g:is_terminal(a)); eq(#g:egress(),2)
end


-- Open roots are genuinely open: target root incidence does not assert that the
-- source locality has no parent.
do
  local vb=W.builder(); local vm=vb:membrane(nil); local R=vb:point(vm,'R'); vb:finish()
  local wb=W.builder(); local root=wb:membrane(nil,'root'); local child=wb:membrane(root,'child'); local s=wb:strand(child,{R}); local world=wb:finish()
  local p=W.builder(); local pr=p:membrane(nil,'open-root'); local i=p:strand(pr,{R}); local o=p:strand(pr,{R}); p:face(pr,{i},{o}); local pat=p:finish()
  local q=W.solve(world,pat,{{from=s,to=i}}); local k,es=decided(q,10); eq(k,'yes'); local g,img=W.join({world,pat},es); eq(img[pr],child); eq(W.membrane(img[o]),child)
end

-- A template is reusable: later parts are instantiated fresh on every join,
-- while prior exact history remains the frame.
do
  local world,ss=token_world(1); local pat,d,out=pattern(1,true)
  local q1=W.solve(world,pat,{{from=ss[1],to=d[1]}}); local _,e1=decided(q1,10); local g1,img1=W.join({world,pat},e1); local s1=img1[out]
  local q2=W.solve(g1,pat,{{from=s1,to=d[1]}}); local k2,e2=decided(q2,10); eq(k2,'yes'); local g2,img2=W.join({g1,pat},e2)
  eq(#g2:faces(),2); eq(#g2:egress(),1); ok(img2[out]~=s1); ok(g2:owns_face(g1:faces()[1]),'prior exact history survives literally')
end


-- Feedback/self-closure is ordinary boundary equality inside one Geometry.
do
  local b=W.builder(); local m=b:membrane(nil,'m'); local p=b:point(m,'p')
  local i=b:strand(m,{p},'in'); local o=b:strand(m,{p},'out'); local f=b:face(m,{i},{o},'f'); local g=b:finish()
  local closed,img=W.join({g},{{from=o,to=i}})
  eq(#closed:faces(),1); eq(#closed:ingress(),0); eq(#closed:egress(),0); ok(img[f]~=nil,'joint face image exists')
end


-- Exact seed incidence must match the demand arity exactly.
do
  local wb=W.builder(); local wm=wb:membrane(nil); local a=wb:point(wm); local b=wb:point(wm); local offer=wb:strand(wm,{a,b}); local world=wb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil); local demand=pb:strand(pm,{a}); local pat=pb:finish()
  local q=W.solve(world,pat,{{from=offer,to=demand}}); local k,no=decided(q,10); eq(k,'no'); ok(Query.is_refutation(no)); eq(no:reason().kind,'empty-base-relation')
end


-- The operational projection is the exact open boundary, not a copy of its
-- authority.  It is object-idempotent once a Geometry is boundary-normal.
do
  local world,ss,p,m=token_world(3)
  local live=W.boundary(world)
  eq(W.boundary(world),live,'immutable Geometry memoises its operational projection')
  eq(W.boundary(live),live,'boundary is an object-level fixed point')
  eq(#live:faces(),0); eq(#live:strands(),3); eq(#live:egress(),3); eq(#live:ingress(),3)
  for i=1,3 do eq(live:egress()[i],ss[i]); ok(live:owns_strand(ss[i])); eq(live:producer(ss[i]),nil); eq(live:consumer(ss[i]),nil) end
  ok(live:owns_point(p)); ok(live:owns_membrane(m))
end

-- Closed causal history disappears completely when it has no live surface.
do
  local b=W.builder(); local m=b:membrane(nil); local i=b:strand(m,{}); local o=b:strand(m,{}); b:face(m,{i},{o}); local g=b:finish()
  local closed=W.join({g},{{from=o,to=i}})
  local live=W.boundary(closed)
  eq(#live:faces(),0); eq(#live:strands(),0); eq(#live:points(),0); eq(#live:membranes(),0)
end

-- solve depends only on the world's open boundary. Historical producer/Face
-- structure cannot change the exact boundary equations returned.
do
  local world,ss=token_world(1); local pat,d,out=pattern(1,true)
  local _,e1=decided(W.solve(world,pat,{{from=ss[1],to=d[1]}}),10)
  local historical,img=W.join({world,pat},e1); local live=W.boundary(historical); local next_token=img[out]
  local pat2,d2=pattern(1,false)
  local kh,eh=decided(W.solve(historical,pat2,{{from=next_token,to=d2[1]}}),10)
  local kl,el=decided(W.solve(live,pat2,{{from=next_token,to=d2[1]}}),10)
  eq(kh,'yes'); eq(kl,'yes'); eq(eh[1].from,el[1].from); eq(eh[1].to,el[1].to)
end

-- Without an optional History observer, closed causal events are not retained by
-- the live boundary and may be collected.
do
  local world,ss=token_world(1); world=W.boundary(world); local pat,d,out=pattern(1,true)
  local _,es=decided(W.solve(world,pat,{{from=ss[1],to=d[1]}}),10)
  local joined,img=W.join({world,pat},es); local live=W.boundary(joined)
  local f=pat:faces()[1]; local historical_face=img[f]; local weak=setmetatable({historical_face},{__mode='v'})
  historical_face=nil; img=nil; joined=nil; es=nil
  collectgarbage(); collectgarbage(); collectgarbage()
  eq(weak[1],nil,'closed Face is collectible once only the live boundary remains')
  eq(#live:faces(),0)
end

-- solve retains only the world egress section, so a retained solve calculation
-- cannot keep closed historical Faces alive.
do
  local world,ss=token_world(1); local pat,d,out=pattern(1,true)
  local _,es=decided(W.solve(world,pat,{{from=ss[1],to=d[1]}}),10)
  local historical,img=W.join({world,pat},es); local token=img[out]; local historical_face=img[pat:faces()[1]]
  local probe,di=pattern(1,false); local q=W.solve(historical,probe,{{from=token,to=di[1]}})
  local weak=setmetatable({historical_face},{__mode='v'})
  historical_face=nil; historical=nil; img=nil; es=nil
  collectgarbage(); collectgarbage(); collectgarbage()
  eq(weak[1],nil,'retained solve state contains only the live boundary world')
  local k=decided(q,10); eq(k,'yes')
end

-- Projecting history before the next join commutes with projecting afterwards,
-- modulo the necessarily fresh identity of newly instantiated template carriers.
do
  local world,ss=token_world(2); local step,d,out=pattern(1,true)
  local _,e1=decided(W.solve(world,step,{{from=ss[1],to=d[1]}}),10)
  local hist1,img1=W.join({world,step},e1); local live1=W.boundary(hist1); local current=img1[out]
  local _,e2=decided(W.solve(hist1,step,{{from=current,to=d[1]}}),10)

  local full2,imgf=W.join({hist1,step},e2); local bf=W.boundary(full2)
  local live2,imgl=W.join({live1,step},e2); local bl=W.boundary(live2)

  eq(#bf:egress(),#bl:egress()); eq(#bf:faces(),0); eq(#bl:faces(),0)
  ok(bf:owns_strand(ss[2]) and bl:owns_strand(ss[2]),'untouched frame authority commutes exactly')
  local of,ol=imgf[out],imgl[out]; ok(of~=ol,'fresh template instances remain fresh')
  eq(W.membrane(of),W.membrane(ol)); eq(#W.points(of),#W.points(ol))
  for i,p in ipairs(W.points(of)) do eq(p,W.points(ol)[i]) end
end

-- Long-running computation remains proportional to the live frontier.  Each
-- transition creates history transiently, then boundary projection returns to
-- one exact live token with no retained Faces.
do
  local world,ss=token_world(1); world=W.boundary(world); local token=ss[1]
  local pat,d,out=pattern(1,true)
  for _=1,1000 do
    local k,es=decided(W.solve(world,pat,{{from=token,to=d[1]}}),10); eq(k,'yes')
    local img; world,img=W.advance(world,pat,es); token=img[out]
    eq(#world:faces(),0); eq(#world:strands(),1); eq(#world:egress(),1); eq(world:egress()[1],token)
  end
end


-- Builder state is lexical, not mutable public representation.  Application
-- code cannot manufacture membership facts by editing implementation tables.
do
  local b=W.builder(); eq(b.mset,nil,'Builder exposes no membership state')
  ok(not pcall(function() b.mset={} end),'Builder proxy is immutable')
  local m=b:membrane(); local p=b:point(m); b:strand(m,{p}); local g=b:finish()
  ok(g:owns_membrane(m) and g:owns_point(p),'closure Builder still produces verified Geometry')
end

-- Public finite-array inputs reject holes instead of silently truncating at
-- the first nil under ipairs/# semantics.
do
  local b=W.builder(); local m=b:membrane(); local p=b:point(m)
  ok(not pcall(function() b:strand(m,{[2]=p}) end),'sparse Strand incidence must be rejected')
  local s=b:strand(m,{p})
  ok(not pcall(function() b:face(m,{[2]=s},{}) end),'sparse Face incidence must be rejected')
  local g=b:finish()
  ok(not pcall(function() W.join({[2]=g},{}) end),'sparse join parts must be rejected')
  ok(not pcall(function() W.join({g},{[2]={from=s,to=s}}) end),'sparse join equations must be rejected')
  ok(not pcall(function() W.solve(g,g,{[2]={from=s,to=s}}) end),'sparse solve seeds must be rejected')
end

print('PASS 0.6.0',n,'assertions')
