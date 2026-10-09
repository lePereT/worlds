-- Canonical portable semantic meaning: an ordered family of relative Developments.
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local Sha=require('speculation.relay.computation.development_calculus.sha256')
local Template=require('speculation.relay.computation.development_calculus.template')
local Family=require('speculation.relay.computation.development_calculus.family')
local M={}
local STATE=setmetatable({}, {__mode='k'})
local MT={__metatable='Transactional Development Package'}
MT.__index=MT

local function deep(x,seen)
  if type(x)~='table' or getmetatable(x)~=nil then return x end
  seen=seen or {}
 if seen[x] then return seen[x] end
  local out={}
 seen[x]=out
  for k,v in pairs(x) do out[deep(k,seen)]=deep(v,seen) end
  return out
end

local function normal_family(spec)
  local f=spec.items and spec or assert(spec.family,'Package definition family required')
  local raw={}
  local arity=nil
  for i,x in ipairs(f.items or {}) do
    local n=Template.normal(x)
    local a={#n.authority.inputs,#n.authority.outputs,#n.values.inputs,#n.values.outputs}
    if not arity then arity=a else
      for j=1,4 do assert(a[j]==arity[j],'Package alternatives disagree on public interface arity') end
    end
    raw[i]={value=n,bytes=Canonical.encode(n)}
  end
  table.sort(raw,function(a,b) return a.bytes<b.bytes end)
  local items,old_to_new={},{}
  local last=nil
  for new,row in ipairs(raw) do
    if row.bytes~=last then items[#items+1]=row.value
 last=row.bytes end
  end
  local byte_to_new={}
  for i,x in ipairs(items) do byte_to_new[Canonical.encode(x)]=i end
  for old,x in ipairs(f.items or {}) do old_to_new[old]=byte_to_new[Canonical.encode(Template.normal(x))] end
  local edges,seen={},{}
  for _,e in ipairs(f.edges or {}) do
    local a,b=old_to_new[e[1]],old_to_new[e[2]]
    if a~=b then local k=a..':'..b
      if not seen[k] then seen[k]=true
 edges[#edges+1]={a,b} end
    end
  end
  return Family.spec(Family.new(items,edges))
end

local function value(family)
  local normal=normal_family(family)
  local spec={kind='transactional-development-family-v1',family=normal}
  local bytes=Canonical.encode(spec)
  local p=setmetatable({},MT)
  STATE[p]={family=normal,bytes=bytes,root='semantic:sha256:'..Sha.sha256(
    'relay-transactional-development-v1:'..bytes)}
  return p
end

function M.new(family) return value(family) end
function M.is(x) return STATE[x]~=nil end
function MT:root() return assert(STATE[self]).root end
function MT:bytes() return assert(STATE[self]).bytes end
function MT:family() return deep(assert(STATE[self]).family) end
function MT:definition() return self:family() end
function MT:alternative(i) local x=assert(assert(STATE[self]).family.items[i],'alternative missing')
 return deep(x) end
function MT:instantiate(i) return Template.instantiate(self:alternative(i)) end

function M.decode(bytes)
  local spec=Canonical.decode(bytes)
  assert(type(spec)=='table' and spec.kind=='transactional-development-family-v1',
    'wrong transactional Development package kind')
  local p=value(assert(spec.family,'Package family missing'))
  assert(p:bytes()==bytes,'Package bytes are not canonical')
  return p
end

return M
