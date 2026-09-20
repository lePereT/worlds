local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx

local wb=W.builder(); local wm=wb:membrane(nil,'host'); local q=wb:point(wm,'q'); local src=wb:strand(wm,{q},'input'); local world=wb:finish()
local function route(name)
  local b=W.builder(); local m=b:membrane(nil,name); local Q=b:point(m,'Q'); local P=b:point(m,name..'.internal')
  local i=b:strand(m,{Q},'in'); local mid=b:strand(m,{Q,P},'hidden route'); local o=b:strand(m,{Q},'out')
  b:face(m,{i},{mid},name..'.first'); b:face(m,{mid},{o},name..'.second')
  return {g=b:finish(),p=P,i=i,o=o}
end
local function run(r)
  local s=W.solve(world,r.g,{{from=src,to=r.i}}); local tag,es=s:step(math.huge); eq(tag,'yes')
  local live,img=W.advance(world,r.g,es); return live,img[r.o],img[r.p]
end
local r0=route('route-y0'); local r1=route('route-y1')
local l0,o0,p0=run(r0); local l1,o1,p1=run(r1)
ok(p0~=p1,'the two materialised hidden route identities remain exact and distinct')
eq(W.points(o0)[1],q); eq(W.points(o1)[1],q)
eq(T.row_key(W,o0),T.row_key(W,o1),'hidden route distinction vanishes at the common live boundary row')
ok(o0~=o1,'exact output occurrences still remember construction identity')

-- Quantum semantics: two Hadamards. For each classical input/output bit, sum the
-- amplitudes of the two hidden y histories before squaring.
local h=1/math.sqrt(2); local H={{h,h},{h,-h}}
local function amp(x,z,y) return H[z+1][y+1]*H[y+1][x+1] end
local P={{0,0},{0,0}}
for x=0,1 do for z=0,1 do
  local a0=amp(x,z,0); local a1=amp(x,z,1); P[z+1][x+1]=(a0+a1)^2
  if z==x then approx(P[z+1][x+1],1,'constructive hidden histories recover deterministic identity') else approx(P[z+1][x+1],0,'destructive hidden histories remove the classically forbidden output') end
end end
ok(T.meq(P,{{1,0},{0,1}}),'the quantum path sum induces the classical deterministic identity transition')

-- No individual hidden history is deterministic: if which-route information
-- destroys interference, each output has 1/2 total probability instead.
for x=0,1 do for z=0,1 do local classicalised=amp(x,z,0)^2+amp(x,z,1)^2; approx(classicalised,0.5) end end

print('path-sum classical determinism: '..T.count()..' assertions passed')
print('  a deterministic classical transition appears only after coherent summation over two exact hidden Worlds constructions')
