local W=require('worlds')
local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local F={W=W,C=C}

F.cube_faces={
  {name='x0',verts={'000','001','011','010'}},
  {name='y0',verts={'000','001','101','100'}},
  {name='z0',verts={'000','010','110','100'}},
  {name='y1',verts={'010','011','111','110'}},
  {name='z1',verts={'001','011','111','101'}},
  {name='x1',verts={'100','101','111','110'}},
}
F.cube_order={x0=1,y0=2,z0=3,y1=4,z1=5,x1=6}
local cube_vertices={'000','001','010','011','100','101','110','111'}
local function edgekey(a,b) if a>b then a,b=b,a end return a..'-'..b end

local function cube_combinatorics()
  local edge_index,edges,face_edges={}, {}, {}
  for fi,f in ipairs(F.cube_faces) do
    face_edges[fi]={}
    for i=1,4 do
      local a,b=f.verts[i],f.verts[i%4+1]; local k=edgekey(a,b)
      if not edge_index[k] then edge_index[k]=#edges+1; edges[#edges+1]={a,b,k} end
      face_edges[fi][#face_edges[fi]+1]=edge_index[k]
    end
  end
  local owners={}; for fi,es in ipairs(face_edges) do for _,ei in ipairs(es) do owners[ei]=owners[ei] or {}; owners[ei][#owners[ei]+1]=fi end end
  return edges,face_edges,owners
end
F.cube_edges,F.cube_face_edges,F.cube_owners=cube_combinatorics()

function F.cube_subset(mask,opts)
  opts=opts or {}; local b=W.builder(); local root=b:membrane(nil,opts.label or ('cube.'..mask)); local shared=nil
  if opts.shared_child then shared=b:membrane(root,opts.shared_child) end
  local p={}; for _,v in ipairs(cube_vertices) do p[v]=b:point(root,v) end
  local es={}
  for ei,e in ipairs(F.cube_edges) do es[ei]=b:strand(root,{p[e[1]],p[e[2]]},e[3]) end
  local faces={}; local top={}
  for fi,f in ipairs(F.cube_faces) do if (mask & (1<<(fi-1)))~=0 then
    local ins,outs={},{}
    for _,ei in ipairs(F.cube_face_edges[fi]) do
      local os=F.cube_owners[ei]; local other=os[1]==fi and os[2] or os[1]
      if F.cube_order[f.name] < F.cube_order[F.cube_faces[other].name] then outs[#outs+1]=es[ei] else ins[#ins+1]=es[ei] end
    end
    local host=root
    if opts.host_bits and ((opts.host_bits & (1<<(fi-1)))~=0) then host=assert(shared,'host_bits require shared_child') end
    faces[fi]=b:face(host,ins,outs,f.name)
    local ids={}; for _,ei in ipairs(F.cube_face_edges[fi]) do ids[#ids+1]=ei end; top[#top+1]=ids
  end end
  return b:finish(),{root=root,shared=shared,p=p,edges=es,faces=faces,top_faces=top}
end

function F.cube_homology(mask)
  local edges={}; for i,e in ipairs(F.cube_edges) do
    local a,b
    for vi,v in ipairs(cube_vertices) do if v==e[1] then a=vi elseif v==e[2] then b=vi end end
    edges[i]={a,b}
  end
  local faces={}; for fi=1,6 do if (mask & (1<<(fi-1)))~=0 then
    local x={}; for _,ei in ipairs(F.cube_face_edges[fi]) do x[#x+1]=ei end; faces[#faces+1]=x
  end end
  return C.homology(8,edges,faces)
end

function F.popcount(x) local n=0; while x~=0 do n=n+(x&1); x=x>>1 end; return n end

function F.causal_face_graph(g)
  local faces=g:faces(); local adj={}; for _,f in ipairs(faces) do adj[f]={} end
  for _,s in ipairs(g:strands()) do local p,c=g:producer(s),g:consumer(s); if p and c then adj[p][c]=true end end
  return faces,adj
end

function F.source_sink_counts(g)
  local faces,adj=F.causal_face_graph(g); local indeg,outdeg={},{}
  for _,f in ipairs(faces) do indeg[f]=0; outdeg[f]=0 end
  for a,ns in pairs(adj) do for b in pairs(ns) do outdeg[a]=outdeg[a]+1; indeg[b]=indeg[b]+1 end end
  local src,sink=0,0; for _,f in ipairs(faces) do if indeg[f]==0 then src=src+1 end; if outdeg[f]==0 then sink=sink+1 end end
  return src,sink
end

function F.key_homology(h) return h.b0..','..h.b1..','..h.b2 end


-- Fixed support tree root/{A,B}; each cube Face state is 0=absent, 1=root,
-- 2=A, 3=B.  The Point/Strand skeleton is always the same and lives at root.
function F.cube_support_assignment(code)
  local states={}; local x=code; local face_mask=0
  for fi=1,6 do states[fi]=x%4; x=math.floor(x/4); if states[fi]~=0 then face_mask=face_mask | (1<<(fi-1)) end end
  local b=W.builder(); local root=b:membrane(nil,'root'); local A=b:membrane(root,'A'); local B=b:membrane(root,'B')
  local p={}; for _,v in ipairs(cube_vertices) do p[v]=b:point(root,v) end
  local es={}; for ei,e in ipairs(F.cube_edges) do es[ei]=b:strand(root,{p[e[1]],p[e[2]]},e[3]) end
  local faces={}
  for fi,f in ipairs(F.cube_faces) do if states[fi]~=0 then
    local ins,outs={},{}
    for _,ei in ipairs(F.cube_face_edges[fi]) do local os=F.cube_owners[ei]; local other=os[1]==fi and os[2] or os[1]
      if F.cube_order[f.name] < F.cube_order[F.cube_faces[other].name] then outs[#outs+1]=es[ei] else ins[#ins+1]=es[ei] end
    end
    local host=states[fi]==1 and root or states[fi]==2 and A or B
    faces[fi]=b:face(host,ins,outs,f.name)
  end end
  return b:finish(),{root=root,A=A,B=B,p=p,edges=es,faces=faces,states=states,face_mask=face_mask}
end

function F.base4_digits(code,n)
  local r={}; for i=1,n do r[i]=code%4; code=math.floor(code/4) end; return r
end

return F
