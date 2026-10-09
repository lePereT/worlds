-- Finite exact authority-boundary quotient for recursive viability.
-- This is Judgement evidence, not a new semantic IR.  It retains the complete
-- two-sided open authority support, public port markings and causal reachability,
-- while forgetting closed interior history.
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local G=require('speculation.relay.computation.development_calculus.geometry')
local Template=require('speculation.relay.computation.recursive_judgement.template')
local M={}

local function open_sets(g)
  g=G.normal(g)
 local producer,consumer={},{}
  for _,f in ipairs(g.faces) do
    for _,s in ipairs(f.outputs) do producer[s]=true end
    for _,s in ipairs(f.inputs) do consumer[s]=true end
  end
  local ins,outs={},{ }
  for i=1,#g.strands do if not producer[i] then ins[#ins+1]=i end
 if not consumer[i] then outs[#outs+1]=i end end
  return ins,outs
end

local function exact_cover(marked,open,label)
  local count={}
 for _,x in ipairs(marked or {}) do count[x]=(count[x] or 0)+1 end
  local open_set={}
 for _,x in ipairs(open) do open_set[x]=true end
  for x,n in pairs(count) do if not open_set[x] or n~=1 then return false,label..' is not a one-to-one presentation of the exact open boundary' end end
  for _,x in ipairs(open) do if count[x]~=1 then return false,label..' omits exact open authority' end end
  return true
end

function M.complete(template)
  local t=Template.normal(template)
 local ins,outs=open_sets(t.geometry)
  local a,why=exact_cover(t.authority.inputs,ins,'authority inputs')
 if not a then return false,why end
  return exact_cover(t.authority.outputs,outs,'authority outputs')
end
function M.assert_complete(template)
  local ok,why=M.complete(template)
 assert(ok,why)
 return Template.normal(template)
end

local function reachability(g)
  g=G.normal(g)
 local n=#g.strands
 local r={}
  for i=1,n do r[i]={}
 r[i][i]=true end
  for _,f in ipairs(g.faces) do for _,a in ipairs(f.inputs) do for _,b in ipairs(f.outputs) do r[a][b]=true end end end
  for k=1,n do for i=1,n do if r[i][k] then for j=1,n do if r[k][j] then r[i][j]=true end end end end end
  return r
end

local function boundary_support(t)
  t=M.assert_complete(t)
 local g=t.geometry
 local open_in,open_out=open_sets(g)
  local strands,points,membranes={},{},{}
  local function add_membrane(mi)
    if membranes[mi] then return end
 membranes[mi]=true
 local p=g.membranes[mi].parent
    if p and p~=0 then add_membrane(p) end
  end
  local function add_strand(si)
    if strands[si] then return end
 strands[si]=true
 local s=g.strands[si]
 add_membrane(s.membrane)
    for _,pi in ipairs(s.points) do points[pi]=true
 add_membrane(g.points[pi].membrane) end
  end
  for _,si in ipairs(open_in) do add_strand(si) end
 for _,si in ipairs(open_out) do add_strand(si) end

  local mm,pm,sm={},{},{}
 local sub={membranes={},points={},strands={},faces={}}
  for i=1,#g.membranes do if membranes[i] then mm[i]=#sub.membranes+1
 sub.membranes[#sub.membranes+1]={parent=0} end end
  for i=1,#g.membranes do if membranes[i] then local p=g.membranes[i].parent
 sub.membranes[mm[i]].parent=(p~=0 and mm[p]) or 0 end end
  for i=1,#g.points do if points[i] then pm[i]=#sub.points+1
 sub.points[#sub.points+1]={membrane=assert(mm[g.points[i].membrane])} end end
  for i=1,#g.strands do if strands[i] then sm[i]=#sub.strands+1
 local ps={}
 for j,pi in ipairs(g.strands[i].points) do ps[j]=assert(pm[pi]) end
    sub.strands[#sub.strands+1]={membrane=assert(mm[g.strands[i].membrane]),points=ps} end end
  local auth={inputs={},outputs={}}
  for i,si in ipairs(t.authority.inputs) do auth.inputs[i]=assert(sm[si]) end
  for i,si in ipairs(t.authority.outputs) do auth.outputs[i]=assert(sm[si]) end
  local cg,ca,cmap=G.canonical(sub,auth)
  local orig_to_can={}
 for si,subi in pairs(sm) do orig_to_can[si]=assert(cmap.S[subi]) end
  local point_to_can={}
 for pi,subi in pairs(pm) do point_to_can[pi]=assert(cmap.P[subi]) end
  local cin,cout={},{}
 for _,si in ipairs(open_in) do cin[#cin+1]=orig_to_can[si] end
 for _,si in ipairs(open_out) do cout[#cout+1]=orig_to_can[si] end
  table.sort(cin)
 table.sort(cout)
  return cg,ca,{inputs=cin,outputs=cout},orig_to_can,point_to_can
end

function M.profile(template)
  local t=M.assert_complete(template)
 local support,authority,open,omap=boundary_support(t)
 local r=reachability(t.geometry)
 local causal={}
  local in_orig,out_orig={},{ }
  for si,ci in pairs(omap) do
    for _,x in ipairs(open.inputs) do if x==ci then in_orig[ci]=si end end
    for _,x in ipairs(open.outputs) do if x==ci then out_orig[ci]=si end end
  end
  for i,ci in ipairs(open.inputs) do local row={}
 causal[i]=row
 local si=assert(in_orig[ci])
    for j,co in ipairs(open.outputs) do row[j]=not not r[si][assert(out_orig[co])] end end
  return {support=support,authority=authority,open=open,causal=causal}
end

function M.point_coordinates(template)
  local _,_,_,_,points=boundary_support(Template.normal(template))
 local out={}
  for p,i in pairs(points) do out[p]='a'..tostring(i) end
  return out
end

function M.key(template) return Canonical.encode(M.profile(template)) end
function M.equal(a,b) return M.key(a)==M.key(b) end

return M
