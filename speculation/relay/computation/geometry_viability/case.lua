-- One finite recursive-viability case: exact authority-boundary behaviour paired
-- with positive occurrence-relative boundary knowledge.  The representative remains
-- an ordinary completed relative Development; only the key is a Judgement quotient.
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local A=require('speculation.relay.computation.geometry_viability.authority')
local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local Template=require('speculation.relay.computation.recursive_judgement.template')
local M={}

local function copy(xs) local out={}
 for i,x in ipairs(xs or {}) do out[i]=x end
 return out end
local function by_point(k) local out={}
 for _,c in ipairs(K.normal(k).ctx) do out[c.point]=c end
 return out end

function M.public_knowledge(template)
  local t=Template.normal(template)
 local k=K.from_spec(t.theory)
 local by=by_point(k)
 local target,src={},{ }
  for i,p in ipairs(t.values.inputs) do local c=assert(by[p],'public value Point lacks knowledge domain')
 target[#target+1]={point='i'..i,sort=c.sort,values=copy(c.values)}
 src[#src+1]=p end
  for i,p in ipairs(t.values.outputs) do local c=assert(by[p],'public value Point lacks knowledge domain')
 target[#target+1]={point='o'..i,sort=c.sort,values=copy(c.values)}
 src[#src+1]=p end
  return K.select(k,src,target)
end

function M.boundary_knowledge(template)
  local t=Template.normal(template)
 local k=K.from_spec(t.theory)
 local by=by_point(k)
 local names=A.point_coordinates(t)
 local nextv=0
  local function name(p)
    if names[p] then return names[p] end
    nextv=nextv+1
 names[p]='v'..nextv
 return names[p]
  end
  -- Interface order gives a canonical name to value-only Points; aliases share it.
  for _,p in ipairs(t.values.inputs) do name(p) end
 for _,p in ipairs(t.values.outputs) do name(p) end
  local rows={}
 for p,n in pairs(names) do if by[p] then rows[#rows+1]={old=p,name=n,c=by[p]} end end
  table.sort(rows,function(a,b) return a.name<b.name end)
  local ctx,map={},{ }
  for _,r in ipairs(rows) do ctx[#ctx+1]={point=r.name,sort=r.c.sort,values=copy(r.c.values)}
 map[r.old]=r.name end
  return K.rename(k,map,ctx),names
end

function M.spec(template)
  local t=Template.normal(template)
 local knowledge,names=M.boundary_knowledge(t)
 local vin,vout={},{}
  for i,p in ipairs(t.values.inputs) do vin[i]=assert(names[p]) end
 for i,p in ipairs(t.values.outputs) do vout[i]=assert(names[p]) end
  return {authority=A.profile(t),knowledge=K.spec(knowledge),values={inputs=vin,outputs=vout}}
end
function M.knowledge(template) return M.boundary_knowledge(template) end
function M.key(template) return Canonical.encode(M.spec(template)) end
function M.template_key(template) return Canonical.encode(Template.normal(template)) end
function M.new(template) local t=Template.normal(template)
 return {key=M.key(t),spec=M.spec(t),representative=t,template_key=M.template_key(t)} end
return M
