-- Quantum Worlds toy experiment
-- Runs against Worlds 0.6.1. Quantum state/observables live in Theory-like
-- side data; Worlds itself supplies exact identity, local authority and causality.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S = require('speculation.support')
local W = S.W
local G = S.G

local EPS = 1e-10
local function approx(a,b,eps) return math.abs(a-b) <= (eps or EPS) end
local function check(x,msg) assert(x,msg) end
local function check_approx(a,b,msg) assert(approx(a,b), (msg or 'not approximately equal') .. ': '..tostring(a)..' ~= '..tostring(b)) end

-- ---------------------------------------------------------------------------
-- Minimal finite-dimensional quantum Theory helpers (real matrices suffice
-- for the standard CHSH-optimal singlet experiment used here).
-- ---------------------------------------------------------------------------
local function mat(rows)
  local r={}
  for i=1,#rows do r[i]={}; for j=1,#rows[i] do r[i][j]=rows[i][j] end end
  return r
end
local I2 = mat{{1,0},{0,1}}
local X  = mat{{0,1},{1,0}}
local Z  = mat{{1,0},{0,-1}}

local function mscale(a,A)
  local R={}; for i=1,#A do R[i]={}; for j=1,#A[i] do R[i][j]=a*A[i][j] end end; return R
end
local function madd(A,B)
  local R={}; for i=1,#A do R[i]={}; for j=1,#A[i] do R[i][j]=A[i][j]+B[i][j] end end; return R
end
local function mmul(A,B)
  local R={}
  for i=1,#A do
    R[i]={}
    for j=1,#B[1] do
      local s=0; for k=1,#B do s=s+A[i][k]*B[k][j] end
      R[i][j]=s
    end
  end
  return R
end
local function kron(A,B)
  local R={}
  for ia=1,#A do
    for ib=1,#B do
      local row={}
      for ja=1,#A[1] do for jb=1,#B[1] do row[#row+1]=A[ia][ja]*B[ib][jb] end end
      R[#R+1]=row
    end
  end
  return R
end
local function mv(A,v)
  local r={}; for i=1,#A do local s=0; for j=1,#v do s=s+A[i][j]*v[j] end; r[i]=s end; return r
end
local function norm2(v) local s=0; for i=1,#v do s=s+v[i]*v[i] end; return s end
local function max_abs_matrix(A)
  local m=0; for i=1,#A do for j=1,#A[i] do m=math.max(m,math.abs(A[i][j])) end end; return m
end
local function msub(A,B) return madd(A,mscale(-1,B)) end

local function projector(observable, outcome)
  -- P_outcome=(I + outcome*A)/2, outcomes are +/-1.
  return mscale(0.5, madd(I2, mscale(outcome, observable)))
end
local function joint_probability(psi,A,B,a,b)
  local P = kron(projector(A,a), projector(B,b))
  return norm2(mv(P,psi))
end
local function correlation(psi,A,B)
  local e=0
  for _,a in ipairs{-1,1} do for _,b in ipairs{-1,1} do
    e=e+a*b*joint_probability(psi,A,B,a,b)
  end end
  return e
end

-- ---------------------------------------------------------------------------
-- Worlds causal skeleton.
-- Exact qA/qB Points are distinct. Each measurement Face consumes only a
-- local Strand and creates a local successor plus a persistent local record.
-- There is no cross-A/B Strand and therefore no remote causal authority.
-- ---------------------------------------------------------------------------
local wb=G.builder()
local root=wb:membrane(nil,'joint-context')
local A_mem=wb:membrane(root,'Alice')
local B_mem=wb:membrane(root,'Bob')

local qA=wb:point(A_mem,'qA')
local qB=wb:point(B_mem,'qB')
local recA=wb:point(A_mem,'Alice-record')
local recB=wb:point(B_mem,'Bob-record')

local a_in =wb:strand(A_mem,{qA},'Alice quantum authority in')
local a_out=wb:strand(A_mem,{qA},'Alice quantum authority out')
local a_rec=wb:strand(A_mem,{recA},'Alice outcome record')
local A_face=wb:face(A_mem,{a_in},{a_out,a_rec},'Alice local measurement')

local b_in =wb:strand(B_mem,{qB},'Bob quantum authority in')
local b_out=wb:strand(B_mem,{qB},'Bob quantum authority out')
local b_rec=wb:strand(B_mem,{recB},'Bob outcome record')
local B_face=wb:face(B_mem,{b_in},{b_out,b_rec},'Bob local measurement')

local geom=wb:finish()
check(W.is_geometry(geom),'measurement geometry must be valid')
check(qA~=qB,'quantum systems must retain exact distinct identity')

local function ancestor_chain(m)
  local r={}; while m do r[m]=true; m=G.parent(m) end; return r
end
local function lca(a,b)
  local aa=ancestor_chain(a); while b do if aa[b] then return b end; b=G.parent(b) end
end
check(lca(A_mem,B_mem)==root,'joint state support should be the membrane join/LCA')

local function face_is_local(face,mem)
  if G.membrane(face)~=mem then return false end
  for _,s in ipairs(G.inputs(face)) do if G.membrane(s)~=mem then return false end end
  for _,s in ipairs(G.outputs(face)) do if G.membrane(s)~=mem then return false end end
  return true
end
check(face_is_local(A_face,A_mem),'Alice Face must consume/produce only Alice-local authority')
check(face_is_local(B_face,B_mem),'Bob Face must consume/produce only Bob-local authority')

-- Stronger structural check: Alice has no exact incidence with qB, Bob none qA.
for _,s in ipairs(G.inputs(A_face)) do for _,p in ipairs(G.points(s)) do check(p~=qB,'Alice must not consume Bob identity/authority') end end
for _,s in ipairs(G.inputs(B_face)) do for _,p in ipairs(G.points(s)) do check(p~=qA,'Bob must not consume Alice identity/authority') end end

-- ---------------------------------------------------------------------------
-- Quantum Theory state at the join.
-- The state is non-separable, but the systems and their causal authorities
-- remain exact and local in Worlds.
-- ---------------------------------------------------------------------------
local invsqrt2=1/math.sqrt(2)
local singlet={0,invsqrt2,-invsqrt2,0} -- (|01>-|10>)/sqrt(2)
check_approx(norm2(singlet),1,'singlet must be normalised')

-- CHSH-optimal observables for singlet:
-- Alice A0=Z, A1=X
-- Bob B0=(Z+X)/sqrt2, B1=(Z-X)/sqrt2
local Aobs={Z,X}
local Bobs={
  mscale(invsqrt2,madd(Z,X)),
  mscale(invsqrt2,madd(Z,mscale(-1,X))),
}

-- Verify local operators commute exactly when lifted to the joint context.
for x=1,2 do for y=1,2 do
  local LA=kron(Aobs[x],I2)
  local LB=kron(I2,Bobs[y])
  check(max_abs_matrix(msub(mmul(LA,LB),mmul(LB,LA))) < EPS,
        'independent local observables must commute at joint context')
end end

local E={}
for x=1,2 do
  E[x]={}
  for y=1,2 do E[x][y]=correlation(singlet,Aobs[x],Bobs[y]) end
end
local S=E[1][1]+E[1][2]+E[2][1]-E[2][2]
check_approx(math.abs(S),2*math.sqrt(2),'CHSH must attain Tsirelson value')

-- No signalling: Alice's marginal is independent of Bob's setting and vice versa.
local alice_marginal,bob_marginal={},{}
for x=1,2 do
  alice_marginal[x]={}
  for _,a in ipairs{-1,1} do
    local vals={}
    for y=1,2 do
      local p=0; for _,b in ipairs{-1,1} do p=p+joint_probability(singlet,Aobs[x],Bobs[y],a,b) end
      vals[y]=p
    end
    check_approx(vals[1],vals[2],'Alice marginal must not depend on Bob setting')
    check_approx(vals[1],0.5,'singlet Alice marginal')
    alice_marginal[x][a]=vals[1]
  end
end
for y=1,2 do
  bob_marginal[y]={}
  for _,b in ipairs{-1,1} do
    local vals={}
    for x=1,2 do
      local p=0; for _,a in ipairs{-1,1} do p=p+joint_probability(singlet,Aobs[x],Bobs[y],a,b) end
      vals[x]=p
    end
    check_approx(vals[1],vals[2],'Bob marginal must not depend on Alice setting')
    check_approx(vals[1],0.5,'singlet Bob marginal')
    bob_marginal[y][b]=vals[1]
  end
end

-- Verify every setting pair defines a proper probability distribution.
for x=1,2 do for y=1,2 do
  local total=0
  for _,a in ipairs{-1,1} do for _,b in ipairs{-1,1} do total=total+joint_probability(singlet,Aobs[x],Bobs[y],a,b) end end
  check_approx(total,1,'joint probabilities must sum to one')
end end

print('Quantum Worlds Bell toy: PASS')
print(string.format('  exact systems: qA != qB: %s', tostring(qA~=qB)))
print('  local causal Faces: Alice-only / Bob-only: true')
print('  joint Theory support: LCA(Alice,Bob) = root: true')
print(string.format('  E00 = %.12f',E[1][1]))
print(string.format('  E01 = %.12f',E[1][2]))
print(string.format('  E10 = %.12f',E[2][1]))
print(string.format('  E11 = %.12f',E[2][2]))
print(string.format('  |CHSH| = %.12f (2*sqrt(2) = %.12f)',math.abs(S),2*math.sqrt(2)))
print('  Alice marginals: 1/2 independent of Bob setting')
print('  Bob marginals:   1/2 independent of Alice setting')
print('  local lifted observables commute at the joint context')
