package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local History=require('worlds.history')
local function decided(q) while true do local k,x=q:step(math.huge); if k~='more' then return k,x end end end
local function setup()
  local wb=W.builder(); local wm=wb:membrane(nil,'w'); local p=wb:point(wm,'p'); local token=wb:strand(wm,{p},'token'); local world=wb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil,'p'); local x=pb:point(pm,'x'); local i=pb:strand(pm,{x},'in'); local o=pb:strand(pm,{x},'out'); pb:face(pm,{i},{o},'step'); local step=pb:finish()
  return world,token,step,i,o
end
local function run_live(n,history)
  local world,token,step,i,o=setup(); world=W.boundary(world)
  collectgarbage(); collectgarbage(); local mem0=collectgarbage('count'); local t=os.clock()
  for _=1,n do
    local _,es=decided(W.solve(world,step,{{from=token,to=i}})); local image
    if history then world,image=history:advance(world,step,es) else world,image=W.advance(world,step,es) end
    token=image[o]
  end
  local dt=os.clock()-t; collectgarbage(); local mem=collectgarbage('count')-mem0
  return dt,mem,#world:faces(),#world:strands(),#world:membranes(),#world:points()
end
local function run_historical(n)
  local world,token,step,i,o=setup()
  collectgarbage(); collectgarbage(); local mem0=collectgarbage('count'); local t=os.clock()
  for _=1,n do
    local _,es=decided(W.solve(world,step,{{from=token,to=i}}))
    local joined,image=W.join({world,step},es); token=image[o]; world=joined
  end
  local dt=os.clock()-t; collectgarbage(); local mem=collectgarbage('count')-mem0
  return dt,mem,#world:faces(),#world:strands(),#world:membranes(),#world:points()
end
local n=tonumber(arg[1]) or 10000
local bt,bm,bf,bs,bmm,bp=run_live(n,nil)
print(('live      %d: %.6fs mem_delta=%.1fKB faces=%d strands=%d membranes=%d points=%d'):format(n,bt,bm,bf,bs,bmm,bp))
local hn=math.min(n,1000)
local history=History.new()
local ot,om,of,os,omm,op=run_live(hn,history)
print(('observed  %d: %.6fs mem_delta=%.1fKB events=%d faces=%d strands=%d'):format(hn,ot,om,history:count(),of,os))
local ht,hm,hf,hs,hmm,hp=run_historical(hn)
print(('full      %d: %.6fs mem_delta=%.1fKB faces=%d strands=%d membranes=%d points=%d'):format(hn,ht,hm,hf,hs,hmm,hp))
