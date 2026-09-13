-- Quantum Worlds: fifth kernel-level exploration.
--
-- Experiments:
--  13. Exact branch identity as a Stinespring/environment record: a coherent
--      many-to-one extensional quotient is impossible, but retaining an exact
--      branch record gives an isometry; tracing the record gives the expected
--      classical mixture, while coherent erasure/recombination can recover phase.
--  14. Quotient-before-quantisation for fresh identity / gauge-like naming:
--      N alpha-renamed fresh realisations should form one semantic basis state
--      when no rigid reference distinguishes the generated token. Linearising
--      raw implementation identities first creates spurious dimensions and a
--      non-isometric quotient.
--  15. General support-graph law: Worlds supplies a zero/nonzero matrix of lawful
--      causal transitions; quantum dynamics fills it with amplitudes. Physicality
--      is a Gram/contraction condition K^dagger K <= I, not merely per-column
--      normalisation when output supports overlap.

local EPS=1e-10
local function approx(a,b) return math.abs(a-b)<=EPS end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg) assert(approx(a,b),(msg or 'not approx')..': '..tostring(a)..' ~= '..tostring(b)) end
local function C(re,im) return {re or 0,im or 0} end
local function cadd(a,b) return C(a[1]+b[1],a[2]+b[2]) end
local function csub(a,b) return C(a[1]-b[1],a[2]-b[2]) end
local function cmul(a,b) return C(a[1]*b[1]-a[2]*b[2],a[1]*b[2]+a[2]*b[1]) end
local function cconj(a) return C(a[1],-a[2]) end
local function cscale(r,a) return C(r*a[1],r*a[2]) end
local function cabs2(a) return a[1]*a[1]+a[2]*a[2] end
local INV=1/math.sqrt(2)

local function norm2(v)
  local s=0; for _,a in pairs(v) do s=s+cabs2(a) end; return s
end

-- ---------------------------------------------------------------------------
-- 13. EXACT BRANCH IDENTITY AS STINESPRING RECORD
-- ---------------------------------------------------------------------------
-- Exact Worlds branches |OA>, |OB> may be extensionally described by one common
-- semantic shape |S>, but coherent evolution cannot identify them directly.
-- Instead retain branch identity in an orthogonal record:
--   |OA> -> |S>|A>, |OB> -> |S>|B>.
-- This is an isometry. Discarding the record is then a legitimate quantum channel.
local phi=math.pi/3
local psi={OA=C(INV), OB=C(INV*math.cos(phi),INV*math.sin(phi))}
check_approx(norm2(psi),1)

local V={ ['S,A']=psi.OA, ['S,B']=psi.OB }
check_approx(norm2(V),1,'Stinespring lift retaining exact branch record preserves norm')
-- Reduced extensional state S has unit probability, while the record density has
-- off-diagonal phase if coherence is still physically accessible.
local record_offdiag=cmul(psi.OA,cconj(psi.OB))
check_approx(cabs2(record_offdiag),0.25,'branch phase survives in joint/record coherence')
-- If record is dephased/traced as inaccessible, branch phase can no longer affect
-- an S-only observation; both alternatives contribute classically.
local pS=cabs2(psi.OA)+cabs2(psi.OB)
check_approx(pS,1,'tracing record yields normalised extensional state')
-- Coherently measuring record in +/- basis recovers interference.
local rplus=cscale(INV,cadd(psi.OA,psi.OB))
local rminus=cscale(INV,csub(psi.OA,psi.OB))
check_approx(cabs2(rplus)+cabs2(rminus),1)

-- ---------------------------------------------------------------------------
-- 14. QUOTIENT BEFORE QUANTISATION: FRESH-NAME GAUGE
-- ---------------------------------------------------------------------------
-- Suppose four implementation runs create four opaque fresh tokens p1..p4 but,
-- relative to a context with no rigid reference to any of them, they are all
-- alpha-renamings of the same semantic event "fresh x". Raw linearisation makes
-- a spurious 4D space. The correct semantic quotient first makes ONE basis state.
local N=4
local raw={}
for i=1,N do raw['p'..i]=C(1/math.sqrt(N)) end
check_approx(norm2(raw),1,'raw alpha-variant superposition normalises')
-- Naive post-quantisation quotient q|pi>=|fresh> has amplitude sqrt(N).
local qamp=C(0)
for _,a in pairs(raw) do qamp=cadd(qamp,a) end
check_approx(cabs2(qamp),N,'many-to-one quotient after linearisation inflates norm by orbit size')
-- A phase-alternating gauge mode can instead vanish completely under q.
local alt={p1=C(0.5),p2=C(-0.5),p3=C(0.5),p4=C(-0.5)}
check_approx(norm2(alt),1)
local altq=C(0); for _,a in pairs(alt) do altq=cadd(altq,a) end
check_approx(cabs2(altq),0,'pure naming-phase mode is annihilated by late quotient')
-- Quotient first: [p1]=...=[p4]=[fresh], then quantise span{|fresh>} -- no
-- spurious naming degrees of freedom exist.
local semantic={fresh=C(1)}
check_approx(norm2(semantic),1)

-- ---------------------------------------------------------------------------
-- 15. SUPPORT GRAPH + GLOBAL GRAM/CONTRACTION CONDITION
-- ---------------------------------------------------------------------------
-- Worlds can determine which exact transitions are lawful; write that as a
-- support graph. Quantum amplitudes fill the supported entries. If different
-- input branches can land in overlapping output subspaces, normalising each
-- input column separately is NOT enough: columns must have a contraction Gram.
--
-- Example K_bad has individually normalised columns but they are identical:
--       I1  I2
--  O1   1/sqrt2  1/sqrt2
--  O2   1/sqrt2  1/sqrt2
-- K^dagger K = [[1,1],[1,1]], eigenvalues {2,0}: not a contraction.
local Kbad={
  {C(INV),C(INV)},
  {C(INV),C(INV)},
}
local function col_inner(K,i,j)
  local z=C(0)
  for r=1,#K do z=cadd(z,cmul(cconj(K[r][i]),K[r][j])) end
  return z
end
local g11=col_inner(Kbad,1,1); local g22=col_inner(Kbad,2,2); local g12=col_inner(Kbad,1,2)
check_approx(g11[1],1); check_approx(g22[1],1); check_approx(g12[1],1)
local lambda_max_bad=2 -- eigenvalues of [[1,1],[1,1]]
check(lambda_max_bad>1,'column-wise normalisation alone does not make a physical Cut operator')

-- Hadamard-supported amplitudes have orthonormal columns and are unitary.
local Kgood={
  {C(INV),C(INV)},
  {C(INV),C(-INV)},
}
local h11=col_inner(Kgood,1,1); local h22=col_inner(Kgood,2,2); local h12=col_inner(Kgood,1,2)
check_approx(h11[1],1); check_approx(h22[1],1); check_approx(cabs2(h12),0)

print('Quantum Worlds kernel explorations V: PASS')
print('')
print('13. Exact branch record / Stinespring lift:')
print('   coherent many-to-one quotient replaced by |Oi> -> |S>|record_i>')
print(string.format('   record coherence |rho_AB|^2 = %.3f',cabs2(record_offdiag)))
print(string.format('   +/- record recombination: P(+) = %.6f, P(-) = %.6f',cabs2(rplus),cabs2(rminus)))
print('')
print('14. Quotient-before-quantisation:')
print('   4 alpha-equivalent fresh-name implementations -> raw 4D artefact')
print(string.format('   late quotient symmetric norm^2 = %.1f; alternating gauge mode norm^2 = %.1f',cabs2(qamp),cabs2(altq)))
print('   quotient first -> one semantic basis state |fresh> with norm 1')
print('')
print('15. Quantum Cut support graph:')
print('   per-column normalisation is insufficient when output supports overlap')
print('   identical normalised columns give lambda_max(K^dagger K)=2 -> unphysical')
print('   Hadamard amplitudes give orthonormal columns -> physical unitary')
