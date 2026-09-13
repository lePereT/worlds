package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local History=require('worlds.history')
local n=0; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function ok(x,m) n=n+1; assert(x,m) end
local function decided(q) while true do local k,x=q:step(100); if k~='more' then return k,x end end end

local wb=W.builder(); local wm=wb:membrane(nil,'w'); local p=wb:point(wm,'p'); local token=wb:strand(wm,{p},'token'); local world=W.boundary(wb:finish())
local pb=W.builder(); local pm=pb:membrane(nil,'p'); local x=pb:point(pm,'x'); local i=pb:strand(pm,{x},'in'); local o=pb:strand(pm,{x},'out'); local f=pb:face(pm,{i},{o},'step'); local step=pb:finish()

local h=History.new()
for k=1,20 do
  local tag,es=decided(W.solve(world,step,{{from=token,to=i}})); eq(tag,'yes')
  local old=token
  local image
  world,image=h:advance(world,step,es); token=image[o]
  eq(#world:faces(),0); eq(#world:strands(),1); ok(token~=old); eq(h:count(),k)
  local r=h:events()[k]; eq(r.development,step); eq(r.equations[1].from,old); eq(r.faces[f],image[f])
end

-- History is observational: dropping it cannot change the next exact solve.
local tag1,e1=decided(W.solve(world,step,{{from=token,to=i}})); eq(tag1,'yes')
local events=h:events(); h=nil; collectgarbage(); collectgarbage()
local tag2,e2=decided(W.solve(world,step,{{from=token,to=i}})); eq(tag2,'yes'); eq(e1[1].from,e2[1].from); eq(e1[1].to,e2[1].to); ok(#events==20)

print('PASS optional history',n,'assertions')
