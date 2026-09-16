-- Quantum Worlds: sixth kernel-level exploration against Worlds 0.6.1.
--
-- Experiments:
--  16. Fresh allocator identity as nominal/gauge structure. Alternative opaque
--      fresh names generated from the same semantic binder are alpha variants
--      until a future carries a rigid exact reference. If alpha-renaming is a
--      gauge symmetry, group averaging projects away the antisymmetric naming
--      phase rather than making it a physical qubit.
--  17. Fresh *relations* are different: "two handles share one fresh Point" vs
--      "two handles carry distinct fresh Points" is invariant under renaming and
--      is directly observable by ordinary Worlds exact matching.
--  18. The relation degree is not forced to be superselected by Worlds: ordinary
--      Worlds supports transformations from either relation sector to either new
--      relation sector. A quantum dynamics may therefore put Hadamard amplitudes
--      on the resulting 2x2 support graph and turn relative phase into an
--      observable equality probability.
--  19. The same phenomenon occurs for fresh Membrane topology: co-locality in one
--      fresh child versus separation into two fresh children is invariant under
--      membrane renaming and can be detected by membrane-topology equations in Cut.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S=require('speculation.support')
local W=S.W
local G=S.G
local O=S.O

local EPS=1e-9
local function approx(a,b) return math.abs(a-b)<=EPS end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg)
  assert(approx(a,b),(msg or 'not approx')..': '..tostring(a)..' ~= '..tostring(b))
end
local function C(re,im) return {re or 0,im or 0} end
local function cadd(a,b) return C(a[1]+b[1],a[2]+b[2]) end
local function csub(a,b) return C(a[1]-b[1],a[2]-b[2]) end
local function cscale(r,a) return C(r*a[1],r*a[2]) end
local function cabs2(a) return a[1]*a[1]+a[2]*a[2] end
local INV=1/math.sqrt(2)

-- Shared rigid vocabulary.
local vb=G.builder(); local vm=vb:membrane(nil,'vocabulary')
local CTRL=vb:point(vm,'Control')
local HANDLE=vb:point(vm,'Handle')
local LEFT=vb:point(vm,'Left')
local RIGHT=vb:point(vm,'Right')
local SAME=vb:point(vm,'Same')
local OUTL=vb:point(vm,'OutL')
local OUTR=vb:point(vm,'OutR')
local LOC_L=vb:point(vm,'LocL')
local LOC_R=vb:point(vm,'LocR')
vb:finish()

-- Shared one-control initial exact boundary.
local ib=G.builder(); local ir=ib:membrane(nil,'root')
local ctl=ib:strand(ir,{CTRL},'control')
local INITIAL=ib:finish()

-- ---------------------------------------------------------------------------
-- 16. FRESH ALLOCATOR IDENTITY: GAUGE UNTIL RIGIDLY SUPPORTED
-- ---------------------------------------------------------------------------
local cb=G.builder(); local cr=cb:membrane(nil,'create')
local ci=cb:strand(cr,{CTRL},'in')
local child=cb:membrane(cr,'fresh-child')
local fx=cb:point(child,'fresh-x')
local h=cb:strand(child,{HANDLE,fx},'handle')
cb:face(cr,{ci},{h},'create')
local CREATE=cb:finish()

local function realise_one_fresh()
  local b=O.from_geometry(INITIAL)
  local w=O.one(b,CREATE,{strands={[ci]=ctl}})
  check(w,'fresh create must be admissible')
  local _,img=O.commit(w)
  return b,img.points[fx],img.strands[h]
end

local b1,p1,h1=realise_one_fresh()
local b2,p2,h2=realise_one_fresh()
check(p1~=p2,'independent realisations generate exact-distinct opaque Points')

-- Parametric future is invariant under renaming of the generated Point.
local ub=G.builder(); local ur=ub:membrane(nil,'use')
local uy=ub:point(ur,'y')
local ui=ub:strand(ur,{HANDLE,uy},'in')
local uo=ub:strand(ur,{OUTL,uy},'out')
ub:face(ur,{ui},{uo},'param-use')
local USE_PARAM=ub:finish()
check(O.one(b1,USE_PARAM,{strands={[ui]=h1}}),'parametric future accepts p1')
check(O.one(b2,USE_PARAM,{strands={[ui]=h2}}),'parametric future accepts p2')

-- A rigid common reference destroys the alpha symmetry.
local rb=G.builder(); local rr=rb:membrane(nil,'rigid')
local ri=rb:strand(rr,{HANDLE,p1},'in')
local ro=rb:strand(rr,{OUTL,p1},'out')
rb:face(rr,{ri},{ro},'rigid-use')
local USE_P1=rb:finish()
check(O.one(b1,USE_P1,{strands={[ri]=h1}}),'rigid p1 future accepts p1 branch')
check(O.one(b2,USE_P1,{offers={h2}})==nil,'rigid p1 future rejects p2 branch')

-- If p1<->p2 is purely alpha-renaming, impose it as a gauge constraint.
-- In raw labelled H=span{|p1>,|p2>}, swap S has invariant projector
-- P_inv=(I+S)/2. |+> survives; |-> is pure naming phase and is projected out.
local plus={p1=C(INV),p2=C(INV)}
local minus={p1=C(INV),p2=C(-INV)}
local function gauge_project(v)
  local a=cscale(0.5,cadd(v.p1,v.p2))
  return {p1=a,p2=a}
end
local gp=gauge_project(plus); local gm=gauge_project(minus)
check_approx(cabs2(gp.p1)+cabs2(gp.p2),1,'symmetric fresh-label state survives gauge projection')
check_approx(cabs2(gm.p1)+cabs2(gm.p2),0,'antisymmetric pure naming phase is gauge')
-- Once p1 is externally rigid, p1<->p2 is no longer an admissible support-fixing
-- renaming, so the gauge projection is no longer the correct semantic quotient.

-- ---------------------------------------------------------------------------
-- 17. FRESH IDENTITY *RELATION* IS A TRUE WORLDS-OBSERVABLE DEGREE
-- ---------------------------------------------------------------------------
local function pair_process(shared)
  local b=G.builder(); local r=b:membrane(nil,shared and 'make-shared' or 'make-split')
  local i=b:strand(r,{CTRL},'control-in')
  local x=b:point(r,'x')
  local y=shared and x or b:point(r,'y')
  local l=b:strand(r,{LEFT,x},'left')
  local q=b:strand(r,{RIGHT,y},'right')
  b:face(r,{i},{l,q},shared and 'shared' or 'split')
  return b:finish(),i,l,q,x,y
end
local MAKE_SHARED,shi,shl,shr=pair_process(true)
local MAKE_SPLIT,spi,spl,spr=pair_process(false)

local function realise_pair(proc,inp,lout,rout)
  local b=O.from_geometry(INITIAL)
  local w=O.one(b,proc,{strands={[inp]=ctl}})
  check(w,'pair generator must be admissible')
  local _,img=O.commit(w)
  return b,img.strands[lout],img.strands[rout]
end
local bs,ls,rs=realise_pair(MAKE_SHARED,shi,shl,shr)
local bd,ld,rd=realise_pair(MAKE_SPLIT,spi,spl,spr)
local lsp,rsp=G.points(ls)[2],G.points(rs)[2]
local ldp,rdp=G.points(ld)[2],G.points(rd)[2]
check(lsp==rsp,'shared generator exports one exact fresh Point through both handles')
check(ldp~=rdp,'split generator exports two exact-distinct fresh Points')

-- Exact equality future: both inputs must carry the same Point variable z.
local eb=G.builder(); local er=eb:membrane(nil,'equality-test')
local ez=eb:point(er,'z')
local eli=eb:strand(er,{LEFT,ez},'left-in')
local eri=eb:strand(er,{RIGHT,ez},'right-in')
local eo=eb:strand(er,{SAME,ez},'same')
eb:face(er,{eli,eri},{eo},'same-test')
local EQ=eb:finish()
local eqs=O.one(bs,EQ,{offers={ls,rs}})
local eqd=O.one(bd,EQ,{offers={ld,rd}})
check(eqs~=nil,'shared fresh-identity relation is observed by exact rendezvous')
check(eqd==nil,'distinct fresh-identity relation is refuted by exact rendezvous')

-- Thus a coherent relation state alpha|same>+beta|distinct> has a meaningful
-- enabled projector P_same. Equal superposition gives 1/2 equality probability.
local rel_plus={same=C(INV),distinct=C(INV)}
local p_equal=cabs2(rel_plus.same)
check_approx(p_equal,0.5,'equality projector has half weight on relation superposition')

-- ---------------------------------------------------------------------------
-- 18. RELATION DEGREE IS NOT KERNEL-SUPERSELECTED: FULL 2x2 SUPPORT EXISTS
-- ---------------------------------------------------------------------------
-- A generic pair consumer (x,y may bind equal or distinct) can rewrite the pair
-- to either one new shared fresh identity or two new fresh identities. Hence both
-- input relation sectors have classical Worlds support to both output sectors.
local function rewrite_pair(to_shared)
  local b=G.builder(); local r=b:membrane(nil,to_shared and 'rewrite-shared' or 'rewrite-split')
  local x=b:point(r,'xin'); local y=b:point(r,'yin')
  local li=b:strand(r,{LEFT,x},'left-in'); local ri2=b:strand(r,{RIGHT,y},'right-in')
  local z=b:point(r,'z')
  local w=to_shared and z or b:point(r,'w')
  local lo=b:strand(r,{OUTL,z},'left-out'); local ro2=b:strand(r,{OUTR,w},'right-out')
  b:face(r,{li,ri2},{lo,ro2},to_shared and 'to-shared' or 'to-split')
  return b:finish(),li,ri2,lo,ro2
end
local TO_SHARED,tsl,tsr= rewrite_pair(true)
local TO_SPLIT,tdl,tdr = rewrite_pair(false)

local function support_hit(boundary,l,r,proc,pi1,pi2)
  return O.one(boundary,proc,{strands={[pi1]=l,[pi2]=r}})~=nil
end
-- Need independent fresh source boundaries for each destructive witness search/commit? O.one is non-destructive.
check(support_hit(bs,ls,rs,TO_SHARED,tsl,tsr),'same -> same support')
check(support_hit(bs,ls,rs,TO_SPLIT,tdl,tdr),'same -> distinct support')
check(support_hit(bd,ld,rd,TO_SHARED,tsl,tsr),'distinct -> same support')
check(support_hit(bd,ld,rd,TO_SPLIT,tdl,tdr),'distinct -> distinct support')

-- The support graph is therefore full. Quantum dynamics may consistently choose
-- Hadamard amplitudes on semantic relation sectors after alpha-quotienting output
-- fresh labels:
--          in same   in distinct
-- out same    +          +
-- out dist    +          -
-- /sqrt(2).
-- This turns relative phase into an equality probability.
local function hadamard_rel(v)
  return {
    same=cscale(INV,cadd(v.same,v.distinct)),
    distinct=cscale(INV,csub(v.same,v.distinct)),
  }
end
local rel_minus={same=C(INV),distinct=C(-INV)}
local Hplus=hadamard_rel(rel_plus)
local Hminus=hadamard_rel(rel_minus)
check_approx(cabs2(Hplus.same),1,'+ relation phase maps to certainly shared under H')
check_approx(cabs2(Hplus.distinct),0)
check_approx(cabs2(Hminus.same),0,'- relation phase maps to certainly distinct under H')
check_approx(cabs2(Hminus.distinct),1)
-- Hence exact equality relation is not forced to be a superselection sector by
-- bare Worlds support; a quantum dynamics can mix it if it supplies coherent amplitudes.

-- ---------------------------------------------------------------------------
-- 19. FRESH MEMBRANE TOPOLOGY: SAME CHILD VS SPLIT CHILDREN IS OBSERVABLE
-- ---------------------------------------------------------------------------
local function locality_pair_process(shared_child)
  local b=G.builder(); local root=b:membrane(nil,shared_child and 'loc-shared-root' or 'loc-split-root')
  local i=b:strand(root,{CTRL},'control-in')
  local c1=b:membrane(root,'c1')
  local c2=shared_child and c1 or b:membrane(root,'c2')
  local l=b:strand(c1,{LOC_L},'left')
  local r=b:strand(c2,{LOC_R},'right')
  -- Put the causal Face at root; the two output localities are generated below its
  -- causally grounded mapped root and therefore operationally legitimate.
  b:face(root,{i},{l,r},shared_child and 'co-local' or 'split-local')
  return b:finish(),i,l,r,c1,c2
end
local LOC_SHARED,lsi,lsl,lsr=locality_pair_process(true)
local LOC_SPLIT,lpi,lpl,lpr=locality_pair_process(false)
local bls,lls,rls=realise_pair(LOC_SHARED,lsi,lsl,lsr)
local bld,lld,rld=realise_pair(LOC_SPLIT,lpi,lpl,lpr)
check(G.membrane(lls)==G.membrane(rls),'co-local branch outputs inhabit one exact fresh child membrane')
check(G.membrane(lld)~=G.membrane(rld),'split-local branch outputs inhabit exact-distinct fresh child membranes')

-- A future requiring both offers to inhabit one local child membrane.
local lb=G.builder(); local lr=lb:membrane(nil,'loc-test-root')
local lc=lb:membrane(lr,'one-child')
local lli=lb:strand(lc,{LOC_L},'left-in')
local lri=lb:strand(lc,{LOC_R},'right-in')
local lout=lb:strand(lc,{SAME},'same-locality')
lb:face(lc,{lli,lri},{lout},'co-local-test')
local SAME_LOCALITY=lb:finish()
local slh=O.one(bls,SAME_LOCALITY,{offers={lls,rls}})
local sld=O.one(bld,SAME_LOCALITY,{offers={lld,rld}})
check(slh~=nil,'same-child membrane relation is observed by Cut topology equations')
check(sld==nil,'split-child membrane relation is refuted by one-child pattern')

print('Quantum Worlds kernel explorations VI: PASS')
print('')
print('16. Fresh allocator labels / gauge:')
print('   two executions generate p1 != p2, but parametric futures are alpha-invariant')
print('   gauge projection keeps |p1>+|p2> and removes |p1>-|p2>')
print('   importing rigid p1 breaks that renaming symmetry and distinguishes the branches')
print('')
print('17. Fresh identity relation:')
print('   shared branch: Left(x), Right(x)')
print('   split branch:  Left(x), Right(y), x != y')
print('   exact shared-Point future Hits only shared branch; relation is rename-invariant and observable')
print(string.format('   equal relation superposition has P(shared)=%.3f',p_equal))
print('')
print('18. Relation mixing support:')
print('   Worlds supports same->same, same->distinct, distinct->same, distinct->distinct')
print('   a Hadamard amplitude law can therefore expose +/- relative phase via equality')
print(string.format('   H|+>: P(shared)=%.1f; H|->: P(shared)=%.1f',cabs2(Hplus.same),cabs2(Hminus.same)))
print('')
print('19. Fresh membrane relation:')
print('   same-child vs split-child fresh locality survives alpha-renaming and is Cut-observable')
print('   => quantum superposition of contextual topology is more plausible than superposition of allocator membrane names')
