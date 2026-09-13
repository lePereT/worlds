package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S = require('speculation.support')
local W = S.W
local G = S.G
local O = S.O
local Aop = S.A

local function printf(...) io.write(string.format(...), '\n') end
local function fact(n) local x=1; for i=2,n do x=x*i end; return x end

print('WORLDS BODYLINE TESTS')

-- 1. "2-complex" stress: arbitrary Point incidence may change across a Face.
do
  local b=G.builder(); local m=b:membrane(nil,'root')
  local A=b:point(m,'A'); local B=b:point(m,'B'); local C=b:point(m,'C')
  local i=b:strand(m,{A},'i'); local o=b:strand(m,{B,C},'o')
  b:face(m,{i},{o},'arbitrary-incidence-change')
  local g=b:finish()
  assert(W.is_geometry(g))
  printf('T1 accepted arbitrary 1-point -> 2-point incidence across Face: faces=%d',#g:faces())
end

-- Vocabulary used by later tests.
local vb=G.builder(); local vm=vb:membrane(nil,'vocab')
local Control=vb:point(vm,'Control'); local Handle=vb:point(vm,'Handle'); local Reborn=vb:point(vm,'Reborn'); local A=vb:point(vm,'A')
vb:finish()

-- 2. Retained Point identity can be re-imported after no live Strand carries it.
do
  local hb=G.builder(); local hm=hb:membrane(nil,'root'); local ctl=hb:strand(hm,{Control},'ctl')
  local boundary=O.from_geometry(hb:finish())

  local cb=G.builder(); local cm=cb:membrane(nil,'create'); local ci=cb:strand(cm,{Control}); local co=cb:strand(cm,{Control});
  local x=cb:point(cm,'fresh'); local ho=cb:strand(cm,{Handle,x}); cb:face(cm,{ci},{co,ho}); local create=cb:finish()
  local cw=assert(O.one(boundary,create,{strands={[ci]=ctl}})); local _,cimg=O.commit(cw)
  local p=cimg.points[x]; local live_ctl=cimg.strands[co]; local live_handle=cimg.strands[ho]

  local rb=G.builder(); local rm=rb:membrane(nil,'retire'); local rx=rb:point(rm,'x'); local ri=rb:strand(rm,{Handle,rx}); rb:face(rm,{ri},{},'retire'); local retire=rb:finish()
  local rw=assert(O.one(boundary,retire,{strands={[ri]=live_handle}})); O.commit(rw)
  -- p is now held only by host variable `p`; no live Strand should carry it.
  for _,s in ipairs(boundary:offers()) do for _,q in ipairs(G.points(s)) do assert(q~=p,'fresh Point unexpectedly remains on boundary') end end

  local xb=G.builder(); local xm=xb:membrane(nil,'resurrect'); local xi=xb:strand(xm,{Control}); local xo=xb:strand(xm,{Control});
  local resurrected=xb:strand(xm,{Reborn,p},'reborn'); xb:face(xm,{xi},{xo,resurrected}); local resurrect=xb:finish()
  local xw=assert(O.one(boundary,resurrect,{strands={[xi]=live_ctl}})); local _,ximg=O.commit(xw)
  local out=ximg.strands[resurrected]
  assert(G.points(out)[2]==p)
  printf('T2 historical Point identity resurrected from host-held rigid reference after leaving boundary: YES')
end

-- 3. Symmetry explosion for k identical reactant slots among n exact offers.
do
  local n,k=8,4
  local bb=G.builder(); local bm=bb:membrane(nil,'vessel'); local offers={}
  for i=1,n do offers[i]=bb:strand(bm,{A},'A'..i) end
  local world=bb:finish()
  local pb=G.builder(); local pm=pb:membrane(nil,'reaction'); local demands={}
  for i=1,k do demands[i]=pb:strand(pm,{A},'slot'..i) end
  local p=pb:finish()
  local cuts=S.solve_all(world,p,{offers=offers})
  local raw=#cuts
  local comb=1; for i=1,k do comb=comb*(n-k+i)/i end
  assert(raw==fact(n)/fact(n-k))
  printf('T3 exact Cut witnesses for %d identical slots from %d offers: %d; unordered combinations: %d; redundancy factor: %d!',k,n,raw,comb,raw/comb)
end

-- 4. Distinct sibling pattern Membranes may collapse to one exact offered locality.
do
  local hb=G.builder(); local hr=hb:membrane(nil,'host'); local hc=hb:membrane(hr,'one-child')
  local s1=hb:strand(hc,{A},'a1'); local s2=hb:strand(hc,{A},'a2'); local host=hb:finish()
  local pb=G.builder(); local pr=pb:membrane(nil,'p'); local p1=pb:membrane(pr,'left'); local p2=pb:membrane(pr,'right')
  local d1=pb:strand(p1,{A},'d1'); local d2=pb:strand(p2,{A},'d2'); local pat=pb:finish()
  local live=O.from_geometry(host); local cuts=O.all(live,pat,{offers={s1,s2}})
  assert(#cuts==2)
  local c=cuts[1]
  assert(c:membrane(p1)==hc and c:membrane(p2)==hc)
  printf('T4 distinct sibling pattern membranes may map to the SAME offered membrane: YES')
end

-- 5. Cross-cutting contextual families are not laminar, hence no single membrane tree can contain both.
do
  local function subset(a,b) for x in pairs(a) do if not b[x] then return false end end; return true end
  local function disjoint(a,b) for x in pairs(a) do if b[x] then return false end end; return true end
  local AB={a=true,b=true}; local AC={a=true,c=true}
  local laminar = disjoint(AB,AC) or subset(AB,AC) or subset(AC,AB)
  assert(not laminar)
  printf('T5 desired contexts {a,b} and {a,c} cross without containment: not representable as clusters of one membrane tree')
end

-- 6. Two semantically same-shaped causal reissues retain different exact boundary occurrences.
do
  local function one_step()
    local hb=G.builder(); local hm=hb:membrane(nil,'r'); local ctl=hb:strand(hm,{Control}); local bd=O.from_geometry(hb:finish())
    local pb=G.builder(); local pm=pb:membrane(nil,'p'); local pi=pb:strand(pm,{Control}); local po=pb:strand(pm,{Control}); pb:face(pm,{pi},{po}); local p=pb:finish()
    local w=assert(O.one(bd,p,{strands={[pi]=ctl}})); local _,img=O.commit(w)
    return img.strands[po]
  end
  local x,y=one_step(),one_step()
  assert(x~=y and G.points(x)[1]==G.points(y)[1])
  printf('T6 extensionally identical one-step boundaries remain exact-distinct occurrences: YES')
end

print('BODYLINE COMPLETE')

-- 7. SCC normalisation erases internal cycle cardinality/topology when external interface agrees.
do
  local vb=G.builder(); local vm=vb:membrane(nil,'v2'); local Ctl=vb:point(vm,'Ctl2'); local Done=vb:point(vm,'Done2'); local roles={}
  for i=1,3 do roles[i]=vb:point(vm,'R'..i) end
  vb:finish()
  local function ring(n)
    local parts,ins,outs,ctls,dones={},{},{},{},{}
    for i=1,n do
      local b=G.builder(); local m=b:membrane(nil,'lane'..i)
      local ri=roles[((i-2)%n)+1] or roles[1]
      local ro=roles[((i-1)%n)+1] or roles[1]
      -- use a shared generic point-variable instead of role matching complexity
      local x=b:point(m,'x'); local si=b:strand(m,{x},'in'); local input={si}
      if i==1 then local c=b:strand(m,{Ctl},'ctl'); input[#input+1]=c; ctls[i]=c end
      local so=b:strand(m,{x},'out'); local outputs={so}
      if i==n then local d=b:strand(m,{Done},'done'); outputs[#outputs+1]=d; dones[i]=d end
      b:face(m,input,outputs,'F'..i)
      parts[i]=b:finish(); ins[i]=si; outs[i]=so
    end
    local links={}; for i=1,n do local j=(i%n)+1; links[#links+1]={outs[i],ins[j]} end
    local g=Aop.close(parts,links)
    return g
  end
  local g2=ring(2); local g3=ring(3)
  assert(#g2:faces()==1 and #g3:faces()==1)
  assert(#g2:ingress()==1 and #g3:ingress()==1)
  assert(#g2:egress()==1 and #g3:egress()==1)
  printf('T7 2-cycle and 3-cycle both normalise to one joint Face with same 1-in/1-out shape: internal cycle cardinality erased')
end

-- 8. Scarcity is not a conservation law: one consumed authority may generate arbitrarily many outputs.
do
  local hb=G.builder(); local hm=hb:membrane(nil,'root'); local ctl=hb:strand(hm,{Control}); local bd=O.from_geometry(hb:finish())
  local pb=G.builder(); local pm=pb:membrane(nil,'fanout'); local pi=pb:strand(pm,{Control}); local outs={}
  for i=1,1000 do local x=pb:point(pm,'x'..i); outs[i]=pb:strand(pm,{x},'out'..i) end
  pb:face(pm,{pi},outs,'fanout'); local p=pb:finish()
  local w=assert(O.one(bd,p,{strands={[pi]=ctl}})); O.commit(w)
  assert(bd:size()==1000)
  printf('T8 one consumed authority generated 1000 fresh live authorities: scarcity is exclusivity, not conservation')
end

-- 9. Distinct local Point variables can unify to one exact host Point.
do
  local hb=G.builder(); local hm=hb:membrane(nil,'host'); local P=hb:point(hm,'P'); local s1=hb:strand(hm,{P}); local s2=hb:strand(hm,{P}); local host=hb:finish()
  local pb=G.builder(); local pm=pb:membrane(nil,'pattern'); local x=pb:point(pm,'x'); local y=pb:point(pm,'y'); local d1=pb:strand(pm,{x}); local d2=pb:strand(pm,{y}); local p=pb:finish()
  local cuts=O.all(O.from_geometry(host),p,{offers={s1,s2}}); assert(#cuts==2)
  assert(cuts[1]:point(x)==P and cuts[1]:point(y)==P)
  printf('T9 distinct local ingress Points x,y may unify to the SAME exact host Point: no intrinsic disequality')
end
