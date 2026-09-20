-- Radical quantum attack: relative phase as a U(1)-like cocycle on exact causal
-- histories. Worlds supplies distinct histories; internal basis rephasings cancel
-- along each route, leaving a gauge-invariant relative phase at a shared boundary class.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local EPS=1e-10
local function approx(a,b) return math.abs(a-b)<EPS end
local function C(re,im) return {re,im} end
local function mul(a,b) return C(a[1]*b[1]-a[2]*b[2],a[1]*b[2]+a[2]*b[1]) end
local function add(a,b) return C(a[1]+b[1],a[2]+b[2]) end
local function conj(a) return C(a[1],-a[2]) end
local function abs2(a) return a[1]*a[1]+a[2]*a[2] end
local function phase(t) return C(math.cos(t),math.sin(t)) end
local function ceq(a,b) return approx(a[1],b[1]) and approx(a[2],b[2]) end

-- Two exact two-Face route presentations with the same one-Point open interface shape.
local function path(name)
  local b=W.builder(); local m=b:membrane(nil,name); local q=b:point(m,'q')
  local i=b:strand(m,{q},name..'.in'); local mid=b:strand(m,{q},name..'.mid'); local o=b:strand(m,{q},name..'.out')
  local f1=b:face(m,{i},{mid},name..'.1'); local f2=b:face(m,{mid},{o},name..'.2')
  return {g=b:finish(),i=i,mid=mid,o=o,f1=f1,f2=f2}
end
local L=path('L'); local R=path('R')
ok(L.mid~=R.mid and L.f1~=R.f1,'routes are exact distinct histories')

-- A face phase transforms under rephasing of its input/output occurrence basis as
-- u_f' = g(out) u_f conj(g(in)). Internal g(mid) cancels in the path product.
local function transformed_path(u1,u2,gin,gmid,gout)
  local u1p=mul(mul(gmid,u1),conj(gin))
  local u2p=mul(mul(gout,u2),conj(gmid))
  return mul(u2p,u1p)
end
local uL1=phase(0.17); local uL2=phase(0.41)
local uR1=phase(-0.23); local uR2=phase(1.02)
local AL=mul(uL2,uL1); local AR=mul(uR2,uR1)
local gin=phase(0.33); local gout=phase(-0.28)
local ALp=transformed_path(uL1,uL2,gin,phase(1.7),gout)
local ARp=transformed_path(uR1,uR2,gin,phase(-2.1),gout)
local common=mul(gout,conj(gin))
ok(ceq(ALp,mul(common,AL)),'left internal gauge cancels')
ok(ceq(ARp,mul(common,AR)),'right internal gauge cancels')

-- Relative holonomy and interference probability are invariant under those rephasings.
local rel=mul(AL,conj(AR)); local relp=mul(ALp,conj(ARp))
ok(ceq(rel,relp),'relative phase between exact histories is gauge invariant')
local amp=add(AL,AR); local ampp=add(ALp,ARp)
ok(approx(abs2(amp),abs2(ampp)),'interference probability is gauge invariant')

print('phase holonomy: '..n..' assertions passed')
print('  exact Worlds histories can carry gauge-dependent local phases with gauge-invariant relative holonomy')
