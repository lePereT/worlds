-- Exhaustive/set-theoretic reference semantics for pointed residuals.
--
-- This module is deliberately not public. It independently derives a residual
-- cut from the *set* of completed generated Faces rather than replaying the
-- production exact Cut transition. Tests use it as an oracle.

local Internal=require('worlds.internal')
local Topology=require('worlds.topology')
local Att=require('worlds.att')
local Ref={}

local function assertf(ok,fmt,...)
  if not ok then error(string.format(fmt,...),3) end
end
local function sorted(set)
  local xs={}; for x in pairs(set or {}) do xs[#xs+1]=x end
  table.sort(xs,function(a,b) return a.serial<b.serial end); return xs
end
local function serials(xs)
  local out={}; for i,x in ipairs(xs) do out[i]=tostring(x.serial) end; return table.concat(out,',')
end

local function derive(m,witness)
  assertf(Att.is_witness(witness),'reference residual expects Att Witness')
  local ok,why=witness:valid(); assertf(ok,'reference residual requires current Witness: %s',tostring(why))
  local im=Internal.model(m); local patch=witness:patch(); local p=Topology.patch(im,patch:seed())
  local faces,fset={},{}
  for c in pairs(p.component) do
    local root=im:_susp_root(c.world)
    if c.dim==2 and root and p.generated_roots[root] then faces[#faces+1]=c; fset[c]=true end
  end
  table.sort(faces,function(a,b) return a.serial<b.serial end)
  local producer,consumer,strands={},{},{}
  for _,f in ipairs(faces) do
    for _,s in ipairs(f.inputs) do
      strands[s]=true
      assertf(not consumer[s] or consumer[s]==f,'reference patch has multiple suspended consumers')
      consumer[s]=f
    end
    for _,s in ipairs(f.outputs) do
      strands[s]=true
      assertf(not producer[s] or producer[s]==f,'reference patch has multiple suspended producers')
      producer[s]=f
    end
  end
  return {im=im,patch=patch,faces=faces,fset=fset,producer=producer,consumer=consumer,strands=strands,witness=witness}
end

local function completed_set(info,completed)
  local done={}
  for i,f in ipairs(completed or {}) do
    assertf(info.fset[f],'completed Face %d is outside patch',i)
    assertf(not done[f],'completed Face %d repeated',i)
    done[f]=true
  end
  -- Causal closure is checked structurally, independent of traversal order.
  for f in pairs(done) do
    for _,s in ipairs(f.inputs) do
      local p=info.producer[s]
      assertf(not p or done[p],'completed set is not causally closed')
    end
  end
  return done
end

local function state_from_info(info,completed)
  local done=completed_set(info,completed)
  local live={}
  for s in pairs(info.strands) do
    local produced=(info.producer[s]==nil or done[info.producer[s]])
    local consumed=(info.consumer[s]~=nil and done[info.consumer[s]])
    if produced and not consumed then live[s]=true end
  end
  local enabled={}
  for _,f in ipairs(info.faces) do
    if not done[f] then
      local yes=true
      for _,s in ipairs(f.inputs) do if not live[s] then yes=false; break end end
      if yes then enabled[#enabled+1]=f end
    end
  end
  local ds=sorted(done); local ls=sorted(live)
  return {
    completed=ds,live=ls,enabled=enabled,
    signature='D{'..serials(ds)..'}|L{'..serials(ls)..'}',
  }
end

function Ref.state(m,witness,completed)
  return state_from_info(derive(m,witness),completed)
end

function Ref.reachable(m,witness)
  local info=derive(m,witness)
  local seen,out={},{}
  local function visit(completed)
    local st=state_from_info(info,completed)
    if seen[st.signature] then return end
    seen[st.signature]=true; out[#out+1]=st
    for _,f in ipairs(st.enabled) do
      local next={}; for i,x in ipairs(st.completed) do next[i]=x end; next[#next+1]=f
      visit(next)
    end
  end
  visit({})
  table.sort(out,function(a,b) return a.signature<b.signature end)
  return out
end

return Ref
