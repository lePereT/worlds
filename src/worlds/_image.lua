-- Exact construction-image value.  This is evidence around Geometry, not Geometry.
local STATE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end
local MT={__newindex=immutable,__metatable='Worlds construction image'}
local M={}
MT.__index=function(self,x)
  local s=STATE[self]
  if not s then return nil end
  if s.full then return s.full[x] end
  local y=s.changed[x]
  if y~=nil then return y end
  if s.consumed[x] then return nil end
  return s.domain and s.domain(s.parts,x) and x or nil
end
function M.new(parts,changed,consumed,full,domain)
  local x=setmetatable({},MT)
  STATE[x]={parts=parts,changed=changed or {},consumed=consumed or {},full=full,domain=domain}
  return x
end
function M.is(x) return not not STATE[x] end
return M
