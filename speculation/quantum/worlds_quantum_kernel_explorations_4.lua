-- Quantum Worlds: fourth kernel-level exploration against Worlds 0.6.1.
--
-- Experiments:
--   9. Build a finite Quantum Cut operator directly from actual Worlds Cut
--      witnesses. Exact witness outputs are orthogonal branch configurations;
--      K^†K <= I reduces to a precise amplitude-budget condition.
--  10. Show that quotienting exact Cut outputs too early repeats the quantum
--      boundary-projection failure: constructive superpositions inflate norm and
--      antisymmetric ones vanish. Exact causal branch information must survive
--      until a lawful observation/channel removes it.
--  11. Quantise causal topology branchwise: ordinary Worlds close normalises a
--      support cycle to one joint Face, while an acyclic alternative remains a
--      different exact geometry. Superposition does not weaken branchwise
--      acyclicity/SCC laws; it makes topology a degree of freedom only if that
--      branch distinction remains future-relevant.
--  12. Fresh exact Point identities exhibit reference-relative distinguishability:
--      two alternative commits generate p1 != p2; a parametric future treats them
--      identically, while a future importing rigid p1 distinguishes them. This is
--      a useful warning about what fresh-name differences should enter a quantum
--      basis before/after contextual quotienting.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S=require('speculation.support')
local W=S.W
local G=S.G
local O=S.O
local A=S.A

local EPS=1e-9
local function approx(a,b) return math.abs(a-b)<=EPS end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg)
  assert(approx(a,b),(msg or 'not approx')..': '..tostring(a)..' ~= '..tostring(b))
end
local function C(re,im) return {re or 0,im or 0} end
local function cadd(a,b) return C(a[1]+b[1],a[2]+b[2]) end
local function csub(a,b) return C(a[1]-b[1],a[2]-b[2]) end
local function cmul(a,b) return C(a[1]*b[1]-a[2]*b[2],a[1]*b[2]+a[2]*b[1]) end
local function cconj(a) return C(a[1],-a[2]) end
local function cscale(r,a) return C(r*a[1],r*a[2]) end
local function cabs2(a) return a[1]*a[1]+a[2]*a[2] end
local function inner(a,b)
  local z=C(0)
  for k,av in pairs(a) do if b[k] then z=cadd(z,cmul(cconj(av),b[k])) end end
  return z
end
local function norm2(v) return inner(v,v)[1] end
local INV=1/math.sqrt(2)

-- Shared rigid semantic identities.
local vb=G.builder(); local vm=vb:membrane(nil,'vocabulary')
local R=vb:point(vm,'R')
local OUT=vb:point(vm,'Out')
local CTRL=vb:point(vm,'Control')
local HANDLE=vb:point(vm,'Handle')
local LINK=vb:point(vm,'Link')
local AOUT=vb:point(vm,'AOut')
local BOUT=vb:point(vm,'BOut')
vb:finish()

-- ---------------------------------------------------------------------------
-- 9. ACTUAL QUANTUM CUT OPERATOR FROM WORLDS WITNESSES
-- ---------------------------------------------------------------------------
local sb=G.builder(); local sr=sb:membrane(nil,'source')
local ma=sb:membrane(sr,'A'); local mb=sb:membrane(sr,'B')
local pA=sb:point(ma,'pA'); local pB=sb:point(mb,'pB')
local sA=sb:strand(ma,{pA},'sA'); local sB=sb:strand(mb,{pB},'sB')
local source=sb:finish()

local pb=G.builder(); local pm=pb:membrane(nil,'process')
local x=pb:point(pm,'x')
local pi=pb:strand(pm,{x},'in')
local po=pb:strand(pm,{OUT,x},'out')
pb:face(pm,{pi},{po},'act')
local P=pb:finish()

local live_for_search=O.from_geometry(source)
local hits=O.all(live_for_search,P,{offers={sA,sB}})
check(#hits==2,'one-demand process should have two exact operational Cut witnesses')
local branches={}
for _,search_w in ipairs(hits) do
  local src=search_w:strand(pi)
  local branch_boundary=O.from_geometry(source)
  local w=O.one(branch_boundary,P,{strands={[pi]=src}})
  check(w,'exact branch witness must replay on independent boundary copy')
  local loc=w:membrane(pm)
  check((src==sA and loc==ma) or (src==sB and loc==mb),
    'Cut must map process locality to exact source locality')
  local _,img=O.commit(w)
  local out=img.strands[po]
  check(out and branch_boundary:contains(out),'realised process output must be exact live egress')
  check(G.membrane(out)==loc,'output locality follows exact Cut embedding')
  branches[src]={witness=w,boundary=branch_boundary,out=out,image=img}
end
check(branches[sA] and branches[sB],'both branch realisations required')
check(branches[sA].out~=branches[sB].out,'alternative realised outputs are exact-distinct occurrences')
local cuts=hits -- report actual operational witness count

-- K|B> = alpha|O_A> + beta|O_B>. On this one-dimensional input sector,
-- K^†K = (|alpha|^2+|beta|^2) I. The quantum operation is a contraction iff
-- that witness-amplitude budget is <= 1.
local theta=math.pi/5
local alpha=C(INV,0)
local beta=C(INV*math.cos(theta),INV*math.sin(theta))
local kout={OA=alpha,OB=beta}
local kdagk=cabs2(alpha)+cabs2(beta)
check_approx(kdagk,1,'normalised competing-Cut operator should be isometric on input state')
check_approx(norm2(kout),1,'actual Cut branch superposition normalises')

local bad_alpha=C(0.9,0); local bad_beta=C(0.9,0)
local bad_kdagk=cabs2(bad_alpha)+cabs2(bad_beta)
check(bad_kdagk>1+EPS,'overweight Cut amplitudes violate K^dagger K <= I')
local lossy_alpha=C(0.5,0); local lossy_beta=C(0.5,0)
local lossy_kdagk=cabs2(lossy_alpha)+cabs2(lossy_beta)
check(lossy_kdagk<1-EPS,'subnormalised Cut branch is a valid non-unit-probability Kraus branch')

-- Recombine exact Cut branches in a +/- basis. Relative branch phase is observable.
local plus=cscale(INV,cadd(alpha,beta))
local minus=cscale(INV,csub(alpha,beta))
local pp,pmns=cabs2(plus),cabs2(minus)
check_approx(pp+pmns,1,'Cut branch recombination probabilities normalise')

-- ---------------------------------------------------------------------------
-- 10. EARLY EXTENSIONAL QUOTIENT OF EXACT OUTPUTS IS NOT A QUANTUM MAP
-- ---------------------------------------------------------------------------
-- A classical observer might describe both outputs merely as "one transformed
-- authority plus one untouched authority". Mapping both orthogonal exact branch
-- states to one ket |same> is many-to-one. It is not a valid coherent evolution.
local q_plus_amp=cadd(C(INV),C(INV))
local q_minus_amp=csub(C(INV),C(INV))
check_approx(cabs2(q_plus_amp),2,'early quotient inflates symmetric norm')
check_approx(cabs2(q_minus_amp),0,'early quotient annihilates antisymmetric state')

-- ---------------------------------------------------------------------------
-- 11. QUANTISED CAUSAL TOPOLOGY, BRANCHWISE SCC NORMALISATION
-- ---------------------------------------------------------------------------
-- Build two grounded process parts A and B. Closing their link outputs/inputs in
-- a two-way cycle forces Worlds to contract them to one joint Face. Leaving the
-- links open gives two ordinary independent Faces. Both exact basis geometries
-- obey ordinary Worlds laws; their causal topology differs.
local ab=G.builder(); local am=ab:membrane(nil,'Aproc')
local actrl=ab:strand(am,{CTRL},'a-ctrl')
local alin=ab:strand(am,{LINK},'a-link-in')
local alout=ab:strand(am,{LINK},'a-link-out')
local ao=ab:strand(am,{AOUT},'a-out')
ab:face(am,{actrl,alin},{alout,ao},'A')
local GA=ab:finish()

local bb=G.builder(); local bm=bb:membrane(nil,'Bproc')
local bctrl=bb:strand(bm,{CTRL},'b-ctrl')
local blin=bb:strand(bm,{LINK},'b-link-in')
local blout=bb:strand(bm,{LINK},'b-link-out')
local bo=bb:strand(bm,{BOUT},'b-out')
bb:face(bm,{bctrl,blin},{blout,bo},'B')
local GB=bb:finish()

local independent=A.tensor({GA,GB})
check(#independent:faces()==2,'tensor alternative keeps two independent Faces')
check(W.is_geometry(independent),'independent branch remains valid')

local joint,jimg=A.close({GA,GB},{
  {from=alout,to=blin},
  {from=blout,to=alin},
})
check(#joint:faces()==1,'mutual support cycle contracts to one joint Face')
check(W.is_geometry(joint),'joint branch remains valid')
check(#joint:ingress()==2,'joint SCC should expose only the two grounding controls')
check(#joint:egress()==2,'joint SCC should expose A/B outputs')

-- A putative quantum state may superpose these exact normal forms branchwise.
-- No branch violates acyclicity: the cycle exists only pre-normalisation.
local topo={independent=C(INV),joint=C(INV)}
check_approx(norm2(topo),1,'causal-topology branch state normalises')
local topo_plus=cscale(INV,cadd(topo.independent,topo.joint))
local topo_minus=cscale(INV,csub(topo.independent,topo.joint))
check_approx(cabs2(topo_plus),1,'equal-phase topology superposition is + eigenstate')
check_approx(cabs2(topo_minus),0)

-- Important semantic warning: such a topology qubit is physical only if the
-- branch distinction remains in future-sufficient state. Quantisation must not
-- resurrect closed topology already quotiented by contextual equivalence.

-- ---------------------------------------------------------------------------
-- 12. QUANTUM FRESH IDENTITY / REFERENCE-RELATIVE DISTINGUISHABILITY
-- ---------------------------------------------------------------------------
-- Initial exact boundary has one Control authority. A process consumes it and
-- creates a fresh local Point x under a fresh nested membrane, returning a handle
-- carrying that Point. Execute the SAME process twice from two copies of the SAME
-- exact initial boundary; operational realisation generates distinct fresh Points.
local ib=G.builder(); local ir=ib:membrane(nil,'identity-root')
local ctl=ib:strand(ir,{CTRL},'ctl')
local initial=ib:finish()

local cb=G.builder(); local cr=cb:membrane(nil,'create-root')
local ci=cb:strand(cr,{CTRL},'control-in')
local child=cb:membrane(cr,'fresh-child')
local fx=cb:point(child,'fresh-x')
local h=cb:strand(child,{HANDLE,fx},'handle')
cb:face(cr,{ci},{h},'create')
local Create=cb:finish()

local function realise_fresh()
  local boundary=O.from_geometry(initial)
  local w=O.one(boundary,Create,{strands={[ci]=ctl}})
  check(w,'fresh create should be admissible')
  local _,img=O.commit(w)
  return boundary,img.points[fx],img.strands[h]
end
local b1,p1,h1=realise_fresh()
local b2,p2,h2=realise_fresh()
check(p1 and p2 and p1~=p2,'alternative realisations generate exact-distinct fresh Points')
check(h1~=h2 and b1:contains(h1) and b2:contains(h2),'fresh handles are exact-distinct live occurrences')

-- Parametric future: local Point y binds to whatever exact identity arrives.
local ub=G.builder(); local ur=ub:membrane(nil,'use-root')
local uy=ub:point(ur,'y')
local ui=ub:strand(ur,{HANDLE,uy},'handle-in')
local uo=ub:strand(ur,{OUT,uy},'done')
ub:face(ur,{ui},{uo},'use')
local UseParam=ub:finish()
local w1=O.one(b1,UseParam,{strands={[ui]=h1}})
local w2=O.one(b2,UseParam,{strands={[ui]=h2}})
check(w1 and w2,'parametric future must accept either fresh identity')
check(w1:point(uy)==p1 and w2:point(uy)==p2,'parametric binding preserves branch exact identity')

-- Rigid-reference future: import p1 directly. It can distinguish the branches,
-- but only because the future has been granted p1 as a common exact reference.
local rb=G.builder(); local rr=rb:membrane(nil,'rigid-use')
local ri=rb:strand(rr,{HANDLE,p1},'rigid-in')
local ro=rb:strand(rr,{OUT,p1},'rigid-out')
rb:face(rr,{ri},{ro},'rigid-use')
local UseP1=rb:finish()
local rw1=O.one(b1,UseP1,{strands={[ri]=h1}})
local rw2=O.one(b2,UseP1,{offers={h2}})
check(rw1~=nil,'branch p1 is distinguishable with rigid p1 reference')
check(rw2==nil,'branch p2 must Retry against rigid p1 incidence')

print('Quantum Worlds kernel explorations IV: PASS')
print('')
print('9. Quantum Cut operator derived from actual Worlds witnesses:')
print('   exact Cut witnesses = '..#cuts)
print(string.format('   K^dagger K on input sector = %.12f',kdagk))
print(string.format('   branch recombination: P(+) = %.12f, P(-) = %.12f',pp,pmns))
print(string.format('   overweight test sum |alpha|^2 = %.3f -> invalid contraction',bad_kdagk))
print(string.format('   lossy Kraus branch sum |alpha|^2 = %.3f -> valid subnormalised branch',lossy_kdagk))
print('')
print('10. Early extensional quotient of exact branch outputs:')
print(string.format('   symmetric state norm^2 -> %.1f; antisymmetric state norm^2 -> %.1f',cabs2(q_plus_amp),cabs2(q_minus_amp)))
print('   => exact causal branch identity cannot be coherently forgotten by a many-to-one quotient.')
print('')
print('11. Causal topology as branchwise exact geometry:')
print('   independent branch Faces = '..#independent:faces())
print('   cyclic-support branch normalises to Faces = '..#joint:faces())
print('   => SCC/acyclicity law survives inside each basis geometry; topology may be superposed only if future-relevant.')
print('')
print('12. Fresh identity:')
print('   p1 != p2: yes')
print('   parametric future accepts both branches: yes')
print('   rigid future importing p1 accepts branch1 and rejects branch2: yes')
print('   => fresh identity differences are future-observable exactly when an exact reference makes them observable.')
