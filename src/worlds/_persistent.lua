-- Small persistent read-only sequence/set mechanics for live boundary sections.
-- Pure representation support: no Geometry or query semantics live here.
--
-- Sequences are persistent AVL ropes over borrowed array slices.  The rope is
-- deliberately opaque: Lua 5.1/LuaJIT do not honour table __len/__ipairs in the
-- same way as later Lua versions.  Internal users therefore go through the
-- helpers below and public Geometry accessors materialise a cached ordinary
-- array.  Local removals/appends still copy only the tree path.
local M={}
local FLAT_MAX=64
local SEQ=setmetatable({}, {__mode='k'})
local SET=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end

local function height(x) return x and x.h or 0 end
local function size(x) return x and x.n or 0 end
local function leaf(base,a,b)
  if not base or a>b then return nil end
  return {leaf=true,base=base,a=a,b=b,n=b-a+1,h=1}
end
local function branch(a,b)
  if not a then return b end
  if not b then return a end
  return {left=a,right=b,n=a.n+b.n,h=math.max(a.h,b.h)+1}
end
local function rotate_left(x)
  local y=x.right
  return branch(branch(x.left,y.left),y.right)
end
local function rotate_right(x)
  local y=x.left
  return branch(y.left,branch(y.right,x.right))
end
local function balance(x)
  if not x or x.leaf then return x end
  local d=height(x.left)-height(x.right)
  if d>1 then
    if height(x.left.left)<height(x.left.right) then x=branch(rotate_left(x.left),x.right) end
    return rotate_right(x)
  elseif d < -1 then
    if height(x.right.right)<height(x.right.left) then x=branch(x.left,rotate_right(x.right)) end
    return rotate_left(x)
  end
  return x
end
local function concat(a,b)
  if not a then return b end
  if not b then return a end
  if height(a)>height(b)+1 then return balance(branch(a.left,concat(a.right,b))) end
  if height(b)>height(a)+1 then return balance(branch(concat(a,b.left),b.right)) end
  return branch(a,b)
end
local function split(x,k)
  if not x then return nil,nil end
  if k<=0 then return nil,x end
  if k>=x.n then return x,nil end
  if x.leaf then
    return leaf(x.base,x.a,x.a+k-1),leaf(x.base,x.a+k,x.b)
  end
  local ln=size(x.left)
  if k<ln then
    local a,b=split(x.left,k)
    return a,concat(b,x.right)
  elseif k==ln then return x.left,x.right
  else
    local a,b=split(x.right,k-ln)
    return concat(x.left,a),b
  end
end
local function node_get(x,i)
  while x and not x.leaf do
    local n=size(x.left)
    if i<=n then x=x.left else i=i-n; x=x.right end
  end
  return x and x.base[x.a+i-1] or nil
end
local function seq_state(xs) return type(xs)=='table' and SEQ[xs] or nil end
function M.length(xs)
  local st=seq_state(xs)
  return st and st.n or #xs
end
function M.get(xs,i)
  local st=seq_state(xs)
  return st and node_get(st.root,i) or xs[i]
end
function M.iter(xs)
  local st=seq_state(xs)
  if not st then return ipairs(xs) end
  local i=0
  return function()
    i=i+1
    if i<=st.n then return i,node_get(st.root,i) end
  end
end
function M.array(xs)
  local st=seq_state(xs)
  if not st then return xs end
  if st.array then return st.array end
  local out={}
  for i=1,st.n do out[i]=node_get(st.root,i) end
  st.array=out
  return out
end
local function root_of(xs)
  local st=seq_state(xs)
  if st then return st.root end
  return leaf(xs,1,#xs)
end
local SeqMT={__metatable='Worlds persistent sequence',__newindex=immutable}
local function sequence(root)
  local x=setmetatable({},SeqMT)
  SEQ[x]={root=root,n=size(root)}
  return x
end
function M.sequence_delta(base,removed,added)
  removed,added=removed or {},added or {}
  if #removed==0 and #added==0 then return base end
  if #removed>1 then table.sort(removed) end
  local base_n=M.length(base)
  local result_n=base_n-#removed+#added
  if result_n<=FLAT_MAX then
    local out,ri={},1
    for i=1,base_n do
      if removed[ri]==i then ri=ri+1 else out[#out+1]=M.get(base,i) end
    end
    for _,x in ipairs(added) do out[#out+1]=x end
    return out
  end
  local current=root_of(base)
  local out=nil
  local previous=0
  for _,p in ipairs(removed) do
    assert(p>previous and p<=base_n,'persistent sequence removal ordinal out of range')
    local keep,rest=split(current,p-previous-1)
    out=concat(out,keep)
    local _,tail=split(rest,1)
    current=tail
    previous=p
  end
  out=concat(out,current)
  if #added>0 then out=concat(out,leaf(added,1,#added)) end
  return sequence(out)
end
function M.sequence_concat(base,added) return M.sequence_delta(base,{},added) end
function M.sequence_state(x) return SEQ[x] end

local SetMT={__metatable='Worlds persistent membership',__newindex=immutable}
SetMT.__index=function(self,k)
  local st=SET[self]
  if st.added[k] then return true end
  if st.removed[k] then return nil end
  return st.base[k]
end
function M.set_delta(base,removed,added,sequence_)
  removed,added=removed or {},added or {}
  if next(removed)==nil and #added==0 then return base end
  if M.length(sequence_)<=FLAT_MAX then
    local raw={}
    for _,x in M.iter(sequence_) do raw[x]=true end
    return raw
  end
  local bst=SET[base]
  local depth=(bst and bst.depth or 0)+1
  if depth>128 then
    local raw={}
    for _,x in M.iter(sequence_) do raw[x]=true end
    return raw
  end
  local a={}
  for _,x in ipairs(added) do a[x]=true end
  local x=setmetatable({},SetMT)
  SET[x]={base=base,removed=removed,added=a,depth=depth}
  return x
end
function M.set_state(x) return SET[x] end
return M
