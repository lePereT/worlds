-- Multi-corridor recursive fixtures for hostile abstraction pressures.
--
-- Every corridor has one public loop ingress and one public loop egress.  A
-- single setup Face creates private locality anchors so otherwise-independent
-- corridors may lawfully inhabit the same hidden Membrane without introducing
-- causal reach from one public loop ingress to another corridor's egress.

local W=require('worlds')
local C=require('speculation.extended_theory_lab.common')

local F={}

function F.roles(prefix)
  return C.roles({'INIT','LOOP','DONE'},prefix or 'multi-recursive')
end

local function membrane_at(b,root,cache,path,prefix)
  local parent=root
  local key=''
  for _,part in ipairs(path or {}) do
    key=key..'/'..part
    if not cache[key] then cache[key]=b:membrane(parent,(prefix or 'm')..key) end
    parent=cache[key]
  end
  return parent
end

local function corridor(b,loc,anchor,loop_in,loop_out,done,kind,prefix)
  kind=kind or 'chain1'
  if kind=='chain1' then
    b:face(loc,{anchor,loop_in},{loop_out,done},prefix..'.one')
  elseif kind=='chain2' then
    local mid=b:strand(loc,{},prefix..'.mid')
    b:face(loc,{anchor,loop_in},{mid},prefix..'.a')
    b:face(loc,{mid},{loop_out,done},prefix..'.b')
  elseif kind=='chain3' then
    local a=b:strand(loc,{},prefix..'.a')
    local z=b:strand(loc,{},prefix..'.z')
    b:face(loc,{anchor,loop_in},{a},prefix..'.f1')
    b:face(loc,{a},{z},prefix..'.f2')
    b:face(loc,{z},{loop_out,done},prefix..'.f3')
  elseif kind=='diamond' then
    local a=b:strand(loc,{},prefix..'.a')
    local z=b:strand(loc,{},prefix..'.z')
    local c=b:strand(loc,{},prefix..'.c')
    local d=b:strand(loc,{},prefix..'.d')
    b:face(loc,{anchor,loop_in},{a,z},prefix..'.fork')
    b:face(loc,{a},{c},prefix..'.left')
    b:face(loc,{z},{d},prefix..'.right')
    b:face(loc,{c,d},{loop_out,done},prefix..'.merge')
  else
    error('unknown multi-recursive corridor kind '..tostring(kind))
  end
end

-- paths[i] is the private Membrane path for corridor i, relative to the public
-- root.  Equal paths share the same hidden locality, different paths may share a
-- prefix.  kinds[i] controls only private Face segmentation.
function F.component(paths,kinds,R,prefix)
  prefix=prefix or 'multi'
  R=R or F.roles(prefix)
  local n=#paths
  assert(n>=2,'multi-recursive fixture requires at least two corridors')
  local b=W.builder()
  local root=b:membrane(nil,prefix..'.root')
  local cache={}
  local init=b:strand(root,{R.INIT},prefix..'.init')
  local loop_in,loop_out,done,loc,anchors={},{},{},{},{}
  for i=1,n do
    loc[i]=membrane_at(b,root,cache,paths[i],prefix..'.loc')
    loop_in[i]=b:strand(root,{R.LOOP},prefix..'.loop.'..i..'.in')
    loop_out[i]=b:strand(root,{R.LOOP},prefix..'.loop.'..i..'.out')
    done[i]=b:strand(root,{R.DONE},prefix..'.done.'..i)
    anchors[i]=b:strand(loc[i],{},prefix..'.anchor.'..i)
  end
  b:face(root,{init},anchors,prefix..'.setup')
  for i=1,n do
    corridor(b,loc[i],anchors[i],loop_in[i],loop_out[i],done[i],kinds and kinds[i] or 'chain1',
        prefix..'.corridor.'..i)
  end
  local g=b:finish()
  return {
    geometry=g,root=root,init=init,loop_in=loop_in,loop_out=loop_out,done=done,
    loc=loc,n=n,iface={ingress=loop_in,egress=loop_out},roles=R,
  }
end

function F.feedbacks(mapping)
  local out={}
  for from,to in ipairs(mapping) do out[#out+1]={from=from,to=to} end
  return out
end

function F.equations(S,feedbacks)
  local eqs={}
  for _,e in ipairs(feedbacks) do
    eqs[#eqs+1]={from=S.loop_out[e.from],to=S.loop_in[e.to]}
  end
  return eqs
end

function F.close(S,feedbacks)
  return W.join({S.geometry},F.equations(S,feedbacks))
end

function F.joint_faces(g)
  local out={}
  for _,f in ipairs(g:faces()) do if W.name(f)=='joint' then out[#out+1]=f end end
  return out
end

function F.joint_depths(g)
  local xs={}
  for _,f in ipairs(F.joint_faces(g)) do xs[#xs+1]=C.depth(W.membrane(f)) end
  table.sort(xs)
  return xs
end

function F.same_numbers(a,b)
  if #a~=#b then return false end
  for i=1,#a do if a[i]~=b[i] then return false end end
  return true
end

return F
