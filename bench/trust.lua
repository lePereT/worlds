package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local Presentation=require('worlds.presentation')
local Query=require('worlds.query')
local clock=os.clock

local function timed(name,n,fn)
  collectgarbage('collect')
  local t=clock()
  local checksum=0
  for i=1,n do if fn(i) then checksum=checksum+1 end end
  local dt=clock()-t
  print(string.format('API\t%s\t%d\t%.9f\t%d',name,n,dt,checksum))
end

local b=W.builder()
local m=b:membrane(nil,'m')
local ps={}
for i=1,8 do ps[i]=b:point(m,'p'..i) end
local s=b:strand(m,ps,'s')
b:finish()
timed('W.points',300000,function() return W.points(s)[4] end)

local eb=W.builder()
local em=eb:membrane(nil,'e')
for i=1,1000 do eb:strand(em,{},'s'..i) end
local eg=eb:finish()
timed('Geometry.egress',5000,function() return eg:egress()[777] end)

local a=W.builder()
local am=a:membrane(nil,'a')
local ao=a:strand(am,{},'ao')
local A=a:finish()
local c=W.builder()
local cm=c:membrane(nil,'c')
local ci=c:strand(cm,{},'ci')
local C=c:finish()
local con=Construction.join({A,C},{{from=ao,to=ci}})
timed('Construction.parts',300000,function() return con:parts()[1] end)
timed('Construction.equations',300000,function() return con:equations()[1].from end)
local pres=Presentation.new(A,{{ao}})
timed('Presentation.row',300000,function() return pres:row(1)[1] end)
local qb=W.builder()
local qm=qb:membrane(nil,'q')
local qi=qb:strand(qm,{},'qi')
local QG=qb:finish()
local q=Query.match(A,QG,{sources={ao},targets={qi},admissible={{from=ao,to=qi}},
    seeds={{from=ao,to=qi}}})
timed('Question.sources',300000,function() return q:sources()[1] end)
timed('Question.seeds',300000,function() return q:seeds()[1].from end)

local NOBJ,NCALL=50000,1000000
local function encapsulation(name,make,call)
  collectgarbage('collect')
  local kb0=collectgarbage('count')
  local t=clock()
  local xs={}
  for i=1,NOBJ do xs[i]=make(i) end
  local make_dt=clock()-t
  local heap=collectgarbage('count')-kb0
  local sum=0
  t=clock()
  for i=1,NCALL do sum=sum+call(xs[(i-1)%NOBJ+1]) end
  local call_dt=clock()-t
  print(string.format('ENCAP\t%s\t%d\t%d\t%.9f\t%.9f\t%.1f\t%d',name,NOBJ,NCALL,make_dt,call_dt,
      heap,sum))
end

local WS=setmetatable({}, {__mode='k'})
local WMT={}
WMT.__index=WMT
function WMT:get() return WS[self].v end
encapsulation('weak-key',function(i) local x=setmetatable({},WMT)
WS[x]={v=i}
return x end,function(x) return x:get() end)

local ACCESS={}
local CMT={}
CMT.__index=CMT
local function closure_state(x) local access=rawget(x,ACCESS)
return access and access() or nil end
function CMT:get() return closure_state(self).v end
encapsulation('closure',function(i)
  local st={v=i}
  local function access() return st end
  return setmetatable({[ACCESS]=access},CMT)
end,function(x) return x:get() end)
