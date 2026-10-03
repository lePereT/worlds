local M={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function index(ctx)
  local out={}
  for i,v in ipairs(ctx) do out[v]=i end
  return out
end

local function bit(row,i)
  return row:sub(i,i)=='1' and 1 or 0
end

local function all_rows(n)
  local out={}
  for x=0,2^n-1 do
    local bits={}
    for i=n,1,-1 do bits[i]=(x%2==1) and '1' or '0'
 x=math.floor(x/2) end
    out[#out+1]=table.concat(bits)
  end
  return out
end

local function set(xs)
  local out={}
  for _,x in ipairs(xs or {}) do out[x]=true end
  return out
end

local function sorted_keys(s)
  local out={}
  for k in pairs(s or {}) do out[#out+1]=k end
  table.sort(out)
  return out
end

function M.relation(ctx, predicate)
  local rows={}
  for _,row in ipairs(all_rows(#ctx)) do
    local env={}
    for i,v in ipairs(ctx) do env[v]=bit(row,i) end
    if predicate(env) then rows[#rows+1]=row end
  end
  return {ctx=copy(ctx), rows=set(rows)}
end

function M.from_rows(ctx, rows)
  return {ctx=copy(ctx), rows=set(rows)}
end

function M.top(ctx) return M.from_rows(ctx,all_rows(#ctx)) end
function M.bottom(ctx) return M.from_rows(ctx,{}) end

local function same_ctx(a,b)
  if #a~=#b then return false end
  for i=1,#a do if a[i]~=b[i] then return false end end
  return true
end

function M.equal(a,b)
  if not same_ctx(a.ctx,b.ctx) then return false end
  for r in pairs(a.rows) do if not b.rows[r] then return false end end
  for r in pairs(b.rows) do if not a.rows[r] then return false end end
  return true
end

-- Information order: a <= b means a entails b (a is at least as strong).
function M.leq(a,b)
  assert(same_ctx(a.ctx,b.ctx),'leq context mismatch')
  for r in pairs(a.rows) do if not b.rows[r] then return false end end
  return true
end

function M.meet(a,b)
  assert(same_ctx(a.ctx,b.ctx),'meet context mismatch')
  local rows={}
  for r in pairs(a.rows) do if b.rows[r] then rows[r]=true end end
  return {ctx=copy(a.ctx),rows=rows}
end

-- Reindex/substitute a relation on Y into context X. sigma maps each Y variable
-- to an X variable. X variables not named by sigma remain unconstrained.
function M.reindex(relY, ctxX, sigma)
  local ix=index(ctxX)
  local iy=index(relY.ctx)
  for _,y in ipairs(relY.ctx) do assert(ix[sigma[y]],'missing substitution for target variable') end
  local rows={}
  for _,rx in ipairs(all_rows(#ctxX)) do
    local ybits={}
    for _,y in ipairs(relY.ctx) do ybits[iy[y]]=tostring(bit(rx,ix[sigma[y]])) end
    local ry=table.concat(ybits)
    if relY.rows[ry] then rows[rx]=true end
  end
  return {ctx=copy(ctxX),rows=rows}
end

-- Existentially hide variables not in keep, preserving the order of keep.
function M.exists(relX, keep)
  local ix=index(relX.ctx)
  local rows={}
  for rx in pairs(relX.rows) do
    local bits={}
    for i,v in ipairs(keep) do bits[i]=tostring(bit(rx,assert(ix[v]))) end
    rows[table.concat(bits)]=true
  end
  return {ctx=copy(keep),rows=rows}
end

-- Push knowledge through a Worlds-like partial exact image map source -> target.
-- Nil images are existentially hidden; surviving source coordinates are then
-- substituted by their exact target images, including many-to-one identification.
function M.transport(relSource, target_ctx, image)
  local visible={}
  local sigma={}
  for _,x in ipairs(relSource.ctx) do
    local y=image[x]
    if y~=nil then visible[#visible+1]=x
 sigma[x]=y end
  end
  local hidden=M.exists(relSource,visible)
  return M.reindex(hidden,target_ctx,sigma)
end

function M.compose_image(first,second)
  local out={}
  for x,y in pairs(first) do out[x]=y and second[y] or nil end
  return out
end

function M.rows(rel) return sorted_keys(rel.rows) end

return M
