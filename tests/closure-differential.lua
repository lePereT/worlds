package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Q=require('worlds.query')

local seed=0x51c0ffee
local function rnd(n) seed=(1103515245*seed+12345)%0x80000000; return (seed%n)+1 end
local function coin() return rnd(2)==1 end
local function decided(q) while true do local k,x=q:step(math.huge); if k~='more' then return k,x end end end

local function part(name,depth)
  local b=W.builder(); local m=b:membrane(nil,name..'.0')
  for i=1,depth do m=b:membrane(m,name..'.'..i) end
  local i=b:strand(m,{},name..'.in'); local o=b:strand(m,{},name..'.out'); b:face(m,{i},{o},name..'.work')
  return b:finish(),i,o
end

local function key(es,sindex,tindex)
  local xs={}; for _,e in ipairs(es) do xs[#xs+1]=sindex[e.from]..'>'..tindex[e.to] end
  table.sort(xs); return table.concat(xs,',')
end

local cases=2000
for case=1,cases do
  local nparts=2+(rnd(2)-1); local parts,ins,outs={},{},{}
  for i=1,nparts do local g,ii,oo=part('c'..case..'p'..i,rnd(3)-1); parts[i]=g; ins[i]=ii; outs[i]=oo end
  local sources,targets={},{}
  for i=1,nparts do if coin() or #sources==0 then sources[#sources+1]=outs[i] end end
  for i=1,nparts do if coin() or #targets==0 then targets[#targets+1]=ins[i] end end
  local sindex,tindex={},{}; for i,x in ipairs(sources) do sindex[x]=i end; for i,x in ipairs(targets) do tindex[x]=i end

  local admissible={}; local allowed={}
  for _,t in ipairs(targets) do allowed[t]={}; for _,s in ipairs(sources) do if rnd(4)~=1 then admissible[#admissible+1]={from=s,to=t}; allowed[t][s]=true end end end
  local required_targets={}; for _,t in ipairs(targets) do if coin() then required_targets[#required_targets+1]=t end end
  local required_sources={}; for _,x in ipairs(sources) do if rnd(4)==1 then required_sources[#required_sources+1]=x end end

  -- Occasionally seed one admissible pair and make its target/source exact.
  local seeds={}
  if #admissible>0 and rnd(4)==1 then
    local e=admissible[rnd(#admissible)]; seeds[1]={from=e.from,to=e.to}
  end

  local spec={sources=sources,targets=targets,required_sources=required_sources,required_targets=required_targets,admissible=admissible,seeds=seeds}
  local got={}; local solve=Q.solve(Q.close(parts,spec))
  while true do
    local tag,x=decided(solve)
    if tag=='yes' then got[key(x,sindex,tindex)]=true
    elseif tag=='done' or tag=='no' then break
    else error('unexpected '..tostring(tag)) end
  end

  local required_set,required_source_set,seed_from,seed_to={},{},{},{}
  for _,x in ipairs(required_sources) do required_source_set[x]=true end
  for _,t in ipairs(required_targets) do required_set[t]=true end
  local base={}
  for _,e in ipairs(seeds) do required_set[e.to]=true; seed_from[e.from]=e.to; seed_to[e.to]=e.from; base[#base+1]={from=e.from,to=e.to} end
  local optional={}; for _,t in ipairs(targets) do if not required_set[t] then optional[#optional+1]=t end end
  local want={}
  local selected={}
  local function candidate()
    local chosen={}; for _,t in ipairs(targets) do
      if required_set[t] then chosen[#chosen+1]=t else for _,x in ipairs(selected) do if x==t then chosen[#chosen+1]=t; break end end end
    end
    local used={}; for s in pairs(seed_from) do used[s]=true end
    local row={}; for i,e in ipairs(base) do row[i]={from=e.from,to=e.to} end
    local function assign(i)
      if i>#chosen then
        local used_required={}; for _,e in ipairs(row) do used_required[e.from]=true end
        for source in pairs(required_source_set) do if not used_required[source] then return end end
        local ok=pcall(function() W.join(parts,row) end)
        if ok then want[key(row,sindex,tindex)]=true end
        return
      end
      local t=chosen[i]; if seed_to[t] then return assign(i+1) end
      for _,s in ipairs(sources) do if not used[s] and allowed[t][s] then
        used[s]=true; row[#row+1]={from=s,to=t}; assign(i+1); row[#row]=nil; used[s]=nil
      end end
    end
    assign(1)
  end
  local function subsets(i)
    if i>#optional then candidate(); return end
    subsets(i+1); selected[#selected+1]=optional[i]; subsets(i+1); selected[#selected]=nil
  end
  subsets(1)

  for k in pairs(got) do assert(want[k],'Close emitted non-oracle witness in case '..case..': '..k) end
  for k in pairs(want) do assert(got[k],'Close missed oracle witness in case '..case..': '..k) end
end
print('PASS closure differential',cases,'cases')
