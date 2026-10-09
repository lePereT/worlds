package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local Query=require('worlds.query')

local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1
assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function fails(f,pat)
  n=n+1
  local good,err=pcall(f)
  assert(not good,'expected failure')
  if pat then assert(tostring(err):match(pat),tostring(err)) end
end

local function stage(name)
  local b=W.builder()
  local m=b:membrane(nil,name)
  local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i')
  local o=b:strand(m,{p},name..'.o')
  local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

-- Basic immutable witness around the ordinary join.
do
  local A,a=stage('A')
  local B,b=stage('B')
  local parts={A,B}
  local equations={{a.o,b.i}}
  local c=Construction.join(parts,equations)
  ok(Construction.is_construction(c))
  ok(not Construction.is_construction({}))
  ok(W.is_geometry(c:result()))
  local ps=c:parts()
  eq(#ps,2)
  eq(ps[1],A)
  eq(ps[2],B)
  local es=c:equations()
  eq(#es,1)
  eq(es[1].from,a.o)
  eq(es[1].to,b.i)
  eq(c:image(a.m),a.m,'unaffected frame locality survives literally')
  eq(c:image(a.p),a.p,'unaffected frame Point survives literally')
  eq(c:image(a.i),a.i,'unaffected frame ingress survives literally')
  eq(c:image(a.f),a.f,'unaffected frame Face survives literally')
  eq(c:image(a.o),c:image(b.i),'joined Strand class has one image')
  ok(c:image(b.f)~=b.f,'non-frame Face is freshly materialised')
  eq(c:image({}),nil,'unknown values have no construction image')

  local corr=c:correspondence()
  ok(Construction.is_correspondence(corr))
  ok(not Construction.is_correspondence({}))
  eq(corr:source_parts(),parts)
  eq(corr:target(),c:result())
  ok(corr:source_equivalent(a.o,b.i),'joined source Strands lack one quotient class')
  eq(corr:source_class(a.o),corr:source_class(b.i),'source class token is not stable')
  eq(corr:source_class(a.o),corr:target_class(c:image(a.o)),
      'surviving target does not retain its source quotient class')
  ok(corr:corresponds(a.o,c:image(b.i)),'source/result correspondence is absent')
  eq(corr:survivor(a.o),c:image(a.o),'survivor disagrees with direct Construction image')
  eq(corr:survivor(b.i),c:image(b.i),'identified source has the wrong survivor')
  eq(corr:survivor({}),nil,'value outside the marked source acquired a survivor')
  eq(W.kind(corr:source_class(a.o)),nil,'quotient evidence leaked as an exact carrier')
  ok(corr:source_class(a.o)~=a.o,'quotient class token aliases exact authority')
  fails(function() corr.extra=true end,'immutable')

  -- Trusted in-process arrays are borrowed/read-only rather than defensively copied.
  eq(c:parts(),parts,'Construction retains the exact parts array')
  eq(c:parts(),ps,'parts accessor returns the same borrowed view')
  eq(c:equations(),es,'equations accessor returns one stable normalised view')
  fails(function() c.extra=true end,'immutable')
end

-- Named and positional equation forms normalise to the same stored shape.
do
  local A,a=stage('N1')
  local B,b=stage('N2')
  local c=Construction.join({A,B},{{from=a.o,to=b.i}})
  local e=c:equations()[1]
  eq(e.from,a.o)
  eq(e.to,b.i)
  eq(e[1],nil)
  eq(e[2],nil)
end

-- The wrapper preserves frame/template asymmetry rather than inventing another
-- composition semantics.
do
  local A,a=stage('frame')
  local B,b=stage('template')
  local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
  local c2=Construction.join({B,A},{{from=b.o,to=a.i}})
  eq(c1:image(a.f),a.f)
  ok(c1:image(b.f)~=b.f)
  eq(c2:image(b.f),b.f)
  ok(c2:image(a.f)~=a.f)
end

-- Construction images retain the kernel's SCC many-to-one Face transport and
-- cyclic Strand annihilation.
do
  local X,x=stage('X')
  local Y,y=stage('Y')
  local product=Construction.join({X,Y},{})
  local g=product:result()
  local xi,yi={},{}
  for k,v in pairs(x) do xi[k]=product:image(v) end
  for k,v in pairs(y) do yi[k]=product:image(v) end
  local c=Construction.join({g},{{from=xi.o,to=yi.i},{from=yi.o,to=xi.i}})
  eq(c:image(xi.f),c:image(yi.f),'SCC Faces map to one joint Face')
  eq(c:image(xi.i),nil)
  eq(c:image(xi.o),nil)
  eq(c:image(yi.i),nil)
  eq(c:image(yi.o),nil)
  eq(#c:result():faces(),1)
  local corr=c:correspondence()
  ok(corr:source_equivalent(xi.o,yi.i),'annihilated cut lost its native source class')
  ok(corr:source_class(xi.o)~=nil,'annihilated quotient class is not retained')
  eq(corr:survivor(xi.o),nil,'annihilated quotient class acquired a survivor')
  eq(corr:survivor(yi.i),nil,'identified annihilated source acquired a survivor')
end

-- Staged image transport is ordinary pointwise composition wherever carriers
-- survive.  Construction itself provides no extra composition primitive.
do
  local A,a=stage('S1')
  local B,b=stage('S2')
  local C,c0=stage('S3')
  local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
  local g1=c1:result()
  local bo=c1:image(b.o)
  local c2=Construction.join({g1,C},{{from=bo,to=c0.i}})
  for _,x in ipairs({a.m,a.p,a.i,a.f,a.o,b.m,b.p,b.i,b.o,b.f}) do
    local mid=c1:image(x)
    local staged=mid and c2:image(mid) or nil
    ok(staged~=nil,'surviving source carrier has a staged image')
    eq(W.kind(staged),W.kind(mid),'staged image preserves carrier kind')
  end
end

-- Correspondence survivor is compositional evidence, not merely an alias for
-- Construction:image on the first Construction.  It follows an old marked
-- source through later quotienting and also covers genuinely fresh later parts.
do
  local A,a=stage('CS1')
  local B,b=stage('CS2')
  local C,c0=stage('CS3')
  local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
  local g1=c1:result()
  local c2=Construction.join({g1,C},{{from=assert(c1:image(b.o)),to=c0.i}})
  local corr=c1:correspondence():compose(c2:correspondence())
  for _,x in ipairs({a.m,a.p,a.i,a.o,a.f,b.m,b.p,b.i,b.o,b.f}) do
    local mid=c1:image(x)
    eq(corr:survivor(x),mid and c2:image(mid) or nil,
        'composed survivor disagrees with staged Construction image')
  end
  for _,x in ipairs({c0.m,c0.p,c0.i,c0.o,c0.f}) do
    eq(corr:survivor(x),c2:image(x),'fresh composed source has the wrong survivor')
  end
end

-- Public dense-array and ordinary join validation still apply.
do
  local A=stage('badA')
  local B=stage('badB')
  fails(function() Construction.join({[1]=A,[3]=B},{}) end,'dense array')
  fails(function() Construction.join({}, {}) end,'join expects Geometry parts')
end


-- Frame reuse is legal only when parent/placement incidence survives the
-- quotient literally.  Identifying a frame parent must therefore rematerialise
-- a surviving child (and its local Point/Strand) under the chosen parent image
-- rather than leaving stale ancestry behind.
do
  local b=W.builder()
  local source_root=b:membrane(nil,'parent-image.source')
  local target_root=b:membrane(nil,'parent-image.target')
  local child=b:membrane(target_root,'parent-image.child')
  local p=b:point(child,'parent-image.p')
  local source=b:strand(source_root,{},'parent-image.source.s')
  local target=b:strand(target_root,{},'parent-image.target.s')
  local survivor=b:strand(child,{p},'parent-image.survivor')
  local g=b:finish()
  local c=Construction.join({g},{{from=source,to=target}})
  local merged=assert(c:image(source))
  eq(merged,c:image(target),'joined roots share one image')
  local cs=assert(c:image(survivor))
  local cm=W.membrane(cs)
  eq(W.parent(cm),W.membrane(merged),'surviving child is reparented through the quotient image')
  local cp=assert(c:image(p))
  eq(W.membrane(cp),cm,'local Point placement follows rematerialised child')
  eq(W.points(cs)[1],cp,'surviving Strand ordered Point incidence follows Point image')
end


-- Identifying a Membrane with one of its strict descendants cannot produce a
-- finite parent forest.  Reject the boundary equation rather than hiding the
-- quotient cycle behind stale frame incidence or recursing during materialisation.
do
  local b=W.builder()
  local root=b:membrane(nil,'cycle.root')
  local child=b:membrane(root,'cycle.child')
  local grandchild=b:membrane(child,'cycle.grandchild')
  local target=b:strand(root,{},'cycle.target')
  local source=b:strand(grandchild,{},'cycle.source')
  local g=b:finish()
  fails(function() Construction.join({g},{{from=source,to=target}}) end,
      'inconsistent boundary equation')
end


-- A cached Query Realisation may lawfully map an annihilated source carrier to nil.
-- Construction:image must return that nil directly rather than falling through to a
-- non-existent materialised image table.
do
  local A,a=stage('cached-cycle-A')
  local B,b=stage('cached-cycle-B')
  local solve=Query.solve(Query.close({A,B},{sources={a.o,b.o},targets={a.i,b.i},
    required_sources={a.o,b.o},required_targets={a.i,b.i},
    admissible={{from=a.o,to=b.i},{from=b.o,to=a.i}}}))
  local kind,equations=solve:step(math.huge)
  eq(kind,'yes','cyclic close did not establish')
  local c=Construction.join({A,B},equations)
  eq(c:image(a.o),nil,'annihilated Realisation source acquired an image')
  eq(c:image(a.i),nil,'annihilated Realisation target acquired an image')
  eq(#c:result():faces(),1,'cyclic rendezvous did not SCC-normalise')
end


-- try_join separates lawful geometric rejection from malformed API use without
-- converting arbitrary Lua failures into composition semantics.
do
  local A,a=stage('try-A')
  local B,b=stage('try-B')
  local c,why=Construction.try_join({A,B},{{from=a.o,to=b.i}})
  ok(Construction.is_construction(c),why)
  eq(why,nil)

  local no,reason=Construction.try_join({A,B},{{from=a.i,to=b.i}})
  eq(no,nil,'invalid exact cut unexpectedly constructed')
  ok(type(reason)=='string' and reason:match('open egress'),
      'try_join did not return geometric rejection reason')

  fails(function() Construction.try_join({[1]=A,[3]=B},{}) end,'dense array')
  fails(function() Construction.try_join({}, {}) end,'join expects Geometry parts')
end

print('PASS construction',n,'assertions')
