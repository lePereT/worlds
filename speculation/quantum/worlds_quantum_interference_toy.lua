-- Worlds 0.6.0 + quantum Theory toy:
-- interference, which-path records, coherent erasure, and leaked/persistent records.
--
-- Worlds remains exact/classical. Quantum amplitudes are Theory-like side data.
-- The experiment tests whether future-relevant which-path information must remain
-- represented on the live boundary for subsequent interference behaviour.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S = require('speculation.support')
local W = S.W
local G = S.G
local O = S.O

local EPS = 1e-10
local function check(x,msg) assert(x,msg) end
local function approx(a,b,eps) return math.abs(a-b) <= (eps or EPS) end
local function check_approx(a,b,msg)
  assert(approx(a,b), (msg or 'not approximately equal')..': '..tostring(a)..' ~= '..tostring(b))
end

-- ---------------------------------------------------------------------------
-- Minimal 3-qubit pure-state quantum Theory.
-- q0 = path system, q1 = which-path marker, q2 = environment/copy of record.
-- Complex values are represented as {re, im}.
-- ---------------------------------------------------------------------------
local function C(re,im) return {re or 0,im or 0} end
local function cadd(a,b) return C(a[1]+b[1],a[2]+b[2]) end
local function cscale(r,a) return C(r*a[1],r*a[2]) end
local function cmul(a,b) return C(a[1]*b[1]-a[2]*b[2], a[1]*b[2]+a[2]*b[1]) end
local function cconj(a) return C(a[1],-a[2]) end
local function cabs2(a) return a[1]*a[1]+a[2]*a[2] end

local function zero_state(n)
  local s={}
  for i=0,(2^n)-1 do s[i]=C(0,0) end
  return s
end
local function basis000()
  local s=zero_state(3); s[0]=C(1,0); return s
end
local function copy_state(s)
  local r={}; for i=0,7 do r[i]=C(s[i][1],s[i][2]) end; return r
end
local function bit(x,q) return math.floor(x/(2^q))%2 end
local function flip(x,q)
  local b=bit(x,q); return x + (b==0 and 2^q or -2^q)
end
local INV_SQRT2=1/math.sqrt(2)
local function apply_h(s,q)
  local out=zero_state(3)
  for i=0,7 do
    local j0 = bit(i,q)==0 and i or flip(i,q)
    local j1 = bit(i,q)==1 and i or flip(i,q)
    if bit(i,q)==0 then
      out[j0]=cadd(out[j0],cscale(INV_SQRT2,s[i]))
      out[j1]=cadd(out[j1],cscale(INV_SQRT2,s[i]))
    else
      out[j0]=cadd(out[j0],cscale(INV_SQRT2,s[i]))
      out[j1]=cadd(out[j1],cscale(-INV_SQRT2,s[i]))
    end
  end
  return out
end
local function apply_phase(s,q,phi)
  local out=copy_state(s)
  local ph=C(math.cos(phi),math.sin(phi))
  for i=0,7 do if bit(i,q)==1 then out[i]=cmul(ph,s[i]) end end
  return out
end
local function apply_cnot(s,control,target)
  local out=zero_state(3)
  for i=0,7 do
    local j=bit(i,control)==1 and flip(i,target) or i
    out[j]=cadd(out[j],s[i])
  end
  return out
end
local function norm2(s)
  local n=0; for i=0,7 do n=n+cabs2(s[i]) end; return n
end
local function prob_qubit(s,q,value)
  local p=0; for i=0,7 do if bit(i,q)==value then p=p+cabs2(s[i]) end end; return p
end
-- Reduced path density matrix off-diagonal rho_01 = sum_{marker,env} a_0,r * conj(a_1,r)
local function path_coherence(s)
  local z=C(0,0)
  for rest=0,3 do
    local i0 = 2*rest       -- q0 = 0
    local i1 = 2*rest + 1   -- q0 = 1
    z=cadd(z,cmul(s[i0],cconj(s[i1])))
  end
  return z
end
local function coherence_abs(s)
  local z=path_coherence(s); return math.sqrt(cabs2(z))
end

-- ---------------------------------------------------------------------------
-- Rigid semantic role Points. These are imported exact identities in process
-- patterns and make Ready/Record visible on exact Worlds boundary Strands.
-- ---------------------------------------------------------------------------
local vocab=G.builder()
local vm=vocab:membrane(nil,'roles')
local PATH=vocab:point(vm,'PathLive')
local READY=vocab:point(vm,'Ready')
local RECORD=vocab:point(vm,'Record')
vocab:finish()

local function make_world()
  local b=G.builder()
  local root=b:membrane(nil,'lab')
  local pm=b:membrane(root,'path')
  local mm=b:membrane(root,'marker')
  local em=b:membrane(root,'environment')
  local q=b:point(pm,'path-system')
  local marker=b:point(mm,'which-path-marker')
  local env=b:point(em,'environment-record')
  local ps=b:strand(pm,{q,PATH},'path-live')
  local ms=b:strand(mm,{marker,READY},'marker-ready')
  local es=b:strand(em,{env,READY},'environment-ready')
  local geom=b:finish()
  return {
    root=root,path_mem=pm,marker_mem=mm,env_mem=em,
    q=q,marker=marker,env=env,
    boundary=O.from_geometry(geom), path=ps, marker_s=ms, env_s=es,
  }
end

local function ancestors(m)
  local r={}; while m do r[m]=true; m=G.parent(m) end; return r
end
local function lca(a,b)
  local aa=ancestors(a); while b do if aa[b] then return b end; b=G.parent(b) end
end

-- A path-local causal gate. Quantum meaning (H, phase, etc.) is supplied by Theory.
local function path_gate(name)
  local b=G.builder(); local r=b:membrane(nil,name..'-root'); local p=b:membrane(r,'path')
  local x=b:point(p,'q')
  local i=b:strand(p,{x,PATH},name..'-in')
  local o=b:strand(p,{x,PATH},name..'-out')
  local f=b:face(p,{i},{o},name)
  return {g=b:finish(),root=r,path_mem=p,i=i,o=o,face=f}
end

-- Joint path+marker transition, changing marker role from from_role to to_role.
local function path_marker_gate(name,from_role,to_role)
  local b=G.builder(); local r=b:membrane(nil,name..'-root')
  local p=b:membrane(r,'path'); local m=b:membrane(r,'marker')
  local q=b:point(p,'q'); local mk=b:point(m,'marker')
  local pi=b:strand(p,{q,PATH},name..'-path-in')
  local mi=b:strand(m,{mk,from_role},name..'-marker-in')
  local po=b:strand(p,{q,PATH},name..'-path-out')
  local mo=b:strand(m,{mk,to_role},name..'-marker-out')
  local f=b:face(r,{pi,mi},{po,mo},name)
  return {g=b:finish(),root=r,path_mem=p,other_mem=m,pi=pi,oi=mi,po=po,oo=mo,face=f}
end

-- Joint marker+environment transition. Marker record is reissued; environment
-- goes Ready -> Record, representing a persistent copied which-path record.
local function copy_record_gate()
  local b=G.builder(); local r=b:membrane(nil,'copy-root')
  local m=b:membrane(r,'marker'); local e=b:membrane(r,'environment')
  local mk=b:point(m,'marker'); local ev=b:point(e,'env')
  local mi=b:strand(m,{mk,RECORD},'marker-record-in')
  local ei=b:strand(e,{ev,READY},'env-ready-in')
  local mo=b:strand(m,{mk,RECORD},'marker-record-out')
  local eo=b:strand(e,{ev,RECORD},'env-record-out')
  local f=b:face(r,{mi,ei},{mo,eo},'copy record to environment')
  return {g=b:finish(),root=r,marker_mem=m,env_mem=e,mi=mi,ei=ei,mo=mo,eo=eo,face=f}
end

-- Joint path+environment transition used for complete coherent erasure.
local function path_env_gate(name,from_role,to_role)
  local b=G.builder(); local r=b:membrane(nil,name..'-root')
  local p=b:membrane(r,'path'); local e=b:membrane(r,'environment')
  local q=b:point(p,'q'); local ev=b:point(e,'env')
  local pi=b:strand(p,{q,PATH},name..'-path-in')
  local ei=b:strand(e,{ev,from_role},name..'-env-in')
  local po=b:strand(p,{q,PATH},name..'-path-out')
  local eo=b:strand(e,{ev,to_role},name..'-env-out')
  local f=b:face(r,{pi,ei},{po,eo},name)
  return {g=b:finish(),root=r,path_mem=p,other_mem=e,pi=pi,oi=ei,po=po,oo=eo,face=f}
end

local PREP=path_gate('prepare superposition')
local RECOMBINE=path_gate('recombine')
local MARK=path_marker_gate('which-path mark',READY,RECORD)
local ERASE_MARK=path_marker_gate('erase local marker',RECORD,READY)
local COPY=copy_record_gate()
local ERASE_ENV=path_env_gate('erase environment record',RECORD,READY)

local function commit_path(world,p)
  local w=O.one(world.boundary,p.g,{strands={[p.i]=world.path}})
  check(w,name or 'path witness expected')
  local _,img=O.commit(w)
  world.path=img.strands[p.o]
end

local function commit_path_other(world,p,which)
  local other = which=='marker' and world.marker_s or world.env_s
  local w=O.one(world.boundary,p.g,{strands={[p.pi]=world.path,[p.oi]=other}})
  check(w,p.g and 'joint witness expected')
  -- Cut must map the compound process root to the exact LCA of its two supports.
  local expected=which=='marker' and lca(world.path_mem,world.marker_mem) or lca(world.path_mem,world.env_mem)
  check(w:membrane(p.root)==expected,'joint Face context must map to exact membrane LCA')
  local _,img=O.commit(w)
  world.path=img.strands[p.po]
  if which=='marker' then world.marker_s=img.strands[p.oo] else world.env_s=img.strands[p.oo] end
end

local function commit_copy(world)
  local w=O.one(world.boundary,COPY.g,{strands={[COPY.mi]=world.marker_s,[COPY.ei]=world.env_s}})
  check(w,'copy-record witness expected')
  check(w:membrane(COPY.root)==lca(world.marker_mem,world.env_mem),'copy record context must be marker/env LCA')
  local _,img=O.commit(w)
  world.marker_s=img.strands[COPY.mo]
  world.env_s=img.strands[COPY.eo]
end

local function strand_has(s,p)
  for _,x in ipairs(G.points(s)) do if x==p then return true end end
  return false
end
local function roles(world)
  return {
    marker_record=strand_has(world.marker_s,RECORD),
    env_record=strand_has(world.env_s,RECORD),
  }
end
local function assert_boundary(world,marker_record,env_record,label)
  check(world.boundary:size()==3,label..': boundary should retain exactly path+marker+environment live authority')
  local r=roles(world)
  check(r.marker_record==marker_record,label..': marker role mismatch')
  check(r.env_record==env_record,label..': environment role mismatch')
end

-- Theory evolution up to the recombiner.
local PHI=math.pi/3 -- no-record ideal fringe: P(detector0)=cos^2(phi/2)=3/4.
local function prepared_state()
  local s=basis000()
  s=apply_h(s,0)
  s=apply_phase(s,0,PHI)
  return s
end
local function detector_probs(s)
  local out=apply_h(s,0)
  return prob_qubit(out,0,0),prob_qubit(out,0,1)
end

local ideal_p0=math.cos(PHI/2)^2
local ideal_p1=math.sin(PHI/2)^2
check_approx(ideal_p0,0.75,'chosen phase ideal P0')
check_approx(ideal_p1,0.25,'chosen phase ideal P1')

-- ---------------------------------------------------------------------------
-- Scenario 1: no which-path record. Full interference.
-- ---------------------------------------------------------------------------
do
  local w=make_world(); local s=prepared_state()
  commit_path(w,PREP)
  assert_boundary(w,false,false,'no-record after prepare')
  local p0,p1=detector_probs(s)
  check_approx(coherence_abs(s),0.5,'unrecorded path coherence')
  check_approx(p0,ideal_p0,'unrecorded fringe P0')
  check_approx(p1,ideal_p1,'unrecorded fringe P1')
end

-- ---------------------------------------------------------------------------
-- Scenario 2: live quantum which-path record retained. The exact Worlds
-- boundary now says a record exists; Theory entangles path with that marker.
-- Ignoring marker gives a fully decohered path and flat detector probabilities.
-- ---------------------------------------------------------------------------
local marked_stats
do
  local w=make_world(); local s=prepared_state()
  commit_path(w,PREP)
  commit_path_other(w,MARK,'marker')
  s=apply_cnot(s,0,1)
  assert_boundary(w,true,false,'marked')
  local p0,p1=detector_probs(s)
  check_approx(coherence_abs(s),0,'which-path marker must kill reduced path coherence')
  check_approx(p0,0.5,'marked detector P0')
  check_approx(p1,0.5,'marked detector P1')
  marked_stats={p0=p0,p1=p1,coh=coherence_abs(s)}
end

-- ---------------------------------------------------------------------------
-- Scenario 3: coherently erase the *only* record before recombination.
-- The record Strand is consumed/reissued Ready and Theory uncomputes the CNOT.
-- Coherence and the original fringe return exactly.
-- ---------------------------------------------------------------------------
local erased_stats
do
  local w=make_world(); local s=prepared_state()
  commit_path(w,PREP)
  commit_path_other(w,MARK,'marker'); s=apply_cnot(s,0,1)
  commit_path_other(w,ERASE_MARK,'marker'); s=apply_cnot(s,0,1)
  assert_boundary(w,false,false,'local record erased')
  local p0,p1=detector_probs(s)
  check_approx(coherence_abs(s),0.5,'coherent erasure must restore path coherence')
  check_approx(p0,ideal_p0,'erased detector P0')
  check_approx(p1,ideal_p1,'erased detector P1')
  erased_stats={p0=p0,p1=p1,coh=coherence_abs(s)}
end

-- ---------------------------------------------------------------------------
-- Scenario 4: copy the which-path record into a separate live environment,
-- then erase only the local marker. The local marker is Ready again, but an
-- environment Record Strand remains on the exact boundary. Theory correspondingly
-- retains path/environment entanglement, so interference does NOT return.
-- ---------------------------------------------------------------------------
local leaked_stats
do
  local w=make_world(); local s=prepared_state()
  commit_path(w,PREP)
  commit_path_other(w,MARK,'marker'); s=apply_cnot(s,0,1)
  commit_copy(w); s=apply_cnot(s,1,2)
  commit_path_other(w,ERASE_MARK,'marker'); s=apply_cnot(s,0,1)
  assert_boundary(w,false,true,'environment record survives')
  local p0,p1=detector_probs(s)
  check_approx(coherence_abs(s),0,'surviving environment record must retain decoherence')
  check_approx(p0,0.5,'environment-record detector P0')
  check_approx(p1,0.5,'environment-record detector P1')
  leaked_stats={p0=p0,p1=p1,coh=coherence_abs(s)}
end

-- ---------------------------------------------------------------------------
-- Scenario 5: erase every live copy coherently. Once the environment record is
-- also consumed/reissued Ready and uncomputed, the boundary contains no surviving
-- which-path record and Theory coherence returns.
-- ---------------------------------------------------------------------------
local full_erase_stats
do
  local w=make_world(); local s=prepared_state()
  commit_path(w,PREP)
  commit_path_other(w,MARK,'marker'); s=apply_cnot(s,0,1)
  commit_copy(w); s=apply_cnot(s,1,2)
  commit_path_other(w,ERASE_MARK,'marker'); s=apply_cnot(s,0,1)
  commit_path_other(w,ERASE_ENV,'env'); s=apply_cnot(s,0,2)
  assert_boundary(w,false,false,'all records erased')
  local p0,p1=detector_probs(s)
  check_approx(coherence_abs(s),0.5,'complete coherent erasure must restore coherence')
  check_approx(p0,ideal_p0,'full-erasure detector P0')
  check_approx(p1,ideal_p1,'full-erasure detector P1')
  full_erase_stats={p0=p0,p1=p1,coh=coherence_abs(s)}
end

-- A direct statement of boundary sufficiency for this toy:
-- after the local marker is erased, two executions with identical local path/marker
-- situation differ in future behaviour exactly because one live environment record
-- remains. Forgetting that live record would predict the wrong future fringe.
check_approx(erased_stats.p0,0.75,'no surviving record predicts fringe')
check_approx(leaked_stats.p0,0.5,'surviving record predicts flat distribution')
check(math.abs(erased_stats.p0-leaked_stats.p0)>0.2,'record boundary must materially affect future prediction')

print('Quantum Worlds interference/record toy: PASS')
print(string.format('  phase phi = pi/3'))
print(string.format('  no record:                  coherence=%.3f  detector=(%.3f, %.3f)',0.5,ideal_p0,ideal_p1))
print(string.format('  live which-path record:     coherence=%.3f  detector=(%.3f, %.3f)',marked_stats.coh,marked_stats.p0,marked_stats.p1))
print(string.format('  coherent local erasure:     coherence=%.3f  detector=(%.3f, %.3f)',erased_stats.coh,erased_stats.p0,erased_stats.p1))
print(string.format('  copied env record survives: coherence=%.3f  detector=(%.3f, %.3f)',leaked_stats.coh,leaked_stats.p0,leaked_stats.p1))
print(string.format('  erase every live record:    coherence=%.3f  detector=(%.3f, %.3f)',full_erase_stats.coh,full_erase_stats.p0,full_erase_stats.p1))
print('  all compound record/erase Faces map to the exact membrane LCA of their causal support')
print('  operational boundary remains exactly three live authorities throughout')
print('  future interference differs exactly when distinguishing record authority remains live')
