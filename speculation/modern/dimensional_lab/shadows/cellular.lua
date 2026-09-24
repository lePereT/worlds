-- Helpers for the W3 shadow laboratory.  These deliberately study the restricted
-- case where higher deformation Strands have exactly two endpoint Points and
-- Faces are attached along cycles.  In that sublanguage ordinary Worlds can be
-- read as an honest finite 2-complex after forgetting causal polarity.

local W=require('worlds')
local C={W=W}

local function gf2_rank(rows,ncols)
  local a={}; for i,row in ipairs(rows) do a[i]={}; for j=1,ncols do a[i][j]=(row[j] or 0)%2 end end
  local r,c=0,1
  while c<=ncols and r<#a do
    local pivot=nil; for i=r+1,#a do if a[i][c]==1 then pivot=i; break end end
    if not pivot then c=c+1 else
      r=r+1; a[r],a[pivot]=a[pivot],a[r]
      for i=1,#a do if i~=r and a[i][c]==1 then for j=c,ncols do a[i][j]=(a[i][j]+a[r][j])%2 end end end
      c=c+1
    end
  end
  return r
end
C.gf2_rank=gf2_rank

function C.homology(vcount,edges,faces)
  local d1={}; for v=1,vcount do d1[v]={} end
  for e,x in ipairs(edges) do d1[x[1]][e]=1; d1[x[2]][e]=(d1[x[2]][e] or 0)+1 end
  local d2={}; for e=1,#edges do d2[e]={} end
  for f,es in ipairs(faces or {}) do for _,e in ipairs(es) do d2[e][f]=(d2[e][f] or 0)+1 end end
  local r1=gf2_rank(d1,#edges); local r2=gf2_rank(d2,#faces)
  -- Check d1*d2 = 0 over GF(2).
  for v=1,vcount do for f=1,#faces do local z=0; for e=1,#edges do z=(z+(d1[v][e] or 0)*(d2[e][f] or 0))%2 end; assert(z==0,'not a mod-2 cellular chain complex') end end
  return {b0=vcount-r1,b1=#edges-r1-r2,b2=#faces-r2,r1=r1,r2=r2}
end

function C.cycle(n,mask,opts)
  opts=opts or {}; local b=W.builder(); local root=b:membrane(nil,opts.label or ('C'..n)); local host=root
  if opts.child_host then host=b:membrane(root,opts.child_host) end
  local p,e={},{}
  for i=1,n do p[i]=b:point(root,'v'..i) end
  for i=1,n do local j=i%n+1; e[i]=b:strand(root,{p[i],p[j]},'e'..i) end
  local f=nil
  if mask~=nil then
    local ins,outs={},{}
    for i=1,n do if (mask & (1<<(i-1)))~=0 then ins[#ins+1]=e[i] else outs[#outs+1]=e[i] end end
    f=b:face(host,ins,outs,opts.face_name or 'fill')
  end
  return b:finish(),{root=root,host=host,p=p,e=e,f=f}
end

function C.cycle_homology(n,filled)
  local edges={}; for i=1,n do edges[i]={i,i%n+1} end
  local faces=filled and {{table.unpack((function() local x={} for i=1,n do x[i]=i end return x end)())}} or {}
  return C.homology(n,edges,faces)
end

function C.mask_bits(mask,n)
  local s={}; for i=1,n do s[i]=((mask & (1<<(i-1)))~=0) and '1' or '0' end; return table.concat(s)
end

function C.hamming(a,b) local x=a~b; local n=0; while x~=0 do n=n+(x&1); x=x>>1 end; return n end

local function rotate_bits(mask,n,k)
  local out=0
  for i=0,n-1 do if (mask & (1<<i))~=0 then out=out | (1<<((i+k)%n)) end end
  return out
end
local function reflect_bits(mask,n)
  local out=0; for i=0,n-1 do if (mask & (1<<i))~=0 then out=out | (1<<((-i)%n)) end end; return out
end
function C.dihedral_orbit(mask,n)
  local seen={}; local r=reflect_bits(mask,n)
  for k=0,n-1 do seen[rotate_bits(mask,n,k)]=true; seen[rotate_bits(r,n,k)]=true end
  return seen
end

-- Cube boundary: vertices are bit triples.  Faces are ordered so x0 is the
-- unique causal source and x1 the sink after orienting every shared edge from
-- earlier face to later face.  Omitting x0 produces a developable punctured
-- sphere; the full sphere has no ingress and is nondevelopable.
local cube_faces={
  {name='x0',verts={'000','001','011','010'}},
  {name='y0',verts={'000','001','101','100'}},
  {name='z0',verts={'000','010','110','100'}},
  {name='y1',verts={'010','011','111','110'}},
  {name='z1',verts={'001','011','111','101'}},
  {name='x1',verts={'100','101','111','110'}},
}
local cube_order={x0=1,y0=2,z0=3,y1=4,z1=5,x1=6}
local function edgekey(a,b) if a>b then a,b=b,a end return a..'-'..b end

function C.cube(omit)
  local b=W.builder(); local m=b:membrane(nil,'cube'); local verts={'000','001','010','011','100','101','110','111'}; local p={}
  for _,v in ipairs(verts) do p[v]=b:point(m,v) end
  local edge,elist,face_edges={},{},{}
  for fi,f in ipairs(cube_faces) do
    face_edges[fi]={}
    for i=1,4 do
      local a,c=f.verts[i],f.verts[i%4+1]; local k=edgekey(a,c)
      if not edge[k] then edge[k]=b:strand(m,{p[a],p[c]},k); elist[#elist+1]=edge[k] end
      face_edges[fi][#face_edges[fi]+1]=edge[k]
    end
  end
  local owners={}; for fi,es in ipairs(face_edges) do for _,s in ipairs(es) do owners[s]=owners[s] or {}; owners[s][#owners[s]+1]=fi end end
  local faces={}; local top_faces={}
  for fi,f in ipairs(cube_faces) do if f.name~=omit then
    local ins,outs={},{}
    for _,s in ipairs(face_edges[fi]) do local os=owners[s]; local other=os[1]==fi and os[2] or os[1]
      if cube_order[f.name]<cube_order[cube_faces[other].name] then outs[#outs+1]=s else ins[#ins+1]=s end
    end
    faces[f.name]=b:face(m,ins,outs,f.name)
    local ids={}; for _,s in ipairs(face_edges[fi]) do for j,x in ipairs(elist) do if x==s then ids[#ids+1]=j; break end end end; top_faces[#top_faces+1]=ids
  end end
  local edge_ends={}; for i,s in ipairs(elist) do local row=W.points(s); local function vi(q) for j,v in ipairs(verts) do if p[v]==q then return j end end end; edge_ends[i]={vi(row[1]),vi(row[2])} end
  return b:finish(),{p=p,edges=elist,faces=faces,edge_ends=edge_ends,top_faces=top_faces}
end

return C
