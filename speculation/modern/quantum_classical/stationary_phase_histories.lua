local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx

-- Representative exact Worlds histories with different hidden intermediate
-- positions but the same surviving subsystem interface.
local wb=W.builder(); local wm=wb:membrane(nil,'endpoints'); local q=wb:point(wm,'particle'); local src=wb:strand(wm,{q},'start'); local world=wb:finish()
local function route(name)
  local b=W.builder(); local m=b:membrane(nil,name); local Q=b:point(m,'Q'); local X=b:point(m,'hidden-position'); local i=b:strand(m,{Q},'in'); local mid=b:strand(m,{Q,X},'x'); local o=b:strand(m,{Q},'out')
  b:face(m,{i},{mid},'first segment'); b:face(m,{mid},{o},'second segment'); return {g=b:finish(),i=i,o=o,X=X}
end
local outs={}
for i,x in ipairs{-0.75,0.25,1.25} do local r=route('x='..x); local s=W.solve(world,r.g,{{from=src,to=r.i}}); local tag,es=s:step(math.huge); eq(tag,'yes'); local live,img=W.advance(world,r.g,es); outs[i]=img[r.o]; ok(img[r.X]~=nil,'hidden route has exact materialised identity in the joined history') end
eq(T.row_key(W,outs[1]),T.row_key(W,outs[2])); eq(T.row_key(W,outs[2]),T.row_key(W,outs[3]))

-- Discrete free-particle-style action for endpoints x0=0 at t=0 and x1=1 at
-- total time 4, with one hidden position at t=1:
--   S(x)=(x-x0)^2/1 + (x1-x)^2/3.
-- Its stationary point is x*=1/4, exactly the classical straight-line position.
local x0,x1,t1,t2=0,1,1,3
local xstar=(x0*t2+x1*t1)/(t1+t2); approx(xstar,0.25)
local function action(x) return (x-x0)^2/t1+(x1-x)^2/t2 end
local Spp=2/t1+2/t2; local Sstar=action(xstar)
local function integrate(lambda)
  local dx=0.001; local re,im,fre,fim=0,0,0,0
  for k=-5000,5000 do
    local x=k*dx; local ph=lambda*action(x); local cr=math.cos(ph)*dx; local ci=math.sin(ph)*dx
    re=re+cr; im=im+ci
    if math.abs(x-xstar)>1 then fre=fre+cr; fim=fim+ci end
  end
  local function mag(a,b) return math.sqrt(a*a+b*b) end
  return {re=re,im=im,mag=mag(re,im),far=mag(fre,fim)}
end
local ratios={}
for i,lam in ipairs{10,40,160} do
  local z=integrate(lam); ratios[i]=z.far/z.mag
  local scale=math.sqrt(2*math.pi/(lam*Spp)); local phase=lam*Sstar+math.pi/4
  local tr=scale*math.cos(phase); local ti=scale*math.sin(phase)
  local err=math.sqrt((z.re-tr)^2+(z.im-ti)^2)/scale
  ok(err<0.02,'path sum approaches stationary-phase asymptotic around the classical intermediate point')
end
ok(ratios[1]>ratios[2] and ratios[2]>ratios[3],'non-stationary regions cancel progressively as action/hbar grows')
ok(ratios[3]<0.04,'high-action path sum is dominated by a fixed neighbourhood of the stationary/classical path')

print('stationary-phase Worlds histories: '..T.count()..' assertions passed')
print('  a free-particle-style quantum sum over hidden exact constructions asymptotically selects the classical least-action intermediate position')
