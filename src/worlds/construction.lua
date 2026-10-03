-- Exact witness of one Worlds join materialisation.
local W=require('worlds')
local Q=require('worlds.query')
local Value=require('worlds._construction')
local Construction={}

local function normal_equations(es)
  local out={}
  for i,e in ipairs(es or {}) do
    assert(type(e)=='table','Construction equation entries must be exact equations')
    out[i]={from=e.from or e[1],to=e.to or e[2]}
  end
  return out
end

function Construction.join(parts,equations)
  equations=equations or {}
  local retained=Q.construction_for(parts,equations)
  if retained then return retained end
  local result,image=W.join(parts,equations)
  return Value.new{parts=parts,equations=normal_equations(equations),result=result,image=image}
end
function Construction.from_realisation(x)
  assert(Q.is_realisation(x),'Construction.from_realisation requires exact join evidence')
  return x
end
Construction.is_construction=Value.is
return Construction
