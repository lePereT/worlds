-- Shared scarce finite-relation search for Worlds Question engines.
--
-- Given finite target -> source support, enumerate injective relations covering
-- required targets and required sources.  Required range is matched first; any
-- still-uncovered required domain is then matched symmetrically against optional
-- targets; remaining optional edges are freely enumerable.  Only finite support
-- and scarcity live here. Geometry lawfulness remains with Question.
local EMPTY={}
local function array(xs) local r={} for i=1,#(xs or EMPTY) do r[i]=xs[i] end return r end
local function set(xs) local r={} for _,x in ipairs(xs or EMPTY) do r[x]=true end return r end

local function hall(order,pools,used,work)
  if #order==0 then return {},nil end
  local same=pools[order[1]] or EMPTY; local allsame=true
  if next(used)==nil then
    for i=2,#order do work(); if (pools[order[i]] or EMPTY)~=same then allsame=false; break end end
    if allsame then
      if #same<#order then return nil,{kind='fibre-capacity',required=#order,available=#same} end
      local preferred={}; for i,demand in ipairs(order) do preferred[demand]=same[i] end; return preferred,nil
    end
  end
  local owner,preferred={},{}
  for _,root in ipairs(order) do
    local queue,qi={root},1; local seenD={[root]=true}; local seenO={}; local prev={}; local free
    while qi<=#queue and not free do
      local demand=queue[qi]; qi=qi+1
      for _,occurrence in ipairs(pools[demand] or EMPTY) do
        work()
        if not used[occurrence] and not seenO[occurrence] then
          seenO[occurrence]=true; prev[occurrence]=demand
          local held=owner[occurrence]
          if not held then free=occurrence; break end
          if not seenD[held] then seenD[held]=true; queue[#queue+1]=held end
        end
      end
    end
    if not free then return nil,{kind='hall-deficiency',demands=seenD,occurrences=seenO} end
    local occurrence=free
    while occurrence do local demand=prev[occurrence]; local old=preferred[demand]; preferred[demand]=occurrence; owner[occurrence]=demand; occurrence=old end
  end
  return preferred,nil
end

local function allocations(demands,pools,used,work,each)
  local order=array(demands)
  if #order==0 then each({},used); return true,nil end
  table.sort(order,function(a,b) return #(pools[a] or EMPTY)<#(pools[b] or EMPTY) end)
  local preferred,proof=hall(order,pools,used,work); if not preferred then return false,proof end
  local ass,frames={},{}; local depth=1; frames[1]={first=true,next=1}
  while depth>0 do
    local demand=order[depth]; local frame=frames[depth]; local pool=pools[demand] or EMPTY; local picked
    while true do
      work(); local occurrence
      if frame.first then frame.first=false; occurrence=preferred[demand]
      else while frame.next<=#pool do local x=pool[frame.next]; frame.next=frame.next+1; if x~=preferred[demand] then occurrence=x; break end end end
      if not occurrence then break end
      if not used[occurrence] then picked=occurrence; break end
    end
    if picked then
      ass[demand]=picked; used[picked]=true
      if depth==#order then each(ass,used); ass[demand]=nil; used[picked]=nil
      else depth=depth+1; frames[depth]={first=true,next=1} end
    else
      frames[depth]=nil; depth=depth-1
      if depth>0 then local parent=order[depth]; local occurrence=ass[parent]; if occurrence then ass[parent]=nil; used[occurrence]=nil end end
    end
  end
  return true,nil
end

return function(spec)
  local targets=array(spec.targets); local pools=spec.pools or EMPTY
  local required_target,required_source=set(spec.required_targets),set(spec.required_sources)
  local required_targets,optional_targets={},{}
  for _,target in ipairs(targets) do if required_target[target] then required_targets[#required_targets+1]=target else optional_targets[#optional_targets+1]=target end end
  local optional_by_source={}
  if next(required_source) then for _,target in ipairs(optional_targets) do for _,source in ipairs(pools[target] or EMPTY) do spec.work(); local xs=optional_by_source[source]; if not xs then xs={}; optional_by_source[source]=xs end; xs[#xs+1]=target end end end

  local used_sources={}; local emitted=0; local lastproof
  local ok,proof=allocations(required_targets,pools,used_sources,spec.work,function(range_ass)
    local missing_sources={}; for source in pairs(required_source) do if not used_sources[source] then missing_sources[#missing_sources+1]=source end end
    local target_pools={}
    for _,source in ipairs(missing_sources) do target_pools[source]=optional_by_source[source] or EMPTY end
    local used_targets={}; for _,target in ipairs(required_targets) do used_targets[target]=true end
    local ok2,proof2=allocations(missing_sources,target_pools,used_targets,spec.work,function(domain_ass)
      for source,target in pairs(domain_ass) do range_ass[target]=source; used_sources[source]=true end
      local function optional(i)
        if i>#optional_targets then local out={}; for target,source in pairs(range_ass) do out[target]=source end; emitted=emitted+1; spec.emit(out); return end
        spec.work(); local target=optional_targets[i]
        if not used_targets[target] then
          optional(i+1)
          for _,source in ipairs(pools[target] or EMPTY) do
            spec.work()
            if not used_sources[source] then range_ass[target]=source; used_sources[source]=true; optional(i+1); used_sources[source]=nil; range_ass[target]=nil end
          end
        else optional(i+1) end
      end
      optional(1)
      for source,target in pairs(domain_ass) do range_ass[target]=nil; used_sources[source]=nil end
    end)
    if not ok2 then lastproof=proof2 end
  end)
  if not ok then return false,proof end
  if emitted==0 then return false,lastproof or {kind='relation-support-exhausted'} end
  return true,nil
end
