-- Finite relational oracle used by the recursive-Judgement and viability labs.
--
-- IMPORTANT: this is not a second Theory host.  Semantic Knowledge operations
-- delegate to the thin host in speculation/relay/theory/knowledge.lua, whose
-- domain contract is exactly: equal, meet, reindex, exists.
--
-- This file adds only lab conveniences needed by the portable recursive model:
-- finite coordinate domains, canonical specs/keys, finite row inspection, and
-- a symbolic correspondence adapter for pre-instantiation Geometry fixtures.

local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local Thin=require('speculation.relay.theory.knowledge')
local M={}

local TOKEN_META=setmetatable({}, {__mode='k'})
local TOKEN_BY_EXACT=setmetatable({}, {__mode='k'})
local TOKEN_BY_SCALAR={}

local function copy(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

local function scalar_key(x)
  local t=type(x)
  assert(t=='boolean' or t=='number' or t=='string','knowledge literal must be bool/number/string')
  return Canonical.encode(x)
end

local function normal_values(xs)
  assert(type(xs)=='table' and #xs>0,'finite knowledge coordinate needs values')
  local rows,seen={},{}
  for _,x in ipairs(xs) do
    local key=scalar_key(x)
    if not seen[key] then seen[key]=true; rows[#rows+1]={key=key,value=x} end
  end
  table.sort(rows,function(a,b) return a.key<b.key end)
  local out={}; for i,row in ipairs(rows) do out[i]=row.value end
  return out
end

local function point_key(point)
  local t=type(point)
  if t=='table' or t=='userdata' then return nil end
  return t..':'..tostring(point)
end

local function same_values(a,b)
  if #a~=#b then return false end
  for i=1,#a do if scalar_key(a[i])~=scalar_key(b[i]) then return false end end
  return true
end

local function token_for(c)
  local point=c.point
  local key=point_key(point)
  local token=key and TOKEN_BY_SCALAR[key] or TOKEN_BY_EXACT[point]
  if token then
    local old=TOKEN_META[token]
    assert(old.sort==c.sort and same_values(old.values,c.values),
      'one knowledge Point has inconsistent finite domain')
    return token
  end
  token={}
  TOKEN_META[token]={point=point,sort=c.sort,values=copy(c.values)}
  if key then TOKEN_BY_SCALAR[key]=token else TOKEN_BY_EXACT[point]=token end
  return token
end

function M.context(spec)
  local out,seen={},{}
  for _,c in ipairs(spec or {}) do
    assert(type(c)=='table' and c.point~=nil,'knowledge coordinate point required')
    local row={point=c.point,sort=c.sort or 'value',values=normal_values(assert(c.values))}
    local token=token_for(row)
    assert(not seen[token],'duplicate knowledge Point coordinate')
    seen[token]=true
    out[#out+1]=row
  end
  return out
end

local function tokens(ctx)
  ctx=M.context(ctx)
  local out={}
  for i,c in ipairs(ctx) do out[i]=token_for(c) end
  return out
end

local function descriptor(token)
  local c=assert(TOKEN_META[token],'unknown knowledge coordinate token')
  return {point=c.point,sort=c.sort,values=copy(c.values)}
end

local function descriptors(ts)
  local out={}; for i,t in ipairs(ts) do out[i]=descriptor(t) end; return out
end

local function ctx_index(ctx)
  local out={}
  for i,c in ipairs(ctx) do out[token_for(c)]=i end
  return out
end

local function enumerate_tokens(ts,visit)
  local row={}
  local function go(i)
    if i>#ts then visit(copy(row)); return end
    for _,v in ipairs(TOKEN_META[ts[i]].values) do row[i]=v; go(i+1) end
  end
  go(1)
end

local function row_key(row) return Canonical.encode(row) end
local function count_rows(rows) local n=0; for _ in pairs(rows) do n=n+1 end; return n end
local function total_rows(ts)
  local n=1
  for _,t in ipairs(ts) do n=n*#TOKEN_META[t].values end
  return n
end

local function normal_raw(ts,rows)
  local n=count_rows(rows)
  if n==0 then return Thin.BOTTOM end
  if n==total_rows(ts) then return Thin.TOP end
  return rows
end

local Domain=Thin.domain{
  name='recursive-lab-finite-relation',

  equal=function(_,a,b)
    for k in pairs(a) do if not b[k] then return false end end
    for k in pairs(b) do if not a[k] then return false end end
    return true
  end,

  meet=function(ctx,a,b)
    local rows={}
    for k,row in pairs(a) do if b[k] then rows[k]=row end end
    return normal_raw(ctx,rows)
  end,

  reindex=function(source,raw,target,sigma)
    local ti={}; for i,t in ipairs(target) do ti[t]=i end
    local rows={}
    enumerate_tokens(target,function(tr)
      local sr={}
      for i,s in ipairs(source) do sr[i]=tr[assert(ti[sigma[s]],'reindex target coordinate absent')] end
      local key=row_key(sr)
      if raw[key] then rows[row_key(tr)]=tr end
    end)
    return normal_raw(target,rows)
  end,

  exists=function(source,raw,keep)
    local si={}; for i,t in ipairs(source) do si[t]=i end
    local rows={}
    for _,sr in pairs(raw) do
      local q={}; for i,t in ipairs(keep) do q[i]=sr[assert(si[t],'existential coordinate absent')] end
      rows[row_key(q)]=q
    end
    return normal_raw(keep,rows)
  end,
}

local function raw_rows(core)
  if Thin.is_bottom(core) then return {} end
  local raw=Thin.component(core,Domain)
  local out={}
  if raw==Thin.TOP then
    enumerate_tokens(Thin.context(core),function(r) out[row_key(r)]=r end)
  else
    for key,row in pairs(raw) do out[key]=copy(row) end
  end
  return out
end

local function wrap(core)
  if core==Thin.DEFERRED then return core end
  return {core=core,ctx=descriptors(Thin.context(core)),rows=raw_rows(core)}
end

local function core(k)
  assert(type(k)=='table' and k.core and Thin.is_knowledge(k.core),'knowledge required')
  return k.core
end

local function make(ctx,rows)
  ctx=M.context(ctx)
  local ts=tokens(ctx)
  local set={}
  for _,row in ipairs(rows or {}) do
    assert(#row==#ctx,'knowledge row arity mismatch')
    for i,v in ipairs(row) do
      local allowed=false
      for _,a in ipairs(ctx[i].values) do if scalar_key(a)==scalar_key(v) then allowed=true; break end end
      assert(allowed,'knowledge row value outside coordinate domain')
    end
    set[row_key(row)]=copy(row)
  end
  return wrap(Thin.of(ts,Domain,normal_raw(ts,set)))
end

function M.top(ctx) return wrap(Thin.top(tokens(ctx))) end
function M.bottom(ctx) return wrap(Thin.bottom(tokens(ctx))) end
function M.from_rows(ctx,rows) return make(ctx,rows) end

function M.relation(ctx,predicate)
  ctx=M.context(ctx)
  local ts=tokens(ctx); local ix=ctx_index(ctx); local rows={}
  enumerate_tokens(ts,function(row)
    local env={}
    for token,i in pairs(ix) do
      local p=TOKEN_META[token].point
      env[p]=row[i]
      local key=point_key(p); if key then env[key]=row[i] end
    end
    if predicate(env) then rows[#rows+1]=row end
  end)
  return make(ctx,rows)
end

function M.normal(k)
  if type(k)=='table' and k.core and Thin.is_knowledge(k.core) then return k end
  assert(type(k)=='table' and type(k.ctx)=='table' and type(k.rows)=='table','knowledge required')
  return make(k.ctx,k.rows)
end
function M.equal(a,b) return Thin.equal(core(a),core(b)) end
function M.is_bottom(k) return Thin.is_bottom(core(k)) end
function M.leq(a,b) local yes,why=Thin.entails(core(a),core(b)); assert(why==nil,why); return yes end
function M.meet(a,b) return wrap(Thin.meet(core(a),core(b))) end
function M.judge(a,b) return Thin.judge(core(a),core(b)) end

function M.exists(k,keep_points)
  k=M.normal(k)
  local ix=ctx_index(k.ctx); local keep={}; local keep_ctx={}
  for _,p in ipairs(keep_points or {}) do
    local token=nil
    for t,i in pairs(ix) do if TOKEN_META[t].point==p then token=t; keep_ctx[#keep_ctx+1]=k.ctx[i]; break end end
    assert(token,'existential keep Point absent from context')
    keep[#keep+1]=token
  end
  return wrap(Thin.exists(core(k),keep))
end

function M.restrict_context(k,target_ctx)
  target_ctx=M.context(target_ctx)
  local keep={}; for _,c in ipairs(target_ctx) do keep[#keep+1]=c.point end
  local out=M.exists(k,keep)
  assert(M.same_context(out,{ctx=target_ctx,core=out.core,rows=out.rows}),'restricted context domain mismatch')
  return out
end

function M.rename(k,map,target_ctx)
  k=M.normal(k); target_ctx=M.context(target_ctx)
  local source_keep,source_tokens={},{}
  for _,c in ipairs(k.ctx) do
    if map[c.point]~=nil then source_keep[#source_keep+1]=c.point; source_tokens[#source_tokens+1]=token_for(c) end
  end
  local hidden=M.exists(k,source_keep)
  local target_tokens=tokens(target_ctx); local target_by_point={}
  for i,c in ipairs(target_ctx) do target_by_point[c.point]=target_tokens[i] end
  local sigma={}
  for _,t in ipairs(source_tokens) do
    local p=TOKEN_META[t].point; local q=map[p]
    sigma[t]=assert(target_by_point[q],'renamed Point absent from target context')
  end
  return wrap(Thin.reindex(core(hidden),target_tokens,sigma))
end

function M.product(parts)
  parts=parts or {}
  if #parts==0 then return M.top({}) end
  local target_ctx,seen={},{}
  for _,k in ipairs(parts) do
    for _,c in ipairs(M.normal(k).ctx) do
      local t=token_for(c); assert(not seen[t],'knowledge product contexts overlap')
      seen[t]=true; target_ctx[#target_ctx+1]=c
    end
  end
  local target_tokens=tokens(target_ctx); local out=Thin.top(target_tokens)
  local by_point={}; for i,c in ipairs(target_ctx) do by_point[c.point]=target_tokens[i] end
  for _,k in ipairs(parts) do
    local sigma={}
    for _,c in ipairs(k.ctx) do sigma[token_for(c)]=by_point[c.point] end
    out=Thin.meet(out,Thin.reindex(core(k),target_tokens,sigma))
  end
  return wrap(out)
end

function M.prefix(k,prefix)
  k=M.normal(k)
  local target,map={},{}
  for i,c in ipairs(k.ctx) do
    local p=prefix..tostring(c.point)
    target[i]={point=p,sort=c.sort,values=copy(c.values)}
    map[c.point]=p
  end
  return M.rename(k,map,target)
end

function M.target_context(parts,class_info)
  local by_target={}
  for pi,k in ipairs(parts or {}) do
    for _,c in ipairs(M.normal(k).ctx) do
      local class=assert(class_info.sources[pi][c.point],'Construction correspondence omitted Theory Point')
      local target=class_info.target[class]
      if target~=nil then
        local old=by_target[target]
        if old then assert(old.sort==c.sort and same_values(old.values,c.values),'identified Point domain mismatch')
        else by_target[target]={point=target,sort=c.sort,values=copy(c.values)} end
      end
    end
  end
  local ids={}; for p in pairs(by_target) do ids[#ids+1]=p end; table.sort(ids)
  local out={}; for _,p in ipairs(ids) do out[#out+1]=by_target[p] end
  return M.context(out)
end

-- Portable-model adapter.  The semantic operation is still meet + reindex +
-- exists; this function merely turns the symbolic lab corelation into those
-- operations before exact Worlds instantiation exists.
function M.transport_parts(parts,class_info,target_ctx,equalities)
  local prefixed={}
  for pi,k in ipairs(parts) do prefixed[pi]=M.prefix(k,'p'..pi..':') end
  local combined=M.product(prefixed)
  for _,e in ipairs(equalities or {}) do
    local a='p'..e.a.part..':'..tostring(e.a.point)
    local b='p'..e.b.part..':'..tostring(e.b.point)
    combined=M.meet(combined,M.points_equal(combined.ctx,a,b))
  end
  local by_class={}
  for pi,k in ipairs(parts) do for _,c in ipairs(M.normal(k).ctx) do
    local source='p'..pi..':'..tostring(c.point)
    local class=assert(class_info.sources[pi][c.point],'Construction correspondence omitted Theory Point')
    local row=by_class[class] or {}; by_class[class]=row; row[#row+1]=source
  end end
  for _,row in pairs(by_class) do
    for i=2,#row do combined=M.meet(combined,M.points_equal(combined.ctx,row[1],row[i])) end
  end
  local map={}
  for pi,k in ipairs(parts) do for _,c in ipairs(M.normal(k).ctx) do
    local source='p'..pi..':'..tostring(c.point)
    local class=assert(class_info.sources[pi][c.point],'Construction correspondence omitted Theory Point')
    map[source]=class_info.target[class]
  end end
  return M.rename(combined,map,target_ctx)
end

function M.select(k,source_points,target_ctx)
  k=M.normal(k); target_ctx=M.context(target_ctx)
  assert(#source_points==#target_ctx,'knowledge select arity mismatch')
  local ix=ctx_index(k.ctx); local rows,seen={},{}
  for _,r in pairs(k.rows) do
    local q={}
    for j,p in ipairs(source_points) do
      local source=nil
      for t,i in pairs(ix) do if TOKEN_META[t].point==p then source=i; break end end
      assert(source,'selected Point absent from knowledge context')
      q[j]=r[source]
    end
    local key=row_key(q); if not seen[key] then seen[key]=true; rows[#rows+1]=q end
  end
  return make(target_ctx,rows)
end

function M.point_value(ctx,point,value)
  ctx=M.context(ctx)
  return M.relation(ctx,function(env) return scalar_key(env[point])==scalar_key(value) end)
end

function M.points_equal(ctx,a,b)
  ctx=M.context(ctx)
  local by={}; for _,c in ipairs(ctx) do by[c.point]=c end
  local ca,cb=assert(by[a],'Point absent'),assert(by[b],'Point absent')
  assert(ca.sort==cb.sort and same_values(ca.values,cb.values),'value equality sort mismatch')
  return M.relation(ctx,function(env) return scalar_key(env[a])==scalar_key(env[b]) end)
end

function M.join_rows(a,b)
  a,b=M.normal(a),M.normal(b)
  assert(M.same_context(a,b),'knowledge union context mismatch')
  local rows,seen={},{}
  for _,x in ipairs({a,b}) do for key,row in pairs(x.rows) do
    if not seen[key] then seen[key]=true; rows[#rows+1]=row end
  end end
  return make(a.ctx,rows)
end

function M.observe(k,point)
  k=M.normal(k)
  if M.is_bottom(k) then return 'Retry' end
  local pos=nil; for i,c in ipairs(k.ctx) do if c.point==point then pos=i end end
  assert(pos,'observed Point absent')
  local vals,by={},{}
  for _,r in pairs(k.rows) do local key=scalar_key(r[pos]); if not by[key] then by[key]=true; vals[#vals+1]=r[pos] end end
  if #vals~=1 then return 'Unknown' end
  local cert=M.point_value(k.ctx,point,vals[1])
  assert(M.leq(k,cert),'observation certificate not entailed')
  return 'Hit',vals[1],cert
end

function M.spec(k)
  k=M.normal(k)
  local rows={}; for _,r in pairs(k.rows) do rows[#rows+1]=copy(r) end
  table.sort(rows,function(a,b) return row_key(a)<row_key(b) end)
  return {ctx=M.context(k.ctx),rows=rows}
end

function M.from_spec(s) return make(assert(s.ctx),assert(s.rows)) end
function M.key(k) return Canonical.encode(M.spec(k)) end
function M.same_context(a,b)
  a,b=M.normal(a),M.normal(b)
  if #a.ctx~=#b.ctx then return false end
  for i=1,#a.ctx do
    local x,y=a.ctx[i],b.ctx[i]
    if x.point~=y.point or x.sort~=y.sort or not same_values(x.values,y.values) then return false end
  end
  return true
end

return M
