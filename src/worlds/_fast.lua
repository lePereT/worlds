-- Disposable exact fast paths.  Every result is a specialisation of strict join.
local Persistent=require('worlds._persistent')
local EMPTY={}
return function(K)
local M={}
local ONE_FACE=setmetatable({}, {__mode='k'})
local function boundary_subset(frame,sources)
  local fs=K.geometry(frame)
  local membranes,points_,strands_={},{},{}
  local mset,pset,sset={},{},{}
  local function addm(m)
    if not(m and fs.mset[m]) or mset[m] then return end
    addm(K.parent(m))
    mset[m]=true
    membranes[#membranes+1]=m
  end
  for _,s in ipairs(sources) do if not sset[s] then
    sset[s]=true
    strands_[#strands_+1]=s
    addm(K.place(s))
    for _,p in ipairs(K.points(s)) do if fs.pset[p] and not pset[p] then pset[p]=true
    points_[#points_+1]=p
    addm(K.place(p)) end end
  end end
  local data={membranes=membranes,points=points_,strands=strands_,faces=EMPTY,mset=mset,
      pset=pset,sset=sset,fset=EMPTY,producer=EMPTY,consumer=EMPTY,ingress=strands_,
          egress=strands_,developable=true,boundary={},boundary_normal=true}
  return K.value(data),data
end

local function frame_match_join(source,target,equations,source_position,want_provenance)
  local fs,ts=K.geometry(source),K.geometry(target)
  if not fs.boundary_normal or Persistent.length(fs.strands)<64 or not source_position then
    return nil,'fallback'
  end
  -- Full parts must still be disjoint, checking the small development against
  -- frame membership is sufficient.
  for _,m in Persistent.iter(ts.membranes) do if fs.mset[m] then return nil,'fallback' end end
  for _,p in Persistent.iter(ts.points) do if fs.pset[p] then return nil,'fallback' end end
  for _,s in Persistent.iter(ts.strands) do if fs.sset[s] then return nil,'fallback' end end
  for _,f in ipairs(ts.faces) do if fs.fset[f] then return nil,'fallback' end end

  local sources,source_seen={},{ }
  for _,e in ipairs(equations or EMPTY) do
    local from,to=e.from or e[1],e.to or e[2]
    if not(fs.sset[from] and fs.consumer[from]==nil and ts.sset[to] and ts.producer[to]==nil)
        then return nil,'fallback' end
    if not source_seen[from] then source_seen[from]=true
    sources[#sources+1]=from end
  end
  -- Decide locality before asking the disposable boundary index for ordinals.
  -- Broad matches therefore pay no frame-position work at all.  Positions are
  -- resolved only after the local quotient tells us which matched sources are
  -- actually consumed, pass-through matched authority remains live.
  if #sources>64 or #sources*4>Persistent.length(fs.strands) then return nil,'fallback' end
  local subset,ss=boundary_subset(source,sources)
  -- If the development mentions an exact frame Point outside the touched source
  -- closure, generic validation must see the whole frame to decide causal use.
  for _,s in Persistent.iter(ts.strands) do for _,p in ipairs(K.points(s)) do if fs.pset[p] and not
      ss.pset[p] then return nil,'fallback' end end end

  local local_result,local_image_or_why,local_provenance=
      K.try_join({subset,target},equations,want_provenance)
  if not local_result then return nil,local_image_or_why end
  -- The frame quotient may only splice untouched authority when the quotient
  -- leaves every touched pre-existing structural coordinate exact-self.  If a
  -- source Membrane or Point is identified/consumed, untouched strands sharing
  -- that coordinate would also change and the local subset is insufficient.
  for _,m in ipairs(ss.membranes) do if local_image_or_why[m]~=m then return nil,'fallback' end end
  for _,p in ipairs(ss.points) do if local_image_or_why[p]~=p then return nil,'fallback' end end
  local ls=K.geometry(local_result)
  local new_m,new_p,new_s={},{},{}
  for _,m in Persistent.iter(ls.membranes) do if not fs.mset[m] then new_m[#new_m+1]=m end end
  for _,p in Persistent.iter(ls.points) do if not fs.pset[p] then new_p[#new_p+1]=p end end
  for _,s in Persistent.iter(ls.strands) do if not fs.sset[s] then new_s[#new_s+1]=s end end

  -- The exact joined witness shares the unrelated frame.  Only genuinely new
  -- local carriers are appended, membership is a read-only overlay.
  local membranes=Persistent.sequence_concat(fs.membranes,new_m)
  local points_=Persistent.sequence_concat(fs.points,new_p)
  local strands_=Persistent.sequence_concat(fs.strands,new_s)
  local faces_=ls.faces
  local mset=Persistent.set_delta(fs.mset,{},new_m,membranes)
  local pset=Persistent.set_delta(fs.pset,{},new_p,points_)
  local sset=Persistent.set_delta(fs.sset,{},new_s,strands_)
  local fset=ls.fset

  -- A boundary-normal frame has every existing strand on ingress.  Local output
  -- contributes only newly produced ingress/egress, consumed frame egress is
  -- represented by an ordinal delta rather than a complete frontier rebuild.
  local new_ingress,added_e={},{}
  for _,s in ipairs(new_s) do
    if ls.producer[s]==nil then new_ingress[#new_ingress+1]=s end
    if ls.consumer[s]==nil then added_e[#added_e+1]=s end
  end
  local removed_e,removed_positions={},{}
  for _,s in ipairs(sources) do
    local mapped=local_image_or_why[s]
    if mapped==nil or ls.consumer[mapped]~=nil then
      removed_e[#removed_e+1]=s
      local pos=source_position(s)
      if not pos then return nil,'fallback' end
      removed_positions[#removed_positions+1]=pos
    end
  end
  table.sort(removed_positions)
  local ingress=Persistent.sequence_concat(fs.ingress,new_ingress)
  local egress=Persistent.sequence_delta(fs.egress,removed_positions,added_e)
  local data={membranes=membranes,points=points_,strands=strands_,faces=faces_,mset=mset,
      pset=pset,sset=sset,fset=fset,producer=ls.producer,consumer=ls.consumer,ingress=ingress,
          egress=egress,developable=ls.developable,boundary={},boundary_normal=false,
              frame_base=source,frame_removed_egress=removed_e,frame_added_egress=added_e,
                  frame_new_membranes=new_m,frame_new_points=new_p}
  local result=K.value(data)

  local changed,consumed={},{}
  local local_image=local_image_or_why
  local function note(x) local y=local_image[x]
  if y==nil then consumed[x]=true elseif y~=x then changed[x]=y end end
  for _,m in ipairs(ss.membranes) do note(m) end
  for _,p in ipairs(ss.points) do note(p) end
  for _,s in ipairs(ss.strands) do note(s) end
  for _,m in Persistent.iter(ts.membranes) do note(m) end
  for _,p in Persistent.iter(ts.points) do note(p) end
  for _,s in Persistent.iter(ts.strands) do note(s) end
  for _,f in ipairs(ts.faces) do note(f) end
  local prov
  if want_provenance then
    local source_parts={source,target}
    prov={parts=source_parts,result=result,source_class=function(x)
      local k=local_provenance.source_class(x)
      if k~=nil then return k end
      local kind=K.geometry(source)
      if kind.mset[x] or kind.pset[x] or kind.sset[x] or kind.fset[x] then return x end
      return nil
    end}
  end
  return result,K.image({source,target},changed,consumed),prov
end

-- Local-only frame join.  This is the same quotient used by Match, but it
-- deliberately preserves the 'fallback' result instead of broadening to a full
-- join.  Operational advance can therefore attempt locality without paying a
-- second whole-frame construction when the locality preconditions are absent.
M.try_frame_join=function(source,target,equations,source_position,want_provenance)
  return frame_match_join(source,target,equations,source_position,want_provenance)
end

M.try_match_join=function(source,target,equations,source_position,want_provenance)
  local g,image_or_why,prov=M.try_frame_join(source,target,equations,source_position,
      want_provenance)
  if g or image_or_why~='fallback' then return g,image_or_why,prov end
  return K.try_join({source,target},equations,want_provenance)
end

-- A common live step is already in quotient-normal form except for one exact
-- Face: a boundary supplies its open inputs and the Face replaces them with new
-- open outputs.  When the development owns no Points and all output locality is
-- causally available through those inputs, the strict quotient is explicit.
-- Constructing it directly avoids building and then immediately discarding a
-- historical joined Geometry.  Every uncertain shape falls back to generic join.
local function single_face_delta(frame,target,ts,equations)
  local fs=K.geometry(frame)
  if not fs.boundary_normal or Persistent.length(fs.points)~=0 then return nil,'fallback' end
  local tm,f=Persistent.get(ts.membranes,1),ts.faces[1]
  if K.parent(tm)~=nil or K.place(f)~=tm then return nil,'fallback' end
  local ins,outs_=K.inputs(f),K.outputs(f)
  if #outs_==0 or #equations~=#ins or Persistent.length(ts.strands)~=#ins+#outs_ then
    return nil,'fallback'
  end

  local inset,outset,to_source,source_seen={},{},{},{}
  for _,x in ipairs(ins) do inset[x]=true
  if ts.producer[x]~=nil or ts.consumer[x]~=f or K.place(x)~=tm then return nil,'fallback' end end
  for _,x in ipairs(outs_) do outset[x]=true
  if ts.producer[x]~=f or ts.consumer[x]~=nil or K.place(x)~=tm then return nil,'fallback' end end
  for _,x in Persistent.iter(ts.strands) do
    if not inset[x] and not outset[x] then return nil,'fallback' 
      end end

  local source_membrane,available_points
  available_points={}
  for _,e in ipairs(equations) do
    local from,to=e.from or e[1],e.to or e[2]
    if not(fs.sset[from] and fs.consumer[from]==nil and inset[to]) or source_seen[from] or
        to_source[to] then return nil,'fallback' end
    local a,b=K.points(from),K.points(to)
    if #a~=#b then return nil,'fallback' end
    for i=1,#a do if a[i]~=b[i] then return nil,'fallback' end end
    local m=K.place(from)
    if source_membrane and source_membrane~=m then return nil,'fallback' end
    source_membrane=m
    source_seen[from]=true
    to_source[to]=from
    for _,q in ipairs(a) do if fs.pset[q] then available_points[q]=true end end
  end
  if not source_membrane then return nil,'fallback' end
  for _,x in ipairs(ins) do if not to_source[x] then return nil,'fallback' end end
  for _,x in ipairs(outs_) do for _,q in ipairs(K.points(x)) do if fs.pset[q] and not
      available_points[q] then return nil,'fallback' end end end

  local changed,mapped_out={},{}
  changed[tm]=source_membrane
  local mapped_in={}
  for i,x in ipairs(ins) do mapped_in[i]=to_source[x]
  changed[x]=mapped_in[i] end
  for i,x in ipairs(outs_) do local y=K.strand(source_membrane,K.points(x),K.name(x))
  mapped_out[i]=y
  changed[x]=y end
  changed[f]=K.face(source_membrane,mapped_in,mapped_out,K.name(f))

  local removed={}
  for x in pairs(source_seen) do removed[#removed+1]=x end
  return {removed=removed,added=mapped_out,image=K.image({frame,target},changed,{})}
end


function M.single_face_delta(frame,target,equations)
  local ts=K.geometry(target)
  local ok=ONE_FACE[target]
  if ok==nil then
    ok=(Persistent.length(ts.points)==0 and Persistent.length(ts.membranes)==1 and #ts.faces==1)
    ONE_FACE[target]=ok
  end
  if not ok then return nil,'fallback' end
  return single_face_delta(frame,target,ts,equations or EMPTY)
end

return M
end
