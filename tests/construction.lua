package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')

local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function fails(f,pat)
  n=n+1
  local good,err=pcall(f); assert(not good,'expected failure')
  if pat then assert(tostring(err):match(pat),tostring(err)) end
end

local function stage(name)
  local b=W.builder(); local m=b:membrane(nil,name); local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i'); local o=b:strand(m,{p},name..'.o'); local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

-- Basic immutable witness around the ordinary join.
do
  local A,a=stage('A'); local B,b=stage('B')
  local parts={A,B}; local equations={{a.o,b.i}}
  local c=Construction.join(parts,equations)
  ok(Construction.is_construction(c)); ok(not Construction.is_construction({}))
  ok(W.is_geometry(c:result()))
  local ps=c:parts(); eq(#ps,2); eq(ps[1],A); eq(ps[2],B)
  local es=c:equations(); eq(#es,1); eq(es[1].from,a.o); eq(es[1].to,b.i)
  eq(c:image(a.m),a.m,'unaffected frame locality survives literally')
  eq(c:image(a.p),a.p,'unaffected frame Point survives literally')
  eq(c:image(a.i),a.i,'unaffected frame ingress survives literally')
  eq(c:image(a.f),a.f,'unaffected frame Face survives literally')
  eq(c:image(a.o),c:image(b.i),'joined Strand class has one image')
  ok(c:image(b.f)~=b.f,'non-frame Face is freshly materialised')
  eq(c:image({}),nil,'unknown values have no construction image')

  -- Inputs and accessors are copied rather than aliased.
  parts[1]=B; equations[1][1]=b.o
  eq(c:parts()[1],A); eq(c:equations()[1].from,a.o)
  ps[1]=B; es[1].from=b.o
  eq(c:parts()[1],A); eq(c:equations()[1].from,a.o)
  fails(function() c.extra=true end,'immutable')
end

-- Named and positional equation forms normalise to the same stored shape.
do
  local A,a=stage('N1'); local B,b=stage('N2')
  local c=Construction.join({A,B},{{from=a.o,to=b.i}})
  local e=c:equations()[1]; eq(e.from,a.o); eq(e.to,b.i); eq(e[1],nil); eq(e[2],nil)
end

-- The wrapper preserves frame/template asymmetry rather than inventing another
-- composition semantics.
do
  local A,a=stage('frame'); local B,b=stage('template')
  local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
  local c2=Construction.join({B,A},{{from=b.o,to=a.i}})
  eq(c1:image(a.f),a.f); ok(c1:image(b.f)~=b.f)
  eq(c2:image(b.f),b.f); ok(c2:image(a.f)~=a.f)
end

-- Construction images retain the kernel's SCC many-to-one Face transport and
-- cyclic Strand annihilation.
do
  local X,x=stage('X'); local Y,y=stage('Y')
  local product=Construction.join({X,Y},{})
  local g=product:result()
  local xi,yi={},{}
  for k,v in pairs(x) do xi[k]=product:image(v) end
  for k,v in pairs(y) do yi[k]=product:image(v) end
  local c=Construction.join({g},{{from=xi.o,to=yi.i},{from=yi.o,to=xi.i}})
  eq(c:image(xi.f),c:image(yi.f),'SCC Faces map to one joint Face')
  eq(c:image(xi.i),nil); eq(c:image(xi.o),nil); eq(c:image(yi.i),nil); eq(c:image(yi.o),nil)
  eq(#c:result():faces(),1)
end

-- Staged image transport is ordinary pointwise composition wherever carriers
-- survive.  Construction itself provides no extra composition primitive.
do
  local A,a=stage('S1'); local B,b=stage('S2'); local C,c0=stage('S3')
  local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
  local g1=c1:result(); local bo=c1:image(b.o)
  local c2=Construction.join({g1,C},{{from=bo,to=c0.i}})
  for _,x in ipairs({a.m,a.p,a.i,a.f,a.o,b.m,b.p,b.i,b.o,b.f}) do
    local mid=c1:image(x)
    local staged=mid and c2:image(mid) or nil
    ok(staged~=nil,'surviving source carrier has a staged image')
    eq(W.kind(staged),W.kind(mid),'staged image preserves carrier kind')
  end
end

-- Public dense-array and ordinary join validation still apply.
do
  local A=stage('badA'); local B=stage('badB')
  fails(function() Construction.join({[1]=A,[3]=B},{}) end,'dense array')
  fails(function() Construction.join({}, {}) end,'join expects Geometry parts')
end

print('PASS construction',n,'assertions')
