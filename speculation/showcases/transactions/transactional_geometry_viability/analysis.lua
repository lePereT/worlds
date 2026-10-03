-- Least fixed point of finite boundary Development cases.  This is semantic
-- Judgement analysis over the cyclic Package, not evaluator/search history.
local Case=require('speculation.showcases.transactions.transactional_geometry_viability.case')
local Authority=require('speculation.showcases.transactions.transactional_geometry_viability.authority')
local Context=require('speculation.showcases.transactions.transactional_recursive_judgement.context')
local Package=require('speculation.showcases.transactions.transactional_recursive_judgement.package')
local M={}

local function sorted_cases(map)
  local keys={}
 for k in pairs(map or {}) do keys[#keys+1]=k end
 table.sort(keys)
  local out={}
 for i,k in ipairs(keys) do out[i]=map[k] end
 return out
end
local function add(map,template,collisions)
  if not template then return false end
  local c=Case.new(template)
 local old=map[c.key]
  if not old then c.alt_representative_keys={[c.template_key]=true}
 map[c.key]=c
 return true end
  old.alt_representative_keys=old.alt_representative_keys or {[old.template_key]=true}
  if not old.alt_representative_keys[c.template_key] then
    old.alt_representative_keys[c.template_key]=true
    old.second_representative=old.second_representative or c.representative
    collisions.count=collisions.count+1
  end
  return false
end
local function product(lists,visit)
  if #lists==0 then visit({})
 return end
  local row={}
  local function go(i)
    if i>#lists then local x={}
 for j,v in ipairs(row) do x[j]=v end
 visit(x)
 return end
    for _,v in ipairs(lists[i]) do row[i]=v
 go(i+1) end
  end
  go(1)
end
local function context_cases(context,behaviour,out,collisions)
  local c=Context.normal(context)
  if #c.holes==0 then local t=Context.plug(c,{})
 if t then add(out,t,collisions) end
 return end
  local lists={}
  for i,h in ipairs(c.holes) do
    local child=assert(behaviour[assert(h.target.root)],'missing child authority viability')
    lists[i]=sorted_cases(child)
    if #lists[i]==0 then return end
  end
  product(lists,function(tuple)
    local reps={}
 for i,x in ipairs(tuple) do reps[i]=x.representative end
    local t=Context.plug(c,reps)
 if t then add(out,t,collisions) end
  end)
end

function M.compute(package)
  assert(Package.is(package),'restrictive recurrence Package required')
  for _,d in ipairs(package:definitions()) do for _,c in ipairs(d.family.items) do Authority.assert_complete(c.template) end end
  local defs=package:definitions()
 local roots={}
 for _,d in ipairs(defs) do roots[#roots+1]=d.root end
  local behaviour={}
 for _,r in ipairs(roots) do behaviour[r]={} end
  local collisions={count=0}
 local rounds=0
  while true do
    rounds=rounds+1
 assert(rounds<=256,'authority viability quotient failed to converge')
    local changed=false
 local generated={}
 for _,r in ipairs(roots) do generated[r]={} end
    for _,r in ipairs(roots) do
      local d=assert(package:definition(r))
      for _,c in ipairs(d.family.items) do context_cases(c,behaviour,generated[r],collisions) end
    end
    for _,r in ipairs(roots) do for _,c in pairs(generated[r]) do
      if not behaviour[r][c.key] then behaviour[r][c.key]=c
 changed=true
      else
        local old=behaviour[r][c.key]
        if c.second_representative and not old.second_representative then old.second_representative=c.second_representative end
      end
    end end
    if not changed then break end
  end
  local alternatives={}
  for _,r in ipairs(roots) do
    local d=assert(package:definition(r))
 alternatives[r]={}
    for i,c in ipairs(d.family.items) do local map={}
 context_cases(c,behaviour,map,collisions)
 alternatives[r][i]=map end
  end
  return {behaviour=behaviour,alternatives=alternatives,rounds=rounds,collisions=collisions.count}
end

function M.list(map) return sorted_cases(map) end
return M
