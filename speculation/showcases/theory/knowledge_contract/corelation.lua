local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local M={}

local function copy(xs) local o={}
 for i,x in ipairs(xs or {}) do o[i]=x end
 return o end
local function rows(n)
  local out={}
  for x=0,2^n-1 do
    local b={}
    for i=n,1,-1 do b[i]=(x%2==1) and '1' or '0'
 x=math.floor(x/2) end
    out[#out+1]=table.concat(b)
  end
  return out
end
local function idx(xs) local o={}
 for i,x in ipairs(xs) do o[x]=i end
 return o end
local function bit(row,i) return row:sub(i,i) end

-- A corelation is an equivalence partition over source + target names. Hidden
-- source-only classes are retained as part of the morphism, even though they do
-- not appear at the target boundary.
function M.new(source,target,equations)
  local parent={}
  local function root(x)
    if not parent[x] then parent[x]=x end
    if parent[x]~=x then parent[x]=root(parent[x]) end
    return parent[x]
  end
  local function union(a,b)
    a,b=root(a),root(b)
 if a~=b then parent[b]=a end
  end
  for _,x in ipairs(source) do root(x) end
  for _,x in ipairs(target) do root(x) end
  for _,p in ipairs(equations or {}) do union(p[1],p[2]) end
  local classes={}
  for x in pairs(parent) do classes[x]=root(x) end
  return {source=copy(source),target=copy(target),classes=classes}
end

function M.transport(k,c)
  local is,it=idx(c.source),idx(c.target)
  local out={}
  for _,rt in ipairs(rows(#c.target)) do
    local allowed=false
    for rs in pairs(k.rows) do
      local vals={}
 local consistent=true
      for _,x in ipairs(c.source) do
        local cl=c.classes[x]
 local v=bit(rs,is[x])
        if vals[cl] and vals[cl]~=v then consistent=false
 break end
        vals[cl]=v
      end
      if consistent then
        for _,y in ipairs(c.target) do
          local cl=c.classes[y]
 local v=bit(rt,it[y])
          if vals[cl] and vals[cl]~=v then consistent=false
 break end
          vals[cl]=v
        end
      end
      if consistent then allowed=true
 break end
    end
    if allowed then out[rt]=true end
  end
  return {ctx=copy(c.target),rows=out}
end

function M.compose(a,b)
  -- Rename shared interface occurrences so that union-find glues exactly the
  -- target of a to the source of b, then forget the shared interface while
  -- retaining induced equivalence on source + final target.
  assert(#a.target==#b.source,'corelation interface arity mismatch')
  for i=1,#a.target do assert(a.target[i]==b.source[i],'corelation interface mismatch') end

  local nodes={}
  local function tag(side,x) return side..':'..tostring(x) end
  local parent={}
  local function root(x)
    if not parent[x] then parent[x]=x end
    if parent[x]~=x then parent[x]=root(parent[x]) end
    return parent[x]
  end
  local function union(x,y) x,y=root(x),root(y)
 if x~=y then parent[y]=x end end

  local function import(c,prefix_source,prefix_target)
    local by={}
    for _,x in ipairs(c.source) do
      local node=tag(prefix_source,x)
 root(node)
 by[x]=by[x] or {}
 by[x][#by[x]+1]=node
    end
    for _,x in ipairs(c.target) do
      local node=tag(prefix_target,x)
 root(node)
 by[x]=by[x] or {}
 by[x][#by[x]+1]=node
    end
    local reps={}
    for x,cl in pairs(c.classes) do
      local list=by[x]
      if list then
        local rkey=prefix_source..'|'..prefix_target..'|'..tostring(cl)
        root(rkey)
        for _,node in ipairs(list) do union(node,rkey) end
      end
    end
  end
  import(a,'S','M')
  import(b,'M','T')
  -- Shared M names deliberately use the same tagged nodes and therefore glue.

  local pairs={}
  local visible={}
  for _,x in ipairs(a.source) do visible[#visible+1]={name=x,node=tag('S',x)} end
  for _,x in ipairs(b.target) do visible[#visible+1]={name=x,node=tag('T',x)} end
  for i=1,#visible do for j=i+1,#visible do
    if root(visible[i].node)==root(visible[j].node) then
      pairs[#pairs+1]={visible[i].name,visible[j].name}
    end
  end end

  -- Preserve source-only equivalences mediated entirely by forgotten M. The
  -- visible-pair reconstruction above already does this through root equality.
  return M.new(a.source,b.target,pairs)
end

return M
