-- Finite ordered-family algebra. The family is semantic data, not search state.
local M={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function edge_key(a,b) return tostring(a)..':'..tostring(b) end

local function normal_edges(n,edges)
  local seen,out={},{}
  for _,e in ipairs(edges or {}) do
    local a,b=e[1] or e.before,e[2] or e.after
    assert(type(a)=='number' and type(b)=='number' and a>=1 and a<=n and b>=1 and b<=n,
      'family dominance endpoint outside family')
    assert(a~=b,'family cannot dominate itself')
    local k=edge_key(a,b)
    if not seen[k] then seen[k]=true
 out[#out+1]={a,b} end
  end
  table.sort(out,function(x,y) return x[1]<y[1] or (x[1]==y[1] and x[2]<y[2]) end)
  return out
end

local function closure(n,edges)
  local r={}
  for i=1,n do r[i]={} end
  for _,e in ipairs(edges) do r[e[1]][e[2]]=true end
  for k=1,n do for i=1,n do if r[i][k] then
    for j=1,n do if r[k][j] then r[i][j]=true end end
  end end end
  for i=1,n do assert(not r[i][i],'family dominance must be acyclic') end
  return r
end

function M.new(items,edges)
  local xs=copy(items)
  local es=normal_edges(#xs,edges)
  local reach=closure(#xs,es)
  local full={}
  for i=1,#xs do for j=1,#xs do if reach[i][j] then full[#full+1]={i,j} end end end
  return {items=xs,edges=full}
end

function M.empty() return M.new({}, {}) end
function M.one(x) return M.new({x}, {}) end

function M.frontier(f)
  local dominated={}
  for _,e in ipairs(f.edges) do dominated[e[2]]=true end
  local out={}
  for i=1,#f.items do if not dominated[i] then out[#out+1]=i end end
  return out
end

function M.or_(a,b)
  local items,edges={},{}
  for _,x in ipairs(a.items) do items[#items+1]=x end
  for _,x in ipairs(b.items) do items[#items+1]=x end
  for _,e in ipairs(a.edges) do edges[#edges+1]={e[1],e[2]} end
  local off=#a.items
  for _,e in ipairs(b.edges) do edges[#edges+1]={e[1]+off,e[2]+off} end
  return M.new(items,edges)
end

function M.or_else(a,b)
  local out=M.or_(a,b)
  local edges=copy(out.edges)
  local off=#a.items
  for i=1,#a.items do for j=1,#b.items do edges[#edges+1]={i,off+j} end end
  return M.new(out.items,edges)
end

-- Complete-descendant substitution. fn returns a family or nil/empty for failure.
function M.bind(a,fn)
  local items,owner,local_edges={}, {}, {}
  local ranges={}
  for i,x in ipairs(a.items) do
    local child=fn(x,i) or M.empty()
    local first=#items+1
    for _,y in ipairs(child.items) do items[#items+1]=y
 owner[#items]=i end
    local last=#items
    ranges[i]={first,last}
    for _,e in ipairs(child.edges) do local_edges[#local_edges+1]={first+e[1]-1,first+e[2]-1} end
  end
  local edges=copy(local_edges)
  local reach=closure(#a.items,a.edges)
  for i=1,#a.items do for j=1,#a.items do if reach[i][j] then
    local ri,rj=ranges[i],ranges[j]
    for x=ri[1],ri[2] do for y=rj[1],rj[2] do edges[#edges+1]={x,y} end end
  end end end
  return M.new(items,edges)
end

local function tuple_key(t)
  local out={}
  for i,x in ipairs(t) do out[i]=tostring(x) end
  return table.concat(out,',')
end

-- True n-ary Cartesian product order.
function M.product(families,combine)
  if #families==0 then return M.one(combine({})) end
  local tuples={}
  local function build(i,t)
    if i>#families then
      local c={}
      for j,x in ipairs(t) do c[j]=x end
      tuples[#tuples+1]=c
      return
    end
    for j=1,#families[i].items do t[i]=j
 build(i+1,t) end
  end
  build(1,{})
  local reach={}
  for i,f in ipairs(families) do reach[i]=closure(#f.items,f.edges) end
  local edges={}
  for i,a in ipairs(tuples) do for j,b in ipairs(tuples) do if i~=j then
    local le,strict=true,false
    for k=1,#families do
      if a[k]~=b[k] then
        if reach[k][a[k]][b[k]] then strict=true else le=false
 break end
      end
    end
    if le and strict then edges[#edges+1]={i,j} end
  end end end
  local items={}
  for i,t in ipairs(tuples) do
    local vals={}
    for k,index in ipairs(t) do vals[k]=families[k].items[index] end
    items[i]=combine(vals,t)
  end
  return M.new(items,edges)
end

function M.map(f,fn)
  local items={}
  for i,x in ipairs(f.items) do items[i]=fn(x,i) end
  return M.new(items,f.edges)
end

function M.spec(f)
  local edges={}
  for i,e in ipairs(f.edges) do edges[i]={e[1],e[2]} end
  return {items=copy(f.items),edges=edges}
end

return M
