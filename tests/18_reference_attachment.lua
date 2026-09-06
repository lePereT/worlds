local S=require('tests.support')
local G,A=S.G,S.A
math.randomseed(731991)

local function amap(copy) local r={}; for k,v in pairs(copy or {}) do r[k]=v end; return r end
local function aset(copy) local r={}; for k,v in pairs(copy or {}) do if v then r[k]=true end end; return r end

-- Deliberately exhaustive public-API oracle. It makes no fail-first choices and
-- recomputes complete assignments before checking the membrane/Point equations.
local function reference(base, selected_list, pat)
  local offers=base:offers(selected_list)
  local visible=base:visible_points(selected_list)
  local inputs={}
  for _,s in ipairs(pat:strands()) do if pat:is_input(s) then inputs[#inputs+1]=s end end
  local count=0

  local function try_assignment(smap)
    local mmap,pmap={}, {}
    local function map_mem(pm,gm)
      local p,g=pm,gm
      while p do
        local pc,gc=pat:cell(p),base:cell(g)
        if not gc or pc.sort~=gc.sort then return false end
        if mmap[p] and mmap[p]~=g then return false end
        mmap[p]=g
        p=pc.parent
        if p then g=gc.parent; if not g then return false end end
      end
      return true
    end
    local function bind_point(pp,gp)
      local pc,gc=pat:cell(pp),base:cell(gp)
      if pc.sort~=gc.sort then return false end
      if pmap[pp] then return pmap[pp]==gp end
      if not map_mem(pc.membrane,gc.membrane) then return false end
      pmap[pp]=gp; return true
    end
    for _,ps in ipairs(inputs) do
      local gs=smap[ps]; local pc,gc=pat:cell(ps),base:cell(gs)
      if not map_mem(pc.membrane,gc.membrane) then return end
      for i,pp in ipairs(pc.points) do if not bind_point(pp,gc.points[i]) then return end end
    end

    local demands={}
    for _,pp in ipairs(pat:points()) do
      local pc=pat:cell(pp)
      if mmap[pc.membrane] and not pmap[pp] then demands[#demands+1]=pp end
    end
    local function assign_points(i)
      if i>#demands then
        -- Selection entitlement, stated independently using public geometry.
        local inputset={}; for _,s in ipairs(inputs) do inputset[s]=true end
        local selected=S.set(selected_list)
        for pm,gm in pairs(mmap) do
          if not selected[gm] then
            for _,f in ipairs(pat:faces()) do if pat:cell(f).membrane==pm then return end end
            for _,s in ipairs(pat:strands()) do if pat:cell(s).membrane==pm and not inputset[s] then return end end
            for _,child in ipairs(pat:children(pm)) do if not mmap[child] then return end end
          end
        end
        for _,pm in ipairs(pat:membranes()) do
          if not mmap[pm] then
            local parent=pat:parent(pm)
            if parent and mmap[parent] and not selected[mmap[parent]] then return end
          end
        end
        count=count+1
        return
      end
      local pp=demands[i]; local pc=pat:cell(pp); local need=mmap[pc.membrane]
      for _,gp in ipairs(visible) do
        local gc=base:cell(gp)
        if gc.sort==pc.sort and gc.membrane==need then
          pmap[pp]=gp; assign_points(i+1); pmap[pp]=nil
        end
      end
    end
    assign_points(1)
  end

  local used,smap={},{}
  local function assign_strands(i)
    if i>#inputs then return try_assignment(smap) end
    local ps=inputs[i]; local pc=pat:cell(ps)
    for _,gs in ipairs(offers) do
      local gc=base:cell(gs)
      if not used[gs] and pc.sort==gc.sort and #pc.points==#gc.points then
        used[gs]=true; smap[ps]=gs; assign_strands(i+1); smap[ps]=nil; used[gs]=nil
      end
    end
  end
  assign_strands(1)
  return count
end

local sorts={'R','S'}
for case=1,160 do
  local b=G.builder(); local Root=b:membrane(nil,'place');
  local ms={b:membrane(Root,'place'),b:membrane(Root,'place'),b:membrane(Root,'place')}
  local global=b:point(Root,'G')
  local locals={}; for i=1,3 do locals[i]=b:point(ms[i],'L') end
  for i=1,3 do
    for k=1,2 do
      local pts=(math.random(2)==1) and {global} or {locals[i]}
      b:strand(ms[i],sorts[math.random(#sorts)],pts)
    end
  end
  local base=b:finish()

  local p=G.builder(); local PR=p:membrane(nil,'place')
  local children={p:membrane(PR,'place'),p:membrane(PR,'place')}
  local pg=p:point(PR,'G'); local pl={p:point(children[1],'L'),p:point(children[2],'L')}
  local ninputs=math.random(1,2)
  for i=1,ninputs do
    local child=children[i]
    local pt=(math.random(2)==1) and pg or pl[i]
    local sin=p:strand(child,sorts[math.random(#sorts)],{pt})
    if math.random(2)==1 then
      local sout=p:strand(child,'O'..i,{pt}); p:face(child,'f'..i,{sin},{sout})
    end
  end
  local pat=p:finish()
  local selected={}
  for i=1,3 do if math.random(2)==1 then selected[#selected+1]=ms[i] end end
  if #selected==0 then selected[1]=ms[math.random(3)] end
  local attachments=A.all(base,selected,pat)
  local got=#attachments
  local want=reference(base,selected,pat)
  S.eq(got,want,'reference mismatch case '..case)
  for _,w in ipairs(attachments) do
    local ok,g=pcall(A.glue,w)
    S.ok(ok and g,'gluing invalid after accepted attachment case '..case)
  end
end

print('ok 18_reference_attachment')
