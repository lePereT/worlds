-- Thin native Worlds 0.6.0 harness for speculative experiments.
-- It deliberately uses only the public 0.6 Worlds/Question APIs; this is not
-- the release compatibility layer and carries no semantic authority.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local S={W=W}

local G={builder=W.builder,parent=W.parent,membrane=W.membrane,points=W.points,inputs=W.inputs,outputs=W.outputs,name=W.name}
function G.is_point(x) return W.kind(x)=='point' end
function G.is_strand(x) return W.kind(x)=='strand' end
function G.is_membrane(x) return W.kind(x)=='membrane' end
function G.is_face(x) return W.kind(x)=='face' end
function G.is_geometry(x) return W.is_geometry(x) end
S.G=G

local function categorise(g,flat)
  local x={membranes={},points={},strands={},faces={}}
  for _,m in ipairs(g:membranes()) do x.membranes[m]=flat[m] end
  for _,p in ipairs(g:points()) do x.points[p]=flat[p] end
  for _,s in ipairs(g:strands()) do x.strands[s]=flat[s] end
  for _,f in ipairs(g:faces()) do x.faces[f]=flat[f] end
  return x
end
S.categorise=categorise

function S.decided(q,budget)
  while true do local k,x=q:step(budget or math.huge); if k~='more' then return k,x end end
end

function S.seeds(strands)
  local es={}
  for demand,offer in pairs(strands or {}) do es[#es+1]={from=offer,to=demand} end
  return es
end

local function question(world,pattern,opts)
  opts=opts or {}
  local spec={seeds=S.seeds(opts.strands)}
  if opts.offers then spec.sources=opts.offers end
  return Query.solve(Query.new(world,pattern,spec))
end

function S.solve_all(world,pattern,opts,budget)
  local q=question(world,pattern,opts)
  local out={}
  while true do
    local k,x=q:step(budget or math.huge)
    if k=='yes' then out[#out+1]=x
    elseif k=='done' then return out,'done',x
    elseif k=='no' then return out,'no',x
    end
  end
end

function S.solve_one(world,pattern,opts,budget)
  local q=question(world,pattern,opts)
  while true do
    local k,x=q:step(budget or math.huge)
    if k=='yes' then return x
    elseif k=='done' or k=='no' then return nil,k,x end
  end
end

function S.preview(world,pattern,eqs)
  return W.join({W.boundary(world),pattern},eqs)
end

function S.advance(world,pattern,eqs)
  return W.advance(world,pattern,eqs)
end

-- Mutable boundary wrapper retained only to minimise noise in the historical
-- speculation scripts. Every operation delegates to the native 0.6 kernel.
local Boundary={}; Boundary.__index=Boundary
function Boundary:contains(s) return self.geom:owns_strand(s) and self.geom:is_terminal(s) end
function Boundary:size() return #self.geom:egress() end
function Boundary:offers() return self.geom:egress() end

local Witness={}; Witness.__index=Witness
function Witness:_preview()
  if not self.joined then self.joined,self.flat=W.join({self.boundary.geom,self.pattern},self.equations) end
  return self.joined,self.flat
end
function Witness:strand(demand)
  for _,e in ipairs(self.equations) do if e.to==demand then return e.from end end
  local _,flat=self:_preview(); return flat[demand]
end
function Witness:membrane(m) local _,flat=self:_preview(); return flat[m] end
function Witness:point(p) local _,flat=self:_preview(); return flat[p] end
function Witness:cut()
  local xs={}; for _,e in ipairs(self.equations) do xs[#xs+1]=e.to end
  return {closed_inputs=function() return xs end}
end

local O={}
function O.from_geometry(g) return setmetatable({geom=W.boundary(g)},Boundary) end
function O.one(boundary,pattern,opts,budget)
  local es=S.solve_one(boundary.geom,pattern,opts,budget); if not es then return nil end
  return setmetatable({boundary=boundary,pattern=pattern,equations=es},Witness)
end
function O.all(boundary,pattern,opts,budget)
  local all=S.solve_all(boundary.geom,pattern,opts,budget); local out={}
  for _,es in ipairs(all) do out[#out+1]=setmetatable({boundary=boundary,pattern=pattern,equations=es},Witness) end
  return out
end
function O.commit(w)
  local nextg,flat=W.advance(w.boundary.geom,w.pattern,w.equations); w.boundary.geom=nextg
  return w.boundary,categorise(w.pattern,flat)
end
S.O=O

local A={}
function A.close(parts,links)
  local es={}; for _,e in ipairs(links or {}) do es[#es+1]={from=e.from or e.left or e[1],to=e.to or e.right or e[2]} end
  local g,flat=W.join(parts,es); local imgs={}; for i,p in ipairs(parts) do imgs[i]=categorise(p,flat) end
  return g,imgs
end
function A.tensor(parts) return A.close(parts,{}) end
function A.cut(left,right,links)
  local g,img=A.close({left,right},links); return g,{left=img[1],right=img[2]}
end
S.A=A

return S
