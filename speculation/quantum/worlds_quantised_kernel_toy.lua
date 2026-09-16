-- Quantising Worlds itself: a kernel-level toy against Worlds 0.6.1.
--
-- This is deliberately NOT a quantum Theory over one exact Worlds boundary.
-- Instead it treats exact Worlds alternatives (Cut witnesses / causal geometries)
-- as basis states of a finite complex vector space and asks which kernel laws
-- survive linearisation.
--
-- Experiments:
--   A. Superposed Cut witnesses: one scarce process demand coherently matches
--      either of two exact local authorities.  Scarcity holds branchwise while
--      the process locality itself becomes indefinite (A or B).
--   B. Superposed causal order: exact acyclic Worlds geometries A->B and B->A
--      are coherent alternatives. Noncommuting X/Z meanings move a relative
--      phase onto the order degree of freedom, detectable by interference.
--   C. Naive linearisation of classical boundary projection is not isometric:
--      identifying genuinely distinct causal histories can destroy or inflate
--      norm. A quantised kernel must retain/recombine that coherence rather than
--      simply forget it.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S = require('speculation.support')
local W = S.W
local G = S.G
local O = S.O
local A = S.A

local EPS=1e-10
local function approx(a,b) return math.abs(a-b)<=EPS end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg)
  assert(approx(a,b),(msg or 'not approx')..': '..tostring(a)..' ~= '..tostring(b))
end

local function lca(a,b)
  local seen={}
  local x=a
  while x do seen[x]=true; x=G.parent(x) end
  x=b
  while x do if seen[x] then return x end; x=G.parent(x) end
end

-- ---------------------------------------------------------------------------
-- Tiny complex / qubit layer used only to expose coherence between GEOMETRIES.
-- ---------------------------------------------------------------------------
local function C(re,im) return {re or 0,im or 0} end
local function cadd(a,b) return C(a[1]+b[1],a[2]+b[2]) end
local function csub(a,b) return C(a[1]-b[1],a[2]-b[2]) end
local function cmul(a,b) return C(a[1]*b[1]-a[2]*b[2],a[1]*b[2]+a[2]*b[1]) end
local function cscale(r,a) return C(r*a[1],r*a[2]) end
local function cabs2(a) return a[1]*a[1]+a[2]*a[2] end
local INV=1/math.sqrt(2)

local function M(a,b,c,d) return {{a,b},{c,d}} end
local X=M(C(0),C(1),C(1),C(0))
local Z=M(C(1),C(0),C(0),C(-1))
local I=M(C(1),C(0),C(0),C(1))
local function mmul(a,b)
  local r={{},{} }
  for i=1,2 do for j=1,2 do
    local s=C(0,0)
    for k=1,2 do s=cadd(s,cmul(a[i][k],b[k][j])) end
    r[i][j]=s
  end end
  return r
end
local function mvec(a,v)
  return {
    cadd(cmul(a[1][1],v[1]),cmul(a[1][2],v[2])),
    cadd(cmul(a[2][1],v[1]),cmul(a[2][2],v[2])),
  }
end
local function vscale(z,v) return {cmul(z,v[1]),cmul(z,v[2])} end
local function vadd(a,b) return {cadd(a[1],b[1]),cadd(a[2],b[2])} end
local function vsub(a,b) return {csub(a[1],b[1]),csub(a[2],b[2])} end
local function vnorm2(v) return cabs2(v[1])+cabs2(v[2]) end
local ket0={C(1),C(0)}

-- ---------------------------------------------------------------------------
-- Shared exact semantic identities.
-- ---------------------------------------------------------------------------
local vb=G.builder()
local vm=vb:membrane(nil,'vocabulary')
local q=vb:point(vm,'q')
local QUBIT=vb:point(vm,'Qubit')
local TOKEN=vb:point(vm,'Token')
vb:finish()

-- ---------------------------------------------------------------------------
-- A. SUPERPOSED CUT WITNESSES / INDEFINITE LOCALITY
-- ---------------------------------------------------------------------------
-- One classical boundary contains two compatible exact authorities in sibling
-- membranes. A one-demand process can consume either, giving two exact Cut
-- witnesses. Classical Worlds may choose one witness. A quantised Worlds would
-- be able to retain a coherent superposition of the mutually exclusive Cuts.
local bb=G.builder()
local root=bb:membrane(nil,'root')
local ma=bb:membrane(root,'A')
local mb=bb:membrane(root,'B')
local sA=bb:strand(ma,{q,TOKEN},'authority-A')
local sB=bb:strand(mb,{q,TOKEN},'authority-B')
local boundary=O.from_geometry(bb:finish())

local pb=G.builder()
local pm=pb:membrane(nil,'process')
local pin=pb:strand(pm,{q,TOKEN},'in')
local pout=pb:strand(pm,{q,TOKEN},'out')
pb:face(pm,{pin},{pout},'local-action')
local P=pb:finish()

local hits=O.all(boundary,P,{offers={sA,sB}})
check(hits and #hits==2,'expected exactly two compatible exact Cut witnesses')
local seen_loc={}
for _,w in ipairs(hits) do
  local src=w:strand(pin)
  local loc=w:membrane(pm)
  check(src==sA or src==sB,'Cut must use one exact offered Strand')
  check(loc==ma or loc==mb,'Cut-induced process locality must be A or B')
  seen_loc[loc]=src
end
check(seen_loc[ma]==sA and seen_loc[mb]==sB,'the two Cuts must induce the two distinct localities')
check(lca(ma,mb)==root,'envelope of the two possible contexts should be root')

-- Quantum interpretation of the Cut relation: one unit of process/authority use
-- is in a coherent superposition of mutually exclusive exact witnesses.
local cut_amp={ [ma]=C(INV,0), [mb]=C(INV,0) }
local cut_norm=cabs2(cut_amp[ma])+cabs2(cut_amp[mb])
check_approx(cut_norm,1,'superposed Cut state norm')

-- Branchwise scarcity: no branch consumes both exact offers. This is not a
-- fractional duplication of authority; it is an alternative exact wiring.
for _,w in ipairs(hits) do
  local closed=w:cut():closed_inputs()
  check(#closed==1,'each Cut branch must consume exactly one scarce authority')
end

-- ---------------------------------------------------------------------------
-- B. SUPERPOSITION OF CAUSAL ORDER
-- ---------------------------------------------------------------------------
-- Build exact process parts A and B. Worlds can close them as A->B or B->A.
-- Each resulting basis Geometry is individually acyclic and ordinary Worlds.
local function unary_process(name)
  local b=G.builder(); local m=b:membrane(nil,name)
  local si=b:strand(m,{q,QUBIT},name..'-in')
  local so=b:strand(m,{q,QUBIT},name..'-out')
  local f=b:face(m,{si},{so},name)
  return {g=b:finish(), input=si, output=so, face=f}
end
local PA=unary_process('A')
local PB=unary_process('B')
local G_AB,imgAB=A.close({PA.g,PB.g},{{from=PA.output,to=PB.input}})
local G_BA,imgBA=A.close({PA.g,PB.g},{{from=PB.output,to=PA.input}})
check(W.is_geometry(G_AB) and W.is_geometry(G_BA),'order branches must be valid Worlds geometries')
check(#G_AB:faces()==2 and #G_BA:faces()==2,'each order branch should contain two Faces')
check(#G_AB:ingress()==1 and #G_AB:egress()==1,'AB should have one external ingress/egress')
check(#G_BA:ingress()==1 and #G_BA:egress()==1,'BA should have one external ingress/egress')
local function same_points(sa,sb)
  local a,b=G.points(sa),G.points(sb)
  if #a~=#b then return false end
  for i=1,#a do if a[i]~=b[i] then return false end end
  return true
end
check(same_points(G_AB:ingress()[1],G_BA:ingress()[1]),'order branches should expose same exact input Point incidence')
check(same_points(G_AB:egress()[1],G_BA:egress()[1]),'order branches should expose same exact output Point incidence')
check(G_AB:egress()[1]~=G_BA:egress()[1],'causally distinct order branches retain distinct exact egress occurrences')

-- Quantise the geometry: |Psi_order> = (|AB> + |BA>)/sqrt(2).
-- Give A and B noncommuting quantum meanings X and Z on a target qubit.
-- If geometry itself is coherent, the two causal orders can interfere.
local branch_AB=mvec(Z,mvec(X,ket0))  -- A then B => Z X |0> = -|1>
local branch_BA=mvec(X,mvec(Z,ket0))  -- B then A => X Z |0> = +|1>
check_approx(vnorm2(branch_AB),1,'AB target norm')
check_approx(vnorm2(branch_BA),1,'BA target norm')

-- The coherent order state before recombination is
--   1/sqrt2 ( |AB> tensor branch_AB + |BA> tensor branch_BA ).
-- Measure/recombine the GEOMETRY order degree in {|+>,|->}.
local plus_target=vscale(C(INV,0),vadd(vscale(C(INV,0),branch_AB),vscale(C(INV,0),branch_BA)))
local minus_target=vscale(C(INV,0),vsub(vscale(C(INV,0),branch_AB),vscale(C(INV,0),branch_BA)))
-- Algebraically the nested INVs above implement projection of the normalised
-- two-branch state onto normalised +/- order basis.
local p_plus=vnorm2(plus_target)
local p_minus=vnorm2(minus_target)
check_approx(p_plus+p_minus,1,'order interference probabilities normalise')
check_approx(p_plus,0,'anticommuting X/Z orders should destructively interfere in + order sector')
check_approx(p_minus,1,'anticommuting X/Z orders should constructively interfere in - order sector')

-- An incoherent classical mixture of the two order branches has no off-diagonal
-- order coherence, so an X-basis order measurement is 50/50.
local mixed_plus=0.5
local mixed_minus=0.5
check_approx(mixed_plus,0.5); check_approx(mixed_minus,0.5)

-- Sanity control: if A and B commute (use I and Z), the coherent order remains +.
local cAB=mvec(Z,mvec(I,ket0))
local cBA=mvec(I,mvec(Z,ket0))
local cplus=vscale(C(INV,0),vadd(vscale(C(INV,0),cAB),vscale(C(INV,0),cBA)))
local cminus=vscale(C(INV,0),vsub(vscale(C(INV,0),cAB),vscale(C(INV,0),cBA)))
check_approx(vnorm2(cplus),1,'commuting orders should remain +')
check_approx(vnorm2(cminus),0,'commuting orders should have no - component')

-- ---------------------------------------------------------------------------
-- C. CLASSICAL BOUNDARY PROJECTION DOES NOT LINEARISE NAIVELY
-- ---------------------------------------------------------------------------
-- G_AB and G_BA have the same exposed exact Point incidence, so an extensional
-- classical projection might be tempted to identify both with one boundary |B>.
-- Linearly applying P|AB>=|B>, P|BA>=|B> is NOT an isometry:
--   (|AB>+|BA>)/sqrt2 -> sqrt2 |B>   (norm^2 2)
--   (|AB>-|BA>)/sqrt2 -> 0           (norm^2 0)
-- This is the kernel-level reason genuinely distinct coherent history cannot
-- simply be forgotten by the classical egress projection.
local plus_projected_amp=cadd(C(INV,0),C(INV,0))
local minus_projected_amp=csub(C(INV,0),C(INV,0))
check_approx(cabs2(plus_projected_amp),2,'naive + history projection inflates norm')
check_approx(cabs2(minus_projected_amp),0,'naive - history projection destroys norm')

print('Quantised Worlds kernel toy: PASS')
print('')
print('A. Superposed Cut / locality:')
print('   exact compatible Cuts: '..#hits)
print('   branch contexts: A and B')
print('   branchwise scarcity: one exact offered Strand consumed per Cut')
print('   coherent Cut norm: 1')
print('   classical context envelope: LCA(A,B) = root')
print('   => a quantised Cut can make the locality of one causal action indefinite.')
print('')
print('B. Superposed causal order:')
print('   exact Worlds basis branches: A->B and B->A')
print('   each branch acyclic: yes')
print('   exposed Point incidence equal: yes')
print('   exact egress occurrence equal: no')
print(string.format('   coherent X/Z order interference: P(+) = %.1f, P(-) = %.1f',p_plus,p_minus))
print(string.format('   incoherent classical order mixture: P(+) = %.1f, P(-) = %.1f',mixed_plus,mixed_minus))
print('   commuting control gives: P(+) = 1, P(-) = 0')
print('   => coherence of causal geometry itself is operationally observable.')
print('')
print('C. Naive boundary projection:')
print(string.format('   |AB>+|BA> identified to one |B>: projected norm^2 = %.1f',cabs2(plus_projected_amp)))
print(string.format('   |AB>-|BA> identified to one |B>: projected norm^2 = %.1f',cabs2(minus_projected_amp)))
print('   => classical many-to-one egress projection is not a valid quantum evolution map.')
print('')
print('Kernel pressure:')
print('   * exact Geometry can remain the basis ontology branchwise;')
print('   * operational state must become a vector/density operator over exact boundaries/geometries;')
print('   * Cut witnesses become coherent basis alternatives rather than merely choices;')
print('   * Hit is evidence of one component, not necessarily enough to commit;')
print('   * membrane join remains branchwise exact, but context itself may be indefinite;')
print('   * history may be discarded only by a quantum-valid quotient/channel, not raw projection.')
