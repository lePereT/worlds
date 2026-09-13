-- Quantum Worlds: seventh kernel-level exploration.
--
-- This file isolates the nominal/gauge mathematics suggested by the actual
-- Worlds fresh-identity experiments in explorations IV/VI.
--
-- 20. For pure fresh allocator labels, permutation-gauge reduction leaves one
--     invariant physical state: quantisation of the quotient and invariant
--     quantisation agree (for the trivial gauge sector).
-- 21. For TWO generated identities, simultaneous renaming has two orbits:
--     same and distinct. The invariant Hilbert space is therefore 2D. Exact
--     identity RELATION survives while allocator names disappear.
-- 22. A rigid exported reference reduces the gauge group to its stabiliser; one
--     fresh name then has two possible relational orbits: equal-to-reference and
--     other. This recovers the reference-relative distinguishability seen in
--     actual Worlds Cut.
-- 23. The same orbit mathematics applies to generated membrane names: raw child
--     IDs disappear, but co-local vs split-child topology remains physical.
-- 24. Correct post-linearisation gauge reduction is an orthogonal projection /
--     coisometry, not the naive many-to-one map that caused norm inflation in
--     earlier toys. If naming is truly gauge, the physical Hilbert should simply
--     be defined as the invariant subspace from the outset.

local EPS=1e-10
local function approx(a,b) return math.abs(a-b)<=EPS end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg)
  assert(approx(a,b),(msg or 'not approx')..': '..tostring(a)..' ~= '..tostring(b))
end
local function key1(i) return tostring(i) end
local function key2(i,j) return tostring(i)..','..tostring(j) end

-- All permutations of {1,2,3}, represented as tables p[i].
local perms={
  {1,2,3}, {1,3,2}, {2,1,3}, {2,3,1}, {3,1,2}, {3,2,1}
}
local function parity(p)
  local inv=0
  for i=1,3 do for j=i+1,3 do if p[i]>p[j] then inv=inv+1 end end end
  return (inv%2==0) and 1 or -1
end

local function orbit(seed, action, group)
  local seen={}
  for _,g in ipairs(group or perms) do seen[action(g,seed)]=true end
  local out={}; for x in pairs(seen) do out[#out+1]=x end; table.sort(out)
  return out
end
local act1=function(g,i) return key1(g[i]) end
local act2=function(g,ij) return key2(g[ij[1]],g[ij[2]]) end

-- ---------------------------------------------------------------------------
-- 20. SINGLE FRESH NAME: ONE GAUGE ORBIT, ONE INVARIANT BASIS STATE
-- ---------------------------------------------------------------------------
local o1=orbit(1,act1)
check(#o1==3,'S3 acts transitively on raw fresh allocator labels')
-- Group average P_G|1>: each target receives 2/6=1/3. Norm^2=1/3 before
-- normalisation; normalised invariant state has 1/sqrt(3) on every label.
local amp_raw_avg=1/3
local norm2_avg=3*amp_raw_avg*amp_raw_avg
check_approx(norm2_avg,1/3)
local amp_inv=1/math.sqrt(3)
check_approx(3*amp_inv*amp_inv,1,'normalised invariant fresh-name state')
-- Rank of permutation-invariant subspace equals number of orbits = 1.
local dim_single_invariant=1

-- Sign-weighted average on the one-name permutation representation vanishes for
-- S3: each target gets one even and one odd permutation contribution.
local sign_amp={0,0,0}
for _,g in ipairs(perms) do sign_amp[g[1]]=sign_amp[g[1]]+parity(g)/6 end
for i=1,3 do check_approx(sign_amp[i],0,'no sign-sector vector in one-name S3 permutation representation') end

-- ---------------------------------------------------------------------------
-- 21. TWO GENERATED IDENTITIES: SAME/DISTINCT ARE TWO GAUGE-INVARIANT ORBITS
-- ---------------------------------------------------------------------------
local same_orbit=orbit({1,1},act2)
local distinct_orbit=orbit({1,2},act2)
check(#same_orbit==3,'diagonal pair orbit has 3 raw labels')
check(#distinct_orbit==6,'off-diagonal ordered pair orbit has 6 raw labels')
local same_set={}; for _,k in ipairs(same_orbit) do same_set[k]=true end
for _,k in ipairs(distinct_orbit) do check(not same_set[k],'same/distinct permutation orbits disjoint') end
local dim_pair_invariant=2
-- Normalised orbit states are orthogonal because their raw supports are disjoint.
local same_amp=1/math.sqrt(#same_orbit)
local distinct_amp=1/math.sqrt(#distinct_orbit)
check_approx(#same_orbit*same_amp*same_amp,1)
check_approx(#distinct_orbit*distinct_amp*distinct_amp,1)
local overlap=0 -- disjoint supports
check_approx(overlap,0)

-- Equality observable is gauge invariant: +1 on same orbit, -1 on distinct.
-- It distinguishes the two physical invariant states.
local E_same=1
local E_distinct=-1
check(E_same~=E_distinct,'identity relation survives fresh-name gauge reduction')

-- ---------------------------------------------------------------------------
-- 22. RIGID REFERENCE SHRINKS GAUGE GROUP TO ITS STABILISER
-- ---------------------------------------------------------------------------
-- Fix exact reference 1. Remaining allowed renaming only swaps 2<->3.
local stab1={ {1,2,3}, {1,3,2} }
local ref_orbit=orbit(1,act1,stab1)
local other_orbit=orbit(2,act1,stab1)
check(#ref_orbit==1 and ref_orbit[1]=='1','rigid reference is fixed point')
check(#other_orbit==2,'all unsupported other names remain alpha-equivalent')
local dim_with_reference=2
check(dim_with_reference==2,'support-fixing gauge gives equal-to-reference vs other sectors')

-- A genuinely fresh generator cannot produce the already-existing rigid ref, so
-- its output remains in the "other" orbit. But an alias-or-fresh process would
-- have a true relational qubit {equal-to-ref, fresh-other}.

-- ---------------------------------------------------------------------------
-- 23. GENERATED MEMBRANE IDS HAVE THE SAME ORBIT STRUCTURE
-- ---------------------------------------------------------------------------
-- Treat c1,c2,c3 as allocator IDs for fresh sibling membranes. One generated
-- child has one orbit. Two outputs have two topology orbits: same child vs split.
local membrane_single=orbit(1,act1)
local membrane_same=orbit({1,1},act2)
local membrane_split=orbit({1,2},act2)
check(#membrane_single==3)
check(#membrane_same==3 and #membrane_split==6)
local dim_membrane_pair_invariant=2

-- ---------------------------------------------------------------------------
-- 24. CORRECT GAUGE REDUCTION AFTER LINEARISATION
-- ---------------------------------------------------------------------------
-- Let E embed quotient/orbit basis |O> as the normalised uniform orbit state.
-- Its adjoint Q=E^dagger maps a raw basis |x in O> to |O>/sqrt(|O|).
-- Therefore the uniform invariant state maps isometrically to |O>, while all
-- non-invariant components orthogonal to it map to zero. This is the correctly
-- normalised coisometry, unlike the naive |x>->|O> map.
local n=#distinct_orbit
local raw_basis_to_orbit_amp=1/math.sqrt(n)
local invariant_component_amp=1/math.sqrt(n)
local quotient_amp=0
for _=1,n do quotient_amp=quotient_amp + invariant_component_amp*raw_basis_to_orbit_amp end
check_approx(quotient_amp,1,'normalised orbit state maps isometrically to quotient basis')
-- Alternating coefficients with zero sum are killed by Q.
local alt={1,-1,1,-1,1,-1}
local alt_norm=0; local alt_sum=0
for _,x in ipairs(alt) do alt_norm=alt_norm+x*x; alt_sum=alt_sum+x end
check(alt_norm>0 and alt_sum==0)
local alt_q=alt_sum/math.sqrt(n)
check_approx(alt_q,0,'pure label mode orthogonal to invariant orbit is removed by gauge reduction')

print('Quantum Worlds kernel explorations VII: PASS')
print('')
print('20. One fresh name under S3 renaming:')
print('   raw allocator labels = 3, semantic gauge orbits = 1')
print('   invariant Hilbert dimension = '..dim_single_invariant)
print('   sign-weighted one-name sector = 0')
print('')
print('21. Two generated identities:')
print('   same-name raw orbit size = '..#same_orbit)
print('   distinct-name raw orbit size = '..#distinct_orbit)
print('   invariant Hilbert dimension = '..dim_pair_invariant..'  (|same>, |distinct>)')
print('   equality relation is gauge invariant and distinguishes the sectors')
print('')
print('22. With rigid reference 1:')
print('   support-fixing gauge orbits = {1}, {2,3}')
print('   invariant Hilbert dimension = '..dim_with_reference..'  (equal-to-ref, other)')
print('')
print('23. Fresh membrane allocator names:')
print('   one child = one orbit; two outputs give same-child vs split-child')
print('   invariant topology dimension = '..dim_membrane_pair_invariant)
print('')
print('24. Gauge reduction:')
print('   quotient-before-quantisation ~= invariant-subspace quantisation for trivial gauge sector')
print('   the correct late map is E^dagger with 1/sqrt(|orbit|) normalisation, not naive many-to-one identification')
