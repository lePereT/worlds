-- Research-only exact Construction correspondence.
--
-- This is evidence around Construction, not Geometry. It records the quotient
-- classes induced across source occurrences and the result, including source-
-- only classes whose result image has disappeared.

local W=require('worlds')
local Construction=require('worlds.construction')
local M={}
local STATE=setmetatable({}, {__mode='k'})
local MT={__metatable='Worlds research Construction correspondence'}
MT.__index=MT

local KINDS={'membranes','points','strands','faces'}
local function carriers(g)
  local out={}
  for _,k in ipairs(KINDS) do for _,x in ipairs(g[k](g)) do out[#out+1]=x end end
  return out
end
local function kind(x) return W.kind(x) end
local function key(side,x) return {side=side,carrier=x} end
local function dsu()
  local parent,rank={},{}
  local D={}
  function D:add(x) if parent[x]==nil then parent[x]=x
  rank[x]=0 end end
  function D:find(x)
    self:add(x)
    if parent[x]~=x then parent[x]=self:find(parent[x]) end
    return parent[x]
  end
  function D:union(a,b)
    a,b=self:find(a),self:find(b)
    if a==b then return a end
    if rank[a]<rank[b] then a,b=b,a end
    parent[b]=a
    if rank[a]==rank[b] then rank[a]=rank[a]+1 end
    return a
  end
  return D
end

local function make(source_parts,target,classes)
  local x=setmetatable({},MT)
  STATE[x]={source_parts=source_parts,target=target,classes=classes}
  return x
end
local function st(self) return assert(STATE[self],'Construction correspondence required') end

local function source_carriers(parts)
  local out={}
  for _,g in ipairs(parts) do for _,x in ipairs(carriers(g)) do out[#out+1]=x end end
  return out
end

local function partition(source_parts,target,relations)
  local D=dsu()
  local sn,tn={},{ }
  for _,x in ipairs(source_carriers(source_parts)) do sn[x]=key('s',x)
  D:add(sn[x]) end
  for _,y in ipairs(carriers(target)) do tn[y]=key('t',y)
  D:add(tn[y]) end
  for _,r in ipairs(relations or {}) do
    local a=(r[1]=='s' and sn[r[2]]) or (r[1]=='t' and tn[r[2]])
    local b=(r[3]=='s' and sn[r[4]]) or (r[3]=='t' and tn[r[4]])
    assert(a and b,'correspondence relation references absent carrier')
    assert(kind(r[2])==kind(r[4]),'correspondence cannot identify carrier kinds')
    D:union(a,b)
  end
  local cls={source={},target={}}
  for x,n in pairs(sn) do cls.source[x]=D:find(n) end
  for y,n in pairs(tn) do cls.target[y]=D:find(n) end
  return make(source_parts,target,cls)
end

local function add_membrane_equations(rel,from,to)
  local a,b=W.membrane(from),W.membrane(to)
  while a and b do
    rel[#rel+1]={'s',a,'s',b}
    a,b=W.parent(a),W.parent(b)
  end
end

function M.from_construction(c)
  assert(Construction.is_construction(c),'from_construction requires Construction')
  local parts,target=c:parts(),c:result()
  local rel={}
  local src=source_carriers(parts)

  -- Surviving images expose every quotient class which reaches the result,
  -- including Face SCC contractions and ordinary many-to-one images.
  for _,x in ipairs(src) do
    local y=c:image(x)
    if y then rel[#rel+1]={'s',x,'t',y} end
  end

  -- Raw boundary equations retain source-only strand quotient classes when a
  -- later causal SCC annihilates their result image. Their Point and Membrane
  -- identifications are exact consequences of the same Worlds cut.
  for _,e in ipairs(c:equations()) do
    local a,b=e.from,e.to
    rel[#rel+1]={'s',a,'s',b}
    local ap,bp=W.points(a),W.points(b)
    assert(#ap==#bp,'valid Construction changed boundary Point arity')
    for i=1,#ap do
      rel[#rel+1]={'s',ap[i],'s',bp[i]}
      add_membrane_equations(rel,ap[i],bp[i])
    end
    add_membrane_equations(rel,a,b)
  end
  return partition(parts,target,rel)
end

function M.identity(g)
  local rel={}
  for _,x in ipairs(carriers(g)) do rel[#rel+1]={'s',x,'t',x} end
  return partition({g},g,rel)
end

function MT:source_parts() return st(self).source_parts end
function MT:target() return st(self).target end
function MT:source_class(x) return st(self).classes.source[x] end
function MT:target_class(x) return st(self).classes.target[x] end
function MT:source_equivalent(a,b)
  local s=st(self)
  return s.classes.source[a]~=nil and s.classes.source[a]==s.classes.source[b]
end

local function class_members(c)
  local s=st(c)
  local out={}
  for x,r in pairs(s.classes.source) do
    out[r]=out[r] or {source={},target={}}
    out[r].source[#out[r].source+1]=x
  end
  for x,r in pairs(s.classes.target) do
    out[r]=out[r] or {source={},target={}}
    out[r].target[#out[r].target+1]=x
  end
  return out
end

-- Compose A : S -> M with B : (M + fresh parts) -> T. This is the cospan/
-- corelation composition needed by staged Worlds construction.
function M.compose(a,b)
  local A,B=st(a),st(b)
  local shared=nil
  local extras={}
  for _,g in ipairs(B.source_parts) do
    if g==A.target then assert(shared==nil,'intermediate Geometry appears twice')
    shared=g
    else extras[#extras+1]=g end
  end
  assert(shared,'second correspondence does not consume first target')
  local out_parts={}
  for _,g in ipairs(A.source_parts) do out_parts[#out_parts+1]=g end
  for _,g in ipairs(extras) do out_parts[#out_parts+1]=g end

  local D=dsu()
  local visS,mid,visT={},{},{}
  for _,g in ipairs(out_parts) do for _,x in ipairs(carriers(g)) do visS[x]=key('s',x)
  D:add(visS[x]) end end
  for _,x in ipairs(carriers(A.target)) do mid[x]=key('m',x)
  D:add(mid[x]) end
  for _,y in ipairs(carriers(B.target)) do visT[y]=key('t',y)
  D:add(visT[y]) end

  local function import(c,map_source,map_target)
    for _,cl in pairs(class_members(c)) do
      local first=nil
      for _,x in ipairs(cl.source) do
        local n=map_source(x)
        assert(n,'unmapped correspondence source')
        if first then D:union(first,n) else first=n end
      end
      for _,x in ipairs(cl.target) do
        local n=map_target(x)
        assert(n,'unmapped correspondence target')
        if first then D:union(first,n) else first=n end
      end
    end
  end
  import(a,function(x) return visS[x] end,function(x) return mid[x] end)
  local extra_set={}
  for _,g in ipairs(extras) do for _,x in ipairs(carriers(g)) do extra_set[x]=true end end
  import(b,function(x)
    return mid[x] or (extra_set[x] and visS[x])
  end,function(x) return visT[x] end)

  local cls={source={},target={}}
  for x,n in pairs(visS) do cls.source[x]=D:find(n) end
  for x,n in pairs(visT) do cls.target[x]=D:find(n) end
  return make(out_parts,B.target,cls)
end

local function source_order(c)
  local out={}
  for _,g in ipairs(st(c).source_parts) do for _,x in ipairs(carriers(g)) do out[#out+1]=x end end
  return out
end
local function signature(c,root)
  local s=st(c)
  local bits={}
  local src=source_order(c)
  for i,x in ipairs(src) do if s.classes.source[x]==root then bits[#bits+1]=tostring(i) end end
  return table.concat(bits,',')
end

-- Canonical source-relative endpoint correspondence used by the existing
-- between-Worlds groupoid experiments.
function M.between(a,b)
  local A,B=st(a),st(b)
  local as,bs=source_order(a),source_order(b)
  assert(#as==#bs,'between requires same marked source')
  for i=1,#as do assert(as[i]==bs[i],'between source marking differs') end
  local by={}
  for y,r in pairs(B.classes.target) do
    local k=kind(y)..'|'..signature(b,r)
    assert(by[k]==nil,'target quotient has duplicate source signature')
    by[k]=y
  end
  local map={}
  for x,r in pairs(A.classes.target) do
    local k=kind(x)..'|'..signature(a,r)
    map[x]=assert(by[k],'target lacks matching source-relative class')
  end
  return map
end

function M.same_source_partition(a,b)
  local as,bs=source_order(a),source_order(b)
  if #as~=#bs then return false end
  for i=1,#as do if as[i]~=bs[i] then return false end end
  for i=1,#as do for j=1,#as do
    if a:source_equivalent(as[i],as[j])~=b:source_equivalent(as[i],as[j]) then return false end
  end end
  return true
end

-- Boolean finite-model transport used only to falsify correspondence laws.
function M.transport(rel,c,target_ctx,R)
  local s=st(c)
  local src_index={}
  for _,x in ipairs(rel.ctx) do assert(s.classes.source[x],'relation carrier outside source')
  src_index[x]=true end
  for _,y in ipairs(target_ctx) do assert(s.classes.target[y],'target carrier outside result') end
  local out={}
  local function all_rows(n)
    local rows={}
    for v=0,2^n-1 do local b={}
    local x=v
      for i=n,1,-1 do b[i]=(x%2==1) and '1' or '0'
      x=math.floor(x/2) end
      rows[#rows+1]=table.concat(b)
    end
    return rows
  end
  local function bit(row,i) return row:sub(i,i) end
  local si,ti={},{ }
  for i,x in ipairs(rel.ctx) do si[x]=i end
  for i,x in ipairs(target_ctx) do ti[x]=i end
  for _,rt in ipairs(all_rows(#target_ctx)) do
    local allowed=false
    for rs in pairs(rel.rows) do
      local vals={}
      local consistent=true
      for _,x in ipairs(rel.ctx) do local cl=s.classes.source[x]
      local v=bit(rs,si[x])
        if vals[cl] and vals[cl]~=v then consistent=false
        break end
        vals[cl]=v end
      if consistent then for _,y in ipairs(target_ctx) do local cl=s.classes.target[y]
      local v=bit(rt,ti[y])
        if vals[cl] and vals[cl]~=v then consistent=false
        break end
        vals[cl]=v end end
      if consistent then allowed=true
      break end
    end
    if allowed then out[rt]=true end
  end
  return {ctx=target_ctx,rows=out}
end

return M
