-- Modern factor-incidence experiments for Worlds 0.6.2.
--
-- Hypothesis under test:
--   the apparent "anti-causal" factor/configuration geometry may already be
--   present in Worlds as Point incidence on open Strands. Points act as exact
--   shared coordinates; Strands act as exact factor occurrences; Faces act on
--   those scopes causally (preserve/copy/create/eliminate), while Theory owns
--   the algebra carried by the scopes.

package.path='./src/?.lua;./src/?/init.lua;'..package.path

local W = require('worlds')
local Query = require('worlds.query')

local assertions = 0
local function ok(x,msg) assertions=assertions+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) assertions=assertions+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function decided(q, fuel)
  while true do
    local k,x=q:step(fuel or math.huge)
    if k~='more' then return k,x end
  end
end

local function first_match(world, dev, sources, targets, seeds)
  local q=Query.solve(Query.match(world,dev,{
    sources=sources,
    targets=targets,
    required_targets=targets,
    seeds=seeds or {},
  }))
  local k,e=decided(q)
  return k,e
end

local function names(xs)
  local r={}
  for i,x in ipairs(xs) do r[i]=W.name(x) or '?' end
  return table.concat(r,',')
end

local function same_points(s, xs)
  local ps=W.points(s)
  if #ps~=#xs then return false end
  for i=1,#xs do if ps[i]~=xs[i] then return false end end
  return true
end

local function count(tbl) local n=0; for _ in pairs(tbl) do n=n+1 end; return n end

-- --------------------------------------------------------------------------
-- 1. Boundary Geometry already contains an ordered hypergraph:
--    Points are vertices, open Strands are ordered hyperedges.
-- --------------------------------------------------------------------------
do
  local b=W.builder(); local m=b:membrane(nil,'factors')
  local i=b:point(m,'i'); local j=b:point(m,'j'); local k=b:point(m,'k')
  local A=b:strand(m,{i,j,k},'A_ijk')
  local B=b:strand(m,{k,i},'B_ki')
  local T=b:strand(m,{i,i},'T_ii')
  local g=b:finish()
  eq(#g:faces(),0,'factor hypergraph has no causal Faces')
  eq(#g:egress(),3)
  ok(same_points(A,{i,j,k}),'rank-3 factor scope is ordered Point incidence')
  ok(same_points(B,{k,i}),'shared coordinates are exact shared Points')
  ok(same_points(T,{i,i}),'repeated coordinate/diagonal multiplicity is representable')
  eq(W.points(A)[1],W.points(B)[2],'i shared across factors')
  eq(W.points(A)[3],W.points(B)[1],'k shared across factors')
end

-- --------------------------------------------------------------------------
-- 2. A generic matrix/tensor contraction pattern is ordinary matching.
--    Local pattern Point K must map to the SAME exact source coordinate on
--    both factor Strands. The output keeps I,J and drops K.
-- --------------------------------------------------------------------------
local function matmul_pattern()
  local b=W.builder(); local m=b:membrane(nil,'contract')
  local I=b:point(m,'I'); local K=b:point(m,'K'); local J=b:point(m,'J')
  local a=b:strand(m,{I,K},'A(I,K)')
  local c=b:strand(m,{K,J},'B(K,J)')
  local out=b:strand(m,{I,J},'C(I,J)')
  local f=b:face(m,{a,c},{out},'contract K')
  return b:finish(),a,c,out,f,I,K,J
end

do
  local wb=W.builder(); local wm=wb:membrane(nil,'world')
  local i=wb:point(wm,'i'); local k=wb:point(wm,'k'); local j=wb:point(wm,'j')
  local A=wb:strand(wm,{i,k},'A'); local B=wb:strand(wm,{k,j},'B')
  local world=wb:finish()
  local dev,ai,bi,co=matmul_pattern()
  local kind,es=first_match(world,dev,{A,B},{ai,bi},{{from=A,to=ai},{from=B,to=bi}})
  eq(kind,'yes','shared coordinate contraction must match')
  local nextw,image=W.advance(world,dev,es)
  eq(#nextw:egress(),1)
  local C=image[co]
  ok(nextw:owns_strand(C),'result is live')
  ok(same_points(C,{i,j}),'contraction output reuses exact surviving coordinates')
  ok(not nextw:owns_point(k),'eliminated coordinate falls out of live boundary')
end

-- A superficially compatible pair with distinct middle coordinates MUST NOT match.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'world-wrong')
  local i=wb:point(wm,'i'); local k=wb:point(wm,'k'); local q=wb:point(wm,'q'); local j=wb:point(wm,'j')
  local A=wb:strand(wm,{i,k},'A'); local B=wb:strand(wm,{q,j},'B')
  local world=wb:finish()
  local dev,ai,bi=matmul_pattern()
  local kind=first_match(world,dev,{A,B},{ai,bi},{{from=A,to=ai},{from=B,to=bi}})
  ok(kind=='no','different exact middle coordinates must reject shared-K pattern')
end

-- --------------------------------------------------------------------------
-- 3. Equality patterns on coordinate occurrences: trace/diagonal.
--    {X,X} distinguishes a diagonal scope from {X,Y}; a set-valued "fibre"
--    overlay could not do this because it loses multiplicity.
-- --------------------------------------------------------------------------
local function trace_pattern()
  local b=W.builder(); local m=b:membrane(nil,'trace')
  local X=b:point(m,'X')
  local a=b:strand(m,{X,X},'A(X,X)')
  local out=b:strand(m,{},'scalar')
  b:face(m,{a},{out},'trace')
  return b:finish(),a,out
end

do
  local wb=W.builder(); local wm=wb:membrane(nil,'diag')
  local i=wb:point(wm,'i'); local D=wb:strand(wm,{i,i},'Dii'); local world=wb:finish()
  local dev,ain,sout=trace_pattern()
  local kind,es=first_match(world,dev,{D},{ain},{{from=D,to=ain}})
  eq(kind,'yes','repeated Point pattern must match diagonal incidence')
  local nw,img=W.advance(world,dev,es)
  eq(#W.points(img[sout]),0)
  eq(#nw:points(),0,'trace removes the hidden coordinate from live boundary')
end

do
  local wb=W.builder(); local wm=wb:membrane(nil,'offdiag')
  local i=wb:point(wm,'i'); local j=wb:point(wm,'j'); local A=wb:strand(wm,{i,j},'Aij'); local world=wb:finish()
  local dev,ain=trace_pattern()
  local kind=first_match(world,dev,{A},{ain},{{from=A,to=ain}})
  ok(kind=='no','distinct exact coordinates must not satisfy repeated-X pattern')
end

-- --------------------------------------------------------------------------
-- 4. Cyclic factor incidence is not causal cyclicity.
--    A(i,j), B(j,k), C(k,i) is a 3-cycle in Point/Strand incidence but contains
--    no Face cycle. Two contraction schedules both reduce it to a scalar.
-- --------------------------------------------------------------------------
local function binary_contract_pattern(label, left_slots, right_slots, out_slots)
  -- slots are symbolic names; equal names denote the same local Point.
  local b=W.builder(); local m=b:membrane(nil,label)
  local pts={}
  local function P(n) if not pts[n] then pts[n]=b:point(m,n) end; return pts[n] end
  local function tuple(ns) local r={}; for _,n in ipairs(ns) do r[#r+1]=P(n) end; return r end
  local a=b:strand(m,tuple(left_slots),'left')
  local c=b:strand(m,tuple(right_slots),'right')
  local o=b:strand(m,tuple(out_slots),'out')
  b:face(m,{a,c},{o},label)
  return b:finish(),a,c,o
end

local function apply_seeded(world,dev,a,b,srca,srcb,out)
  local kind,es=first_match(world,dev,{srca,srcb},{a,b},{{from=srca,to=a},{from=srcb,to=b}})
  eq(kind,'yes','seeded contraction must match')
  local nw,img=W.advance(world,dev,es)
  return nw,img[out]
end

do
  local wb=W.builder(); local wm=wb:membrane(nil,'triangle')
  local i=wb:point(wm,'i'); local j=wb:point(wm,'j'); local k=wb:point(wm,'k')
  local A=wb:strand(wm,{i,j},'Aij'); local B=wb:strand(wm,{j,k},'Bjk'); local C=wb:strand(wm,{k,i},'Cki')
  local initial=wb:finish()
  eq(#initial:faces(),0)
  ok(initial:is_developable(),'cyclic factor incidence is lawful face-free Geometry')

  -- (A B) C
  local d1,l1,r1,o1=binary_contract_pattern('AB over j',{'i','j'},{'j','k'},{'i','k'})
  local w1,D=apply_seeded(initial,d1,l1,r1,A,B,o1)
  eq(#w1:egress(),2,'untouched C plus contracted D survive')
  local d2,l2,r2,o2=binary_contract_pattern('DC over i,k',{'i','k'},{'k','i'},{})
  local w1f,S1=apply_seeded(w1,d2,l2,r2,D,C,o2)
  eq(#w1f:egress(),1); eq(#W.points(S1),0)

  -- A (B C)
  local e1,l3,r3,o3=binary_contract_pattern('BC over k',{'j','k'},{'k','i'},{'j','i'})
  local w2,E=apply_seeded(initial,e1,l3,r3,B,C,o3)
  local e2,l4,r4,o4=binary_contract_pattern('AE over i,j',{'i','j'},{'j','i'},{})
  local w2f,S2=apply_seeded(w2,e2,l4,r4,A,E,o4)
  eq(#w2f:egress(),1); eq(#W.points(S2),0)

  -- Causal histories are different, but both are acyclic and expose the same
  -- zero-coordinate factor shape.
  eq(#w1f:faces(),0,'advance returns boundary, so contraction history is not live authority')
  eq(#w2f:faces(),0)
end

-- Numeric check for the same triangle: trace(A B C) independent of schedule.
do
  local A={{1,2},{3,4}}
  local B={{0,5},{6,7}}
  local C={{2,1},{1,3}}
  local function mm(X,Y)
    local Z={{0,0},{0,0}}
    for i=1,2 do for j=1,2 do for k=1,2 do Z[i][j]=Z[i][j]+X[i][k]*Y[k][j] end end end
    return Z
  end
  local function tr(X) return X[1][1]+X[2][2] end
  eq(tr(mm(mm(A,B),C)),tr(mm(A,mm(B,C))),'tensor contraction algebra is schedule associative here')
end

-- --------------------------------------------------------------------------
-- 5. Face action on the transverse Point incidence already supports preserve,
--    explicit split/copy, merge/accumulate, fresh-coordinate creation and
--    elimination. No separate arbitrary "Face action on fibres" object needed
--    for these cases.
-- --------------------------------------------------------------------------
do
  local wb=W.builder(); local wm=wb:membrane(nil,'x-world'); local x=wb:point(wm,'x'); local s=wb:strand(wm,{x},'x'); local world=wb:finish()

  -- preserve
  local b=W.builder(); local m=b:membrane(nil,'preserve'); local X=b:point(m,'X'); local i=b:strand(m,{X}); local o=b:strand(m,{X}); b:face(m,{i},{o}); local d=b:finish()
  local k,es=first_match(world,d,{s},{i},{{from=s,to=i}}); eq(k,'yes'); local n,img=W.advance(world,d,es); ok(same_points(img[o],{x}))

  -- explicit split: one authority -> two occurrences, same exact coordinate
  local b2=W.builder(); local m2=b2:membrane(nil,'split'); local X2=b2:point(m2,'X'); local ii=b2:strand(m2,{X2}); local o1=b2:strand(m2,{X2}); local o2=b2:strand(m2,{X2}); b2:face(m2,{ii},{o1,o2}); local d2=b2:finish()
  local k2,e2=first_match(world,d2,{s},{ii},{{from=s,to=ii}}); eq(k2,'yes'); local n2,im2=W.advance(world,d2,e2); eq(#n2:egress(),2); eq(W.points(im2[o1])[1],x); eq(W.points(im2[o2])[1],x)
end

-- Merge requires two distinct scarce occurrences but may require the same exact
-- coordinate, which is precisely copy^T/add-like structure.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'two-x'); local x=wb:point(wm,'x'); local s1=wb:strand(wm,{x},'x1'); local s2=wb:strand(wm,{x},'x2'); local world=wb:finish()
  local b=W.builder(); local m=b:membrane(nil,'merge'); local X=b:point(m,'X'); local i1=b:strand(m,{X}); local i2=b:strand(m,{X}); local o=b:strand(m,{X}); b:face(m,{i1,i2},{o}); local d=b:finish()
  local k,es=first_match(world,d,{s1,s2},{i1,i2},{{from=s1,to=i1},{from=s2,to=i2}}); eq(k,'yes'); local n,img=W.advance(world,d,es); eq(#n:egress(),1); eq(W.points(img[o])[1],x)
end

-- Fresh coordinate creation shared by two outputs.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'fresh-world'); local x=wb:point(wm,'x'); local s=wb:strand(wm,{x}); local world=wb:finish()
  local b=W.builder(); local m=b:membrane(nil,'fresh'); local X=b:point(m,'X'); local Y=b:point(m,'Y'); local i=b:strand(m,{X}); local o1=b:strand(m,{Y}); local o2=b:strand(m,{Y}); b:face(m,{i},{o1,o2}); local d=b:finish()
  local k,es=first_match(world,d,{s},{i},{{from=s,to=i}}); eq(k,'yes'); local n,img=W.advance(world,d,es)
  local y1=W.points(img[o1])[1]; local y2=W.points(img[o2])[1]
  eq(y1,y2,'two outputs share one freshly materialised coordinate'); ok(y1~=x,'fresh coordinate is not input coordinate')
end

-- --------------------------------------------------------------------------
-- 6. Cross-cutting extensional scopes do not require non-laminar membranes.
--    They can coexist as arbitrary overlapping open Strand scopes.
-- --------------------------------------------------------------------------
do
  local b=W.builder(); local m=b:membrane(nil,'one causal locality')
  local a=b:point(m,'a'); local bb=b:point(m,'b'); local c=b:point(m,'c')
  local host=b:strand(m,{a,bb},'host-H1')
  local red=b:strand(m,{a,c},'security-red')
  local g=b:finish()
  eq(#g:membranes(),1)
  eq(#g:strands(),2)
  eq(W.points(host)[1],W.points(red)[1],'crossing extensional scopes share a without membrane overlap')
end

-- --------------------------------------------------------------------------
-- 7. Perverse candidate: set-valued fibre membership is too weak.
--    It cannot distinguish order or multiplicity, while current Strand incidence can.
-- --------------------------------------------------------------------------
do
  local function set_signature(xs)
    local s={}; for _,x in ipairs(xs) do s[x]=true end
    local ns={}; for x in pairs(s) do ns[#ns+1]=W.name(x) end; table.sort(ns); return table.concat(ns,',')
  end
  local b=W.builder(); local m=b:membrane(nil,'set-loss')
  local i=b:point(m,'i'); local j=b:point(m,'j')
  local Aij=b:strand(m,{i,j},'Aij'); local Aji=b:strand(m,{j,i},'Aji'); local Aii=b:strand(m,{i,i},'Aii'); local Ai=b:strand(m,{i},'Ai'); b:finish()
  eq(set_signature(W.points(Aij)),set_signature(W.points(Aji)),'set fibre model loses index order')
  eq(set_signature(W.points(Aii)),set_signature(W.points(Ai)),'set fibre model loses repeated-index multiplicity')
  ok(names(W.points(Aij))~=names(W.points(Aji)),'ordered Worlds incidence keeps order')
  ok(#W.points(Aii)~=#W.points(Ai),'ordered Worlds incidence keeps multiplicity')
end

-- --------------------------------------------------------------------------
-- 8. Perverse candidate: a separate generic Factor-hypergraph carrier largely
--    duplicates face-free Worlds boundary structure. Round-trip scopes exactly.
-- --------------------------------------------------------------------------
do
  local hyper={
    {name='A', vars={'i','j','k'}},
    {name='B', vars={'k','i'}},
    {name='C', vars={'j','j'}},
  }
  local b=W.builder(); local m=b:membrane(nil,'roundtrip')
  local pby={}; local sby={}
  local function point(v) if not pby[v] then pby[v]=b:point(m,v) end; return pby[v] end
  for _,f in ipairs(hyper) do local ps={}; for _,v in ipairs(f.vars) do ps[#ps+1]=point(v) end; sby[f.name]=b:strand(m,ps,f.name) end
  local g=b:finish()
  for _,f in ipairs(hyper) do
    local ps=W.points(sby[f.name]); eq(#ps,#f.vars)
    for n,v in ipairs(f.vars) do eq(W.name(ps[n]),v,'factor scope roundtrip') end
  end
  eq(#g:faces(),0)
end

-- --------------------------------------------------------------------------
-- 9. Perverse candidate: dummy-coordinate exactness is harmless when the dummy
--    is truly internal. Two alternative paths share the SAME exact external
--    coordinates i,j but use distinct exact internal k1/k2. Contracting either
--    path exposes the same exact external coordinate tuple and drops its dummy.
-- --------------------------------------------------------------------------
do
  local wb=W.builder(); local wm=wb:membrane(nil,'alpha')
  local i=wb:point(wm,'i'); local j=wb:point(wm,'j')
  local k1=wb:point(wm,'k1'); local k2=wb:point(wm,'k2')
  local A1=wb:strand(wm,{i,k1},'A1'); local B1=wb:strand(wm,{k1,j},'B1')
  local A2=wb:strand(wm,{i,k2},'A2'); local B2=wb:strand(wm,{k2,j},'B2')
  local initial=wb:finish()

  local d,ai,bi,co=matmul_pattern()
  local q1,e1=first_match(initial,d,{A1,B1},{ai,bi},{{from=A1,to=ai},{from=B1,to=bi}}); eq(q1,'yes')
  local n1,im1=W.advance(initial,d,e1); local c1=im1[co]
  local q2,e2=first_match(initial,d,{A2,B2},{ai,bi},{{from=A2,to=ai},{from=B2,to=bi}}); eq(q2,'yes')
  local n2,im2=W.advance(initial,d,e2); local c2=im2[co]
  ok(k1~=k2,'dummy coordinates are exact-distinct')
  ok(same_points(c1,{i,j}) and same_points(c2,{i,j}),'distinct internal dummy identities expose the same exact outer coordinates')
  ok(not n1:owns_point(k1) and not n2:owns_point(k2),'the contracted dummy drops from each corresponding live result')
end

-- --------------------------------------------------------------------------
-- 10. Variable elimination fill-in is directly visible as output Point scope.
--     Factors F(x,y), G(y,z), H(y,w) share y. Eliminating y across all three
--     naturally creates a factor on x,z,w. This is the graph/treewidth geometry
--     common to sparse elimination, factor graphs and tensor contraction.
-- --------------------------------------------------------------------------
do
  local wb=W.builder(); local wm=wb:membrane(nil,'fill')
  local x=wb:point(wm,'x'); local y=wb:point(wm,'y'); local z=wb:point(wm,'z'); local w=wb:point(wm,'w')
  local F=wb:strand(wm,{x,y},'F'); local G=wb:strand(wm,{y,z},'G'); local H=wb:strand(wm,{y,w},'H'); local world=wb:finish()

  local b=W.builder(); local m=b:membrane(nil,'eliminate-y')
  local X=b:point(m,'X'); local Y=b:point(m,'Y'); local Z=b:point(m,'Z'); local Wp=b:point(m,'W')
  local fi=b:strand(m,{X,Y}); local gi=b:strand(m,{Y,Z}); local hi=b:strand(m,{Y,Wp}); local out=b:strand(m,{X,Z,Wp}); b:face(m,{fi,gi,hi},{out}); local dev=b:finish()
  local kind,es=first_match(world,dev,{F,G,H},{fi,gi,hi},{{from=F,to=fi},{from=G,to=gi},{from=H,to=hi}}); eq(kind,'yes')
  local nw,img=W.advance(world,dev,es)
  ok(same_points(img[out],{x,z,w}),'elimination fill-in is the surviving neighbour scope')
  ok(not nw:owns_point(y),'fully eliminated y disappears')
end

-- --------------------------------------------------------------------------
-- 11. Quantum/tensor thread: the SAME factor-scope geometry supports either
--     probability sum-product or complex-amplitude contraction. Interference is
--     algebra, not extra incidence. H * phase(pi) * H maps |0> to |1> in amplitudes;
--     a classical stochastic reading of the two H scopes does not.
-- --------------------------------------------------------------------------
do
  local rt=math.sqrt(0.5)
  local H={{rt,rt},{rt,-rt}}
  local P={{1,0},{0,-1}}
  local ket0={1,0}
  local function mv(M,v) return {M[1][1]*v[1]+M[1][2]*v[2], M[2][1]*v[1]+M[2][2]*v[2]} end
  local v=mv(H,mv(P,mv(H,ket0)))
  ok(math.abs(v[1])<1e-12 and math.abs(v[2]-1)<1e-12,'amplitude algebra gives destructive/constructive interference')

  -- Classicalise H to transition probabilities |H_ij|^2 = 1/2; the phase gate
  -- becomes observationally the identity. Result remains uniform, not |1>.
  local S={{0.5,0.5},{0.5,0.5}}
  local p=mv(S,mv({{1,0},{0,1}},mv(S,ket0)))
  ok(math.abs(p[1]-0.5)<1e-12 and math.abs(p[2]-0.5)<1e-12,'same scope topology with probability algebra has no phase interference')
end


-- --------------------------------------------------------------------------
-- 12. Unseeded matching can discover factor-compatible pairs from Point sharing.
--     Thus the existing Worlds query judgement can already operate as a scarce
--     structural matcher over factor scopes; no factor-specific search primitive.
-- --------------------------------------------------------------------------
do
  local wb=W.builder(); local wm=wb:membrane(nil,'discover')
  local i=wb:point(wm,'i'); local k=wb:point(wm,'k'); local j=wb:point(wm,'j')
  local p=wb:point(wm,'p'); local q=wb:point(wm,'q'); local r=wb:point(wm,'r')
  local A=wb:strand(wm,{i,k},'A'); local B=wb:strand(wm,{k,j},'B')
  local D=wb:strand(wm,{p,q},'D'); local E=wb:strand(wm,{q,r},'E')
  local bad=wb:strand(wm,{i,r},'bad')
  local world=wb:finish()
  local dev,ai,bi=matmul_pattern()
  local qq=Query.solve(Query.match(world,dev,{sources={A,B,D,E,bad},targets={ai,bi},required_targets={ai,bi}}))
  local pairs={}
  while true do
    local tag,es=decided(qq)
    if tag=='yes' then
      local by={}; for _,e in ipairs(es) do by[e.to]=e.from end
      pairs[(W.name(by[ai]) or '?')..'+'..(W.name(by[bi]) or '?')]=true
    elseif tag=='done' or tag=='no' then break else error(tag) end
  end
  ok(pairs['A+B'],'matcher discovers first shared-coordinate chain')
  ok(pairs['D+E'],'matcher discovers second shared-coordinate chain')
  eq(count(pairs),2,'no structurally incompatible pair should satisfy shared-K pattern')
end

-- --------------------------------------------------------------------------
-- 13. Elimination-order complexity is visible without knowing the algebra.
--     The open Point/Strand incidence alone determines the star of a variable
--     and the fill-in scope created by eliminating it.
-- --------------------------------------------------------------------------
local function open_star(g,p)
  local hit={}
  for _,s in ipairs(g:egress()) do
    for _,q in ipairs(W.points(s)) do if q==p then hit[#hit+1]=s; break end end
  end
  return hit
end

local function fill_scope(g,p)
  local seen,scope={},{}
  for _,s in ipairs(open_star(g,p)) do
    for _,q in ipairs(W.points(s)) do
      if q~=p and not seen[q] then seen[q]=true; scope[#scope+1]=q end
    end
  end
  return scope
end

do
  local b=W.builder(); local m=b:membrane(nil,'star-width')
  local y=b:point(m,'y'); local a=b:point(m,'a'); local c=b:point(m,'c'); local d=b:point(m,'d'); local e=b:point(m,'e')
  b:strand(m,{y,a},'ya'); b:strand(m,{y,c},'yc'); b:strand(m,{y,d},'yd'); b:strand(m,{y,e},'ye')
  local g=b:finish()
  eq(#open_star(g,y),4)
  eq(#fill_scope(g,y),4,'eliminating star centre creates a four-coordinate fill factor')
  eq(#open_star(g,a),1)
  eq(#fill_scope(g,a),1,'eliminating a leaf creates only a unary factor')
end

-- --------------------------------------------------------------------------
-- 14. An important limit: Point/Strand incidence geometrises dependency scope,
--     not the domain algebra. Identical scope topology can support incompatible
--     semantics. The geometry can expose WHERE elimination happens, but Theory
--     must still say whether elimination means exists, sum, min, integral, etc.
-- --------------------------------------------------------------------------
do
  local b=W.builder(); local m=b:membrane(nil,'same-shape-different-algebra')
  local x=b:point(m,'x'); local y=b:point(m,'y'); local z=b:point(m,'z')
  local F=b:strand(m,{x,y},'F'); local G=b:strand(m,{y,z},'G'); local g=b:finish()
  eq(#open_star(g,y),2)
  local fs=fill_scope(g,y); eq(#fs,2)
  ok((fs[1]==x and fs[2]==z) or (fs[1]==z and fs[2]==x),'scope says only that x,z become coupled')
  -- It intentionally says nothing about whether the new x-z relation is NAND,
  -- a matrix product, a shortest-path cost, a marginal, or an amplitude sum.
end


-- --------------------------------------------------------------------------
-- 15. The transverse Point incidence is not independent of membranes.
--     A shared coordinate can live at an enclosing locality while factor
--     occurrences inhabit sibling localities; a causal contraction at the root
--     consumes both and produces a root result carrying the surviving child Points.
-- --------------------------------------------------------------------------
do
  local wb=W.builder(); local rootm=wb:membrane(nil,'root'); local lm=wb:membrane(rootm,'left'); local rm=wb:membrane(rootm,'right')
  local i=wb:point(lm,'i'); local k=wb:point(rootm,'k'); local j=wb:point(rm,'j')
  local A=wb:strand(lm,{i,k},'A-left'); local B=wb:strand(rm,{k,j},'B-right'); local world=wb:finish()

  local b=W.builder(); local r=b:membrane(nil,'R'); local l=b:membrane(r,'L'); local rr=b:membrane(r,'RR')
  local I=b:point(l,'I'); local K=b:point(r,'K'); local J=b:point(rr,'J')
  local ai=b:strand(l,{I,K},'left-factor'); local bi=b:strand(rr,{K,J},'right-factor'); local out=b:strand(r,{I,J},'joined-factor')
  b:face(r,{ai,bi},{out},'cross-local contraction'); local dev=b:finish()
  local kind,es=first_match(world,dev,{A,B},{ai,bi},{{from=A,to=ai},{from=B,to=bi}}); eq(kind,'yes')
  local nw,img=W.advance(world,dev,es); local C=img[out]
  ok(same_points(C,{i,j}),'cross-local contraction keeps exact outer coordinates')
  eq(W.membrane(C),rootm,'result factor inhabits the common enclosing membrane')
  eq(#nw:egress(),1)
end


-- --------------------------------------------------------------------------
-- 16. Quantum/separability pressure: Geometry can represent factorisation and
--     its change, but MUST NOT decide whether a joint factor may split.
--     Worlds structurally permits joint {q,e} -> {q},{e}; a Bell amplitude has
--     rank 2 and cannot actually factor, whereas a product amplitude has rank 1.
--     This is a clean boundary: factorisation SHAPE is geometric; factorisation
--     LAWFULNESS is Theory.
-- --------------------------------------------------------------------------
do
  local wb=W.builder(); local wm=wb:membrane(nil,'separable')
  local q=wb:point(wm,'q'); local e=wb:point(wm,'e')
  local qs=wb:strand(wm,{q},'Q'); local es=wb:strand(wm,{e},'E'); local world=wb:finish()

  local mb=W.builder(); local mm=mb:membrane(nil,'merge-factors')
  local Q=mb:point(mm,'Q'); local E=mb:point(mm,'E')
  local qi=mb:strand(mm,{Q}); local ei=mb:strand(mm,{E}); local joint=mb:strand(mm,{Q,E})
  mb:face(mm,{qi,ei},{joint},'form joint factor'); local merge=mb:finish()
  local mk,mes=first_match(world,merge,{qs,es},{qi,ei},{{from=qs,to=qi},{from=es,to=ei}}); eq(mk,'yes')
  local jw,jimg=W.advance(world,merge,mes); local js=jimg[joint]; ok(same_points(js,{q,e}))

  local sb=W.builder(); local sm=sb:membrane(nil,'split-factor')
  local SQ=sb:point(sm,'Q'); local SE=sb:point(sm,'E'); local jin=sb:strand(sm,{SQ,SE}); local qo=sb:strand(sm,{SQ}); local eo=sb:strand(sm,{SE})
  sb:face(sm,{jin},{qo,eo},'factorise'); local split=sb:finish()
  local sk,ses=first_match(jw,split,{js},{jin},{{from=js,to=jin}}); eq(sk,'yes','Worlds alone structurally permits factor split')

  local rt=math.sqrt(0.5)
  local bell={{rt,0},{0,rt}}
  local product={{rt,0},{rt,0}}
  local function det2(M) return M[1][1]*M[2][2]-M[1][2]*M[2][1] end
  ok(math.abs(det2(bell))>1e-12,'Bell amplitude has rank 2: split would be semantically false')
  ok(math.abs(det2(product))<1e-12,'product amplitude has rank 1: split can be semantically lawful')
end

print(string.format('Transverse-axis experiments: PASS (%d assertions)',assertions))
print('Key observation: Point incidence on open Strands already behaves as an ordered factor/configuration hypergraph.')
print('Faces already act on that transverse incidence by preserving, copying, creating and eliminating exact Points.')
print('Domain algebra (Boolean/probability/tensor amplitude/polynomial/etc.) still belongs outside Geometry.')
