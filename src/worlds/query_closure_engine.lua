-- Direct finite-closure Question engine.
--
-- It compiles the explicit admissibility section into finite support and asks
-- the shared scarce-relation solver for injective relations covering the
-- required domain/range.  Geometry lawfulness remains exclusively with the
-- public Question wrapper's strict join check.
local relation=require('worlds.query_relation')
local EMPTY={}
local function immutable() error('Worlds values are immutable',2) end

local function solve_object(st)
  local q; local methods={}
  function methods:step(fuel)
    if st.done then return st.final_tag,st.final_value end
    fuel=fuel or 1000; if fuel<=0 then return 'more',q end
    local ok,tag,value=coroutine.resume(st.co,fuel); assert(ok,tag)
    if coroutine.status(st.co)=='dead' then st.done=true; st.final_tag,st.final_value=tag,value; return tag,value end
    return tag,value
  end
  q=setmetatable({}, {__index=methods,__newindex=immutable,__metatable='Worlds closure query state'}); return q
end

local function machine(st,initial_fuel)
  local fuel=initial_fuel or 0
  local function work(n) n=n or 1; while fuel<n do fuel=fuel+(coroutine.yield('more') or 0) end; fuel=fuel-n end
  local function emit(tag,value) fuel=coroutine.yield(tag,value) or 0 end

  local seed_from,seed_to,base={}, {},{}
  for _,e in ipairs(st.seeds or EMPTY) do local from,to=e.from or e[1],e.to or e[2]; seed_from[from]=to; seed_to[to]=from; base[#base+1]={from=from,to=to} end
  local required_sources={}; for _,source in ipairs(st.required_sources or EMPTY) do if not seed_from[source] then required_sources[#required_sources+1]=source end end
  local required_targets={}; for _,target in ipairs(st.required_targets or EMPTY) do if not seed_to[target] then required_targets[#required_targets+1]=target end end

  local targets,pools={},{}
  for _,target in ipairs(st.targets or EMPTY) do
    if not seed_to[target] then
      targets[#targets+1]=target; local pool={}
      for _,source in ipairs(st.sources or EMPTY) do
        work()
        if not seed_from[source] and (st.admissible_all or (st.allowed_by_to[target] and st.allowed_by_to[target][source])) then pool[#pool+1]=source end
      end
      pools[target]=pool
    end
  end

  local hits=0
  local _,proof=relation{
    targets=targets,pools=pools,required_targets=required_targets,required_sources=required_sources,work=work,
    emit=function(ass)
      local out={}; for _,e in ipairs(base) do out[#out+1]={from=e.from,to=e.to} end
      for _,target in ipairs(targets) do local source=ass[target]; if source then out[#out+1]={from=source,to=target} end end
      hits=hits+1; emit('yes',out)
    end,
  }
  if hits>0 then return 'done',hits end
  return 'no',proof or {kind='relation-support-exhausted'}
end

return function(spec)
  local st={sources=spec.sources or EMPTY,targets=spec.targets or EMPTY,required_sources=spec.required_sources or EMPTY,required_targets=spec.required_targets or EMPTY,seeds=spec.seeds or EMPTY,allowed_by_to=spec.allowed_by_to,admissible_all=spec.admissible_all,done=false}
  st.co=coroutine.create(function(fuel) return machine(st,fuel) end); return solve_object(st)
end
