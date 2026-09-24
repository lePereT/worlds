package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common'); local R=require('speculation.modern.dimensional_lab.reduct')
local ok,eq,count=D.counter()

local function route(label,marked)
  local b=W.builder(); local m=b:membrane(nil,label); local q=b:point(m,'q'); local pts={q}
  if marked then pts[#pts+1]=b:point(m,label..'.record') end
  local i=b:strand(m,{q},'in'); local o=b:strand(m,pts,'out'); b:face(m,{i},{o},label); return {g=b:finish(),i=i,o=o}
end
local function erase(label)
  local b=W.builder(); local m=b:membrane(nil,label); local q=b:point(m,'q'); local r=b:point(m,'record')
  local i=b:strand(m,{q,r},'marked'); local o=b:strand(m,{q},'unmarked'); b:face(m,{i},{o},'erase'); return {g=b:finish(),i=i,o=o}
end

print('1. which-path authority refines the W1 structural boundary')
local U=route('unmarked',false); local M=route('marked',true)
local ur=R.reduce(U.g); local mr=R.reduce(M.g)
local urow=W.points(ur.scope_arc[U.o]); local mrow=W.points(mr.scope_arc[M.o])
eq(#urow,2,'exact port + q'); eq(#mrow,3,'exact port + q + record')
ok(#mrow>#urow,'record creates a strictly finer structural observation')

print('2. causal erasure coarsens the exposed W1 structure again')
local E=erase('eraser'); local joined,img=W.join({M.g,E.g},{{from=M.o,to=E.i}})
local red=R.reduce(joined); local out=img[E.o]; local row=W.points(red.scope_arc[out])
eq(#row,2,'erased output returns to exact port + q')
eq(#joined:faces(),2,'coarsening is caused by a real W2 erasure history')

print('3. structural observational class and exact causal history remain different notions')
eq(#U.g:faces(),1); eq(#joined:faces(),2)
eq(D.boundary_signature(U.g),D.boundary_signature(joined),'same unmarked observed boundary after different exact histories')
ok(U.g~=joined,'observation coarsening does not erase exact history')

print('PASS interference-resolution W1 pressure',count(),'assertions')
