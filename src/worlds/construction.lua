-- Immutable witness of one exact Worlds join materialisation.
--
-- Construction does not introduce a second composition semantics:
-- Construction.join(parts,equations) performs the ordinary Worlds join and
-- retains immutable access to its parts, normalised equations, result Geometry
-- and exact construction-relative carrier image.

local W=require('worlds')
local Q=require('worlds.query')
local Construction={}
local STATE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end
local MT={__newindex=immutable,__metatable='Worlds Construction'}; MT.__index=MT

local function state(x) return type(x)=='table' and STATE[x] or nil end

local function normal_equations(es)
  local out={}
  for i,e in ipairs(es) do
    assert(type(e)=='table','Construction equation entries must be exact equations')
    out[i]={from=e.from or e[1],to=e.to or e[2]}
  end
  return out
end

local function value(st)
  local x=setmetatable({},MT); STATE[x]=st; return x
end

function Construction.join(parts,equations)
  equations=equations or {}
  local r=Q.realisation_for(parts,equations)
  if r then return value{realisation=r} end
  local result,image=W.join(parts,equations)
  return value{parts=parts,equations=normal_equations(equations),result=result,image=image}
end

function Construction.from_realisation(realisation)
  assert(Q.is_realisation(realisation),'Construction.from_realisation requires Worlds Realisation')
  return value{realisation=realisation}
end

function Construction.is_construction(x)
  return state(x)~=nil
end

function MT:parts()
  local st=assert(state(self),'Worlds Construction required'); return st.realisation and st.realisation:parts() or st.parts
end

function MT:equations()
  local st=assert(state(self),'Worlds Construction required'); return st.realisation and st.realisation:equations() or st.equations
end

function MT:result()
  local st=assert(state(self),'Worlds Construction required'); return st.realisation and st.realisation:result() or st.result
end

function MT:image(carrier)
  local st=assert(state(self),'Worlds Construction required'); return st.realisation and st.realisation:image(carrier) or st.image[carrier]
end

return Construction
