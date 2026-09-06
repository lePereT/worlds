-- Fresh exact-Witness grafting for Worlds 0.3.
--
-- Search/possibility is non-generative. This module is the single operation
-- which takes a complete boundary matching and grows actuality with a fresh
-- instance of the generated part of the detached patch.

local Topology=require('worlds.topology')
local topology_patch=assert(Topology.patch)
local topology_generated_roots=assert(Topology.generated_roots)
local G={}

local function assertf(ok,fmt,...)
  if not ok then error(string.format(fmt,...),3) end
end
local function copy_map(t) local o={}; for k,v in pairs(t or {}) do o[k]=v end; return o end

function G.install(M)
  function M:_graft_attachment(seed,locality,bindings)
    assertf(self:_owned(locality,-1) and self:is_realised(locality),'graft locality must be an actual World of this Model')
    assertf(self:_owned(seed) and seed.dim>=0 and self:is_suspended(seed),'graft seed must be suspended geometry of this Model')
    local patch=topology_patch(self,seed)
    assertf(patch.attachable,'detached component is not an attachable open patch')
    local roots=topology_generated_roots(patch)
    assertf(#roots>0,'attachment has no generated World root')

    local tag='$g'..tostring(#self.instances+1)
    local worldmap,map,created,instance_worlds={},{},{},{}
    map=copy_map(bindings)
    local rootset={}; for _,r in ipairs(roots) do rootset[r]=true end

    local function clone_world(w,parent)
      local nw=self:world(w.name..'@'..tag,parent)
      nw.origin=w; worldmap[w]=nw; map[w]=nw; created[#created+1]=nw
      for _,ch in ipairs(self:_children(w)) do clone_world(ch,nw) end
      return nw
    end
    for _,r in ipairs(roots) do instance_worlds[#instance_worlds+1]=clone_world(r,locality) end

    local function in_roots(w)
      while w do if rootset[w] then return true end; w=w.parent end
      return false
    end
    local cells={}
    for _,c in ipairs(self.objects) do
      if c.dim>=0 and in_roots(c.world) then cells[#cells+1]=c end
    end
    table.sort(cells,function(a,b)
      if a.dim~=b.dim then return a.dim<b.dim end
      return a.serial<b.serial
    end)

    local function mapped(d)
      if map[d] then return map[d] end
      if self:is_realised(d) then return d end
      error('unmapped suspended dependency '..tostring(d),2)
    end

    -- Generated identity exists before egress because returned authority may
    -- expose fresh Points to the caller locality.
    for _,c in ipairs(cells) do
      if c.dim==0 then
        local nc=self:point(c.name..'@'..tag,worldmap[c.world],c.sort)
        nc.origin=c; map[c]=nc; created[#created+1]=nc
      end
    end

    local actual_egress={}
    for _,c in ipairs(patch.outputs) do
      local ps={}; for i,p in ipairs(c.points) do ps[i]=mapped(p) end
      local nc=self:strand(c.name..'@'..tag,locality,ps,c.sort)
      nc.origin=c; map[c]=nc; created[#created+1]=nc; actual_egress[#actual_egress+1]=nc
    end

    local actual_faces={}
    for _,c in ipairs(cells) do
      if c.dim~=0 and not (c.dim==1 and map[c]) then
        local nc
        if c.dim==1 then
          local ps={}; for i,p in ipairs(c.points) do ps[i]=mapped(p) end
          nc=self:strand(c.name..'@'..tag,worldmap[c.world],ps,c.sort)
        else
          local ins,outs={},{}
          for i,s in ipairs(c.inputs) do ins[i]=mapped(s) end
          for i,s in ipairs(c.outputs) do outs[i]=mapped(s) end
          if c.structural=='copy' then
            nc=self:copy(c.name..'@'..tag,worldmap[c.world],ins[1],outs,c.sort)
          elseif c.structural=='discard' then
            nc=self:discard(c.name..'@'..tag,worldmap[c.world],ins[1],c.sort)
          else
            nc=self:face(c.name..'@'..tag,worldmap[c.world],ins,outs,c.sort)
          end
          actual_faces[#actual_faces+1]=nc
        end
        nc.origin=c; map[c]=nc; created[#created+1]=nc
      end
    end

    -- Demand cells denote the matched actual boundary, never a cloned copy.
    for d,o in pairs(bindings or {}) do map[d]=map[o] or o end

    local inst={
      patch_seed=seed,locality=locality,map=map,created=created,
      worlds=instance_worlds,egress=actual_egress,faces=actual_faces,
    }
    self.instances[#self.instances+1]=inst
    return inst
  end
end

return G
