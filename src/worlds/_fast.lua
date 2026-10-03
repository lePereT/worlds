-- Disposable exact fast paths for Worlds.
--
-- This module is not part of the geometric centre.  Every operation either
-- returns an exact result obtained by the centre's own construction rules, or
-- returns 'fallback' and lets the caller use the reference path.
local Persistent=require('worlds._persistent')
local EMPTY={}
local INSTANCES=setmetatable({}, {__mode='k'})

return function(K)
local hit=INSTANCES[K]; if hit then return hit end
local M={}

local function boundary_subset(frame,sources)
  local fs=K.geometry(frame); local ms,ps,ss={},{},{}; local mset,pset,sset={},{},{}
  local function addm(m)
    if not(m and fs.mset[m]) or mset[m] then return end
    addm(K.parent(m)); mset[m]=true; ms[#ms+1]=m
  end
  for _,s in ipairs(sources) do if not sset[s] then
    sset[s]=true; ss[#ss+1]=s; addm(K.place(s))
    for _,p in ipairs(K.points(s)) do if fs.pset[p] and not pset[p] then
      pset[p]=true; ps[#ps+1]=p; addm(K.place(p))
    end end
  end end
  return K.make_boundary{membranes=ms,points=ps,strands=ss,mset=mset,pset=pset,sset=sset}, {membranes=ms,points=ps,strands=ss,mset=mset,pset=pset,sset=sset}
end

function M.try_frame_join(source,target,equations,source_position)
  local fs,ts=K.geometry(source),K.geometry(target)
  if not fs.boundary_normal or Persistent.length(fs.strands)<64 or not source_position then return nil,'fallback' end
  for _,m in Persistent.iter(ts.membranes) do if fs.mset[m] then return nil,'fallback' end end
  for _,p in Persistent.iter(ts.points) do if fs.pset[p] then return nil,'fallback' end end
  for _,s in Persistent.iter(ts.strands) do if fs.sset[s] then return nil,'fallback' end end
  for _,f in ipairs(ts.faces) do if fs.fset[f] then return nil,'fallback' end end

  local sources,seen={},{}
  for _,e in ipairs(equations or EMPTY) do
    local from,to=e.from or e[1],e.to or e[2]
    if not(fs.sset[from] and fs.consumer[from]==nil and ts.sset[to] and ts.producer[to]==nil) then return nil,'fallback' end
    if not seen[from] then seen[from]=true; sources[#sources+1]=from end
  end
  if #sources>64 or #sources*4>Persistent.length(fs.strands) then return nil,'fallback' end
  local subset,ss=boundary_subset(source,sources)
  for _,s in Persistent.iter(ts.strands) do for _,p in ipairs(K.points(s)) do
    if fs.pset[p] and not ss.pset[p] then return nil,'fallback' end
  end end

  local local_result,image=K.try_join({subset,target},equations)
  if not local_result then return nil,image end
  for _,m in ipairs(ss.membranes) do if image[m]~=m then return nil,'fallback' end end
  for _,p in ipairs(ss.points) do if image[p]~=p then return nil,'fallback' end end
  local ls=K.geometry(local_result)
  local new_m,new_p,new_s={},{},{}
  for _,m in Persistent.iter(ls.membranes) do if not fs.mset[m] then new_m[#new_m+1]=m end end
  for _,p in Persistent.iter(ls.points) do if not fs.pset[p] then new_p[#new_p+1]=p end end
  for _,s in Persistent.iter(ls.strands) do if not fs.sset[s] then new_s[#new_s+1]=s end end

  local membranes=Persistent.sequence_concat(fs.membranes,new_m)
  local points=Persistent.sequence_concat(fs.points,new_p)
  local strands=Persistent.sequence_concat(fs.strands,new_s)
  local mset=Persistent.set_delta(fs.mset,{},new_m,membranes)
  local pset=Persistent.set_delta(fs.pset,{},new_p,points)
  local sset=Persistent.set_delta(fs.sset,{},new_s,strands)

  local new_ingress,added_e={},{}
  for _,s in ipairs(new_s) do
    if ls.producer[s]==nil then new_ingress[#new_ingress+1]=s end
    if ls.consumer[s]==nil then added_e[#added_e+1]=s end
  end
  local removed_e,removed_pos={},{}
  for _,s in ipairs(sources) do
    local mapped=image[s]
    if mapped==nil or ls.consumer[mapped]~=nil then
      removed_e[#removed_e+1]=s
      local pos=source_position(s); if not pos then return nil,'fallback' end
      removed_pos[#removed_pos+1]=pos
    end
  end
  table.sort(removed_pos)
  local result=K.make_geometry{
    membranes=membranes,points=points,strands=strands,faces=ls.faces,
    mset=mset,pset=pset,sset=sset,fset=ls.fset,
    producer=ls.producer,consumer=ls.consumer,
    ingress=Persistent.sequence_concat(fs.ingress,new_ingress),
    egress=Persistent.sequence_delta(fs.egress,removed_pos,added_e),
    developable=ls.developable,boundary_normal=false,
    frame_base=source,frame_removed_egress=removed_e,frame_added_egress=added_e,
    frame_new_membranes=new_m,frame_new_points=new_p,
  }

  local changed,consumed={},{}
  local function note(x) local y=image[x]; if y==nil then consumed[x]=true elseif y~=x then changed[x]=y end end
  for _,m in ipairs(ss.membranes) do note(m) end; for _,p in ipairs(ss.points) do note(p) end; for _,s in ipairs(ss.strands) do note(s) end
  for _,m in Persistent.iter(ts.membranes) do note(m) end; for _,p in Persistent.iter(ts.points) do note(p) end; for _,s in Persistent.iter(ts.strands) do note(s) end; for _,f in ipairs(ts.faces) do note(f) end
  return result,K.image({source,target},changed,consumed)
end

function M.try_match_join(source,target,equations,source_position)
  local g,image=M.try_frame_join(source,target,equations,source_position)
  if g or image~='fallback' then return g,image end
  return K.try_join({source,target},equations)
end

function M.single_face_delta(frame,target,equations)
  local fs,ts=K.geometry(frame),K.geometry(target)
  if not(fs.boundary_normal and Persistent.length(fs.points)==0 and Persistent.length(ts.points)==0 and Persistent.length(ts.membranes)==1 and #ts.faces==1) then return nil,'fallback' end
  local tm,f=Persistent.get(ts.membranes,1),ts.faces[1]
  if K.parent(tm)~=nil or K.place(f)~=tm then return nil,'fallback' end
  local ins,outs=K.inputs(f),K.outputs(f)
  if #outs==0 or #(equations or EMPTY)~=#ins or Persistent.length(ts.strands)~=#ins+#outs then return nil,'fallback' end

  local inset,outset,to_source,used={},{},{},{}
  for _,x in ipairs(ins) do inset[x]=true; if ts.producer[x]~=nil or ts.consumer[x]~=f or K.place(x)~=tm then return nil,'fallback' end end
  for _,x in ipairs(outs) do outset[x]=true; if ts.producer[x]~=f or ts.consumer[x]~=nil or K.place(x)~=tm then return nil,'fallback' end end
  for _,x in Persistent.iter(ts.strands) do if not inset[x] and not outset[x] then return nil,'fallback' end end

  local home,available={},{ }
  for _,e in ipairs(equations or EMPTY) do
    local from,to=e.from or e[1],e.to or e[2]
    if not(fs.sset[from] and fs.consumer[from]==nil and inset[to]) or used[from] or to_source[to] then return nil,'fallback' end
    local a,b=K.points(from),K.points(to); if #a~=#b then return nil,'fallback' end
    for i=1,#a do if a[i]~=b[i] then return nil,'fallback' end end
    local m=K.place(from); if home[1] and home[1]~=m then return nil,'fallback' end; home[1]=m
    used[from]=true; to_source[to]=from
    for _,p in ipairs(a) do if fs.pset[p] then available[p]=true end end
  end
  local m=home[1]; if not m then return nil,'fallback' end
  for _,x in ipairs(ins) do if not to_source[x] then return nil,'fallback' end end
  for _,x in ipairs(outs) do for _,p in ipairs(K.points(x)) do if fs.pset[p] and not available[p] then return nil,'fallback' end end end

  local changed,mapped_in,mapped_out={}, {}, {}
  changed[tm]=m
  for i,x in ipairs(ins) do mapped_in[i]=to_source[x]; changed[x]=mapped_in[i] end
  for i,x in ipairs(outs) do local y=K.new_strand(m,K.points(x),K.name(x)); mapped_out[i]=y; changed[x]=y end
  changed[f]=K.new_face(m,mapped_in,mapped_out,K.name(f))
  local removed={}; for x in pairs(used) do removed[#removed+1]=x end
  return {removed=removed,added=mapped_out,image=K.image({frame,target},changed,{})}
end

INSTANCES[K]=M
return M
end
