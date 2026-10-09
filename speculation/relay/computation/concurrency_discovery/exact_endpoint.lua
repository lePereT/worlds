-- Exact dynamic endpoint identity experiment.
-- Fresh identity is an imported exact Point. It is not package data and not a string name.
-- Close treats imported target Points as rigid, so only seams carrying the same exact Point match.
local W=require('worlds')
local Q=require('worlds.query')
local M={}

local anchor_builder=W.builder()
local anchor_membrane=anchor_builder:membrane(nil,'relay.endpoint.anchor')
local anchor_geometry=anchor_builder:finish()
local mint=W.minter(anchor_membrane)
local OFFER=mint('relay.endpoint.offer')
local ACK=mint('relay.endpoint.ack')

function M.mint(name) return mint(name) end
function M.anchor() return anchor_geometry end

local function action(kind,identity)
  assert(W.kind(identity)=='point','exact endpoint Point required')
  local b=W.development_builder()
  local m=b:membrane(nil,kind)
  local p=b:point(m,kind..'.continuation')
  local cont=b:strand(m,{p},kind..'.continue')
  local offer,ack,face
  if kind=='send' then
    ack=b:strand(m,{identity,ACK},'ack.in')
    offer=b:strand(m,{identity,OFFER},'offer.out')
    face=b:face(m,{ack},{offer,cont},'send')
    local g=b:finish()
    return {geometry=g,inputs={ack},outputs={offer,cont},open_inputs={ack},open_outputs={offer}}
  end
  offer=b:strand(m,{identity,OFFER},'offer.in')
  ack=b:strand(m,{identity,ACK},'ack.out')
  face=b:face(m,{offer},{ack,cont},'recv')
  local g=b:finish()
  return {geometry=g,inputs={offer},outputs={ack,cont},open_inputs={offer},open_outputs={ack}}
end

function M.send(identity) return action('send',identity) end
function M.recv(identity) return action('recv',identity) end

function M.close(a,b)
  local parts={a.geometry,b.geometry}
  local sources={}
  for _,x in ipairs(a.open_outputs) do sources[#sources+1]=x end
  for _,x in ipairs(b.open_outputs) do sources[#sources+1]=x end
  local targets={}
  for _,x in ipairs(a.open_inputs) do targets[#targets+1]=x end
  for _,x in ipairs(b.open_inputs) do targets[#targets+1]=x end
  local admissible={}
  for _,from in ipairs(a.open_outputs) do for _,to in ipairs(b.open_inputs) do
    admissible[#admissible+1]={from=from,to=to}
  end end
  for _,from in ipairs(b.open_outputs) do for _,to in ipairs(a.open_inputs) do
    admissible[#admissible+1]={from=from,to=to}
  end end
  local search=Q.solve(Q.close(parts,{sources=sources,targets=targets,
    required_sources=sources,required_targets=targets,admissible=admissible}))
  local results={}
  while true do
    local tag,eqs=search:step(math.huge)
    if tag=='yes' then
      local g,image=W.join(parts,eqs)
      results[#results+1]={geometry=g,image=image,equations=eqs}
    elseif tag=='done' or tag=='no' then break
    elseif tag~='more' then error('unexpected exact endpoint Close result '..tostring(tag)) end
  end
  return results
end

return M
