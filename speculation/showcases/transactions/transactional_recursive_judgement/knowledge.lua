-- Exact finite-model oracle for the restrictive occurrence-relative knowledge doctrine.
-- Coordinates are symbolic/exact Point occurrences.  Meet is conjunction, hiding is
-- existential projection, and exact identity transport is supplied by Construction.
-- This is deliberately finite and exhaustive: a semantic oracle, not a production solver.
local Canonical=require('speculation.showcases.transactions.transactional_development_calculus.canonical')
local M={}

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
  for _,x in ipairs(xs) do local k=scalar_key(x)
 if not seen[k] then seen[k]=true
 rows[#rows+1]={k=k,v=x} end end
  table.sort(rows,function(a,b) return a.k<b.k end)
  local out={}
 for i,r in ipairs(rows) do out[i]=r.v end
 return out
end

local function coord_key(p) return type(p)..':'..tostring(p) end
local function ctx_index(ctx)
  local out={}
 for i,c in ipairs(ctx) do out[coord_key(c.point)]=i end
 return out
end

function M.context(spec)
  local rows,seen={},{}
  for _,c in ipairs(spec or {}) do
    assert(type(c)=='table' and c.point~=nil,'knowledge coordinate point required')
    local key=coord_key(c.point)
 assert(not seen[key],'duplicate knowledge Point coordinate')
 seen[key]=true
    rows[#rows+1]={point=c.point,sort=c.sort or 'value',values=normal_values(assert(c.values))}
  end
  return rows
end

local function same_values(a,b)
  if #a~=#b then return false end
  for i=1,#a do if Canonical.encode(a[i])~=Canonical.encode(b[i]) then return false end end
  return true
end

local function same_ctx(a,b)
  if #a~=#b then return false end
  for i=1,#a do
    if coord_key(a[i].point)~=coord_key(b[i].point) or a[i].sort~=b[i].sort or not same_values(a[i].values,b[i].values) then return false end
  end
  return true
end

local function enumerate(ctx,visit)
  local row={}
  local function go(i)
    if i>#ctx then local r={}
 for j,x in ipairs(row) do r[j]=x end
 visit(r)
 return end
    for _,v in ipairs(ctx[i].values) do row[i]=v
 go(i+1) end
  end
  go(1)
end

local function row_key(row) return Canonical.encode(row) end

local function make(ctx,rows)
  ctx=M.context(ctx)
  local set={}
  for _,row in ipairs(rows or {}) do
    assert(#row==#ctx,'knowledge row arity mismatch')
    for i,v in ipairs(row) do
      local ok=false
 local vk=scalar_key(v)
      for _,a in ipairs(ctx[i].values) do if scalar_key(a)==vk then ok=true
 break end end
      assert(ok,'knowledge row value outside coordinate domain')
    end
    set[row_key(row)]=copy(row)
  end
  return {ctx=ctx,rows=set}
end

function M.top(ctx)
  local rows={}
 enumerate(M.context(ctx),function(r) rows[#rows+1]=r end)
 return make(ctx,rows)
end
function M.bottom(ctx) return make(ctx,{}) end
function M.from_rows(ctx,rows) return make(ctx,rows) end
function M.relation(ctx,predicate)
  ctx=M.context(ctx)
 local rows={}
 local ix=ctx_index(ctx)
  enumerate(ctx,function(row)
    local env={}
    for key,i in pairs(ix) do env[ctx[i].point]=row[i]
 env[key]=row[i] end
    if predicate(env) then rows[#rows+1]=row end
  end)
  return make(ctx,rows)
end
function M.normal(k)
  assert(type(k)=='table','knowledge required')
  local rows={}
 for _,r in pairs(k.rows or {}) do rows[#rows+1]=r end
  return make(assert(k.ctx),rows)
end
function M.equal(a,b)
  a,b=M.normal(a),M.normal(b)
 if not same_ctx(a.ctx,b.ctx) then return false end
  for k in pairs(a.rows) do if not b.rows[k] then return false end end
  for k in pairs(b.rows) do if not a.rows[k] then return false end end
  return true
end
function M.is_bottom(k) k=M.normal(k)
 return next(k.rows)==nil end
function M.leq(a,b)
  a,b=M.normal(a),M.normal(b)
 assert(same_ctx(a.ctx,b.ctx),'knowledge entailment context mismatch')
  for k in pairs(a.rows) do if not b.rows[k] then return false end end
  return true
end
function M.meet(a,b)
  a,b=M.normal(a),M.normal(b)
 assert(same_ctx(a.ctx,b.ctx),'knowledge meet context mismatch')
  local rows={}
 for k,r in pairs(a.rows) do if b.rows[k] then rows[#rows+1]=r end end
  return make(a.ctx,rows)
end

function M.join_rows(a,b)
  -- Meta-level extensional union used by Judgement fixed-point analysis, not Theory disjunction.
  a,b=M.normal(a),M.normal(b)
 assert(same_ctx(a.ctx,b.ctx),'knowledge union context mismatch')
  local rows={}
 local seen={}
  for _,x in ipairs({a,b}) do for k,r in pairs(x.rows) do if not seen[k] then seen[k]=true
 rows[#rows+1]=r end end end
  return make(a.ctx,rows)
end

function M.exists(k,keep_points)
  k=M.normal(k)
 local ix=ctx_index(k.ctx)
 local keep,ctx={},{}
  for _,p in ipairs(keep_points or {}) do
    local i=assert(ix[coord_key(p)],'existential keep Point absent from context')
 keep[#keep+1]=i
 ctx[#ctx+1]=k.ctx[i]
  end
  local rows,seen={},{}
  for _,r in pairs(k.rows) do
    local q={}
 for j,i in ipairs(keep) do q[j]=r[i] end
    local key=row_key(q)
 if not seen[key] then seen[key]=true
 rows[#rows+1]=q end
  end
  return make(ctx,rows)
end

function M.restrict_context(k,target_ctx)
  k=M.normal(k)
 target_ctx=M.context(target_ctx)
  local keep={}
 for _,c in ipairs(target_ctx) do keep[#keep+1]=c.point end
  local out=M.exists(k,keep)
  assert(same_ctx(out.ctx,target_ctx),'restricted context domain mismatch')
  return out
end

function M.rename(k,map,target_ctx)
  -- Pure exact bijective/identifying reindex of coordinate names.  Values on identified
  -- exact Points must agree.  Coordinates absent from map are existentially hidden.
  k=M.normal(k)
 target_ctx=M.context(target_ctx)
  local tx=ctx_index(target_ctx)
 local groups={}
  for i,c in ipairs(k.ctx) do
    local t=map[c.point]
    if t~=nil then
      local ti=assert(tx[coord_key(t)],'renamed Point absent from target context')
      local tc=target_ctx[ti]
      assert(c.sort==tc.sort and same_values(c.values,tc.values),'identified Point domain mismatch')
      local g=groups[coord_key(t)] or {}
 groups[coord_key(t)]=g
 g[#g+1]=i
    end
  end
  local rows,seen={},{}
  for _,r in pairs(k.rows) do
    local q={},true
    for ti,tc in ipairs(target_ctx) do
      local g=groups[coord_key(tc.point)]
      if g and #g>0 then
        local v=r[g[1]]
        for j=2,#g do if scalar_key(r[g[j]])~=scalar_key(v) then q=nil
 break end end
        if not q then break end
        q[ti]=v
      else
        -- Target coordinates with no source knowledge are unconstrained: expand below.
        q[ti]=nil
      end
    end
    if q then
      local function fill(i)
        if i>#target_ctx then local key=row_key(q)
 if not seen[key] then seen[key]=true
 rows[#rows+1]=copy(q) end
 return end
        if q[i]~=nil then fill(i+1) else for _,v in ipairs(target_ctx[i].values) do q[i]=v
 fill(i+1) end
 q[i]=nil end
      end
      fill(1)
    end
  end
  return make(target_ctx,rows)
end

function M.product(parts)
  parts=parts or {}
 if #parts==0 then return make({},{{}}) end
  local ctx={}
 local offsets={}
 local seen={}
  for pi,k in ipairs(parts) do
    k=M.normal(k)
 offsets[pi]=#ctx
    for _,c in ipairs(k.ctx) do local key=coord_key(c.point)
 assert(not seen[key],'knowledge product contexts overlap')
      seen[key]=true
 ctx[#ctx+1]=c end
  end
  local rows={{}}
  for _,k in ipairs(parts) do
    local nextrows={}
    for _,prefix in ipairs(rows) do for _,r in pairs(k.rows) do local q=copy(prefix)
 for _,v in ipairs(r) do q[#q+1]=v end
 nextrows[#nextrows+1]=q end end
    rows=nextrows
  end
  return make(ctx,rows)
end

function M.prefix(k,prefix)
  k=M.normal(k)
 local ctx={}
  for i,c in ipairs(k.ctx) do ctx[i]={point=prefix..tostring(c.point),sort=c.sort,values=copy(c.values)} end
  local rows={}
 for _,r in pairs(k.rows) do rows[#rows+1]=r end
  return make(ctx,rows)
end

function M.target_context(parts,class_info)
  local by_target={}
  for pi,k in ipairs(parts or {}) do
    k=M.normal(k)
    for _,c in ipairs(k.ctx) do
      local class=assert(class_info.sources[pi][c.point],'Construction correspondence omitted Theory Point')
      local target=class_info.target[class]
      if target~=nil then
        local old=by_target[target]
        if old then assert(old.sort==c.sort and same_values(old.values,c.values),'identified Theory Point domain mismatch')
        else by_target[target]={point=target,sort=c.sort,values=copy(c.values)} end
      end
    end
  end
  local ids={}
 for pnt in pairs(by_target) do ids[#ids+1]=pnt end
 table.sort(ids)
  local out={}
 for _,pnt in ipairs(ids) do out[#out+1]=by_target[pnt] end
  return M.context(out)
end

function M.transport_parts(parts,class_info,target_ctx,equalities)
  -- parts are knowledge relations whose Point ids are local symbolic indices.
  -- class_info.sources[part][point] -> opaque/canonical class key;
  -- class_info.target[class] -> target symbolic Point index (or nil).
  local prefixed={},{}
  for pi,k in ipairs(parts) do prefixed[pi]=M.prefix(k,'p'..pi..':') end
  local combined=M.product(prefixed)
  for _,e in ipairs(equalities or {}) do
    local a='p'..e.a.part..':'..tostring(e.a.point)
    local b='p'..e.b.part..':'..tostring(e.b.point)
    combined=M.meet(combined,M.points_equal(combined.ctx,a,b))
  end
  -- Exact Construction identification is imposed before hiding, even when the
  -- resulting class has no public target occurrence.
  local by_class={}
  for pi,k in ipairs(parts) do for _,c in ipairs(M.normal(k).ctx) do
    local source='p'..pi..':'..tostring(c.point)
    local class=assert(class_info.sources[pi][c.point],'Construction correspondence omitted Theory Point')
    local row=by_class[class] or {}
 by_class[class]=row
 row[#row+1]=source
  end end
  for _,row in pairs(by_class) do
    for i=2,#row do combined=M.meet(combined,M.points_equal(combined.ctx,row[1],row[i])) end
  end
  local map={}
  for pi,k in ipairs(parts) do for _,c in ipairs(M.normal(k).ctx) do
    local source='p'..pi..':'..tostring(c.point)
    local class=assert(class_info.sources[pi][c.point],'Construction correspondence omitted Theory Point')
    map[source]=class_info.target[class] -- nil means existential hiding after class equality
  end end
  return M.rename(combined,map,target_ctx)
end

function M.select(k,source_points,target_ctx)
  -- Project/duplicate ordered coordinates into an explicitly supplied target context.
  k=M.normal(k)
 target_ctx=M.context(target_ctx)
 assert(#source_points==#target_ctx,'knowledge select arity mismatch')
  local ix=ctx_index(k.ctx)
 local rows,seen={},{}
  for _,r in pairs(k.rows) do
    local q={}
    for j,p in ipairs(source_points) do
      local i=assert(ix[coord_key(p)],'selected Point absent from knowledge context')
      local sc,tc=k.ctx[i],target_ctx[j]
      assert(sc.sort==tc.sort and same_values(sc.values,tc.values),'selected Point domain mismatch')
      q[j]=r[i]
    end
    local key=row_key(q)
 if not seen[key] then seen[key]=true
 rows[#rows+1]=q end
  end
  return make(target_ctx,rows)
end

function M.point_value(ctx,point,value)
  ctx=M.context(ctx)
 local ix=ctx_index(ctx)
 local i=assert(ix[coord_key(point)],'Point absent')
  return M.relation(ctx,function(env) return scalar_key(env[point])==scalar_key(value) end)
end
function M.points_equal(ctx,a,b)
  ctx=M.context(ctx)
 local ix=ctx_index(ctx)
 local ia,ib=assert(ix[coord_key(a)]),assert(ix[coord_key(b)])
  local ca,cb=ctx[ia],ctx[ib]
 assert(ca.sort==cb.sort and same_values(ca.values,cb.values),'value equality sort mismatch')
  return M.relation(ctx,function(env) return scalar_key(env[a])==scalar_key(env[b]) end)
end

function M.judge(k,r)
  local both=M.meet(k,r)
  if M.is_bottom(both) then return 'Retry' end
  if M.equal(both,k) then return 'Hit' end
  return 'Unknown'
end

function M.observe(k,point)
  k=M.normal(k)
 local ix=ctx_index(k.ctx)
 local i=assert(ix[coord_key(point)],'observed Point absent')
  if M.is_bottom(k) then return 'Retry' end
  local vals={}
 local by={}
  for _,r in pairs(k.rows) do local key=scalar_key(r[i])
 if not by[key] then by[key]=r[i]
 vals[#vals+1]=r[i] end end
  if #vals~=1 then return 'Unknown' end
  local cert=M.point_value(k.ctx,point,vals[1])
 assert(M.leq(k,cert),'observation certificate not entailed')
  return 'Hit',vals[1],cert
end

function M.spec(k)
  k=M.normal(k)
 local rows={}
  for _,r in pairs(k.rows) do rows[#rows+1]=copy(r) end
  table.sort(rows,function(a,b) return row_key(a)<row_key(b) end)
  local ctx={}
 for i,c in ipairs(k.ctx) do ctx[i]={point=c.point,sort=c.sort,values=copy(c.values)} end
  return {ctx=ctx,rows=rows}
end
function M.from_spec(s) return make(assert(s.ctx),assert(s.rows)) end
function M.key(k) return Canonical.encode(M.spec(k)) end
function M.same_context(a,b) return same_ctx(M.normal(a).ctx,M.normal(b).ctx) end

return M
