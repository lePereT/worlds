-- One exact witness of one Worlds join materialisation.
-- Query search and direct construction share this value; it carries no authority.
local STATE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end
local MT={__newindex=immutable,__metatable='Worlds Construction'}; MT.__index=MT
local M={}

function M.new(st)
  local x=setmetatable({},MT); STATE[x]=st; return x
end
function M.is(x) return type(x)=='table' and STATE[x]~=nil end
function M.state(x) return STATE[x] end
function M.image_table(x) local st=assert(STATE[x],'Worlds Construction required'); return st.image end

function MT:parts() return assert(STATE[self],'Worlds Construction required').parts end
function MT:equations() return assert(STATE[self],'Worlds Construction required').equations end
function MT:result() return assert(STATE[self],'Worlds Construction required').result end
function MT:image(carrier) return assert(STATE[self],'Worlds Construction required').image[carrier] end
function MT:boundary()
  local st=assert(STATE[self],'Worlds Construction required')
  if st.boundary_ready then return st.boundary or nil end
  st.boundary_ready=true
  st.boundary=st.boundary_fn and st.boundary_fn() or false
  st.boundary_fn=nil
  return st.boundary or nil
end
return M
