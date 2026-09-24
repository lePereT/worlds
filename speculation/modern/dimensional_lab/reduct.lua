-- Minimal self-contained dimensional-lab reduct.
--
-- This is intentionally not a kernel proposal.  It supplies only the exact
-- occurrence/scope lowering used by the cross-domain laboratory so that this
-- quarantined folder does not depend on the separate boundary_reduct branch.
local W=require('worlds')
local R={}

local function clone_membranes(g,b)
  local map={}
  local function clone(m)
    if not m then return nil end
    if map[m] then return map[m] end
    local p=W.parent(m); local x=b:membrane(p and clone(p) or nil,'L:'..tostring(W.name(m) or '?')); map[m]=x; return x
  end
  for _,m in ipairs(g:membranes()) do clone(m) end
  return map
end

local function lower(g,full)
  local b=W.builder(); local rmem=clone_membranes(g,b)
  local carrier_point,struct_point,face_point={},{},{}
  local scope_arc,in_arc,out_arc,face_cell={},{},{},{}
  local function Ps(s)
    local p=carrier_point[s]
    if not p then p=b:point(rmem[W.membrane(s)],'strand:'..tostring(W.name(s) or '?')); carrier_point[s]=p end
    return p
  end
  local function Pq(q)
    local p=struct_point[q]
    if not p then p=b:point(rmem[W.membrane(q)],'point:'..tostring(W.name(q) or '?')); struct_point[q]=p end
    return p
  end
  local function Pf(f)
    local p=face_point[f]
    if not p then p=b:point(rmem[W.membrane(f)],'face:'..tostring(W.name(f) or '?')); face_point[f]=p end
    return p
  end
  local selected={}
  for _,s in ipairs(g:strands()) do if full or g:is_input(s) or g:is_terminal(s) then selected[s]=true; Ps(s) end end
  if full then for _,f in ipairs(g:faces()) do Pf(f); face_cell[f]=b:strand(rmem[W.membrane(f)],{Pf(f)},'face-cell:'..tostring(W.name(f) or '?')) end end
  for s in pairs(selected) do
    local row={Ps(s)}; for _,q in ipairs(W.points(s)) do row[#row+1]=Pq(q) end
    scope_arc[s]=b:strand(rmem[W.membrane(s)],row,'scope:'..tostring(W.name(s) or '?'))
    local c=g:consumer(s); if c then in_arc[s]=b:strand(rmem[W.membrane(s)],{Ps(s),Pf(c)},'in:'..tostring(W.name(s) or '?')) end
    local p=g:producer(s); if p then out_arc[s]=b:strand(rmem[W.membrane(s)],{Pf(p),Ps(s)},'out:'..tostring(W.name(s) or '?')) end
  end
  return {source=g,world=b:finish(),membrane=rmem,port_point=carrier_point,carrier_point=carrier_point,
          struct_point=struct_point,face_point=face_point,scope_arc=scope_arc,in_arc=in_arc,out_arc=out_arc,face_cell=face_cell}
end
function R.reduce(g) return lower(g,false) end
function R.reduce_full(g) return lower(g,true) end
return R
