-- Finite Kleene approximants of a recursive Package.
-- This is semantic expansion of cyclic Development contexts, not execution.
local Family=require('speculation.relay.computation.development_calculus.family')
local FinitePackage=require('speculation.relay.computation.development_calculus.package')
local Context=require('speculation.relay.computation.recurrence_calculus.context')
local RecPackage=require('speculation.relay.computation.recurrence_calculus.package')
local M={}

local function filter_family(f,keep_value)
  local items,map={},{}
  for i,x in ipairs(f.items) do
    local y=keep_value(x,i)
    if y~=nil then map[i]=#items+1
 items[#items+1]=y end
  end
  local edges={}
  for _,e in ipairs(f.edges) do local a,b=map[e[1]],map[e[2]]
    if a and b then edges[#edges+1]={a,b} end end
  return Family.new(items,edges)
end

local function expand_context(package,context,depth,memo)
  if #context.holes==0 then
    local value=assert(Context.plug(context,{}))
    return Family.one(value)
  end
  local children={}
  for i,h in ipairs(context.holes) do
    local root=assert(h.target.root,'resolved recurrence hole lacks semantic root')
    children[i]=assert(M._family(package,root,depth-1,memo))
    if #children[i].items==0 then return Family.empty() end
  end
  local raw=Family.product(children,function(tuple)
    local value,why=Context.plug(context,tuple)
    return {value=value,why=why}
  end)
  return filter_family(raw,function(row) return row.value end)
end

function M._family(package,root,depth,memo)
  assert(RecPackage.is(package),'recurrence Package required')
  assert(type(depth)=='number' and depth%1==0 and depth>=0,'finite recurrence depth required')
  memo=memo or {}
  local key=root..'@'..depth
  if memo[key] then return memo[key] end
  if depth==0 then local z=Family.empty()
 memo[key]=z
 return z end
  local definition=assert(package:definition(root),'unresolved recurrence semantic root '..tostring(root))
  local parents=Family.new(definition.family.items,definition.family.edges)
  local result=Family.bind(parents,function(context)
    return expand_context(package,context,depth,memo)
  end)
  memo[key]=result
  return result
end

function M.family(package,root,depth)
  return M._family(package,root,depth,{})
end

function M.package(package,root,depth)
  return FinitePackage.new(Family.spec(M.family(package,root,depth)))
end

function M.series(package,root,max_depth)
  local out,memo={},{}
  for d=0,max_depth do out[d]=FinitePackage.new(Family.spec(M._family(package,root,d,memo))) end
  return out
end

return M
