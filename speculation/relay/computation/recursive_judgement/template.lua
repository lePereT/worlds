-- Portable relative Development with occurrence-relative positive knowledge.
-- Public values are Points.  Their extensional values live only in Knowledge;
-- relating two value slots never identifies their exact Points.
local G=require('speculation.relay.computation.development_calculus.geometry')
local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local M={}

local function copy(xs) local out={}
 for i,x in ipairs(xs or {}) do out[i]=x end
 return out end
local function knowledge(x) if x==nil then return K.top({}) end
 return K.normal(x) end

local function remap_knowledge(k,pmap)
  k=knowledge(k)
  local ctx={}
 local map={}
  for _,c in ipairs(k.ctx) do
    local np=assert(pmap[c.point],'Theory support Point vanished during alpha-normalisation')
    map[c.point]=np
 ctx[#ctx+1]={point=np,sort=c.sort,values=copy(c.values)}
  end
  table.sort(ctx,function(a,b) return a.point<b.point end)
  return K.rename(k,map,ctx)
end

function M.normal(a)
  assert(type(a)=='table','restrictive relative Development required')
  local geometry=G.normal(a.geometry or G.empty())
  local authority=a.authority or {}
 local ain,aout=copy(authority.inputs),copy(authority.outputs)
  local values=a.values or {}
 local vin,vout=copy(values.inputs),copy(values.outputs)
  local point_marks={}
  local function mark(p,label)
    assert(geometry.points[p],'public value must be a symbolic Point')
    local row=point_marks[p] or {}
 point_marks[p]=row
 row[#row+1]=label
  end
  for i,p in ipairs(vin) do mark(p,'VI'..i) end
  for i,p in ipairs(vout) do mark(p,'VO'..i) end
  local cmap
  geometry,authority,cmap=G.canonical(geometry,{inputs=ain,outputs=aout},point_marks)
  ain,aout=authority.inputs,authority.outputs
  local exact=G.instantiate(geometry)
  for _,si in ipairs(ain) do assert(exact:is_input(exact:strands()[si]),'authority input must be symbolic Geometry ingress') end
  for _,si in ipairs(aout) do assert(exact:is_terminal(exact:strands()[si]),'authority output must be symbolic Geometry egress') end
  local rvin,rvout={},{}
  for i,p in ipairs(vin) do rvin[i]=assert(cmap.P[p]) end
  for i,p in ipairs(vout) do rvout[i]=assert(cmap.P[p]) end
  local theory=remap_knowledge(knowledge(a.theory),cmap.P)
  local present={}
 for _,c in ipairs(theory.ctx) do present[c.point]=true end
  for _,p in ipairs(rvin) do assert(present[p],'value input Point lacks Theory domain') end
  for _,p in ipairs(rvout) do assert(present[p],'value output Point lacks Theory domain') end
  return {geometry=geometry,theory=K.spec(theory),authority={inputs=ain,outputs=aout},values={inputs=rvin,outputs=rvout}}
end

function M.knowledge(a) a=M.normal(a)
 return K.from_spec(a.theory) end

function M.instantiate(a)
  a=M.normal(a)
  local geometry,map=G.instantiate(a.geometry)
  local ain,aout,vin,vout={}, {}, {}, {}
  for i,s in ipairs(a.authority.inputs) do ain[i]=map.strands[s] end
  for i,s in ipairs(a.authority.outputs) do aout[i]=map.strands[s] end
  for i,p in ipairs(a.values.inputs) do vin[i]=map.points[p] end
  for i,p in ipairs(a.values.outputs) do vout[i]=map.points[p] end
  local k=K.from_spec(a.theory)
 local point_map,ctx={},{ }
  for _,c in ipairs(k.ctx) do point_map[c.point]=map.points[c.point]
 ctx[#ctx+1]={point=map.points[c.point],sort=c.sort,values=copy(c.values)} end
  local exact_k=K.rename(k,point_map,ctx)
  return {geometry=geometry,theory=exact_k,authority={inputs=ain,outputs=aout},values={inputs=vin,outputs=vout}}
end

function M.requirement(a)
  a=M.normal(a)
 local k=K.from_spec(a.theory)
  local keep,seen={},{}
  local function add(p) if not seen[p] then seen[p]=true
 keep[#keep+1]=p end end
  for _,p in ipairs(a.values.inputs) do add(p) end
  for _,si in ipairs(a.authority.inputs) do for _,p in ipairs(a.geometry.strands[si].points) do
    for _,c in ipairs(k.ctx) do if c.point==p then add(p)
 break end end
  end end
  table.sort(keep)
  return K.exists(k,keep)
end

return M
