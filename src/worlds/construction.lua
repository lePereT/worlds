-- Immutable witness of one exact Worlds join materialisation.
--
-- Construction does not introduce a second composition semantics:
-- Construction.join(parts,equations) performs the ordinary Worlds join and
-- retains immutable access to its parts, normalised equations, result Geometry
-- and exact construction-relative carrier image.

local W=require('worlds')
local DENSE=require('worlds._array')

local Construction={}
local MT={}; MT.__index=MT
local MARK_KEY,STATE_KEY,MARK={},{},{}

local function immutable() error('Worlds values are immutable',2) end

local function state(x)
  if type(x)~='table' then return nil end
  local ok,m=pcall(function() return x[MARK_KEY] end)
  if not ok or m~=MARK then return nil end
  local ok2,st=pcall(function() return x[STATE_KEY] end)
  return ok2 and st or nil
end

local function copy(xs)
  local out={}
  for i=1,#xs do out[i]=xs[i] end
  return out
end

local function copy_equations(es)
  local out={}
  for i=1,#es do out[i]={from=es[i].from,to=es[i].to} end
  return out
end

local function normal_equations(es)
  es=es or {}
  DENSE.length(es,'Construction equations')
  local out={}
  for i,e in ipairs(es) do
    assert(type(e)=='table','Construction equation entries must be exact equations')
    out[i]={from=e.from or e[1],to=e.to or e[2]}
  end
  return out
end

local function value(st)
  return setmetatable({}, {
    __newindex=immutable,
    __metatable='Worlds Construction',
    __index=function(_,k)
      if k==MARK_KEY then return MARK end
      if k==STATE_KEY then return st end
      return MT[k]
    end,
  })
end

function Construction.join(parts,equations)
  local ps=DENSE.copy(parts,'Construction parts')
  local es=normal_equations(equations)
  local result,image=W.join(ps,es)
  return value{parts=ps,equations=es,result=result,image=image}
end

function Construction.is_construction(x)
  return state(x)~=nil
end

function MT:parts()
  return copy(assert(state(self),'Worlds Construction required').parts)
end

function MT:equations()
  return copy_equations(assert(state(self),'Worlds Construction required').equations)
end

function MT:result()
  return assert(state(self),'Worlds Construction required').result
end

function MT:image(carrier)
  return assert(state(self),'Worlds Construction required').image[carrier]
end

return Construction
