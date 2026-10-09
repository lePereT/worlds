-- Canonical finite presentation of recursive transactional Development meaning.
-- Definitions are finite families of open Development contexts. Cycles are Package
-- graph linkage between context holes and semantic roots, never evaluator code.
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local Sha=require('speculation.relay.computation.development_calculus.sha256')
local Family=require('speculation.relay.computation.development_calculus.family')
local Context=require('speculation.relay.computation.recursive_judgement.context')
local M={}
local STATE=setmetatable({}, {__mode='k'})
local MT={__metatable='Restrictive Transactional Recurrence Package'}
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

local function same_interface(a,b) return Canonical.encode(a)==Canonical.encode(b) end

local function source_definition(d)
  assert(type(d)=='table','recursive definition required')
  assert(type(d.identity)=='string' and d.identity~='','recursive definition identity required')
  local alternatives=d.alternatives or (d.family and d.family.items)
  local prefers=d.prefers or (d.family and d.family.edges) or {}
  assert(type(alternatives)=='table' and #alternatives>0,'recursive definition needs alternatives')
  local items,iface={},nil
  for i,x in ipairs(alternatives) do
    items[i]=Context.normal(x)
    local ii=Context.signature(items[i])
    if iface then assert(same_interface(iface,ii),'recursive alternatives disagree on outer interface')
    else iface=ii end
  end
  local f=Family.new(items,prefers)
  return {identity=d.identity,family={items=f.items,edges=f.edges},interface=iface}
end

local function target_transform(target,local_slot,roots,known)
  if target.root then return {root=target.root} end
  local name=target.definition
  if local_slot and local_slot[name] then return {slot=local_slot[name]} end
  if roots and roots[name] then return {root=roots[name]} end
  if known then assert(known[name],'recursive local definition is undefined: '..tostring(name)) end
  return {definition=name}
end

local function normal_family(f,transform)
  local raw={}
  for i,x in ipairs(f.items or {}) do
    local n=Context.rewrite_targets(x,transform)
    raw[i]={old=i,value=n,bytes=Canonical.encode(n)}
  end
  table.sort(raw,function(a,b) return a.bytes<b.bytes or (a.bytes==b.bytes and a.old<b.old) end)
  local items,old_to_new,by_bytes={}, {}, {}
  for _,row in ipairs(raw) do
    local ni=by_bytes[row.bytes]
    if not ni then ni=#items+1
 items[ni]=row.value
 by_bytes[row.bytes]=ni end
    old_to_new[row.old]=ni
  end
  local edges={}
  for _,e in ipairs(f.edges or {}) do
    local a,b=assert(old_to_new[e[1]]),assert(old_to_new[e[2]])
    if a~=b then edges[#edges+1]={a,b} end
  end
  local nf=Family.new(items,edges)
  return {items=nf.items,edges=nf.edges}
end

local function dependencies(definition)
  local out={}
  for _,a in ipairs(definition.family.items) do
    for _,h in ipairs(a.holes) do if h.target.definition then out[h.target.definition]=true end end
  end
  return out
end

local function components(identities,edges)
  local index,low,stack,on,nexti,groups,which={},{},{},{},0,{},{ }
  local function visit(v)
    nexti=nexti+1
 index[v]=nexti
 low[v]=nexti
 stack[#stack+1]=v
 on[v]=true
    local ns={}
 for x in pairs(edges[v] or {}) do ns[#ns+1]=x end
 table.sort(ns)
    for _,x in ipairs(ns) do
      if not index[x] then visit(x)
 low[v]=math.min(low[v],low[x])
      elseif on[x] then low[v]=math.min(low[v],index[x]) end
    end
    if low[v]==index[v] then
      local g={}
      while true do local x=table.remove(stack)
 on[x]=nil
 g[#g+1]=x
 if x==v then break end end
      table.sort(g)
 groups[#groups+1]=g
      for _,x in ipairs(g) do which[x]=#groups end
    end
  end
  local ordered={}
 for i,x in ipairs(identities) do ordered[i]=x end
 table.sort(ordered)
  for _,x in ipairs(ordered) do if not index[x] then visit(x) end end
  return groups,which
end

local function permutations(xs)
  local out={}
  local function build(prefix,used)
    if #prefix==#xs then local row={}
 for i,x in ipairs(prefix) do row[i]=x end
 out[#out+1]=row
 return end
    for i,x in ipairs(xs) do if not used[i] then used[i]=true
 prefix[#prefix+1]=x
      build(prefix,used)
 prefix[#prefix]=nil
 used[i]=nil end end
  end
  build({},{})
 return out
end

local function derive(definitions)
  local by_identity,identities,edges={},{},{}
  for _,d in ipairs(definitions) do
    assert(not by_identity[d.identity],'duplicate recursive definition identity')
    by_identity[d.identity]=d
 identities[#identities+1]=d.identity
  end
  for _,d in ipairs(definitions) do
    local dep=dependencies(d)
 edges[d.identity]=dep
    for x in pairs(dep) do assert(by_identity[x],'recursive local definition is undefined: '..x) end
  end
  local groups,which=components(identities,edges)
  local roots,group_done={},{}

  local function resolve_group(gi)
    if group_done[gi] then return end
    local members=groups[gi]
 local member_set={}
    for _,x in ipairs(members) do member_set[x]=true end
    for _,x in ipairs(members) do for dep in pairs(edges[x] or {}) do
      local dg=which[dep]
 if dg~=gi then resolve_group(dg) end
    end end

    assert(#members<=7,'research recurrence SCC exceeds brute-force canonicalisation limit')
    local best,minimisers=nil,{}
    for _,perm in ipairs(permutations(members)) do
      local slot={}
 for i,x in ipairs(perm) do slot[x]=i end
      local rows={}
      for i,x in ipairs(perm) do
        rows[i]={family=normal_family(by_identity[x].family,function(t)
          return target_transform(t,slot,roots,by_identity)
        end)}
      end
      local bytes=Canonical.encode({members=rows})
      if best==nil or bytes<best then best=bytes
 minimisers={{perm=perm,slot=slot}}
      elseif bytes==best then minimisers[#minimisers+1]={perm=perm,slot=slot} end
    end
    local fingerprint=Sha.sha256('relay-restrictive-recurrence-scc-v1:'..assert(best))
    for _,x in ipairs(members) do
      local positions,seen={},{}
      for _,m in ipairs(minimisers) do local p=m.slot[x]
 if not seen[p] then seen[p]=true
 positions[#positions+1]=p end end
      table.sort(positions)
      local entry=Canonical.encode({scc=fingerprint,orbit=positions})
      roots[x]='semantic:sha256:'..Sha.sha256('relay-restrictive-recurrence-entry-v1:'..entry)
    end
    group_done[gi]=true
  end
  for i=1,#groups do resolve_group(i) end

  local resolved_by_root={}
  for _,d in ipairs(definitions) do
    local root=assert(roots[d.identity])
    local family=normal_family(d.family,function(t) return target_transform(t,nil,roots,by_identity) end)
    local row={root=root,family=family}
    local bytes=Canonical.encode(row)
    if resolved_by_root[root] then
      assert(Canonical.encode(resolved_by_root[root])==bytes,
        'semantically symmetric recursive entries disagree after root resolution')
    else resolved_by_root[root]=row end
  end
  return roots,resolved_by_root
end

local function canonical_definitions(by_root)
  local roots={}
 for r in pairs(by_root) do roots[#roots+1]=r end
 table.sort(roots)
  local out={}
  for i,r in ipairs(roots) do out[i]=deep(by_root[r]) end
  return out
end

local function make(by_root,aliases)
  local definitions=canonical_definitions(by_root)
  local spec={kind='restrictive-transactional-recurrence-package-v1',definitions=definitions}
  local bytes=Canonical.encode(spec)
  local p=setmetatable({},MT)
  STATE[p]={definitions=definitions,by_root=by_root,aliases=aliases or {},bytes=bytes,
    root='semantic:sha256:'..Sha.sha256('relay-restrictive-transactional-recurrence-package-v1:'..bytes)}
  return p
end

function M.new(spec)
  assert(type(spec)=='table','recurrence Package spec required')
  local defs={}
  for i,d in ipairs(spec.definitions or {}) do defs[i]=source_definition(d) end
  assert(#defs>0,'recurrence Package requires definitions')
  local roots,by_root=derive(defs)
  return make(by_root,roots)
end

function M.is(x) return STATE[x]~=nil end
function MT:bytes() return assert(STATE[self]).bytes end
function MT:package_root() return assert(STATE[self]).root end
function MT:root(identity) return assert(STATE[self]).aliases[identity] end
function MT:definitions() return deep(assert(STATE[self]).definitions) end
function MT:definition(root) local x=assert(STATE[self]).by_root[root]
 return x and deep(x) or nil end

local function validate_resolved(definitions)
  local by_root={}
 local last=nil
  for _,d in ipairs(definitions or {}) do
    assert(type(d.root)=='string' and d.root:match('^semantic:sha256:'),'resolved recurrence root required')
    assert(not last or last<d.root,'resolved recurrence definitions must be root-sorted and unique')
    last=d.root
    local family=normal_family(assert(d.family),function(t)
      assert(t.root and not t.definition,'decoded recurrence target must be semantic root')
      return {root=t.root}
    end)
    local row={root=d.root,family=family}
    assert(Canonical.encode(row)==Canonical.encode(d),'decoded recurrence definition is not canonical')
    by_root[d.root]=row
  end
  return by_root
end

function M.decode(bytes)
  local spec=Canonical.decode(bytes)
  assert(type(spec)=='table' and spec.kind=='restrictive-transactional-recurrence-package-v1',
    'wrong recurrence Package kind')
  local p=make(validate_resolved(assert(spec.definitions)),{})
  assert(p:bytes()==bytes,'recurrence Package bytes are not canonical')
  return p
end

function M.link(packages)
  local by_root={}
  for _,p in ipairs(packages or {}) do
    assert(M.is(p),'recurrence Package required for link')
    for _,d in ipairs(p:definitions()) do
      local old=by_root[d.root]
      if old then assert(Canonical.encode(old)==Canonical.encode(d),'recurrence semantic-root collision')
      else by_root[d.root]=d end
    end
  end
  assert(next(by_root)~=nil,'link requires at least one recurrence Package')
  return make(by_root,{})
end

return M
