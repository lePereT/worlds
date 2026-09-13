package.path='./src/?.lua;'..package.path
local W=require('worlds')
local function decided(q) while true do local k,x=q:step(math.huge); if k~='more' then return k,x end end end
local function timed(name,fn) collectgarbage('collect'); local before=collectgarbage('count'); local t=os.clock(); local x=fn(); collectgarbage('collect'); local after=collectgarbage('count'); print(string.format('%-24s %.6f  heap=%dKB  %s',name,os.clock()-t,math.floor(after-before),tostring(x or ''))) end

-- Transitive descendant equality: adjacent shared Points connect all demands,
-- so the common depth-3000 membrane ancestry is not a factor variable.
local function chain(depth,n)
  local b=W.builder(); local m=b:membrane(nil); for _=2,depth do m=b:membrane(m) end
  local p={}; for i=1,n-1 do p[i]=b:point(m) end
  for i=1,n do local ps={}; if i>1 then ps[#ps+1]=p[i-1] end; if i<n then ps[#ps+1]=p[i] end; b:strand(m,ps) end
  return b:finish()
end
local cw,cp=chain(3000,50),chain(3000,50)
timed('boundary-chain-3000x50',function() return decided(W.solve(cw,cp)) end)


-- Many locality endpoints at different depths exercise the lazy level-ancestor
-- index. This used to retain long ancestor prefixes per starting membrane.
local function multistart(depth,n)
  local b=W.builder(); local ms={}; ms[1]=b:membrane(nil)
  for i=2,depth do ms[i]=b:membrane(ms[i-1]) end
  local ps={}; for i=1,n do ps[i]=b:point(ms[math.max(1,math.floor(i*depth/n))]) end
  b:strand(ms[depth],ps); return b:finish()
end
local mw,mp=multistart(2000,80),multistart(2000,80)
timed('ancestor-2000x80',function() return decided(W.solve(mw,mp)) end)

-- Dense provenance/support pressure.
local function complete(n)
  local b=W.builder(); local m=b:membrane(nil); local p={}
  for i=1,n do p[i]=b:point(m) end
  for i=1,n do for j=1,n do b:strand(m,{p[i],p[j]}) end end
  return b:finish()
end
local world=complete(50)
local p=W.builder(); local m=p:membrane(nil); local a=p:point(m); local b=p:point(m); local c=p:point(m)
p:strand(m,{a,b}); p:strand(m,{b,c}); p:strand(m,{c,a}); local tri=p:finish()
timed('dense-triangle-50',function() return decided(W.solve(world,tri)) end)

-- Whole-Geometry join remains linear in a large flat frame.
local fb=W.builder(); local fm=fb:membrane(nil); local ss={}; for i=1,50000 do ss[i]=fb:strand(fm,{}) end; local frame=fb:finish()
local tb=W.builder(); local tm=tb:membrane(nil); local d=tb:strand(tm,{}); local templ=tb:finish()
local _,es=decided(W.solve(frame,templ,{{from=ss[1],to=d}}))
timed('join-frame-50000',function() local g=W.join({frame,templ},es); return #g:egress() end)
