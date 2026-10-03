-- Worlds 0.6.4 public facade.
--
-- `worlds._kernel` is the small verified centre.  This edge may eagerly build
-- disposable acceleration for Geometry entering through the public Builder,
-- but the centre neither imports nor calls the acceleration layer.
local Kernel=require('worlds._kernel')
local Core=Kernel.public
local Compiled=require('worlds._compiled')(Kernel.private)
local Boundary=require('worlds._boundary')(Kernel.private)
local DENSE=require('worlds._array')
local EMPTY={}
local W={}
for k,v in pairs(Core) do W[k]=v end

-- Ordinary Builder output is an installed/query-source boundary and prepares
-- disposable outgoing acceleration.  Short-lived developments can explicitly
-- use development_builder(), which creates the same exact Geometry without the
-- source-only preparation cost.
function W.builder()
  local b=Core.builder(); local methods={}
  function methods:membrane(...) return b:membrane(...) end
  function methods:point(...) return b:point(...) end
  function methods:strand(...) return b:strand(...) end
  function methods:face(...) return b:face(...) end
  function methods:finish(...) local g=b:finish(...); Compiled.prepare(g); local st=Kernel.private.geometry(g); if st.boundary_normal and #st.strands>=64 then Boundary.prepare(g) end; return g end
  return setmetatable({}, {__index=methods,__newindex=function() error('Worlds values are immutable',2) end,__metatable='Worlds builder'})
end
function W.development_builder() return Kernel.private.development_builder() end

-- Exact in-process token minting.  The minter retains only its authentic
-- locality; minted Points are ordinary exact carriers and are not retained by
-- Worlds once clients drop them.
function W.minter(membrane)
  assert(Core.kind(membrane)=='membrane','Worlds minter requires an exact Membrane')
  return function(name) return Kernel.private.mint_point(membrane,name) end
end

local QUERY
local core_advance=W.advance
function W.solve(world,development,seeds)
  if not QUERY then QUERY=require('worlds._query') end
  return QUERY.private.complete_solve(world,development,seeds or {})
end

-- A successful Question has already performed the strict join.  Reusing that
-- exact witness avoids re-materialising the same candidate at commit.
function W.advance(world,development,equations)
  if not QUERY then QUERY=require('worlds._query') end
  if QUERY.public.is_realisation(world) then
    return QUERY.public.realisation_boundary(world) or Core.boundary(world:result()),QUERY.public.realisation_image(world)
  end
  local es=equations or EMPTY
  local bw=Core.boundary(world); local st=QUERY.private.take_realisation({bw,development},es)
  if st then return QUERY.private.realisation_boundary(st) or Core.boundary(st.result),st.image end
  -- Fast advance paths are public API implementations of strict join, so they
  -- must preserve the same finite-section shape contract before bypassing the
  -- generic join validator.  This checks only the touched equation section and
  -- does not copy it.
  local equation_count=DENSE.length(es,'join equations')
  if Boundary.has(bw) then
    local delta=Kernel.private.single_face_delta(bw,development,es)
    if delta then return Boundary.apply(bw,delta.removed,delta.added),delta.image end

    -- General local Development: use the same frame quotient as directional
    -- Match, but only when its locality preconditions are evident.  The helper
    -- is soft solely so an invalid candidate can fall through to the public
    -- strict reference law below, preserving its validation/error behaviour.
    -- Equation count is a conservative upper bound on touched source count.
    -- Broad exact actions therefore skip the local probe rather than paying a
    -- second target scan before the generic strict join.  Duplicate equations
    -- may forgo an optimisation, never semantics.
    if equation_count<=64 and equation_count*4<=#bw:egress() then
      local function source_position(from) return Boundary.position(bw,'strand',from) end
      local local_result,local_image=Kernel.private.try_frame_join(bw,development,es,source_position)
      if local_result then return Boundary.after(bw,local_result),local_image end
    end
  end
  return core_advance(world,development,es)
end

return W
