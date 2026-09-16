-- Direct finite-closure Question engine.
--
-- This is deliberately simple search machinery. It owns no Geometry and does
-- not decide quotient lawfulness: the public Question judgement validates every
-- prospective witness with the kernel's strict join law before exposing yes(E).
--
-- A closure question supplies finite exact source/target sections, a required
-- target subset, an optional admissibility relation and exact seed equations.
-- Search enumerates injective equation sets covering every required/seed target
-- and any finite subset of optional targets. Presentation order has already been
-- canonicalised by worlds.query_factory.

return function()
local M={}
local function immutable() error('Worlds values are immutable',2) end
local EMPTY={}

local function solve_object(st)
  local q
  local methods={}
  function methods:step(fuel)
    if st.done then return st.final_tag,st.final_value end
    fuel=fuel or 1000
    if fuel<=0 then return 'more',q end
    local ok,tag,value=coroutine.resume(st.co,fuel)
    assert(ok,tag)
    if coroutine.status(st.co)=='dead' then
      st.done=true; st.final_tag,st.final_value=tag,value
      return tag,value
    end
    return tag,value
  end
  q=setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds closure query state'})
  return q
end

local function machine(st,initial_fuel)
  local fuel=initial_fuel or 0
  local function work(n)
    n=n or 1
    while fuel<n do fuel=fuel+(coroutine.yield('more') or 0) end
    fuel=fuel-n
  end
  local function emit(tag,value) fuel=coroutine.yield(tag,value) or 0 end

  local sources,targets=st.sources,st.targets
  local required_source={}; for _,x in ipairs(st.required_sources or EMPTY) do required_source[x]=true end
  local required,seed_from,seed_to={}, {}, {}
  for _,t in ipairs(st.required or EMPTY) do required[t]=true end
  local base={}
  for _,e in ipairs(st.seeds or EMPTY) do
    local from,to=e.from or e[1],e.to or e[2]
    seed_from[from]=to; seed_to[to]=from; required[to]=true
    base[#base+1]={from=from,to=to}
  end

  local optional={}
  for _,t in ipairs(targets) do if not required[t] then optional[#optional+1]=t end end

  local selected_optional={}
  local hits=0
  local last_support=nil

  local function source_allowed(from,to)
    return st.admissible_all or not not(st.allowed_by_to[to] and st.allowed_by_to[to][from])
  end

  local function enumerate_assignment()
    local used={}; for from in pairs(seed_from) do used[from]=true end
    local row={}; for i,e in ipairs(base) do row[i]={from=e.from,to=e.to} end
    local chosen={}
    for _,t in ipairs(targets) do
      if required[t] then chosen[#chosen+1]=t
      else
        for _,x in ipairs(selected_optional) do if x==t then chosen[#chosen+1]=t; break end end
      end
    end

    local function assign(i)
      if i>#chosen then
        local used_required={}; for _,e in ipairs(row) do used_required[e.from]=true end
        for source in pairs(required_source) do if not used_required[source] then return end end
        local out={}; for j,e in ipairs(row) do out[j]={from=e.from,to=e.to} end
        hits=hits+1; emit('yes',out); return
      end
      local to=chosen[i]
      local seeded=seed_to[to]
      if seeded then assign(i+1); return end
      local any=false
      for _,from in ipairs(sources) do
        work()
        if not used[from] and source_allowed(from,to) then
          any=true; used[from]=true; row[#row+1]={from=from,to=to}
          assign(i+1)
          row[#row]=nil; used[from]=nil
        end
      end
      if not any then last_support={kind='closure-support-exhausted',target=to} end
    end

    assign(1)
  end

  -- Enumerate optional-target subsets in canonical binary order.  Required and
  -- seeded targets are always present.  The empty optional subset comes first.
  local function subsets(i)
    if i>#optional then enumerate_assignment(); return end
    work(); subsets(i+1)
    selected_optional[#selected_optional+1]=optional[i]; subsets(i+1); selected_optional[#selected_optional]=nil
  end
  subsets(1)

  if hits>0 then return 'done',hits end
  return 'no',last_support or {kind='closure-support-exhausted'}
end

function M.solve(spec)
  local st={
    sources=spec.sources or EMPTY,targets=spec.targets or EMPTY,
    required_sources=spec.required_sources or EMPTY,required=spec.required or EMPTY,seeds=spec.seeds or EMPTY,
    allowed_by_to=spec.allowed_by_to,admissible_all=spec.admissible_all,
    done=false,
  }
  st.co=coroutine.create(function(fuel) return machine(st,fuel) end)
  return solve_object(st)
end
return M
end
