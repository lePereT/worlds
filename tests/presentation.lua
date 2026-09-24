package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local Presentation=require('worlds.presentation')

local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function fails(f,pat)
  n=n+1
  local good,err=pcall(f); assert(not good,'expected failure')
  if pat then assert(tostring(err):match(pat),tostring(err)) end
end

local function unary(name)
  local b=W.builder(); local m=b:membrane(nil,name); local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.in'); local o=b:strand(m,{p},name..'.out'); local f=b:face(m,{i},{o},name..'.face')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

-- Presentation is an ordered descriptive view over exact open occurrences.
do
  local b=W.builder(); local m=b:membrane(nil,'body'); local p=b:point(m,'p')
  local a1=b:strand(m,{p},'a1'); local a2=b:strand(m,{p},'a2'); local r=b:strand(m,{p},'r')
  local body=b:finish()
  local rows={{a1,a2},{r},{},{a1,a1}}
  local p1=Presentation.new(body,rows)
  ok(Presentation.is_presentation(p1)); ok(not Presentation.is_presentation({}))
  eq(p1:ambient(),body); eq(#p1:rows(),4)
  eq(p1:row(1)[1],a1); eq(p1:row(1)[2],a2); eq(#p1:row(3),0)
  eq(p1:row(4)[1],a1); eq(p1:row(4)[2],a1,'presentation multiplicity is descriptive and retained')
  rows[1][1]=r; eq(p1:row(1)[1],a1,'constructor copies row arrays')
  local got=p1:rows(); got[1][1]=r; eq(p1:row(1)[1],a1,'rows accessor returns copies')
  local one=p1:row(1); one[1]=r; eq(p1:row(1)[1],a1,'row accessor returns a copy')
  fails(function() p1.extra=true end,'immutable')
  fails(function() p1:row(0) end,'row index')
end

-- Exact same-row fibres remain distinguishable, and presentation order may differ
-- without changing ambient Geometry.
do
  local b=W.builder(); local m=b:membrane(nil,'fibre'); local q=b:point(m,'q')
  local o1=b:strand(m,{q},'o1'); local o2=b:strand(m,{q},'o2'); local g=b:finish()
  local p12=Presentation.new(g,{{o1,o2}}); local p21=Presentation.new(g,{{o2,o1}})
  ok(o1~=o2); eq(W.points(o1)[1],W.points(o2)[1]); eq(p12:row(1)[1],o1); eq(p21:row(1)[1],o2)
  eq(#g:strands(),2,'presentations do not alter Geometry')
end

-- Ingress-only, egress-only and isolated Strands are open; an internal Strand is
-- not presentable.
do
  local g,x=unary('open')
  local isolated_builder=W.builder(); local im=isolated_builder:membrane(nil,'isolated'); local s=isolated_builder:strand(im,{},'s'); local isolated=isolated_builder:finish()
  ok(Presentation.new(g,{{x.i},{x.o}})); ok(Presentation.new(isolated,{{s}}))
  local A,a=unary('left'); local B,b=unary('right')
  local c=Construction.join({A,B},{{from=a.o,to=b.i}}); local joined=c:result(); local internal=c:image(a.o)
  ok(joined:producer(internal)~=nil and joined:consumer(internal)~=nil)
  fails(function() Presentation.new(joined,{{internal}}) end,'must be open')
  fails(function() Presentation.new(g,{{b.o}}) end,'ambient Geometry')
  fails(function() Presentation.new(g,{{x.f}}) end,'exact Strand')
end

-- Residual transport maps pointwise, retains surviving order/multiplicity and
-- drops coordinates which became internal.
do
  local caller,ca=unary('caller')
  local b=W.builder(); local m=b:membrane(nil,'callee'); local q=b:point(m,'q')
  local a=b:strand(m,{q},'arg'); local r1=b:strand(m,{q},'r1'); local r2=b:strand(m,{q},'r2'); local hidden=b:strand(m,{q},'hidden')
  b:face(m,{a},{r1,r2,hidden},'body')
  local callee=b:finish()
  local p=Presentation.new(callee,{{a},{r2,r1},{},{r1,r1}})
  local c=Construction.join({caller,callee},{{from=ca.o,to=a}})
  local residual=p:transport(c)
  eq(residual:ambient(),c:result()); eq(#residual:row(1),0,'closed argument disappears')
  eq(residual:row(2)[1],c:image(r2)); eq(residual:row(2)[2],c:image(r1),'result order survives transport')
  eq(#residual:row(3),0)
  eq(residual:row(4)[1],c:image(r1)); eq(residual:row(4)[2],c:image(r1),'multiplicity survives transport')
  ok(c:result():owns_strand(c:image(hidden)),'omitted hidden authority remains ordinary Geometry')
end

-- If two distinct presented exact occurrences are identified, coordinate
-- multiplicity is still mapped pointwise rather than deduplicated.
do
  local b=W.builder(); local m=b:membrane(nil,'identify'); local p=b:point(m,'p')
  local s1=b:strand(m,{p},'s1'); local s2=b:strand(m,{p},'s2'); local g=b:finish()
  local pres=Presentation.new(g,{{s1,s2}})
  local c=Construction.join({g},{{from=s1,to=s2}})
  local t=pres:transport(c); eq(#t:row(1),2); eq(t:row(1)[1],t:row(1)[2]); ok(s1~=s2)
end

-- SCC annihilation residualises presented cyclic authority rather than inventing
-- a completion occurrence.
do
  local X,x=unary('X'); local Y,y=unary('Y')
  local product=Construction.join({X,Y},{})
  local g=product:result()
  local xi,yi={},{}; for k,v in pairs(x) do xi[k]=product:image(v) end; for k,v in pairs(y) do yi[k]=product:image(v) end
  local p=Presentation.new(g,{{xi.i,xi.o,yi.i,yi.o},{}})
  local c=Construction.join({g},{{from=xi.o,to=yi.i},{from=yi.o,to=xi.i}})
  local t=p:transport(c); eq(#t:row(1),0); eq(#t:row(2),0); eq(#c:result():faces(),1)
end

-- Zero-result presentation has no causal completion semantics.
do
  local g,x=unary('zero')
  local p=Presentation.new(g,{{x.i},{}})
  eq(#p:row(2),0); eq(#g:faces(),1); eq(g:consumer(x.o),nil)
end

-- Transport is authorised only by exact part identity, and staged transport is
-- obtained by transporting through successive actual Constructions.
do
  local A,a=unary('stageA'); local B,b=unary('stageB'); local C,c0=unary('stageC')
  local p=Presentation.new(B,{{b.o}})
  local c1=Construction.join({A,B},{{from=a.o,to=b.i}})
  local p1=p:transport(c1); eq(p1:row(1)[1],c1:image(b.o))
  local c2=Construction.join({c1:result(),C},{{from=p1:row(1)[1],to=c0.i}})
  local p2=p1:transport(c2); eq(#p2:row(1),0)
  fails(function() p:transport(c2) end,'exact part')
  fails(function() p:transport({}) end,'requires Worlds Construction')
end

-- Dense-array validation is part of the public finite-input contract.
do
  local g,x=unary('dense')
  fails(function() Presentation.new(g,{[1]={x.i},[3]={x.o}}) end,'dense array')
  fails(function() Presentation.new(g,{{[2]=x.i}}) end,'dense array')
end

-- Presentations are edge values and cannot be supplied as Geometry to join.
do
  local g,x=unary('authority')
  local p=Presentation.new(g,{{x.i}})
  fails(function() W.join({p},{}) end,'expected Worlds Geometry')
end

print('PASS presentation',n,'assertions')
