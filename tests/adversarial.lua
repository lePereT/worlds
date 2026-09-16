package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local n=0; local function ok(x,m) n=n+1; assert(x,m) end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function decided(q,b) while true do local k,x=q:step(b or math.huge); if k~='more' then return k,x end end end
local function shared_world(groups,per)
  local b=W.builder(); local m=b:membrane(nil); local ps={}
  for i=1,groups do local p=b:point(m); ps[i]=p; for _=1,per do b:strand(m,{p}) end end
  return b:finish(),ps,m
end
local function independent(k) local b=W.builder(); local m=b:membrane(nil); for _=1,k do local p=b:point(m); b:strand(m,{p}) end; return b:finish() end
local function shared(k) local b=W.builder(); local m=b:membrane(nil); local p=b:point(m); for _=1,k do b:strand(m,{p}) end; return b:finish() end
local function bipartite(s)
  local b=W.builder(); local m=b:membrane(nil); local a,c={},{}
  for i=1,s do a[i]=b:point(m); c[i]=b:point(m) end
  for i=1,s do for j=1,s do b:strand(m,{a[i],c[j]}); b:strand(m,{c[j],a[i]}) end end
  return b:finish()
end
local function cycle(k) local b=W.builder(); local m=b:membrane(nil); local p={}; for i=1,k do p[i]=b:point(m) end; for i=1,k do b:strand(m,{p[i],p[i%k+1]}) end; return b:finish() end

-- solve is retained from the first unit of work and all expensive work is fuelled.
do
  local q=W.solve(shared_world(2000,1),shared(2))
  local k=q:step(8); eq(k,'more')
end

-- Private distinctions coalesce semantically: the broad case yields immediately
-- under an unbounded step and does not manufacture extra structural distinctions.
do
  local q=W.solve(shared_world(1,1000),independent(1000)); local k=decided(q); eq(k,'yes')
end

-- Generic coordinate postings: a rigid point amongst 100,000 incidence groups
-- remains a direct lookup path (timed externally; semantics asserted here).
do
  local world,ps=shared_world(100000,1); local b=W.builder(); local m=b:membrane(nil); b:strand(m,{ps[77777]}); local pat=b:finish()
  local q=W.solve(world,pat); local k=decided(q); eq(k,'yes')
end

-- Factorisation, not structural DFS, proves odd-cycle impossibility.
do
  local world=bipartite(5)
  for _,len in ipairs{3,5,7,9,11} do
    local q=W.solve(world,cycle(len)); local k,no=decided(q)
    eq(k,'no','odd cycle '..len); ok(Query.is_refutation(no)); eq(no:reason().kind,'empty-join')
  end
end

-- Exact permutation complexity exists only in the fibre allocator; the retained
-- structural factor graph has one solution.
do
  local cases={{8,4,1680},{9,4,3024},{10,4,5040},{10,5,30240}}
  for _,c in ipairs(cases) do
    local q=W.solve(shared_world(1,c[1]),independent(c[2])); local hits=0
    while true do local k=q:step(math.huge); if k=='yes' then hits=hits+1 elseif k=='done' then break elseif k~='more' then error(k) end end
    eq(hits,c[3])
  end
end

-- Distinct structural atoms can overlap in exact fibres; structural success is
-- not allowed to manufacture scarce authority.
do
  local wb=W.builder(); local wm=wb:membrane(nil); local rigid=wb:point(wm); wb:strand(wm,{rigid}); local world=wb:finish()
  local p=W.builder(); local pm=p:membrane(nil); local x=p:point(pm); p:strand(pm,{x}); p:strand(pm,{rigid}); local pat=p:finish()
  local q=W.solve(world,pat); local k,no=decided(q); eq(k,'no'); ok(no and Query.is_refutation(no) and no:reason().kind)
end

-- Exact allocation itself is fuelled. A large common fibre cannot be consumed
-- in one tiny step merely because structural reasoning has finished.
do
  local q=W.solve(shared_world(1,1000),independent(1000)); local calls=0; local k
  repeat calls=calls+1; k=q:step(8) until k~='more'
  eq(k,'yes'); ok(calls>100,'large exact allocation should yield repeatedly under tiny fuel')
end


-- Boundary projection: one shared deep Point determines its complete locality
-- ancestry, so thousands of redundant ancestor variables must not be required.
do
  local depth=3000
  local function deep()
    local b=W.builder(); local m=b:membrane(nil)
    for _=2,depth do m=b:membrane(m) end
    local p=b:point(m); b:strand(m,{p}); b:strand(m,{p})
    return b:finish()
  end
  local q=W.solve(deep(),deep())
  eq(q:step(8),'more')
  local k=decided(q,64); eq(k,'yes')
end

-- The converse boundary law: a parent shared by sibling requirements remains
-- future-relevant. Individually matching children under different world roots
-- cannot satisfy one shared pattern parent.
do
  local wb=W.builder()
  local r1=wb:membrane(nil); local a=wb:membrane(r1); wb:strand(a,{})
  local r2=wb:membrane(nil); local b=wb:membrane(r2); wb:strand(b,{})
  local world=wb:finish()
  local pb=W.builder(); local r=pb:membrane(nil); local x=pb:membrane(r); local y=pb:membrane(r)
  pb:strand(x,{}); pb:strand(y,{})
  local k=decided(W.solve(world,pb:finish())); eq(k,'no')
end


-- Retained provenance is immutable even across repeated projection.  In a
-- complete 3-point directed relation there are 27 structural triangle
-- assignments; the three all-equal assignments would reuse one exact self-loop
-- three times, so scarce exact allocation leaves exactly 24 witnesses.
do
  local wb=W.builder(); local wm=wb:membrane(nil); local wp={}
  for i=1,3 do wp[i]=wb:point(wm) end
  for i=1,3 do for j=1,3 do wb:strand(wm,{wp[i],wp[j]}) end end
  local world=wb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil); local a=pb:point(pm); local b=pb:point(pm); local c=pb:point(pm)
  pb:strand(pm,{a,b}); pb:strand(pm,{b,c}); pb:strand(pm,{c,a})
  local q=W.solve(world,pb:finish()); local hits=0
  while true do local k=q:step(math.huge); if k=='yes' then hits=hits+1 elseif k=='done' then break elseif k~='more' then error(k) end end
  eq(hits,24)
end


-- Boundary connectivity is transitive through descendants. No single shared
-- Point has the same use-set as the common membrane here: p1 couples A/B and
-- p2 couples B/C. Their overlap nevertheless determines the parent locality.
do
  local function chain_world(split)
    local b=W.builder(); local r1=b:membrane(nil); local r2=split and b:membrane(nil) or r1
    local p1=b:point(r1); local p2=b:point(r1)
    b:strand(r1,{p1}); b:strand(r1,{p1,p2}); b:strand(split and r2 or r1,{p2})
    return b:finish()
  end
  local pat=chain_world(false)
  local good=chain_world(false); eq(decided(W.solve(good,pat)),'yes')
  -- In the split world the last requirement cannot share p2 itself with the
  -- middle requirement, so descendant equality does not manufacture locality.
  local bad=chain_world(true); eq(decided(W.solve(bad,pat)),'no')
end


-- High-arity locality is represented as equality classes, not a quadratic
-- clique of pairwise checks. All local Points must inhabit the Strand locality.
do
  local function arity_world(split)
    local b=W.builder(); local r=b:membrane(nil); local a=b:membrane(r); local z=split and b:membrane(r) or a; local ps={}
    for i=1,64 do ps[i]=b:point(i==64 and z or a) end
    b:strand(a,ps); return b:finish()
  end
  local pat=arity_world(false)
  eq(decided(W.solve(arity_world(false),pat)),'yes')
  eq(decided(W.solve(arity_world(true),pat)),'no')
end


-- Endpoint-thread quotient: equality discovered in one sibling locality must
-- not leak into another sibling merely because the same demands participate in
-- both.  Construction order of siblings is irrelevant.
do
  local vb=W.builder(); local vm=vb:membrane(nil); local R1=vb:point(vm); local R2=vb:point(vm); vb:finish()
  local function pat(reverse)
    local b=W.builder(); local r=b:membrane(nil); local left,right
    if reverse then right=b:membrane(r); left=b:membrane(r) else left=b:membrane(r); right=b:membrane(r) end
    local shared=b:point(left); local q1=b:point(right); local q2=b:point(right)
    b:strand(r,{shared,q1,R1}); b:strand(r,{shared,q2,R2}); return b:finish()
  end
  local wb=W.builder(); local wr=wb:membrane(nil); local left=wb:membrane(wr); local r1=wb:membrane(wr); local r2=wb:membrane(wr)
  local shared=wb:point(left); local q1=wb:point(r1); local q2=wb:point(r2)
  wb:strand(wr,{shared,q1,R1}); wb:strand(wr,{shared,q2,R2}); local world=wb:finish()
  eq(decided(W.solve(world,pat(false))),'no')
  eq(decided(W.solve(world,pat(true))),'no')
end

print('PASS 0.6.1 adversarial',n,'assertions')
