-- Portable endpoint action whose first symbolic Point is an exact instantiation parameter.
-- Parameterisation is non-authoritative presentation: the Package shape stays symbolic while Live
-- supplies an imported exact Point instead of minting an owned local occurrence for that slot.
local W=require('worlds')
local Q=require('worlds.query')
local G=require('speculation.relay.computation.development_calculus.geometry')
local M={}

local anchor_builder=W.builder()
local anchor_membrane=anchor_builder:membrane(nil,'relay.endpoint.parameter.anchor')
anchor_builder:finish()
local mint=W.minter(anchor_membrane)

function M.mint(name) return mint(name) end

local function spec(kind)
  local g={membranes={{parent=0}},points={{membrane=1}},strands={},faces={}}
  local function strand()
    g.strands[#g.strands+1]={membrane=1,points={1}}
    return #g.strands
  end
  local cont
  g.points[2]={membrane=1}
  g.strands[1]={membrane=1,points={2}}
  cont=1
  local offer,ack
  if kind=='send' then
    ack=strand(); offer=strand()
    g.faces[1]={membrane=1,inputs={ack},outputs={offer,cont}}
    return g,{offer=offer,ack=ack,cont=cont,open_outputs={offer},open_inputs={ack}}
  end
  offer=strand(); ack=strand()
  g.faces[1]={membrane=1,inputs={offer},outputs={ack,cont}}
  return g,{offer=offer,ack=ack,cont=cont,open_outputs={ack},open_inputs={offer}}
end

local function instantiate(kind,identity)
  local g,p=spec(kind)
  local exact,map=G.instantiate(g,{[1]=identity})
  return {geometry=exact,identity=identity,offer=map.strands[p.offer],ack=map.strands[p.ack],
    cont=map.strands[p.cont],open_outputs=(kind=='send') and {map.strands[p.offer]} or {map.strands[p.ack]},
    open_inputs=(kind=='send') and {map.strands[p.ack]} or {map.strands[p.offer]}}
end
function M.send(identity) return instantiate('send',identity) end
function M.recv(identity) return instantiate('recv',identity) end

function M.close(a,b)
  local sources,targets={},{}
  for _,x in ipairs(a.open_outputs) do sources[#sources+1]=x end
  for _,x in ipairs(b.open_outputs) do sources[#sources+1]=x end
  for _,x in ipairs(a.open_inputs) do targets[#targets+1]=x end
  for _,x in ipairs(b.open_inputs) do targets[#targets+1]=x end
  local admissible={}
  for _,from in ipairs(a.open_outputs) do for _,to in ipairs(b.open_inputs) do admissible[#admissible+1]={from=from,to=to} end end
  for _,from in ipairs(b.open_outputs) do for _,to in ipairs(a.open_inputs) do admissible[#admissible+1]={from=from,to=to} end end
  local search=Q.solve(Q.close({a.geometry,b.geometry},{sources=sources,targets=targets,
    required_sources=sources,required_targets=targets,admissible=admissible}))
  local n=0
  while true do
    local tag=search:step(math.huge)
    if tag=='yes' then n=n+1 elseif tag=='done' or tag=='no' then break
    elseif tag~='more' then error('unexpected parameter endpoint Close result '..tostring(tag)) end
  end
  return n
end
return M
