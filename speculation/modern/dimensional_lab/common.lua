-- Cross-domain dimensional laboratory.
--
-- The higher-layer helpers deliberately reuse ordinary Worlds one rank up, but
-- retain an external exact lift from higher Points to the W2 histories/surfaces
-- they denote.  The lift is part of the experiment: round-4 showed that bare
-- lower Geometry is not sufficiently graded to recover source rank.

local W=require('worlds')
local M={W=W}

function M.counter()
  local n=0
  local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
  local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
  return ok,eq,function() return n end
end

local function sorted(xs)
  table.sort(xs); return xs
end

-- Domain-facing boundary signature.  Point names are used only as an explicit
-- domain vocabulary oracle; exact Worlds identity is never inferred from them.
function M.boundary_signature(g)
  local function side(xs)
    local rows={}
    for _,s in ipairs(xs) do
      local ps=W.points(s); local row={}
      for i,p in ipairs(ps) do row[i]=tostring(W.name(p) or '?') end
      rows[#rows+1]=table.concat(row,',')
    end
    return table.concat(sorted(rows),'|')
  end
  return side(g:ingress())..' -> '..side(g:egress())
end

function M.boundary_multiset(g)
  local function side(xs)
    local c={}
    for _,s in ipairs(xs) do
      local ps=W.points(s); assert(#ps>=1,'domain multiset expects role Point')
      local k=tostring(W.name(ps[1]) or '?'); c[k]=(c[k] or 0)+1
    end
    return c
  end
  return side(g:ingress()),side(g:egress())
end

function M.same_multiset(a,b)
  for k,v in pairs(a) do if b[k]~=v then return false end end
  for k,v in pairs(b) do if a[k]~=v then return false end end
  return true
end

-- A face-free higher deformation atlas.  Each W2 history becomes an exact Point
-- at the next rank.  A row [P,Q] says only that an elementary deformation relates
-- those exact histories; it does not identify them and adds no lower causality.
function M.deformation_atlas(surfaces,edges,label)
  local b=W.builder(); local m=b:membrane(nil,label or 'higher deformation atlas')
  local point,lift={},{}
  for i,s in ipairs(surfaces) do
    local p=b:point(m,'surface.'..i..':'..tostring(s.label or '?'))
    point[s]=p; lift[p]=s
  end
  local arcs={}
  for i,e in ipairs(edges) do
    assert(point[e[1]] and point[e[2]],'edge references unknown surface')
    arcs[i]=b:strand(m,{point[e[1]],point[e[2]]},'deformation.'..i)
  end
  return {world=b:finish(),point=point,lift=lift,arcs=arcs,surfaces=surfaces}
end

-- One higher causal rewrite between two exact W2 surfaces.  Source and target
-- state occurrences remain scarce and distinct; their Points carry the graded
-- lift to the W2 surfaces being related.
function M.higher_rewrite(source,target,label)
  local b=W.builder(); local m=b:membrane(nil,label or 'higher rewrite')
  local ps=b:point(m,'source:'..tostring(source.label or '?'))
  local pt=b:point(m,'target:'..tostring(target.label or '?'))
  local i=b:strand(m,{ps},'source surface occurrence')
  local o=b:strand(m,{pt},'target surface occurrence')
  local f=b:face(m,{i},{o},label or 'higher rewrite')
  return {world=b:finish(),source=source,target=target,source_point=ps,target_point=pt,input=i,output=o,face=f,lift={[ps]=source,[pt]=target}}
end

function M.path_rewrites(rewrites)
  local parts,eqs={},{}
  for i,r in ipairs(rewrites) do parts[i]=r.world; if i>1 then eqs[#eqs+1]={from=rewrites[i-1].output,to=r.input} end end
  return W.join(parts,eqs)
end

function M.face_reaches(g,a,b)
  local adj={}; for _,f in ipairs(g:faces()) do adj[f]={} end
  for _,s in ipairs(g:strands()) do local p,c=g:producer(s),g:consumer(s); if p and c then adj[p][c]=true end end
  local seen={}
  local function walk(x)
    if x==b then return true end; if seen[x] then return false end; seen[x]=true
    for y in pairs(adj[x] or {}) do if walk(y) then return true end end
    return false
  end
  return walk(a)
end

function M.surface(label,g,extra) return {label=label,g=g,extra=extra} end

return M
