-- Worlds geometric research kernel
--
-- Geometry is an immutable finite 2-complex inside a forest of membranes:
--   Point  (0-cell) : semantic identity
--   Strand (1-cell) : authority occurrence
--   Face   (2-cell) : causal occurrence
--
-- There is deliberately no actuality flag, transaction object, residual object,
-- virtual cell class, Point equivalence relation, or stored frontier.

local M = {}

local geometry_state = setmetatable({}, {__mode='k'})
local builder_state = setmetatable({}, {__mode='k'})

local next_id = {m=0, p=0, s=0, f=0}
local function fresh_id(prefix)
  next_id[prefix] = next_id[prefix] + 1
  return prefix .. tostring(next_id[prefix])
end

local function copy_array(xs)
  local r = {}
  for i=1,#xs do r[i]=xs[i] end
  return r
end

local function copy_set(s)
  local r={}
  for k,v in pairs(s) do if v then r[k]=true end end
  return r
end

local function shallow_map(m)
  local r={}
  for k,v in pairs(m) do r[k]=v end
  return r
end

local function readonly_error()
  error('Worlds Geometry values are immutable', 2)
end

local GeometryMT = {__newindex=readonly_error}
GeometryMT.__index = GeometryMT
local BuilderMT = {}
BuilderMT.__index = BuilderMT

local function assert_geometry(g)
  local st=geometry_state[g]
  assert(st, 'expected Geometry')
  return st
end

local function assert_builder(b)
  local st=builder_state[b]
  assert(st, 'expected Geometry.Builder')
  assert(not st.finished, 'builder already finished')
  return st
end

local function cell_of(st,id)
  return st.membranes[id] or st.points[id] or st.strands[id] or st.faces[id]
end

local function index_state(st)
  local producer, consumer = {}, {}
  local point_users = {}
  local children = {}
  local local_points, local_strands, local_faces = {}, {}, {}

  for _,mid in ipairs(st.morder) do
    children[mid] = children[mid] or {}
    local_points[mid] = local_points[mid] or {}
    local_strands[mid] = local_strands[mid] or {}
    local_faces[mid] = local_faces[mid] or {}
    local m=st.membranes[mid]
    if m.parent then
      children[m.parent] = children[m.parent] or {}
      children[m.parent][#children[m.parent]+1]=mid
    end
  end
  for _,pid in ipairs(st.porder) do
    local p=st.points[pid]
    local_points[p.membrane][#local_points[p.membrane]+1]=pid
    point_users[pid]={}
  end
  for _,sid in ipairs(st.sorder) do
    local s=st.strands[sid]
    local_strands[s.membrane][#local_strands[s.membrane]+1]=sid
    for pos,pid in ipairs(s.points) do
      point_users[pid][#point_users[pid]+1]={strand=sid,pos=pos}
    end
  end
  for _,fid in ipairs(st.forder) do
    local f=st.faces[fid]
    local_faces[f.membrane][#local_faces[f.membrane]+1]=fid
    local seen={}
    for _,sid in ipairs(f.inputs) do
      assert(not seen[sid], 'Face consumes the same Strand twice')
      seen[sid]=true
      assert(not consumer[sid], 'a Strand may have at most one consumer')
      consumer[sid]=fid
    end
    seen={}
    for _,sid in ipairs(f.outputs) do
      assert(not seen[sid], 'Face produces the same Strand twice')
      seen[sid]=true
      assert(not producer[sid], 'a Strand may have at most one producer')
      producer[sid]=fid
    end
  end

  -- Causal acyclicity: producer(F) -> consumer(F) along each Strand.
  local edges, indeg = {}, {}
  for _,fid in ipairs(st.forder) do edges[fid]={}; indeg[fid]=0 end
  for _,sid in ipairs(st.sorder) do
    local a,b=producer[sid],consumer[sid]
    if a and b then
      edges[a][#edges[a]+1]=b
      indeg[b]=indeg[b]+1
    end
  end
  local q={}
  for _,fid in ipairs(st.forder) do if indeg[fid]==0 then q[#q+1]=fid end end
  local qi,n=1,0
  while qi<=#q do
    local a=q[qi]; qi=qi+1; n=n+1
    for _,b in ipairs(edges[a]) do
      indeg[b]=indeg[b]-1
      if indeg[b]==0 then q[#q+1]=b end
    end
  end
  assert(n==#st.forder, 'causal Face/Strand incidence must be acyclic')

  st.producer=producer
  st.consumer=consumer
  st.point_users=point_users
  st.children=children
  st.local_points=local_points
  st.local_strands=local_strands
  st.local_faces=local_faces
end

local function validate_state(st)
  -- Membrane forest.
  for _,mid in ipairs(st.morder) do
    local m=st.membranes[mid]
    if m.parent then assert(st.membranes[m.parent], 'unknown parent membrane') end
    local seen={}
    local x=mid
    while x do
      assert(not seen[x], 'membrane containment must be acyclic')
      seen[x]=true
      x=st.membranes[x] and st.membranes[x].parent or nil
    end
  end
  for _,pid in ipairs(st.porder) do
    local p=st.points[pid]
    assert(st.membranes[p.membrane], 'Point has unknown membrane')
  end
  for _,sid in ipairs(st.sorder) do
    local s=st.strands[sid]
    assert(st.membranes[s.membrane], 'Strand has unknown membrane')
    for _,pid in ipairs(s.points) do assert(st.points[pid], 'Strand has unknown Point') end
  end
  for _,fid in ipairs(st.forder) do
    local f=st.faces[fid]
    assert(st.membranes[f.membrane], 'Face has unknown membrane')
    for _,sid in ipairs(f.inputs) do assert(st.strands[sid], 'Face has unknown input Strand') end
    for _,sid in ipairs(f.outputs) do assert(st.strands[sid], 'Face has unknown output Strand') end
  end
  index_state(st)
end

local function make_geometry(st)
  validate_state(st)
  local g=setmetatable({},GeometryMT)
  geometry_state[g]=st
  return g
end

function M.builder()
  local b=setmetatable({},BuilderMT)
  builder_state[b]={
    membranes={}, points={}, strands={}, faces={},
    morder={}, porder={}, sorder={}, forder={}, finished=false,
  }
  return b
end

function BuilderMT:membrane(parent, sort, name)
  local st=assert_builder(self)
  if parent~=nil then assert(st.membranes[parent], 'parent membrane must already exist') end
  local id=fresh_id('m')
  st.membranes[id]={id=id,parent=parent,sort=sort or '_',name=name}
  st.morder[#st.morder+1]=id
  return id
end

function BuilderMT:point(membrane, sort, name)
  local st=assert_builder(self)
  assert(st.membranes[membrane], 'unknown Point membrane')
  local id=fresh_id('p')
  st.points[id]={id=id,membrane=membrane,sort=sort or '_',name=name}
  st.porder[#st.porder+1]=id
  return id
end

function BuilderMT:strand(membrane, sort, points, name)
  local st=assert_builder(self)
  assert(st.membranes[membrane], 'unknown Strand membrane')
  points=points or {}
  for _,pid in ipairs(points) do assert(st.points[pid], 'unknown Strand Point') end
  local id=fresh_id('s')
  st.strands[id]={id=id,membrane=membrane,sort=sort or '_',points=copy_array(points),name=name}
  st.sorder[#st.sorder+1]=id
  return id
end

function BuilderMT:face(membrane, sort, inputs, outputs, name)
  local st=assert_builder(self)
  assert(st.membranes[membrane], 'unknown Face membrane')
  inputs,outputs=inputs or {},outputs or {}
  for _,sid in ipairs(inputs) do assert(st.strands[sid], 'unknown Face input') end
  for _,sid in ipairs(outputs) do assert(st.strands[sid], 'unknown Face output') end
  local id=fresh_id('f')
  st.faces[id]={id=id,membrane=membrane,sort=sort or '_',inputs=copy_array(inputs),outputs=copy_array(outputs),name=name}
  st.forder[#st.forder+1]=id
  return id
end

function BuilderMT:finish()
  local st=assert_builder(self)
  st.finished=true
  local gs={
    membranes=shallow_map(st.membranes), points=shallow_map(st.points),
    strands=shallow_map(st.strands), faces=shallow_map(st.faces),
    morder=copy_array(st.morder), porder=copy_array(st.porder),
    sorder=copy_array(st.sorder), forder=copy_array(st.forder),
  }
  return make_geometry(gs)
end

function GeometryMT:membranes() return copy_array(assert_geometry(self).morder) end
function GeometryMT:points() return copy_array(assert_geometry(self).porder) end
function GeometryMT:strands() return copy_array(assert_geometry(self).sorder) end
function GeometryMT:faces() return copy_array(assert_geometry(self).forder) end

local function public_cell(c)
  if not c then return nil end
  local r={id=c.id,membrane=c.membrane,parent=c.parent,sort=c.sort,name=c.name}
  if c.points then r.points=copy_array(c.points) end
  if c.inputs then r.inputs=copy_array(c.inputs) end
  if c.outputs then r.outputs=copy_array(c.outputs) end
  return r
end

function GeometryMT:cell(id) return public_cell(cell_of(assert_geometry(self),id)) end
function GeometryMT:producer(sid) return assert_geometry(self).producer[sid] end
function GeometryMT:consumer(sid) return assert_geometry(self).consumer[sid] end
function GeometryMT:is_input(sid) return assert_geometry(self).producer[sid]==nil end
function GeometryMT:is_terminal(sid) return assert_geometry(self).consumer[sid]==nil end
function GeometryMT:parent(mid) local m=assert_geometry(self).membranes[mid]; assert(m,'unknown membrane'); return m.parent end
function GeometryMT:children(mid) local st=assert_geometry(self); assert(st.membranes[mid],'unknown membrane'); return copy_array(st.children[mid] or {}) end

function GeometryMT:find(kind,name)
  local st=assert_geometry(self)
  local order,map
  if kind=='membrane' then order,map=st.morder,st.membranes
  elseif kind=='point' then order,map=st.porder,st.points
  elseif kind=='strand' then order,map=st.sorder,st.strands
  elseif kind=='face' then order,map=st.forder,st.faces
  else error('unknown cell kind '..tostring(kind)) end
  for _,id in ipairs(order) do if map[id].name==name then return id end end
  return nil
end

local function select_membranes(st, membranes)
  local selected,order={},{}
  for _,mid in ipairs(membranes or {}) do
    assert(st.membranes[mid], 'unknown selected membrane')
    if not selected[mid] then selected[mid]=true; order[#order+1]=mid end
  end
  return selected,order
end

local function offers_selected(st, selected)
  local r={}
  for _,sid in ipairs(st.sorder) do
    local strand=st.strands[sid]
    if selected[strand.membrane] and st.consumer[sid]==nil then r[#r+1]=sid end
  end
  return r
end

local function visible_points_selected(st, selected)
  local seen,r={},{}
  for _,pid in ipairs(st.porder) do
    if selected[st.points[pid].membrane] then seen[pid]=true end
  end
  for _,sid in ipairs(offers_selected(st,selected)) do
    for _,pid in ipairs(st.strands[sid].points) do seen[pid]=true end
  end
  for _,pid in ipairs(st.porder) do if seen[pid] then r[#r+1]=pid end end
  return r
end

-- Selection is not a semantic object. These are pure projections of this
-- Geometry through an explicitly supplied set of membrane occurrences.
function GeometryMT:offers(membranes)
  local st=assert_geometry(self)
  local selected=select_membranes(st,membranes)
  return offers_selected(st,selected)
end

function GeometryMT:visible_points(membranes)
  local st=assert_geometry(self)
  local selected=select_membranes(st,membranes)
  return visible_points_selected(st,selected)
end

-- Internal access for attach.lua. Kept out of the public object surface.
M._state=assert_geometry
M._make_geometry=make_geometry
M._selection=select_membranes
M._offers_selected=offers_selected
M._visible_points_selected=visible_points_selected
M._fresh_id=fresh_id
M._copy_array=copy_array
M._shallow_map=shallow_map

-- Exact geometry isomorphism modulo names of cells not shared by the two values.
-- Shared IDs are exact occurrence anchors; all other IDs may alpha-rename.
local function kind_data(st)
  local kind={}
  for _,id in ipairs(st.morder) do kind[id]='m' end
  for _,id in ipairs(st.porder) do kind[id]='p' end
  for _,id in ipairs(st.sorder) do kind[id]='s' end
  for _,id in ipairs(st.forder) do kind[id]='f' end
  return kind
end

local function coarse_signature(st,id,kind)
  if kind=='m' then
    local c=st.membranes[id]
    return table.concat({'m',c.sort,c.parent and '1' or '0',#(st.children[id] or {}),#(st.local_points[id] or {}),#(st.local_strands[id] or {}),#(st.local_faces[id] or {})},'|')
  elseif kind=='p' then
    local c=st.points[id]
    return table.concat({'p',c.sort,#(st.point_users[id] or {})},'|')
  elseif kind=='s' then
    local c=st.strands[id]
    return table.concat({'s',c.sort,#c.points,st.producer[id] and '1' or '0',st.consumer[id] and '1' or '0'},'|')
  else
    local c=st.faces[id]
    return table.concat({'f',c.sort,#c.inputs,#c.outputs},'|')
  end
end

local function relation_ok(a,b,sa,sb,map,rmap,ka,kb)
  local k=ka[a]
  if k~=kb[b] then return false end
  local ca=cell_of(sa,a); local cb=cell_of(sb,b)
  if ca.sort~=cb.sort then return false end
  local function eqref(x,y)
    if x==nil or y==nil then return x==y end
    if map[x] then return map[x]==y end
    if rmap[y] then return false end
    return true
  end
  if k=='m' then
    return eqref(ca.parent,cb.parent)
  elseif k=='p' then
    return eqref(ca.membrane,cb.membrane)
  elseif k=='s' then
    if not eqref(ca.membrane,cb.membrane) then return false end
    if #ca.points~=#cb.points then return false end
    for i=1,#ca.points do if not eqref(ca.points[i],cb.points[i]) then return false end end
    if not eqref(sa.producer[a],sb.producer[b]) then return false end
    if not eqref(sa.consumer[a],sb.consumer[b]) then return false end
    return true
  else
    if not eqref(ca.membrane,cb.membrane) then return false end
    if #ca.inputs~=#cb.inputs or #ca.outputs~=#cb.outputs then return false end
    for i=1,#ca.inputs do if not eqref(ca.inputs[i],cb.inputs[i]) then return false end end
    for i=1,#ca.outputs do if not eqref(ca.outputs[i],cb.outputs[i]) then return false end end
    return true
  end
end

local function all_ids(st)
  local r={}
  for _,x in ipairs(st.morder) do r[#r+1]=x end
  for _,x in ipairs(st.porder) do r[#r+1]=x end
  for _,x in ipairs(st.sorder) do r[#r+1]=x end
  for _,x in ipairs(st.forder) do r[#r+1]=x end
  return r
end

function M.same(a,b)
  local sa,sb=assert_geometry(a),assert_geometry(b)
  if #sa.morder~=#sb.morder or #sa.porder~=#sb.porder or #sa.sorder~=#sb.sorder or #sa.forder~=#sb.forder then return false end
  local ka,kb=kind_data(sa),kind_data(sb)
  local map,rmap={},{}

  -- IDs appearing in both geometries denote the same already-existing occurrence.
  for id,k in pairs(ka) do
    if kb[id] then
      if kb[id]~=k then return false end
      map[id]=id; rmap[id]=id
    end
  end
  for a0,b0 in pairs(map) do
    if not relation_ok(a0,b0,sa,sb,map,rmap,ka,kb) then return false end
  end

  local cand={}
  local idsA=all_ids(sa)
  local idsB=all_ids(sb)
  for _,id in ipairs(idsA) do
    if not map[id] then
      local sig=coarse_signature(sa,id,ka[id])
      local xs={}
      for _,j in ipairs(idsB) do
        if not rmap[j] and kb[j]==ka[id] and coarse_signature(sb,j,kb[j])==sig then xs[#xs+1]=j end
      end
      if #xs==0 then return false end
      cand[id]=xs
    end
  end

  local function choose_unmapped()
    local best,bestn=nil,math.huge
    for _,id in ipairs(idsA) do
      if not map[id] then
        local n=0
        for _,j in ipairs(cand[id]) do
          if not rmap[j] and relation_ok(id,j,sa,sb,map,rmap,ka,kb) then n=n+1 end
        end
        if n<bestn then best,bestn=id,n end
      end
    end
    return best,bestn
  end

  local function search()
    local id,n=choose_unmapped()
    if not id then return true end
    if n==0 then return false end
    for _,j in ipairs(cand[id]) do
      if not rmap[j] and relation_ok(id,j,sa,sb,map,rmap,ka,kb) then
        map[id]=j; rmap[j]=id
        local ok=true
        for x,y in pairs(map) do
          if not relation_ok(x,y,sa,sb,map,rmap,ka,kb) then ok=false; break end
        end
        if ok and search() then return true end
        map[id]=nil; rmap[j]=nil
      end
    end
    return false
  end
  return search()
end

return M
