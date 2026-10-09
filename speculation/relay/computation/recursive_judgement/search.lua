-- Ephemeral finite discovery with derivation evidence.  This is deliberately not
-- Package meaning.  Judgement consumes a discovered candidate plus this proof tree
-- and proves stable eligibility independently of discovery depth/order.
local Family=require('speculation.relay.computation.development_calculus.family')
local Context=require('speculation.relay.computation.recursive_judgement.context')
local Package=require('speculation.relay.computation.recursive_judgement.package')
local M={}

local function filter_family(f)
  local items,map={},{}
  for i,x in ipairs(f.items) do if x.value then map[i]=#items+1
 items[#items+1]=x end end
  local edges={}
 for _,e in ipairs(f.edges) do local a,b=map[e[1]],map[e[2]]
 if a and b then edges[#edges+1]={a,b} end end
  return Family.new(items,edges)
end

local function expand_context(package,root,alt_index,context,depth,memo)
  if #context.holes==0 then
    local value=Context.plug(context,{})
    if not value then return Family.empty() end
    return Family.one({value=value,proof={root=root,alternative=alt_index,context=context,children={},value=value}})
  end
  local children={}
  for i,h in ipairs(context.holes) do
    local childroot=assert(h.target.root)
    children[i]=M._family(package,childroot,depth-1,memo)
    if #children[i].items==0 then return Family.empty() end
  end
  local raw=Family.product(children,function(tuple)
    local vals,proofs={},{}
    for i,row in ipairs(tuple) do vals[i]=row.value
 proofs[i]=row.proof end
    local value=Context.plug(context,vals)
    return {value=value,proof=value and {root=root,alternative=alt_index,context=context,children=proofs,value=value} or nil}
  end)
  return filter_family(raw)
end

function M._family(package,root,depth,memo)
  assert(Package.is(package),'restrictive recurrence Package required')
  assert(type(depth)=='number' and depth%1==0 and depth>=0,'finite discovery depth required')
  memo=memo or {}
 local key=root..'@'..depth
 if memo[key] then return memo[key] end
  if depth==0 then local z=Family.empty()
 memo[key]=z
 return z end
  local d=assert(package:definition(root))
 local parents=Family.new(d.family.items,d.family.edges)
  local out=Family.bind(parents,function(c,i) return expand_context(package,root,i,c,depth,memo) end)
  memo[key]=out
 return out
end
function M.family(package,root,depth) return M._family(package,root,depth,{}) end
return M
