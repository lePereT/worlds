-- Atlas-derived attack: classicality as Theory-certified copyability.
-- Geometry permits an explicit two-system correlation operation; Theory decides
-- whether the result is two copies or an entangled joint state.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local EPS=1e-12
local function approx(a,b) return math.abs(a-b)<EPS end

-- Two exact subsystems and their scarce authorities.
local wb=W.builder(); local wm=wb:membrane(nil,'pair')
local q=wb:point(wm,'source-system'); local r=wb:point(wm,'blank-system')
local aq=wb:strand(wm,{q},'q authority'); local ar=wb:strand(wm,{r},'r authority'); local world=wb:finish()

local b=W.builder(); local m=b:membrane(nil,'copy-candidate')
local Q=b:point(m,'Q'); local R=b:point(m,'R')
local iq=b:strand(m,{Q},'qin'); local ir=b:strand(m,{R},'blank')
local oq=b:strand(m,{Q},'qout'); local orr=b:strand(m,{R},'rout'); local joint=b:strand(m,{Q,R},'joint factor')
b:face(m,{iq,ir},{oq,orr,joint},'controlled correlate')
local dev=b:finish()
local s=W.solve(world,dev,{{from=aq,to=iq},{from=ar,to=ir}}); local tag,es=s:step(math.huge); eq(tag,'yes')
local live,img=W.advance(world,dev,es)
ok(live:owns_strand(img[oq]) and live:owns_strand(img[orr]) and live:owns_strand(img[joint]),'Geometry supports explicit two-system correlation')

-- Tiny CNOT Theory on input |psi>|0>. Basis states are copied as classical values.
-- A superposition is not cloned: it becomes Bell entangled.
local inv=1/math.sqrt(2)
local function cnot_blank(a,beta) -- psi=a|0>+beta|1>; blank target |0>
  return {a,0,0,beta} -- |00>,|01>,|10>,|11>
end
local function kron_same(a,beta)
  return {a*a,a*beta,a*beta,beta*beta}
end
local function veq(x,y)
  for i=1,#x do if not approx(x[i],y[i]) then return false end end
  return true
end
local out0=cnot_blank(1,0); ok(veq(out0,kron_same(1,0)),'|0> is copied')
local out1=cnot_blank(0,1); ok(veq(out1,kron_same(0,1)),'|1> is copied')
local outp=cnot_blank(inv,inv); ok(not veq(outp,kron_same(inv,inv)),'|+> is not cloned')
-- Bell separability test for 2x2 amplitudes: determinant non-zero => entangled.
local det=outp[1]*outp[4]-outp[2]*outp[3]
ok(not approx(det,0),'CNOT(|+>|0>) is entangled')

-- Worlds itself did not implicitly duplicate aq: both input authorities were explicitly consumed.
ok(not live:owns_strand(aq) and not live:owns_strand(ar),'correlation required explicit scarce inputs')

print('classicality/copyability: '..n..' assertions passed')
print('  one geometric operation copies basis-classical information but entangles a superposition')
