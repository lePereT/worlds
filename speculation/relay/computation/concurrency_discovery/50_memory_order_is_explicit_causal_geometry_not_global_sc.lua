local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local C,M,T=H.C,H.MemoryOrder,H.T
local x=M.step(M.seed('x'),M.relaxed('x'))
local y=M.step(M.seed('y'),M.relaxed('y'))
local independent=C.each({x,y})
local a=independent:alternative(1)
local function state_face(cell)
  local si=nil
  for _,s in ipairs(a.authority.outputs) do
    local r=a.support and a.support.strands and a.support.strands[s]
    if r and r.protocol=='relay.atomic.state' and T.value(a.theory,r.cell.var)==cell then si=s; break end
  end
  assert(si,'state output not found')
  for fi,f in ipairs(a.geometry.faces) do for _,out in ipairs(f.outputs) do if out==si then return fi end end end
  error('state producer Face not found')
end
local fx,fy=state_face('x'),state_face('y')
ok(not H.G.face_reaches(a.geometry,fx,fy) and not H.G.face_reaches(a.geometry,fy,fx),
  'operations on distinct cells acquired accidental global SC order')
local rx=M.step(M.seed('x'),M.release('x'))
local pair=C.each({rx,M.seed('y')})
local sync=M.output_position(pair,'relay.atomic.order')
local ystate=M.output_position(pair,'relay.atomic.state','y')
local ordered=C.and_then(pair,M.acquire('y'),{value_pairs={},captures={{from=ystate,to=1},{from=sync,to=2}}})
local o=ordered:alternative(1)
local xout=nil; local yout=nil
for _,s in ipairs(o.authority.outputs) do
  local r=o.support and o.support.strands and o.support.strands[s]
  if r and r.protocol=='relay.atomic.state' then
    local cell=T.value(o.theory,r.cell.var)
    if cell=='x' then xout=s elseif cell=='y' then yout=s end
  end
end
local function producer(si)
  for fi,f in ipairs(o.geometry.faces) do for _,out in ipairs(f.outputs) do if out==si then return fi end end end
end
ok(H.G.face_reaches(o.geometry,assert(producer(xout)),assert(producer(yout))),
  'release/acquire authority did not create cross-location causal order')
ok(H.no_runtime_words(ordered:bytes()))
print('PASS cc 50: distinct atomics are not globally SC; release/acquire is explicit causal authority ('..count()..')')
