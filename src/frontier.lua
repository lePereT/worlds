-- Frontier abstraction for source-less compiled World artefacts.
--
-- A FrontierVar is not a kernel Point and never reaches Model/Separate import.
-- It is a variadic row of Point positions in an incomplete portable artefact.
-- specialise(...) replaces each row occurrence with ordinary suspended Points
-- preserving only sort/order/equivalence shape. Actual generative identity is
-- still bound later by develop(...).
local F={FORMAT='worlds.frontier-artifact/1'}

local function fail(msg) error('Worlds frontier: '..msg,0) end
local function copy(x,seen)
  if type(x)~='table' then return x end
  seen=seen or {}; if seen[x] then return seen[x] end
  local y={}; seen[x]=y
  for k,v in pairs(x) do y[copy(k,seen)]=copy(v,seen) end
  return y
end
local function safe(s) return tostring(s):gsub('[^%w_%.%-]','_') end

-- Compiler helper: make one detached marker prototype for a frontier variable.
-- A compiler normally copies this Point's sort into each suspended stage seam;
-- abstract_unit erases every such marker before the artefact may be linked.
function F.prototype(model,id)
  id=assert(id,'frontier variable id required')
  local base='$frontier.marker.'..safe(id)
  local sort=base..'.row'
  local w=model:world(base..'.prototype')
  local p=model:point(base..'.row',w,sort)
  return {id=id,points={p},prototype_world=w,marker_sort=sort}
end

function F.is_abstract_points(points)
  for _,p in ipairs(points or {}) do
    if type(p.sort)=='string' and p.sort:match('^%$frontier%.marker%.') then return true end
  end
  return false
end

-- Shape records structure, not identity. Equal concrete Points receive the same
-- class number. Empty rows are legal.
function F.shape(model,points)
  local positions,reps={},{}
  for i,p in ipairs(points or {}) do
    local cls
    for j,r in ipairs(reps) do if model:same_point(p,r) then cls=j; break end end
    if not cls then reps[#reps+1]=p; cls=#reps end
    positions[i]={sort=p.sort,class=cls}
  end
  return {positions=positions}
end

function F.shape_key(shape)
  local xs={}
  for i,p in ipairs(assert(shape.positions,'shape.positions required')) do
    xs[i]=tostring(p.sort)..'@'..tostring(p.class)
  end
  return table.concat(xs,'|')
end

local function token(var) return {frontier=var} end
local function remap_ref(r,map,markers)
  if r.anchor then return {anchor=r.anchor} end
  local id=markers[r.cell]; if id then return token(id) end
  local n=map[r.cell]; if not n then fail('reference to removed/nonexistent cell '..tostring(r.cell)) end
  return {cell=n}
end

function F.abstract_unit(unit,prototypes)
  if not unit or unit.format~='worlds.unit/1' then fail('unsupported Separate unit') end
  local marker_by_sort,vars={},{}
  for _,p in ipairs(prototypes or {}) do
    if vars[p.id] then fail('duplicate frontier variable '..p.id) end
    vars[p.id]={id=p.id}
    if marker_by_sort[p.marker_sort] then fail('duplicate frontier marker sort '..p.marker_sort) end
    marker_by_sort[p.marker_sort]=p.id
  end
  local out={format=F.FORMAT,unit={format='worlds.unit/1',frontier=nil,anchors=copy(unit.anchors),stages={}},vars=vars}
  for si,st in ipairs(unit.stages or {}) do
    local markers,sites={},{}
    for i,c in ipairs(st.cells or {}) do
      if c.dim==0 and marker_by_sort[c.sort] then
        local id=marker_by_sort[c.sort]; markers[i]=id
        if sites[id] then fail('duplicate frontier marker for '..id..' in stage '..si) end
        sites[id]={world=c.world,name=c.name}
      end
    end
    local map,n={},0
    for i,c in ipairs(st.cells or {}) do if not markers[i] then n=n+1; map[i]=n end end
    local cells={}
    for i,c0 in ipairs(st.cells or {}) do if not markers[i] then
      local c=copy(c0)
      if c.dim==1 then
        local ps={}; for _,r in ipairs(c0.points or {}) do ps[#ps+1]=remap_ref(r,map,markers) end; c.points=ps
      elseif c.dim==2 then
        local ins,outs={},{}
        for _,r in ipairs(c0.inputs or {}) do ins[#ins+1]=remap_ref(r,map,markers) end
        for _,r in ipairs(c0.outputs or {}) do outs[#outs+1]=remap_ref(r,map,markers) end
        c.inputs,c.outputs=ins,outs
      end
      cells[#cells+1]=c
    end end
    local gate=map[st.gate]; if not gate then fail('stage gate was frontier marker') end
    out.unit.stages[si]={worlds=copy(st.worlds),cells=cells,gate=gate,frontier=nil,frontier_sites=sites}
  end
  for _,a in ipairs(out.unit.anchors or {}) do
    if marker_by_sort[a.sort] then fail('frontier marker escaped as realised anchor') end
  end
  return out
end

function F.validate(artifact)
  if type(artifact)~='table' or artifact.format~=F.FORMAT then fail('unsupported artefact') end
  if type(artifact.vars)~='table' or type(artifact.unit)~='table' or artifact.unit.format~='worlds.unit/1' then fail('malformed artefact') end
  local anchors={}
  for _,a in ipairs(artifact.unit.anchors or {}) do
    if type(a.key)~='string' or type(a.name)~='string' or type(a.sort)~='string' or anchors[a.key] then fail('malformed/duplicate artefact anchor') end
    if a.sort:match('^%$frontier%.marker%.') then fail('frontier marker escaped into artefact anchors') end
    anchors[a.key]=true
  end
  for id,v in pairs(artifact.vars) do
    if type(id)~='string' or type(v)~='table' or v.id~=id then fail('malformed frontier variable '..tostring(id)) end
  end
  for si,st in ipairs(artifact.unit.stages or {}) do
    if type(st)~='table' or type(st.cells)~='table' or type(st.worlds)~='table' or type(st.gate)~='number' or not st.cells[st.gate] then fail('malformed artefact stage '..si) end
    for id,site in pairs(st.frontier_sites or {}) do
      if not artifact.vars[id] or type(site)~='table' or type(site.world)~='number' or not st.worlds[site.world] then fail('unknown/malformed frontier site '..tostring(id)) end
    end
    local function ref_ok(r,limit,allow_frontier)
      if type(r)~='table' then return false end
      if r.anchor then return anchors[r.anchor]==true and not r.cell and not r.frontier end
      if r.cell then return type(r.cell)=='number' and r.cell>=1 and r.cell<limit and not r.frontier end
      if allow_frontier and r.frontier then return artifact.vars[r.frontier]~=nil and not r.anchor and not r.cell end
      return false
    end
    for i,c in ipairs(st.cells) do
      if type(c)~='table' or type(c.dim)~='number' or type(c.sort)~='string' or type(c.world)~='number' or not st.worlds[c.world] then fail('malformed artefact cell '..si..':'..i) end
      if c.dim==0 then
        if c.sort:match('^%$frontier%.marker%.') then fail('frontier marker survived abstraction') end
      elseif c.dim==1 then
        for _,r in ipairs(c.points or {}) do if not ref_ok(r,i,true) then fail('bad Strand reference in artefact stage '..si) end end
      elseif c.dim==2 then
        for _,r in ipairs(c.inputs or {}) do if not ref_ok(r,i,false) then fail('bad Face input in artefact stage '..si) end end
        for _,r in ipairs(c.outputs or {}) do if not ref_ok(r,i,false) then fail('bad Face output in artefact stage '..si) end end
      else fail('unsupported cell dimension in artefact') end
    end
  end
  return true
end

local function validate_shape(id,shape)
  if type(shape)~='table' or type(shape.positions)~='table' then fail('missing substitution for '..id) end
  local classes={}
  for i,p in ipairs(shape.positions) do
    if type(p.sort)~='string' or type(p.class)~='number' or p.class<1 or p.class%1~=0 then fail('malformed frontier position '..i..' for '..id) end
    if classes[p.class] and classes[p.class]~=p.sort then fail('equivalent frontier positions disagree on sort for '..id) end
    classes[p.class]=p.sort
  end
  return classes
end
local function is_token(r) return type(r)=='table' and r.frontier~=nil end

function F.specialise(artifact,substitution)
  F.validate(artifact)
  substitution=substitution or {}
  for id in pairs(substitution) do if not artifact.vars[id] then fail('substitution for unknown frontier variable '..tostring(id)) end end
  local validated={}
  local unit={format='worlds.unit/1',frontier=nil,anchors=copy(artifact.unit.anchors),stages={}}
  for si,st0 in ipairs(artifact.unit.stages or {}) do
    local used={}
    for _,c in ipairs(st0.cells or {}) do
      if c.dim==1 then for _,r in ipairs(c.points or {}) do if is_token(r) then used[r.frontier]=true end end end
    end
    local vars={}; for id in pairs(used) do vars[#vars+1]=id end; table.sort(vars)
    local additions,refs={},{}
    local n0=0; for _,c in ipairs(st0.cells or {}) do if c.dim==0 then n0=n0+1 else break end end
    for _,id in ipairs(vars) do
      if not artifact.vars[id] then fail('stage references unknown frontier variable '..id) end
      local shape=substitution[id]; local classes=validated[id] or validate_shape(id,shape); validated[id]=classes
      local site=(st0.frontier_sites or {})[id]; if not site then fail('missing seam site for '..id..' in stage '..si) end
      refs[id]={}
      local class_ids={}; for cls in pairs(classes) do class_ids[#class_ids+1]=cls end; table.sort(class_ids)
      for _,cls in ipairs(class_ids) do
        additions[#additions+1]={name='$frontier:'..safe(id)..'.c'..cls,dim=0,sort=classes[cls],world=site.world}
        refs[id][cls]=n0+#additions
      end
    end
    local shift=#additions
    local function remap_cell(i) return i<=n0 and i or i+shift end
    local function plain_ref(r) if r.anchor then return {anchor=r.anchor} end; return {cell=remap_cell(assert(r.cell))} end
    local function expand_points(points)
      local out={}
      for _,r in ipairs(points or {}) do
        if is_token(r) then
          local sh=substitution[r.frontier]; if not sh then fail('unspecialised frontier variable '..r.frontier) end
          for _,p in ipairs(sh.positions) do out[#out+1]={cell=refs[r.frontier][p.class]} end
        else out[#out+1]=plain_ref(r) end
      end
      return out
    end
    local cells={}
    for i=1,n0 do cells[#cells+1]=copy(st0.cells[i]) end
    for _,c in ipairs(additions) do cells[#cells+1]=c end
    for i=n0+1,#(st0.cells or {}) do
      local c0=st0.cells[i]; local c=copy(c0)
      if c.dim==1 then c.points=expand_points(c0.points)
      elseif c.dim==2 then
        local ins,outs={},{}
        for _,r in ipairs(c0.inputs or {}) do ins[#ins+1]=plain_ref(r) end
        for _,r in ipairs(c0.outputs or {}) do outs[#outs+1]=plain_ref(r) end
        c.inputs,c.outputs=ins,outs
      end
      cells[#cells+1]=c
    end
    unit.stages[si]={worlds=copy(st0.worlds),cells=cells,gate=remap_cell(st0.gate),frontier=nil}
  end
  for id in pairs(artifact.vars or {}) do
    local occurs=false
    for _,st in ipairs(artifact.unit.stages or {}) do if (st.frontier_sites or {})[id] then occurs=true; break end end
    if occurs and not substitution[id] then fail('frontier variable '..id..' remains abstract') end
  end
  return unit
end

return F
