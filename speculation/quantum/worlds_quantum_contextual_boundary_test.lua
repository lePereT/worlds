-- Worlds 0.6.0 + quantum contextual-equivalence toy.
--
-- Question:
--   Can "what must remain on the boundary" be characterised universally as
--   the coarsest quotient of closed histories that preserves every admissible
--   future observation?
--
-- This toy fixes one exact Worlds live boundary and varies only Theory meaning
-- arising from different closed preparation histories.  It then computes the
-- observational partition induced by progressively richer future contexts.
--
-- For a qubit, X/Y/Z expectation values are tomographically complete:
--   rho = 1/2 (I + x X + y Y + z Z).
-- Therefore equality of the X/Y/Z observation signature is exactly equality
-- of density operators, and equal density operators have equal statistics for
-- every subsequent quantum channel + measurement.

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
-- Tiny complex/matrix layer.
-- Complex = {re, im}; matrices are 2x2 arrays.
-- ---------------------------------------------------------------------------
local function C(re,im) return {re or 0, im or 0} end
local function cadd(a,b) return C(a[1]+b[1], a[2]+b[2]) end
local function csub(a,b) return C(a[1]-b[1], a[2]-b[2]) end
local function cmul(a,b) return C(a[1]*b[1]-a[2]*b[2], a[1]*b[2]+a[2]*b[1]) end
local function cscale(r,a) return C(r*a[1], r*a[2]) end
local function cconj(a) return C(a[1], -a[2]) end
local function ceq(a,b) return approx(a[1],b[1]) and approx(a[2],b[2]) end

local function M(a,b,c,d) return {{a,b},{c,d}} end
local I = M(C(1),C(0),C(0),C(1))
local X = M(C(0),C(1),C(1),C(0))
local Y = M(C(0),C(0,-1),C(0,1),C(0))
local Z = M(C(1),C(0),C(0),C(-1))

local function madd(a,b)
  return M(cadd(a[1][1],b[1][1]), cadd(a[1][2],b[1][2]),
           cadd(a[2][1],b[2][1]), cadd(a[2][2],b[2][2]))
end
local function mscale(r,a)
  return M(cscale(r,a[1][1]), cscale(r,a[1][2]),
           cscale(r,a[2][1]), cscale(r,a[2][2]))
end
local function mmul(a,b)
  local out={{},{}}
  for i=1,2 do
    for j=1,2 do
      local s=C(0,0)
      for k=1,2 do s=cadd(s,cmul(a[i][k],b[k][j])) end
      out[i][j]=s
    end
  end
  return out
end
local function trace(a) return cadd(a[1][1],a[2][2]) end
local function meq(a,b)
  for i=1,2 do for j=1,2 do if not ceq(a[i][j],b[i][j]) then return false end end end
  return true
end
local function density(ket)
  return M(cmul(ket[1],cconj(ket[1])), cmul(ket[1],cconj(ket[2])),
           cmul(ket[2],cconj(ket[1])), cmul(ket[2],cconj(ket[2])))
end
local function global_phase(ket,phi)
  local z=C(math.cos(phi),math.sin(phi))
  return {cmul(z,ket[1]),cmul(z,ket[2])}
end
local INV_SQRT2=1/math.sqrt(2)
local ket0={C(1),C(0)}
local ket1={C(0),C(1)}
local plus={C(INV_SQRT2),C(INV_SQRT2)}
local minus={C(INV_SQRT2),C(-INV_SQRT2)}
local plus_i={C(INV_SQRT2),C(0,INV_SQRT2)}
local minus_i={C(INV_SQRT2),C(0,-INV_SQRT2)}

local function expect(rho,obs)
  local t=trace(mmul(rho,obs))
  check_approx(t[2],0,'Hermitian expectation should be real')
  return t[1]
end
local function p_plus(rho,obs) return (1+expect(rho,obs))/2 end

local function reconstruct_from_xyz(x,y,z)
  -- rho = 1/2(I + xX + yY + zZ)
  return mscale(0.5,madd(I,madd(mscale(x,X),madd(mscale(y,Y),mscale(z,Z)))))
end

-- ---------------------------------------------------------------------------
-- One fixed exact Worlds causal boundary and three admissible future contexts.
-- The quantum histories below all project onto this same *causal interface*;
-- the experiment asks what Theory meaning must accompany it.
-- ---------------------------------------------------------------------------
local vb=G.builder()
local vm=vb:membrane(nil,'roles')
local QUBIT=vb:point(vm,'Qubit')
local RX=vb:point(vm,'Record-X')
local RY=vb:point(vm,'Record-Y')
local RZ=vb:point(vm,'Record-Z')
vb:finish()

local ib=G.builder()
local root=ib:membrane(nil,'lab')
local q=ib:point(root,'q')
local live=ib:strand(root,{q,QUBIT},'q-live')
local initial_geom=ib:finish()

local function measurement_pattern(name,record_role)
  local b=G.builder(); local m=b:membrane(nil,name..'-context')
  local x=b:point(m,'q')
  local sin=b:strand(m,{x,QUBIT},name..'-in')
  local sout=b:strand(m,{x,QUBIT},name..'-out')
  local rec=b:strand(m,{x,record_role},name..'-record')
  b:face(m,{sin},{sout,rec},name)
  return {g=b:finish(),input=sin,output=sout,record=rec}
end

local MX=measurement_pattern('measure-X',RX)
local MY=measurement_pattern('measure-Y',RY)
local MZ=measurement_pattern('measure-Z',RZ)

for _,p in ipairs({MX,MY,MZ}) do
  local boundary=O.from_geometry(initial_geom)
  local w=O.one(boundary,p.g,{strands={[p.input]=live}})
  check(w,'each future measurement context must be Worlds-admissible from the same exact boundary')
end

-- ---------------------------------------------------------------------------
-- Closed preparation histories and their boundary Theory projection.
-- Narrative/history labels are deliberately richer than the physical state.
-- ---------------------------------------------------------------------------
local histories={
  {name='plus via H',              rho=density(plus)},
  {name='plus via H + global φ',   rho=density(global_phase(plus,0.731))},
  {name='minus',                   rho=density(minus)},
  {name='plus-i',                  rho=density(plus_i)},
  {name='minus-i',                 rho=density(minus_i)},
  {name='zero',                    rho=density(ket0)},
  {name='one',                     rho=density(ket1)},
  {name='maximally mixed',         rho=mscale(0.5,I)},
  {name='z-biased mixed',          rho=M(C(0.75),C(0),C(0),C(0.25))},
}

-- The two plus histories differ as preparation narratives/state vectors but
-- have exactly the same density operator.  A boundary-sufficient Theory should
-- therefore quotient them together.
check(meq(histories[1].rho,histories[2].rho),'global phase/preparation history must quotient to same density state')

local OBS={X=X,Y=Y,Z=Z}
local function signature(h,axes)
  local s={}
  for _,a in ipairs(axes) do s[#s+1]=p_plus(h.rho,OBS[a]) end
  return s
end
local function sig_equal(a,b)
  if #a~=#b then return false end
  for i=1,#a do if not approx(a[i],b[i]) then return false end end
  return true
end

local function partition(axes)
  local groups={}
  for _,h in ipairs(histories) do
    local sig=signature(h,axes)
    local found=nil
    for _,g in ipairs(groups) do if sig_equal(sig,g.sig) then found=g; break end end
    if not found then found={sig=sig,members={}}; groups[#groups+1]=found end
    found.members[#found.members+1]=h
  end
  return groups
end

local function group_of(groups,name)
  for gi,g in ipairs(groups) do
    for _,h in ipairs(g.members) do if h.name==name then return gi end end
  end
end

local pz=partition({'Z'})
local pxz=partition({'X','Z'})
local pxyz=partition({'X','Y','Z'})

-- Z-only sees populations and therefore cannot see phase/coherence.
check(group_of(pz,'plus via H')==group_of(pz,'minus'),'Z-only future must identify plus and minus')
check(group_of(pz,'plus-i')==group_of(pz,'minus-i'),'Z-only future must identify +/-i')
check(group_of(pz,'plus via H')==group_of(pz,'maximally mixed'),'Z-only future must identify coherent and mixed 50/50 populations')

-- Adding X exposes real coherence, but imaginary coherence remains hidden.
check(group_of(pxz,'plus via H')~=group_of(pxz,'minus'),'X future must distinguish plus/minus')
check(group_of(pxz,'plus-i')==group_of(pxz,'minus-i'),'X,Z futures still identify +/-i')
check(group_of(pxz,'plus-i')==group_of(pxz,'maximally mixed'),'X,Z futures still identify Y-coherent state and mixed state')

-- Adding Y makes X/Y/Z tomographically complete. Only physically equal density
-- matrices may remain observationally equivalent.
for i=1,#histories do
  for j=1,#histories do
    local eqsig = group_of(pxyz,histories[i].name)==group_of(pxyz,histories[j].name)
    local eqrho = meq(histories[i].rho,histories[j].rho)
    check(eqsig==eqrho,'XYZ contextual equivalence must coincide with density equality for sample histories')
  end
end

-- Explicit tomography: reconstruct every current density operator from only its
-- X/Y/Z future-observation signature.
for _,h in ipairs(histories) do
  local x=expect(h.rho,X); local y=expect(h.rho,Y); local z=expect(h.rho,Z)
  local reconstructed=reconstruct_from_xyz(x,y,z)
  check(meq(reconstructed,h.rho),'XYZ observations must reconstruct boundary density state: '..h.name)
end

-- Therefore no strictly coarser projection than density equality can preserve
-- all X/Y/Z observations in this qubit model. Conversely equal density matrices
-- are indistinguishable by every future quantum channel+POVM because all such
-- probabilities are functions of rho alone.

local function names(g)
  local out={}
  for _,h in ipairs(g.members) do out[#out+1]=h.name end
  return table.concat(out,' | ')
end
local function print_partition(label,groups)
  print(label..' ('..#groups..' classes)')
  for i,g in ipairs(groups) do
    local sig={}; for _,v in ipairs(g.sig) do sig[#sig+1]=string.format('%.3f',v) end
    print(string.format('  %d. [%s]  {%s}',i,table.concat(sig,','),names(g)))
  end
end

print('Quantum contextual boundary quotient toy: PASS')
print('')
print('Fixed exact Worlds boundary: one q-live Strand occurrence')
print('All X/Y/Z future measurement processes are independently Worlds-admissible from it.')
print('')
print_partition('Future observations = {Z}',pz)
print('')
print_partition('Future observations = {X,Z}',pxz)
print('')
print_partition('Future observations = {X,Y,Z}',pxyz)
print('')
print('XYZ signature reconstructs every density matrix exactly (within floating tolerance).')
print('Only the two globally phase-equivalent plus preparations remain in one class.')
print('')
print('Interpretation:')
print('  history equivalence = indistinguishability by all admissible future observations')
print('  boundary projection  = a representative of that equivalence class')
print('  qubit case           = exact Worlds boundary + density operator')
