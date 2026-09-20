-- Deep latent-structure experiments for Worlds 0.6.2.
--
-- Targets:
--   A. Point/Strand locality support and endpoint-thread structure.
--   B. Structural Strand shape + exact scarce occurrence fibres.
--   C. Owned/local vs imported/rigid Point identity and freshness.
--
-- These experiments intentionally use the public Worlds and Question APIs only.

package.path='./src/?.lua;./src/?/init.lua;'..package.path

local W = require('worlds')
local Query = require('worlds.query')

local assertions = 0
local function ok(x,msg) assertions=assertions+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) assertions=assertions+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function decide(question)
  local s=Query.solve(question)
  while true do
    local k,v=s:step(math.huge)
    if k~='more' then return k,v end
  end
end

local function seeded_match(world,dev,pairs,sources,targets)
  return decide(Query.match(world,dev,{
    sources=sources,
    targets=targets,
    required_targets=targets,
    seeds=pairs or {},
  }))
end

local function count_solutions(question)
  local s=Query.solve(question)
  local hits=0
  while true do
    local k,v=s:step(math.huge)
    if k=='yes' then hits=hits+1
    elseif k=='done' then return hits,'done'
    elseif k=='no' then return hits,'no',v
    end
  end
end

local function array_set(xs)
  local s={}; for _,x in ipairs(xs) do s[x]=true end; return s
end

local function fibre_count(g)
  local groups={}
  for _,s in ipairs(g:egress()) do
    local ps=W.points(s)
    local key={W.membrane(s)}
    for _,p in ipairs(ps) do key[#key+1]=p end
    -- Tables cannot key structurally, so find a matching existing group.
    local found
    for _,q in ipairs(groups) do
      if #q.key==#key then
        local same=true; for i=1,#key do if q.key[i]~=key[i] then same=false; break end end
        if same then found=q; break end
      end
    end
    if not found then found={key=key,members={}}; groups[#groups+1]=found end
    found.members[#found.members+1]=s
  end
  return groups
end

-- ============================================================================
-- A. LOCALITY SUPPORT / ENDPOINT THREADS
-- ============================================================================

-- A1. boundary is exactly the owned support hull needed by live egress:
-- Strand locality + owned Point localities + their owned ancestry. Unrelated
-- owned locality and Points disappear.
do
  local b=W.builder()
  local r=b:membrane(nil,'R')
  local a=b:membrane(r,'A'); local a1=b:membrane(a,'A1')
  local bb=b:membrane(r,'B')
  local junk=b:membrane(r,'JUNK')
  local p=b:point(a1,'p'); local q=b:point(bb,'q'); b:point(junk,'unused')
  local s=b:strand(r,{p,q},'live')
  local g=b:finish(); local live=W.boundary(g)
  local ms=array_set(live:membranes())
  eq(#live:membranes(),4,'boundary keeps minimal owned support ancestry')
  ok(ms[r] and ms[a] and ms[a1] and ms[bb],'required support ancestry survives')
  ok(not ms[junk],'unrelated owned locality is dropped')
  eq(#live:points(),2,'only live owned endpoint Points survive')
  eq(live:egress()[1],s,'live exact occurrence survives literally')
end

-- A2. Matching does not require support-tree isomorphism. It behaves like a
-- non-injective parent-preserving map: distinct target siblings may collapse,
-- asserted equality cannot split, and parent/child depth cannot collapse.
local SHAPES={
  root_same={'R','R'},
  child_same={'A','A'},
  siblings={'A','B'},
  chain={'A','A1'},
  cousins={'A1','B1'},
  deep_same={'A1','A1'},
  deep_siblings={'A1','A2'},
}
local SHAPE_ORDER={'root_same','child_same','siblings','chain','cousins','deep_same','deep_siblings'}
local function shaped_geometry(shape)
  local b=W.builder(); local M={}
  M.R=b:membrane(nil,'R'); M.A=b:membrane(M.R,'A'); M.B=b:membrane(M.R,'B')
  M.A1=b:membrane(M.A,'A1'); M.A2=b:membrane(M.A,'A2'); M.B1=b:membrane(M.B,'B1')
  local p=b:point(M[SHAPES[shape][1]],'p'); local q=b:point(M[SHAPES[shape][2]],'q')
  local s=b:strand(M.R,{p,q},shape)
  return b:finish(),s,M,p,q
end

local EXPECT={
  root_same={root_same=true},
  child_same={child_same=true},
  siblings={child_same=true,siblings=true},
  chain={chain=true},
  cousins={cousins=true,deep_same=true,deep_siblings=true},
  deep_same={deep_same=true},
  deep_siblings={deep_same=true,deep_siblings=true},
}

local locality_matrix={}
for _,t in ipairs(SHAPE_ORDER) do
  locality_matrix[t]={}
  for _,sname in ipairs(SHAPE_ORDER) do
    local wg,ws=shaped_geometry(sname); local dg,ds=shaped_geometry(t)
    local k=seeded_match(wg,dg,{{from=ws,to=ds}},{ws},{ds})
    locality_matrix[t][sname]=(k=='yes')
    eq(locality_matrix[t][sname],not not EXPECT[t][sname],'locality specialisation matrix mismatch '..t..' <- '..sname)
  end
end

-- Explicitly inspect the characteristic quotient: sibling target membrane
-- variables both identify with the same source child.
do
  local world,src,SM=shaped_geometry('child_same')
  local dev,tgt,TM=shaped_geometry('siblings')
  local k,e=seeded_match(world,dev,{{from=src,to=tgt}},{src},{tgt}); eq(k,'yes')
  local joined,img=W.join({world,dev},e)
  eq(img[TM.A],SM.A,'first target sibling maps to source child')
  eq(img[TM.B],SM.A,'second target sibling may collapse to same source child')
  eq(img[TM.R],SM.R,'target support root maps to source support root')
  ok(joined:owns_membrane(SM.A),'collapsed source locality remains exact frame identity')
end

-- Reverse direction fails: an asserted same-locality relation cannot split.
do
  local world,src=shaped_geometry('siblings')
  local dev,tgt=shaped_geometry('child_same')
  local k=seeded_match(world,dev,{{from=src,to=tgt}},{src},{tgt})
  eq(k,'no','one target locality cannot map to two source siblings')
end

-- A3. A locality constraint can couple separate scarce demands. Same target
-- membrane means the chosen sources must come from one structural locality row;
-- sibling target membranes are independent variables and may collapse or differ.
do
  local vb=W.builder(); local vm=vb:membrane(nil,'V'); local P=vb:point(vm,'P'); vb:finish()
  local wb=W.builder(); local r=wb:membrane(nil,'R'); local a=wb:membrane(r,'A'); local b=wb:membrane(r,'B')
  local src={wb:strand(a,{P},'a1'),wb:strand(a,{P},'a2'),wb:strand(b,{P},'b1'),wb:strand(b,{P},'b2')}; local world=wb:finish()
  local function demand(shared)
    local d=W.builder(); local rr=d:membrane(nil,'T'); local m1,m2
    if shared then m1,m2=rr,rr else m1=d:membrane(rr,'X'); m2=d:membrane(rr,'Y') end
    local t1=d:strand(m1,{P},'t1'); local t2=d:strand(m2,{P},'t2')
    return d:finish(),t1,t2
  end
  local g1=select(1,demand(true)); local t1,t2=select(2,demand(true)) -- not used; rebuilt below for clarity
  local dg,a1,a2=demand(true); local n1=count_solutions(Query.match(world,dg,{})); eq(n1,4,'same target locality permits 2P2 inside either source row only')
  local dg2,b1,b2=demand(false); local n2=count_solutions(Query.match(world,dg2,{})); eq(n2,12,'independent sibling target localities permit all 4P2 exact allocations')
end

-- ============================================================================
-- B. STRUCTURAL SHAPE + EXACT OCCURRENCE FIBRES
-- ============================================================================

-- B1. For n exact source occurrences in one structural row and k exact demands,
-- the solution count is the falling factorial n!/(n-k)!: scarcity is allocation
-- over the exact fibre, not structural ambiguity.
do
  local vb=W.builder(); local vm=vb:membrane(nil,'V'); local P=vb:point(vm,'P'); vb:finish()
  local function world(n)
    local b=W.builder(); local m=b:membrane(nil,'M')
    for i=1,n do b:strand(m,{P},'s'..i) end
    return b:finish()
  end
  local function target(k)
    local b=W.builder(); local m=b:membrane(nil,'T')
    for i=1,k do b:strand(m,{P},'t'..i) end
    return b:finish()
  end
  local expected={[1]=4,[2]=12,[3]=24,[4]=24,[5]=0}
  for k=1,5 do
    local n,terminal=count_solutions(Query.match(world(4),target(k),{}))
    eq(n,expected[k],'4-source fibre allocation count k='..k)
    if k<=4 then eq(terminal,'done') else eq(terminal,'no') end
  end
end

-- B2. Fibre occupancy is dynamic, not conserved. An explicit Face can copy one
-- scarce occurrence to two same-shape exact occurrences, then another Face can
-- merge two back to one.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'W'); local p=wb:point(wm,'p'); local s=wb:strand(wm,{p},'s'); local world=wb:finish()
  local c=W.builder(); local cm=c:membrane(nil,'C'); local X=c:point(cm,'X'); local ci=c:strand(cm,{X},'ci'); local co1=c:strand(cm,{X},'co1'); local co2=c:strand(cm,{X},'co2'); c:face(cm,{ci},{co1,co2},'copy'); local copy=c:finish()
  local k,e=seeded_match(world,copy,{{from=s,to=ci}},{s},{ci}); eq(k,'yes'); local two,img=W.advance(world,copy,e)
  local groups=fibre_count(two); eq(#groups,1); eq(#groups[1].members,2,'copy increases exact fibre occupancy')

  local m=W.builder(); local mm=m:membrane(nil,'M'); local Y=m:point(mm,'Y'); local mi1=m:strand(mm,{Y},'mi1'); local mi2=m:strand(mm,{Y},'mi2'); local mo=m:strand(mm,{Y},'mo'); m:face(mm,{mi1,mi2},{mo},'merge'); local merge=m:finish()
  local live=two; local ss=live:egress(); local k2,e2=seeded_match(live,merge,{{from=ss[1],to=mi1},{from=ss[2],to=mi2}},ss,{mi1,mi2}); eq(k2,'yes'); local one=W.advance(live,merge,e2)
  local gs=fibre_count(one); eq(#gs,1); eq(#gs[1].members,1,'merge decreases exact fibre occupancy')
end

-- B3. The structural quotient cannot replace exact fibre identity. Consuming s1
-- versus s2 from the same row leaves a different exact frame occurrence live.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'W'); local p=wb:point(wm,'p'); local s1=wb:strand(wm,{p},'s1'); local s2=wb:strand(wm,{p},'s2'); local world=wb:finish()
  local d=W.builder(); local dm=d:membrane(nil,'D'); local X=d:point(dm,'X'); local i=d:strand(dm,{X},'i'); local o=d:strand(dm,{X},'o'); d:face(dm,{i},{o},'touch'); local dev=d:finish()
  local function run(chosen)
    local k,e=seeded_match(world,dev,{{from=chosen,to=i}},{s1,s2},{i}); eq(k,'yes')
    local live,img=W.advance(world,dev,e); return live,img[o]
  end
  local l1,o1=run(s1); local l2,o2=run(s2)
  ok(l1:owns_strand(s2) and not l1:owns_strand(s1),'consuming s1 leaves exact sibling s2')
  ok(l2:owns_strand(s1) and not l2:owns_strand(s2),'consuming s2 leaves exact sibling s1')
  ok(o1~=o2,'template output materialises freshly in independent joins')
end

-- ============================================================================
-- C. RANDOM THIRD TARGET: OWNED/LOCAL VS IMPORTED/RIGID POINTS
-- ============================================================================

-- C1. A Geometry may carry a rigid exact Point which it does not own, and need
-- not own that Point's membrane ancestry. Exact reference is therefore distinct
-- from local support ownership.
local VR,VA,P,Q,VOCAB
do
  local v=W.builder(); VR=v:membrane(nil,'VR'); VA=v:membrane(VR,'VA'); P=v:point(VA,'P'); Q=v:point(VA,'Q'); VOCAB=v:finish()
  local b=W.builder(); local lr=b:membrane(nil,'LR'); local s=b:strand(lr,{P},'ref-P'); local g=b:finish(); local live=W.boundary(g)
  ok(not live:owns_point(P),'imported rigid Point is not owned')
  ok(not live:owns_membrane(VA),'foreign Point ancestry is not adopted merely by reference')
  eq(W.points(s)[1],P,'exact rigid identity remains incident')
  eq(W.membrane(P),VA,'rigid Point retains its ambient exact locality')
end

-- C2. A local Point behaves as a unification variable constrained by its local
-- membrane skeleton. Matching it to an exact source Point transports both the
-- Point and the local membrane ancestry.
do
  local wb=W.builder(); local wr=wb:membrane(nil,'WR'); local wc=wb:membrane(wr,'WC'); local sp=wb:point(wc,'sp'); local ss=wb:strand(wr,{sp},'s'); local world=wb:finish()
  local d=W.builder(); local dr=d:membrane(nil,'DR'); local dc=d:membrane(dr,'DC'); local X=d:point(dc,'X'); local ti=d:strand(dr,{X},'ti'); local to=d:strand(dc,{X},'to'); d:face(dr,{ti},{to},'use'); local dev=d:finish()
  local k,e=seeded_match(world,dev,{{from=ss,to=ti}},{ss},{ti}); eq(k,'yes'); local joined,img=W.join({world,dev},e)
  eq(img[X],sp,'local Point variable binds to exact source Point')
  eq(img[dr],wr,'local root binds to source occurrence locality')
  eq(img[dc],wc,'local child support binds with Point home locality')
  eq(W.membrane(img[to]),wc,'downstream occurrence inherits instantiated locality')

  -- Move the local variable to the target root: now the source child Point is
  -- structurally incompatible even though arity and causal shape are identical.
  local d2=W.builder(); local rr=d2:membrane(nil,'RR'); local Y=d2:point(rr,'Y'); local ii=d2:strand(rr,{Y},'ii'); local oo=d2:strand(rr,{Y},'oo'); d2:face(rr,{ii},{oo}); local dev2=d2:finish()
  local k2=seeded_match(world,dev2,{{from=ss,to=ii}},{ss},{ii}); eq(k2,'no','local binding remains dependent on locality shape')
end

-- C3. Imported rigid identity is deliberately different: it constrains identity
-- but does not demand that the template reproduce the rigid Point's home
-- locality. A rigid parameter can therefore be mentioned cross-locally.
do
  local wb=W.builder(); local wr=wb:membrane(nil,'W'); local s=wb:strand(wr,{P},'p-source'); local world=wb:finish()
  local d=W.builder(); local tr=d:membrane(nil,'T'); local i=d:strand(tr,{P},'rigid-in'); local o=d:strand(tr,{P},'rigid-out'); d:face(tr,{i},{o}); local dev=d:finish()
  local k,e=seeded_match(world,dev,{{from=s,to=i}},{s},{i}); eq(k,'yes'); local joined,img=W.join({world,dev},e)
  eq(img[tr],wr,'template occurrence locality follows source occurrence')
  eq(W.points(img[o])[1],P,'rigid Point is preserved literally')
  eq(W.membrane(P),VA,'rigid Point keeps foreign home locality')
  eq(W.membrane(img[o]),wr,'occurrence locality remains distinct from rigid Point home')
end

-- C4. Equality without disequality: one local Point shared across demands forces
-- one exact source identity; two distinct local Point variables may collapse to
-- the same exact Point when separate scarce occurrences support them.
do
  local wb=W.builder(); local m=wb:membrane(nil,'M'); local p=wb:point(m,'p'); local q=wb:point(m,'q'); local sp=wb:strand(m,{p},'sp'); local sq=wb:strand(m,{q},'sq'); local world=wb:finish()
  local d=W.builder(); local dm=d:membrane(nil,'D'); local X=d:point(dm,'X'); local a=d:strand(dm,{X},'a'); local b=d:strand(dm,{X},'b'); local shared=d:finish()
  local k=seeded_match(world,shared,{{from=sp,to=a},{from=sq,to=b}},{sp,sq},{a,b}); eq(k,'no','shared local variable enforces exact equality across demands')

  local wb2=W.builder(); local m2=wb2:membrane(nil,'M2'); local r=wb2:point(m2,'r'); local r1=wb2:strand(m2,{r},'r1'); local r2=wb2:strand(m2,{r},'r2'); local world2=wb2:finish()
  local d2=W.builder(); local n=d2:membrane(nil,'N'); local A=d2:point(n,'A'); local B=d2:point(n,'B'); local x=d2:strand(n,{A},'x'); local y=d2:strand(n,{B},'y'); local distinct=d2:finish()
  local k2=seeded_match(world2,distinct,{{from=r1,to=x},{from=r2,to=y}},{r1,r2},{x,y}); eq(k2,'yes','distinct local variables carry no implicit disequality')
end

-- C5. Freshness lifecycle: an unbound local Point in a reusable Development is a
-- generator, not a constant. Each materialisation creates a distinct exact Point;
-- once created, that identity can be imported rigidly in a later Development.
do
  local wb=W.builder(); local wr=wb:membrane(nil,'W'); local ctl=wb:strand(wr,{},'ctl'); local world=wb:finish()
  local d=W.builder(); local dr=d:membrane(nil,'D'); local dc=d:membrane(dr,'fresh'); local i=d:strand(dr,{},'i'); local Y=d:point(dc,'Y'); local o=d:strand(dr,{Y},'o'); d:face(dr,{i},{o},'new'); local dev=d:finish()
  local k,e=seeded_match(world,dev,{{from=ctl,to=i}},{ctl},{i}); eq(k,'yes')
  local g1,img1=W.join({world,dev},e); local y1=img1[Y]; local out1=img1[o]
  local g2,img2=W.join({world,dev},e); local y2=img2[Y]; local out2=img2[o]
  ok(y1~=Y and y2~=Y,'template-local Point does not survive as its template identity')
  ok(y1~=y2,'reusing one Development materialises genuinely fresh exact Points')
  ok(g1:owns_point(y1) and g2:owns_point(y2),'fresh exact Points become owned Geometry')

  local later=W.builder(); local lm=later:membrane(nil,'L'); local li=later:strand(lm,{y1},'li'); local lo=later:strand(lm,{y1},'lo'); later:face(lm,{li},{lo},'use exact'); local use=later:finish()
  local live1=W.boundary(g1); local k1=seeded_match(live1,use,{{from=out1,to=li}},{out1},{li}); eq(k1,'yes','fresh name can later be imported rigidly')
  local live2=W.boundary(g2); local k3=seeded_match(live2,use,{{from=out2,to=li}},{out2},{li}); eq(k3,'no','different fresh materialisation does not satisfy rigid identity')
end

print('deep structure experiments: '..assertions..' assertions passed')
print('locality matrix (target rows, source columns):')
io.write(string.format('%-15s','target\\source'))
for _,s in ipairs(SHAPE_ORDER) do io.write(string.format('%-15s',s)) end
io.write('\n')
for _,t in ipairs(SHAPE_ORDER) do
  io.write(string.format('%-15s',t))
  for _,s in ipairs(SHAPE_ORDER) do io.write(string.format('%-15s',locality_matrix[t][s] and 'yes' or '.')) end
  io.write('\n')
end
