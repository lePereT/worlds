-- Worlds 0.6.1 public facade.
--
-- `worlds._kernel` is the small verified centre.  This edge may eagerly build
-- disposable acceleration for Geometry entering through the public Builder,
-- but the centre neither imports nor calls the acceleration layer.
local Kernel=require('worlds._kernel')
local Core=Kernel.public
local Compiled=require('worlds._compiled')(Kernel.private)
local W={}
for k,v in pairs(Core) do W[k]=v end

-- Builder output is a natural installation boundary: prepare its outgoing
-- section here so the first query does not inherit O(boundary) compilation
-- work.  The wrapper owns no semantic state and preparation can be discarded.
function W.builder()
  local b=Core.builder()
  local methods={}
  function methods:membrane(...) return b:membrane(...) end
  function methods:point(...) return b:point(...) end
  function methods:strand(...) return b:strand(...) end
  function methods:face(...) return b:face(...) end
  function methods:finish(...)
    local g=b:finish(...)
    Compiled.prepare(g)
    return g
  end
  return setmetatable({}, {
    __index=methods,
    __newindex=function() error('Worlds values are immutable',2) end,
    __metatable='Worlds builder',
  })
end

local QUERY
function W.solve(world,development,seeds)
  if not QUERY then QUERY=require('worlds._query') end
  return QUERY.private.complete_solve(world,development,seeds or {})
end

return W
