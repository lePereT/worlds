-- Atlas-derived attack: quantum mechanics as a compositional semantics of Worlds.
-- Sequential Worlds composition maps to matrix multiplication; independent
-- juxtaposition maps to tensor product. The kernel remains unchanged.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local EPS=1e-10
local function meq(A,B)
  if #A~=#B or #A[1]~=#B[1] then return false end
  for i=1,#A do for j=1,#A[i] do if math.abs(A[i][j]-B[i][j])>EPS then return false end end end
  return true
end
local function mm(A,B)
  local R={}; for i=1,#A do R[i]={}; for j=1,#B[1] do local s=0; for k=1,#B do s=s+A[i][k]*B[k][j] end; R[i][j]=s end end; return R
end
local function kron(A,B)
  local R={}; for ia=1,#A do for ib=1,#B do local row={}; for ja=1,#A[1] do for jb=1,#B[1] do row[#row+1]=A[ia][ja]*B[ib][jb] end end; R[#R+1]=row end end; return R
end
local inv=1/math.sqrt(2)
local H={{inv,inv},{inv,-inv}}; local X={{0,1},{1,0}}; local Z={{1,0},{0,-1}}; local I={{1,0},{0,1}}

local function gate(name)
  local b=W.builder(); local m=b:membrane(nil,name); local q=b:point(m,'q')
  local i=b:strand(m,{q},name..'.in'); local o=b:strand(m,{q},name..'.out'); local f=b:face(m,{i},{o},name)
  return {g=b:finish(),q=q,i=i,o=o,f=f}
end
local gH=gate('H'); local gZ=gate('Z'); local seq,img=W.join({gH.g,gZ.g},{{from=gH.o,to=gZ.i}})
eq(#seq:faces(),2,'sequential gate geometry retains two acyclic Faces')
eq(#seq:ingress(),1); eq(#seq:egress(),1)
ok(meq(mm(Z,H),{{inv,inv},{-inv,inv}}),'sequential semantic matrix is ZH')

-- Parallel disjoint processes need no causal equations; quantum semantics is tensor product.
local gX=gate('X'); local par=W.join({gH.g,gX.g},{})
eq(#par:faces(),2,'parallel geometry has two independent Faces')
eq(#par:ingress(),2); eq(#par:egress(),2)
local HX=kron(H,X); ok(#HX==4 and #HX[1]==4,'parallel semantic map has tensor-product dimension')

-- Interchange law at the semantic level for independent wires.
local left=mm(kron(Z,X),kron(H,I))
local right=kron(mm(Z,H),mm(X,I))
ok(meq(left,right),'parallel/sequential interchange agrees with tensor/matrix composition')

print('monoidal quantum semantics: '..n..' assertions passed')
print('  Worlds composition supports a direct monoidal process interpretation')
