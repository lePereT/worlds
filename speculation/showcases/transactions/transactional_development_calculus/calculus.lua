-- Package-first finite transactional Development calculus.
-- There are no computation closures, continuation callbacks, instructions or live Package state.
local W=require('worlds')
local Q=require('worlds.query')
local Construction=require('worlds.construction')
local G=require('speculation.showcases.transactions.transactional_development_calculus.geometry')
local T=require('speculation.showcases.transactions.transactional_development_calculus.theory')
local Template=require('speculation.showcases.transactions.transactional_development_calculus.template')
local Family=require('speculation.showcases.transactions.transactional_development_calculus.family')
local Package=require('speculation.showcases.transactions.transactional_development_calculus.package')
local M={}

local function copy(xs) local out={} for i,x in ipairs(xs or {}) do out[i]=x end return out end
local function set(xs) local out={} for _,x in ipairs(xs or {}) do out[x]=true end return out end

local function family(p) return Family.new(p:family().items,p:family().edges) end
local function packaged(f) return Package.new(Family.spec(f)) end

function M.atom(template) return Package.new({items={Template.normal(template)},edges={}}) end

function M.always(value)
  return M.atom({geometry=G.empty(),theory={variables={'v'},equalities={T.eq(T.var('v'),value)}},
    authority={inputs={},outputs={}},values={inputs={},outputs={'v'}}})
end

function M.identity_value()
  return M.atom({geometry=G.empty(),theory={variables={'x','y'},equalities={T.eq(T.var('x'),T.var('y'))}},
    authority={inputs={},outputs={}},values={inputs={'x'},outputs={'y'}}})
end

function M.operation(input_count,output_count,value_inputs,value_outputs,theory)
  local geometry,ports=G.operation(input_count,output_count)
  return M.atom({geometry=geometry,theory=theory or {variables={},equalities={}},
    authority={inputs=ports.inputs,outputs=ports.outputs},
    values={inputs=value_inputs or {},outputs=value_outputs or {}}})
end

function M.or_(a,b) return packaged(Family.or_(family(a),family(b))) end
function M.or_else(a,b) return packaged(Family.or_else(family(a),family(b))) end

local function combine_theory(parts,external_inputs,external_outputs,extra_equalities)
  local variables,equalities={},{}
  local seen={}
  for _,p in ipairs(parts) do
    for _,v in ipairs(p.theory.variables) do if not seen[v] then seen[v]=true
 variables[#variables+1]=v end end
    for _,e in ipairs(p.theory.equalities) do equalities[#equalities+1]=T.eq(e.a,e.b) end
  end
  for _,e in ipairs(extra_equalities or {}) do equalities[#equalities+1]=e end
  local keep={}
  for _,v in ipairs(external_inputs) do keep[v]=true end
  for _,v in ipairs(external_outputs) do keep[v]=true end
  return T.normal({variables=variables,equalities=equalities},keep)
end

local function renamed_parts(xs)
  local out={}
  for i,x in ipairs(xs) do out[i]=Template.rename_values(x,'p'..i..'.') end
  return out
end

local function compose_geometry(parts,captures)
  local gs={}
  for i,p in ipairs(parts) do gs[i]=p.geometry end
  return G.compose(gs,captures)
end

local function map_authority(parts,images,captured_inputs,captured_outputs)
  local inputs,outputs={},{}
  for pi,p in ipairs(parts) do
    local cin=captured_inputs[pi] or {}
    local cout=captured_outputs[pi] or {}
    for i,si in ipairs(p.authority.inputs) do if not cin[i] then
      local y=images[pi].strands[si]
 if y then inputs[#inputs+1]=y end
    end end
    for i,si in ipairs(p.authority.outputs) do if not cout[i] then
      local y=images[pi].strands[si]
 if y then outputs[#outputs+1]=y end
    end end
  end
  return inputs,outputs
end

local function compose_bind_pair(left,right,spec)
  local parts=renamed_parts({left,right})
  local L,R=parts[1],parts[2]
  local value_pairs=spec.value_pairs or {{from=1,to=1}}
  local captures=spec.captures or {}
  local geqs={}
  local cin,cout={[1]={},[2]={}},{[1]={},[2]={}}
  for _,e in ipairs(captures) do
    assert(L.authority.outputs[e.from] and R.authority.inputs[e.to],'bad bind authority capture')
    geqs[#geqs+1]={from={part=1,strand=L.authority.outputs[e.from]},
      to={part=2,strand=R.authority.inputs[e.to]}}
    cout[1][e.from]=true
 cin[2][e.to]=true
  end
  local geometry,images=compose_geometry(parts,geqs)
  local ain,aout=map_authority(parts,images,cin,cout)

  local bound_right={}
  local teqs={}
  for _,e in ipairs(value_pairs) do
    assert(L.values.outputs[e.from] and R.values.inputs[e.to],'bad bind value pair')
    teqs[#teqs+1]=T.eq(T.var(L.values.outputs[e.from]),T.var(R.values.inputs[e.to]))
    bound_right[e.to]=true
  end
  local vin={}
  for _,v in ipairs(L.values.inputs) do vin[#vin+1]=v end
  for i,v in ipairs(R.values.inputs) do if not bound_right[i] then vin[#vin+1]=v end end
  local vout=copy(R.values.outputs)
  local theory=combine_theory(parts,vin,vout,teqs)
  if not theory then return nil end
  return Template.normal({geometry=geometry,theory=theory,authority={inputs=ain,outputs=aout},
    values={inputs=vin,outputs=vout}})
end

local function child_family_for(left,right_family,spec)
  local items,old_to_new={},{}
  for i,r in ipairs(right_family.items) do
    local x=compose_bind_pair(left,r,spec)
    if x then old_to_new[i]=#items+1
 items[#items+1]=x end
  end
  local edges={}
  for _,e in ipairs(right_family.edges) do
    local a,b=old_to_new[e[1]],old_to_new[e[2]]
    if a and b then edges[#edges+1]={a,b} end
  end
  return Family.new(items,edges)
end

-- Dependent composition of separately compiled semantic families.
-- Knowledge binding is Theory equality/projection; authority binding is explicit exact cut.
function M.bind(left,right,spec)
  spec=spec or {}
  local rf=family(right)
  return packaged(Family.bind(family(left),function(l)
    return child_family_for(l,rf,spec)
  end))
end
M.and_then=M.bind

local function compose_tuple(tuple)
  local parts=renamed_parts(tuple)
  local geometry,images=compose_geometry(parts,{})
  local cin,cout={},{}
  for i=1,#parts do cin[i]={}
 cout[i]={} end
  local ain,aout=map_authority(parts,images,cin,cout)
  local vin,vout={},{}
  for _,p in ipairs(parts) do
    for _,v in ipairs(p.values.inputs) do vin[#vin+1]=v end
    for _,v in ipairs(p.values.outputs) do vout[#vout+1]=v end
  end
  local theory=assert(combine_theory(parts,vin,vout,{}))
  return Template.normal({geometry=geometry,theory=theory,authority={inputs=ain,outputs=aout},
    values={inputs=vin,outputs=vout}})
end

function M.each(packages)
  local fs={}
  for i,p in ipairs(packages) do fs[i]=family(p) end
  return packaged(Family.product(fs,function(tuple) return compose_tuple(tuple) end))
end

local function close_tuple(tuple,spec)
  spec=spec or {}
  local parts=renamed_parts(tuple)
  local exact,maps={},{}
  for i,p in ipairs(parts) do exact[i],maps[i]=G.instantiate(p.geometry) end

  local function refs(kind,provided)
    local out={}
    if provided then
      for _,r in ipairs(provided) do
        local p=assert(parts[r.part],'closure reference part outside tuple')
        local ports=kind=='source' and p.authority.outputs or p.authority.inputs
        assert(ports[r.port],'closure reference port outside interface')
        out[#out+1]={part=r.part,port=r.port}
      end
    else
      for pi,p in ipairs(parts) do
        local ports=kind=='source' and p.authority.outputs or p.authority.inputs
        for i=1,#ports do out[#out+1]={part=pi,port=i} end
      end
    end
    return out
  end
  local source_refs=refs('source',spec.sources)
  local target_refs=refs('target',spec.targets)
  local sources,targets={},{}
  for i,r in ipairs(source_refs) do
    sources[i]=maps[r.part].strands[parts[r.part].authority.outputs[r.port]]
  end
  for i,r in ipairs(target_refs) do
    targets[i]=maps[r.part].strands[parts[r.part].authority.inputs[r.port]]
  end
  local function exact_ref(r,kind)
    local p=assert(parts[r.part],'closure reference part outside tuple')
    local ports=kind=='source' and p.authority.outputs or p.authority.inputs
    local si=assert(ports[r.port],'closure reference port outside interface')
    return maps[r.part].strands[si]
  end
  local admissible={}
  if spec.admissible then
    for _,e in ipairs(spec.admissible) do
      assert(e.from.part~=e.to.part,'together cannot close one sibling to itself')
      admissible[#admissible+1]={from=exact_ref(e.from,'source'),to=exact_ref(e.to,'target')}
    end
  else
    for si,sr in ipairs(source_refs) do for ti,tr in ipairs(target_refs) do
      if sr.part~=tr.part then admissible[#admissible+1]={from=sources[si],to=targets[ti]} end
    end end
  end
  local required_targets={}
  local rt=spec.required_targets or target_refs
  for i,r in ipairs(rt) do required_targets[i]=exact_ref(r,'target') end
  local required_sources={}
  for i,r in ipairs(spec.required_sources or {}) do required_sources[i]=exact_ref(r,'source') end
  local qspec={sources=sources,targets=targets,required_targets=required_targets,
    required_sources=required_sources,admissible=admissible}
  local solve=Q.solve(Q.close(exact,qspec))
  local items={}
  while true do
    local tag,eqs=solve:step(math.huge)
    if tag=='yes' then
      local c=Construction.join(exact,eqs)
      local geometry,index=G.symbolize_construction(c,maps)
      local ain,aout={},{}
      for pi,p in ipairs(parts) do
        for _,si in ipairs(p.authority.inputs) do
          local y=c:image(maps[pi].strands[si])
          if y and c:result():is_input(y) then ain[#ain+1]=assert(index.strands[y]) end
        end
        for _,si in ipairs(p.authority.outputs) do
          local y=c:image(maps[pi].strands[si])
          if y and c:result():is_terminal(y) then aout[#aout+1]=assert(index.strands[y]) end
        end
      end
      local vin,vout={},{}
      for _,p in ipairs(parts) do
        for _,v in ipairs(p.values.inputs) do vin[#vin+1]=v end
        for _,v in ipairs(p.values.outputs) do vout[#vout+1]=v end
      end
      local theory=assert(combine_theory(parts,vin,vout,{}))
      items[#items+1]=Template.normal({geometry=geometry,theory=theory,
        authority={inputs=ain,outputs=aout},values={inputs=vin,outputs=vout}})
    elseif tag=='done' or tag=='no' then break
    elseif tag~='more' then error('unexpected Worlds Close result '..tostring(tag)) end
  end
  return Family.new(items,{})
end

function M.together(packages,spec)
  assert(#packages>=2,'together requires sibling packages')
  local fs={}
  for i,p in ipairs(packages) do fs[i]=family(p) end
  local tuples=Family.product(fs,function(tuple) return tuple end)
  return packaged(Family.bind(tuples,function(tuple) return close_tuple(tuple,spec) end))
end

function M.specialize(p,values)
  values=values or {}
  local f=family(p)
  local items,old_to_new={},{}
  for i,a0 in ipairs(f.items) do
    local a=Template.rename_values(a0,'s.')
    local eqs,keep={}, {}
    local remove={}
    for pos,value in pairs(values) do
      local name=assert(a.values.inputs[pos],'specialized value input outside interface')
      eqs[#eqs+1]=T.eq(T.var(name),value)
 remove[pos]=true
    end
    local vin={}
    for pos,name in ipairs(a.values.inputs) do if not remove[pos] then vin[#vin+1]=name
 keep[name]=true end end
    local vout=copy(a.values.outputs)
 for _,name in ipairs(vout) do keep[name]=true end
    local theory=T.substitute(a.theory,eqs,keep)
    if theory then
      old_to_new[i]=#items+1
      items[#items+1]=Template.normal({geometry=a.geometry,theory=theory,authority=a.authority,
        values={inputs=vin,outputs=vout}})
    end
  end
  local edges={}
  for _,e in ipairs(f.edges) do local a,b=old_to_new[e[1]],old_to_new[e[2]]
    if a and b then edges[#edges+1]={a,b} end end
  return packaged(Family.new(items,edges))
end

local function filtered_family(f,keep)
  local items,map={},{}
  for i,x in ipairs(f.items) do if keep[i] then map[i]=#items+1
 items[#items+1]=x end end
  local edges={}
  for _,e in ipairs(f.edges) do local a,b=map[e[1]],map[e[2]]
    if a and b then edges[#edges+1]={a,b} end end
  return Family.new(items,edges),map
end

-- Tiny judgement boundary used only by scarcity/eligibility pressures.
-- Package meaning is already complete before this point.
function M.prepare(state,p,sources)
  assert(W.is_geometry(state),'prepare requires exact live Geometry')
  sources=sources or {}
  local f=family(p)
  local hits,keep={},{ }
  for i,a in ipairs(f.items) do
    local inst=Template.instantiate(a)
    if #inst.values.inputs==0 then
      local seeds={}
      local possible=true
      for j,target in ipairs(inst.authority.inputs) do
        local from=sources[j]
        if not from then possible=false
 break end
        seeds[#seeds+1]={from=from,to=target}
      end
      if possible then
        local ok,c=pcall(Construction.join,{state,inst.geometry},seeds)
        if ok then
          keep[i]=true
 hits[i]={construction=c,rule=inst,result=W.boundary(c:result())}
        end
      end
    end
  end
  local eligible=filtered_family(f,keep)
  local frontier=Family.frontier(eligible)
  if #frontier==0 then return 'Retry',nil end
  if #frontier>1 then return 'Many',eligible end
  local original=nil
  local target_item=eligible.items[frontier[1]]
  for i,x in ipairs(f.items) do if keep[i] and x==target_item then original=i break end end
  return 'Hit',assert(hits[original])
end

function M.family(p) return family(p) end
function M.Package() return Package end
function M.Theory() return T end
function M.Geometry() return G end

return M
