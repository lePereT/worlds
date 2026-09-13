-- Disposable Worlds 0.5 compatibility adapter for Worlds 0.6.0.
-- It executes the authoritative 0.6.0 kernel directly; there is no copied
-- compatibility implementation.
local src=os.getenv('WORLDS_SRC') or 'src/worlds.lua'
local chunk,err=loadfile(src); assert(chunk,err)
local N=chunk()
local Geometry={builder=N.builder,parent=N.parent,membrane=N.membrane,points=N.points,inputs=N.inputs,outputs=N.outputs,name=N.name}
function Geometry.is_point(x) return N.kind(x)=='point' end
function Geometry.is_strand(x) return N.kind(x)=='strand' end
function Geometry.is_membrane(x) return N.kind(x)=='membrane' end
function Geometry.is_face(x) return N.kind(x)=='face' end
function Geometry.is_geometry(x) return N.is_geometry(x) end
local Algebra={}
local function old_images(parts,flat)
  local imgs={}; for i,g in ipairs(parts) do local x={membranes={},points={},strands={},faces={}}; imgs[i]=x; for _,m in ipairs(g:membranes()) do x.membranes[m]=flat[m] end; for _,p in ipairs(g:points()) do x.points[p]=flat[p] end; for _,s in ipairs(g:strands()) do x.strands[s]=flat[s] end; for _,f in ipairs(g:faces()) do x.faces[f]=flat[f] end end; return imgs
end
function Algebra.close(parts,links) local es={}; for _,e in ipairs(links or {}) do es[#es+1]={from=e.from or e.left or e[1],to=e.to or e.right or e[2]} end; local g,flat,meta=N.join(parts,es); return g,old_images(parts,flat),meta end
function Algebra.tensor(parts) local g,flat,meta=N.join(parts,{}); return g,old_images(parts,flat),meta end
function Algebra.cut(left,right,links) local g,img,meta=Algebra.close({left,right},links); return g,{left=img[1],right=img[2]},meta end
local Operational={}
local B={}; B.__index=B
function Operational.from_geometry(g) return setmetatable({geom=g},B) end
function B:contains(s) return self.geom:owns_strand(s) and self.geom:is_terminal(s) end
function B:size() return #self.geom:egress() end
function B:offers() return self.geom:egress() end
local function seeds(ctx) local es={}; for p,w in pairs((ctx and ctx.strands) or {}) do es[#es+1]={from=w,to=p} end; return es end
local function wrap(boundary,pattern,eqs) return {boundary=boundary,pattern=pattern,eqs=eqs} end
function Operational.all(boundary,pattern,ctx,budget)
  local q=N.solve(boundary.geom,pattern,seeds(ctx)); local out={}
  while true do local k,x=q:step(budget or math.huge); if k=='yes' then out[#out+1]=wrap(boundary,pattern,x) elseif k=='done' or k=='no' then return out else return nil,'Unknown',q end end
end
function Operational.one(boundary,pattern,ctx,budget) local xs=Operational.all(boundary,pattern,ctx,budget); return xs and xs[1] or nil end
function Operational.commit(w)
  local parts={w.boundary.geom,w.pattern}; local g,flat=N.join(parts,w.eqs); w.boundary.geom=g
  local full=old_images(parts,flat)[2]; local out={membranes=full.membranes,points=full.points,strands={},faces=full.faces}
  for _,s in ipairs(w.pattern:egress()) do if w.pattern:producer(s) then out.strands[s]=full.strands[s] end end
  return w.boundary,out
end
return {Geometry=Geometry,Algebra=Algebra,Operational=Operational}
