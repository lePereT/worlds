-- Emit lawful/developable vertex sets for the finite support-branching census.
-- State 0 = Face absent, 1 = root-hosted, 2..q-1 = one of q-2 sibling children.
-- The cubical analysis script treats one state change at one Face as an edge.
package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local F=require('speculation.modern.dimensional_lab.shadows.fibre_census.common')
if not arg[1] then print('SKIP support-vertex emitter (run via fibre_census/run_homology.sh)'); return end
local q=assert(tonumber(arg[1]),'state count q required'); assert(q>=2)
local lawful_path=assert(arg[2]); local dev_path=assert(arg[3]); local lawful=assert(io.open(lawful_path,'w')); local dev=assert(io.open(dev_path,'w'))
local vertices={'000','001','010','011','100','101','110','111'}
local function build(code)
  local st={}; local x=code; for i=1,6 do st[i]=x%q; x=math.floor(x/q) end
  local b=W.builder(); local root=b:membrane(nil,'root'); local child={}; for s=2,q-1 do child[s]=b:membrane(root,'C'..(s-1)) end
  local p={}; for _,v in ipairs(vertices) do p[v]=b:point(root,v) end; local es={}; for ei,e in ipairs(F.cube_edges) do es[ei]=b:strand(root,{p[e[1]],p[e[2]]},e[3]) end
  for fi,face in ipairs(F.cube_faces) do if st[fi]~=0 then
    local ins,outs={},{}; for _,ei in ipairs(F.cube_face_edges[fi]) do local os=F.cube_owners[ei]; local other=os[1]==fi and os[2] or os[1]; if F.cube_order[face.name]<F.cube_order[F.cube_faces[other].name] then outs[#outs+1]=es[ei] else ins[#ins+1]=es[ei] end end
    local host=st[fi]==1 and root or child[st[fi]]; b:face(host,ins,outs,face.name)
  end end
  return b:finish()
end
local lc,dc=0,0
for code=0,q^6-1 do local ok,g=pcall(build,code); if ok then lc=lc+1; lawful:write(code,'\n'); if g:is_developable() then dc=dc+1; dev:write(code,'\n') end end end
lawful:close(); dev:close(); print('q',q,'lawful',lc,'developable',dc)
