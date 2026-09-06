-- Generic resource/conservation audit for the World kernel.
--
-- Face.sort is uninterpreted.  Structural authority changes are certified from
-- private construction facts created by Model:admit/copy/discard, never from a
-- trusted semantic label vocabulary.
local A={}

local function actual_faces(m)
  local xs={}; for _,o in ipairs(m.objects) do if o.dim==2 and m:is_realised(o) then xs[#xs+1]=o end end; return xs
end
local function actual_strands(m)
  local xs={}; for _,o in ipairs(m.objects) do if o.dim==1 and m:is_realised(o) then xs[#xs+1]=o end end; return xs
end

function A.producer(m,s)
  local found={}
  for _,f in ipairs(actual_faces(m)) do for _,x in ipairs(f.outputs) do if x==s then found[#found+1]=f end end end
  return found
end
function A.consumers(m,s)
  local found={}
  for _,f in ipairs(actual_faces(m)) do for _,x in ipairs(f.inputs) do if x==s then found[#found+1]=f end end end
  return found
end

local function causal_cycle(faces,strands)
  local adj={}
  for _,s in ipairs(strands) do adj[s]=adj[s] or {} end
  for _,f in ipairs(faces) do
    adj[f]=adj[f] or {}
    for _,s in ipairs(f.inputs or {}) do adj[s]=adj[s] or {}; adj[s][#adj[s]+1]=f end
    for _,s in ipairs(f.outputs or {}) do adj[f][#adj[f]+1]=s end
  end
  local state={}
  local function dfs(n)
    if state[n]==1 then return true end
    if state[n]==2 then return false end
    state[n]=1; for _,v in ipairs(adj[n] or {}) do if dfs(v) then return true end end; state[n]=2; return false
  end
  for n,_ in pairs(adj) do if dfs(n) then return true end end
  return false
end

local function same_boundary(m,a,b)
  if a.sort~=b.sort or #a.points~=#b.points then return false end
  for i,p in ipairs(a.points) do if not m:same_point(p,b.points[i]) then return false end end
  return true
end

local function check_structural_face(m,f,prefix)
  local k=m:structural_kind(f)
  prefix=prefix or ''
  if k=='copy' then
    if #f.inputs~=1 or #f.outputs<2 then return false,prefix..'copy must consume one occurrence and produce at least two' end
    for _,o in ipairs(f.outputs) do if not same_boundary(m,f.inputs[1],o) then return false,prefix..'copy outputs must preserve occurrence identity boundary' end end
  elseif k=='discard' then
    if #f.inputs~=1 or #f.outputs~=0 then return false,prefix..'discard must consume exactly one occurrence and produce none' end
  elseif k=='admission' then
    if #f.inputs~=0 or #f.outputs~=1 then return false,prefix..'admission must produce exactly one occurrence from no authority input' end
  else
    if #f.inputs>0 and #f.outputs==0 then return false,prefix..'authority discard requires explicit discard operation' end
    for i=1,#f.outputs do
      local copies=0
      for j=1,#f.outputs do if same_boundary(m,f.outputs[i],f.outputs[j]) then copies=copies+1 end end
      if copies>1 then return false,prefix..'structural duplication requires explicit copy operation' end
    end
  end
  return true
end

function A.check(m)
  for _,s in ipairs(actual_strands(m)) do
    local ps=A.producer(m,s); if #ps>1 then return false,string.format('provenance: %s has %d producers',s.id,#ps) end
    local cs=A.consumers(m,s); if #cs>1 then return false,string.format('scarcity: %s has %d consumers',s.id,#cs) end
  end
  local af,as=actual_faces(m),actual_strands(m)
  if causal_cycle(af,as) then return false,'causality: realised incidence contains a cycle' end
  for _,f in ipairs(af) do local ok,why=check_structural_face(m,f); if not ok then return false,why end end
  return true
end

function A.check_stage(m,gate)
  if not (gate and gate.dim==1 and m:is_suspended(gate)) then return false,'stage gate must be suspended Strand' end
  local component=m:_stage_component(gate)
  if not m:_is_open_input(gate,component) then return false,'stage gate is not an open input' end
  local faces,strands={},{}
  for c,_ in pairs(component) do if c.dim==2 then faces[#faces+1]=c elseif c.dim==1 then strands[#strands+1]=c end end
  if causal_cycle(faces,strands) then return false,'suspended causality: stage incidence contains a cycle' end
  local function parents_as(kind,s)
    local xs={}; for _,f in ipairs(faces) do local arr=(kind=='producer') and f.outputs or f.inputs; for _,x in ipairs(arr) do if x==s then xs[#xs+1]=f end end end; return xs
  end
  for _,s in ipairs(strands) do
    if #parents_as('producer',s)>1 then return false,'suspended provenance: '..s.id..' has multiple producers' end
    if #parents_as('consumer',s)>1 then return false,'suspended scarcity: '..s.id..' has multiple consumers' end
  end
  for _,f in ipairs(faces) do local ok,why=check_structural_face(m,f,'suspended '); if not ok then return false,why end end
  return true
end

-- Publication-strength provenance: every realised authority occurrence has one
-- producer.  Initial authority is an explicit admission event.
function A.check_provenance(m)
  for _,s in ipairs(actual_strands(m)) do
    local ps=A.producer(m,s)
    if #ps~=1 then return false,string.format('provenance: %s has %d producers; actual authority requires exactly one producer or explicit admission',s.id,#ps) end
    local p=ps[1]
    if m:structural_kind(p)=='admission' then
      if #p.inputs~=0 or #p.outputs~=1 or p.outputs[1]~=s then return false,'provenance: malformed admission' end
      if p.world~=s.world then return false,'provenance: admission and admitted Strand must share a World' end
    end
  end
  return true
end

function A.check_certified(m)
  local ok,why=A.check(m); if not ok then return false,why end
  return A.check_provenance(m)
end

return A
