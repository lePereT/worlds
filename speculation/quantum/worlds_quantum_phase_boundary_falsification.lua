-- Worlds 0.6.1 + quantum Theory falsification toy:
-- Can two distinct pasts have the same exact Worlds live boundary while a
-- relative quantum phase still changes future interference?
--
-- Result:
--   * If Theory is allowed hidden mutable history, YES -- and boundary
--     sufficiency is violated immediately.
--   * If every future-relevant quantum fact is projected onto the current
--     boundary Theory state, NO hidden history is needed. Exact Worlds causal
--     evolution also reissues fresh Strand occurrences, so causally distinct
--     executions do not accidentally collapse to one exact Strand identity.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S = require('speculation.support')
local W = S.W
local G = S.G
local O = S.O

local EPS = 1e-10
local function approx(a,b) return math.abs(a-b) <= EPS end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg)
  assert(approx(a,b), (msg or 'not approximately equal')..': '..tostring(a)..' ~= '..tostring(b))
end

-- ---------------------------------------------------------------------------
-- Tiny one-qubit Theory. Complex numbers are {re, im}.
-- ---------------------------------------------------------------------------
local function C(re,im) return {re or 0, im or 0} end
local function cadd(a,b) return C(a[1]+b[1], a[2]+b[2]) end
local function cscale(r,a) return C(r*a[1], r*a[2]) end
local function cmul(a,b) return C(a[1]*b[1]-a[2]*b[2], a[1]*b[2]+a[2]*b[1]) end
local function cconj(a) return C(a[1],-a[2]) end
local function cabs2(a) return a[1]*a[1]+a[2]*a[2] end
local INV_SQRT2 = 1/math.sqrt(2)

local function copy_state(s) return {C(s[1][1],s[1][2]), C(s[2][1],s[2][2])} end
local function ket0() return {C(1,0),C(0,0)} end
local function apply_h(s)
  return {
    cscale(INV_SQRT2,cadd(s[1],s[2])),
    cscale(INV_SQRT2,cadd(s[1],cscale(-1,s[2]))),
  }
end
local function apply_phase(s,phi)
  local r=copy_state(s)
  r[2]=cmul(C(math.cos(phi),math.sin(phi)),r[2])
  return r
end
local function global_phase(s,phi)
  local z=C(math.cos(phi),math.sin(phi))
  return {cmul(z,s[1]),cmul(z,s[2])}
end
local function probs(s) return cabs2(s[1]),cabs2(s[2]) end
local function rho01(s) return cmul(s[1],cconj(s[2])) end
local function density_equal(a,b)
  local function ceq(x,y) return approx(x[1],y[1]) and approx(x[2],y[2]) end
  local aa={
    {cmul(a[1],cconj(a[1])), cmul(a[1],cconj(a[2]))},
    {cmul(a[2],cconj(a[1])), cmul(a[2],cconj(a[2]))},
  }
  local bb={
    {cmul(b[1],cconj(b[1])), cmul(b[1],cconj(b[2]))},
    {cmul(b[2],cconj(b[1])), cmul(b[2],cconj(b[2]))},
  }
  for i=1,2 do for j=1,2 do if not ceq(aa[i][j],bb[i][j]) then return false end end end
  return true
end

-- ---------------------------------------------------------------------------
-- Exact Worlds vocabulary and one live quantum-system authority.
-- ---------------------------------------------------------------------------
local vb=G.builder()
local vm=vb:membrane(nil,'roles')
local QUBIT=vb:point(vm,'Qubit')
vb:finish()

local ib=G.builder()
local root=ib:membrane(nil,'lab')
local q=ib:point(root,'q')
local initial_strand=ib:strand(root,{q,QUBIT},'q-live')
local initial_geom=ib:finish()

local function boundary_exactly_same(a,b)
  if a:size() ~= b:size() then return false end
  local sa,sb={},{}
  for _,s in ipairs(a:offers()) do sa[s]=true end
  for _,s in ipairs(b:offers()) do sb[s]=true end
  for s in pairs(sa) do if not sb[s] then return false end end
  for s in pairs(sb) do if not sa[s] then return false end end
  return true
end

local function same_incidence(a,b)
  if G.membrane(a) ~= G.membrane(b) then return false end
  local ap,bp=G.points(a),G.points(b)
  if #ap ~= #bp then return false end
  for i=1,#ap do if ap[i] ~= bp[i] then return false end end
  return true
end

-- A structurally ordinary local gate. Quantum meaning is a Theory transform.
local function gate(name)
  local b=G.builder(); local m=b:membrane(nil,name..'-local')
  local x=b:point(m,'q')
  local si=b:strand(m,{x,QUBIT},name..'-in')
  local so=b:strand(m,{x,QUBIT},name..'-out')
  b:face(m,{si},{so},name)
  return {g=b:finish(),input=si,output=so}
end

local PHASE0=gate('phase-0')
local PHASEPI=gate('phase-pi')
local RECOMBINE=gate('recombine-H')

local function commit(boundary,live,p)
  local w=O.one(boundary,p.g,{strands={[p.input]=live}})
  check(w,'Worlds witness expected')
  local _,img=O.commit(w)
  return img.strands[p.output]
end

-- Prepare |+>. The two alternatives below have identical basis populations,
-- differing only in the relative phase carried by the off-diagonal density term.
local plus=apply_h(ket0())
local minus=apply_phase(plus,math.pi)
local pplus0,pplus1=probs(plus)
local pminus0,pminus1=probs(minus)
check_approx(pplus0,0.5,'plus population 0')
check_approx(pplus1,0.5,'plus population 1')
check_approx(pminus0,0.5,'minus population 0')
check_approx(pminus1,0.5,'minus population 1')
local zplus,zminus=rho01(plus),rho01(minus)
check_approx(zplus[1],0.5,'plus coherence')
check_approx(zminus[1],-0.5,'minus coherence')

-- ---------------------------------------------------------------------------
-- TEST A: Deliberately violate Worlds Theory boundary sufficiency.
-- Two runtimes share the *same exact live Strand occurrence*. We mutate only
-- hidden Theory history, leaving Worlds untouched. The same future H gate then
-- produces different statistics. This is a direct counterexample to treating
-- hidden Theory history as semantically permissible.
-- ---------------------------------------------------------------------------
local bad_b0=O.from_geometry(initial_geom)
local bad_bpi=O.from_geometry(initial_geom)
check(boundary_exactly_same(bad_b0,bad_bpi),'bad test must begin with the same exact boundary occurrence')

-- Hidden/non-boundary Theory history:
local hidden0=plus
local hiddenpi=minus
check(boundary_exactly_same(bad_b0,bad_bpi),'hidden phase must leave exact Worlds boundary unchanged')

local h0=apply_h(hidden0)
local hpi=apply_h(hiddenpi)
local h0p0,h0p1=probs(h0)
local hpip0,hpip1=probs(hpi)
check_approx(h0p0,1,'hidden-history phase 0 future P0')
check_approx(h0p1,0,'hidden-history phase 0 future P1')
check_approx(hpip0,0,'hidden-history phase pi future P0')
check_approx(hpip1,1,'hidden-history phase pi future P1')

-- ---------------------------------------------------------------------------
-- TEST B: Make the phase change a real causal Worlds development.
-- The same initial exact authority is supplied in two independent operational
-- branches. Each causal gate consumes it and reissues a fresh exact Strand.
-- Thus causally distinct developments do NOT converge to the same exact live
-- occurrence, even though their locality and Point incidence are identical.
-- ---------------------------------------------------------------------------
local good_b0=O.from_geometry(initial_geom)
local good_bpi=O.from_geometry(initial_geom)
local out0=commit(good_b0,initial_strand,PHASE0)
local outpi=commit(good_bpi,initial_strand,PHASEPI)
check(out0 ~= outpi,'separate causal realisations must reissue distinct exact Strand occurrences')
check(same_incidence(out0,outpi),'phase outputs should have identical exact Point incidence/locality')
check(not boundary_exactly_same(good_b0,good_bpi),'causally distinct runs must not have the same exact live boundary occurrence')

-- Boundary-sufficient quantum Theory: attach all future-relevant quantum state
-- to the current exact live authority. No closed history is retained.
local theory_state=setmetatable({}, {__mode='k'})
theory_state[out0]=plus
theory_state[outpi]=minus

-- A common future Worlds gate is executable from either current boundary.
-- Its predictions are determined solely by (current exact boundary, current
-- boundary Theory meaning), not by a stored causal history.
local r0=commit(good_b0,out0,RECOMBINE)
local rpi=commit(good_bpi,outpi,RECOMBINE)
local final0=apply_h(theory_state[out0])
local finalpi=apply_h(theory_state[outpi])
theory_state[r0]=final0
theory_state[rpi]=finalpi
local f0a,f0b=probs(theory_state[r0])
local fpia,fpib=probs(theory_state[rpi])
check_approx(f0a,1,'boundary Theory phase 0 future P0')
check_approx(f0b,0,'boundary Theory phase 0 future P1')
check_approx(fpia,0,'boundary Theory phase pi future P0')
check_approx(fpib,1,'boundary Theory phase pi future P1')

-- ---------------------------------------------------------------------------
-- TEST C: What must survive is physical relative phase, not arbitrary history.
-- Global phase changes the state vector but not its density operator and cannot
-- affect any later interference experiment. Boundary Theory need not retain it.
-- ---------------------------------------------------------------------------
local globally_shifted=global_phase(plus,0.731)
check(density_equal(plus,globally_shifted),'global phase should quotient out of boundary-sufficient physical state')
local gp0,gp1=probs(apply_h(globally_shifted))
check_approx(gp0,1,'global phase cannot alter recombination P0')
check_approx(gp1,0,'global phase cannot alter recombination P1')

print('Quantum history/boundary falsification toy: PASS')
print('')
print('A. Forbidden hidden-Theory collision:')
print('   exact Worlds boundary identical: yes')
print(string.format('   same current basis populations: (%.1f, %.1f)',pplus0,pplus1))
print(string.format('   retained relative coherence:    Re rho01 = %+0.1f vs %+0.1f',zplus[1],zminus[1]))
print(string.format('   common future H gives:          P0 = %.1f vs %.1f',h0p0,hpip0))
print('   => exact geometry alone cannot support such hidden Theory evolution.')
print('')
print('B. Worlds-mediated causal evolution:')
print('   phase histories start from same exact input Strand: yes')
print('   resulting live Strand occurrence identical: no')
print('   resulting Point incidence/locality identical: yes')
print('   future phase stored in boundary Theory meaning: yes')
print(string.format('   common future H gives: P0 = %.1f vs %.1f',f0a,fpia))
print('   => no closed history is required once phase/coherence is projected to boundary meaning.')
print('')
print('C. Global phase:')
print('   state vectors differ, density operators identical: yes')
print('   future probabilities identical: yes')
print('   => boundary projection need retain physical coherence, not arbitrary historical phase.')
print('')
print('Conclusion:')
print('   The strict counterexample exists only if Theory is permitted future-relevant')
print('   hidden state outside the open boundary. That is exactly what Worlds forbids.')
print('   For quantum semantics the future-sufficient operational object is naturally')
print('       (exact Worlds live boundary, boundary-projected quantum Theory state).')
