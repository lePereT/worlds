-- Canonical symbolic Geometry for portable relative Developments.
local W=require('worlds')
local Construction=require('worlds.construction')
local M={}

local function array(xs)
  local out={}
  for i,x in ipairs(xs or {}) do out[i]=x end
  return out
end

function M.empty()
  return {membranes={},points={},strands={},faces={}}
end

function M.normal(g)
  assert(type(g)=='table','symbolic Geometry required')
  local out=M.empty()
  for i,m in ipairs(g.membranes or {}) do
    local parent=m.parent or 0
    assert(type(parent)=='number' and parent>=0 and parent<i,'bad symbolic Membrane parent')
    out.membranes[i]={parent=parent}
  end
  for i,p in ipairs(g.points or {}) do
    assert(out.membranes[p.membrane],'bad symbolic Point membrane')
    out.points[i]={membrane=p.membrane}
  end
  for i,s in ipairs(g.strands or {}) do
    assert(out.membranes[s.membrane],'bad symbolic Strand membrane')
    local ps={}
    for j,pi in ipairs(s.points or {}) do assert(out.points[pi],'bad symbolic Strand Point')
      ps[j]=pi end
    out.strands[i]={membrane=s.membrane,points=ps}
  end
  for i,f in ipairs(g.faces or {}) do
    assert(out.membranes[f.membrane],'bad symbolic Face membrane')
    local ins,outs={},{}
    for j,si in ipairs(f.inputs or {}) do assert(out.strands[si],'bad symbolic Face input')
      ins[j]=si end
    for j,si in ipairs(f.outputs or {}) do assert(out.strands[si],'bad symbolic Face output')
      outs[j]=si end
    out.faces[i]={membrane=f.membrane,inputs=ins,outputs=outs}
  end
  return out
end

function M.instantiate(spec)
  spec=M.normal(spec)
  local b=W.builder()
  local map={membranes={},points={},strands={},faces={}}
  for i,m in ipairs(spec.membranes) do
    map.membranes[i]=b:membrane(m.parent~=0 and map.membranes[m.parent] or nil)
  end
  for i,p in ipairs(spec.points) do map.points[i]=b:point(map.membranes[p.membrane]) end
  for i,s in ipairs(spec.strands) do
    local ps={}
    for j,pi in ipairs(s.points) do ps[j]=map.points[pi] end
    map.strands[i]=b:strand(map.membranes[s.membrane],ps)
  end
  for i,f in ipairs(spec.faces) do
    local ins,outs={},{ }
    for j,si in ipairs(f.inputs) do ins[j]=map.strands[si] end
    for j,si in ipairs(f.outputs) do outs[j]=map.strands[si] end
    map.faces[i]=b:face(map.membranes[f.membrane],ins,outs)
  end
  return b:finish(),map
end

function M.symbolize(g)
  assert(W.is_geometry(g),'exact Worlds Geometry required')
  local spec=M.empty()
  local index={membranes={},points={},strands={},faces={}}
  for i,m in ipairs(g:membranes()) do index.membranes[m]=i end
  for i,p in ipairs(g:points()) do index.points[p]=i end
  for i,s in ipairs(g:strands()) do index.strands[s]=i end
  for i,f in ipairs(g:faces()) do index.faces[f]=i end
  for i,m in ipairs(g:membranes()) do
    local p=W.parent(m)
    spec.membranes[i]={parent=p and assert(index.membranes[p]) or 0}
  end
  for i,p in ipairs(g:points()) do spec.points[i]={membrane=assert(index.membranes[W.membrane(p)])} end
  for i,s in ipairs(g:strands()) do
    local ps={}
    for j,p in ipairs(W.points(s)) do ps[j]=assert(index.points[p]) end
    spec.strands[i]={membrane=assert(index.membranes[W.membrane(s)]),points=ps}
  end
  for i,f in ipairs(g:faces()) do
    local ins,outs={},{}
    for j,s in ipairs(W.inputs(f)) do ins[j]=assert(index.strands[s]) end
    for j,s in ipairs(W.outputs(f)) do outs[j]=assert(index.strands[s]) end
    spec.faces[i]={membrane=assert(index.membranes[W.membrane(f)]),inputs=ins,outputs=outs}
  end
  return spec,index
end

-- Compose symbolic parts by asking actual Worlds to perform the exact join, then erase
-- all exact identity back to canonical symbolic indices. The exact occurrence used by
-- the linker is therefore disposable normalisation evidence, never Package meaning.

local KIND_FIELDS={'membranes','points','strands','faces'}

-- Canonicalise a Construction result by its marked symbolic sources, never by fresh
-- carrier allocation/order in the exact result. Native Construction correspondence
-- is precisely the evidence needed to erase linker occurrences without ambiguity.
function M.symbolize_construction(c,maps)
  local corr=c:correspondence()
  local target=c:result()
  local ordered,index={},{membranes={},points={},strands={},faces={}}
  for _,field in ipairs(KIND_FIELDS) do
    local rank={}
    for pi,map in ipairs(maps) do
      for si,x in ipairs(map[field] or {}) do
        local cl=assert(corr:source_class(x),'Construction correspondence omitted source carrier')
        local key=string.format('%09d:%09d',pi,si)
        if rank[cl]==nil or key<rank[cl] then rank[cl]=key end
      end
    end
    local xs={}
    for _,y in ipairs(target[field](target)) do
      local cl=assert(corr:target_class(y),'Construction correspondence omitted target carrier')
      assert(rank[cl]~=nil,'Construction result carrier lacks marked source provenance')
      xs[#xs+1]={carrier=y,key=rank[cl]}
    end
    table.sort(xs,function(a,b) return a.key<b.key end)
    ordered[field]={}
    for i,row in ipairs(xs) do ordered[field][i]=row.carrier
 index[field][row.carrier]=i end
  end
  local spec=M.empty()
  for i,m in ipairs(ordered.membranes) do local parent=W.parent(m)
    spec.membranes[i]={parent=parent and assert(index.membranes[parent]) or 0} end
  for i,p in ipairs(ordered.points) do spec.points[i]={membrane=assert(index.membranes[W.membrane(p)])} end
  for i,st in ipairs(ordered.strands) do local ps={}
    for j,pnt in ipairs(W.points(st)) do ps[j]=assert(index.points[pnt]) end
    spec.strands[i]={membrane=assert(index.membranes[W.membrane(st)]),points=ps} end
  for i,f in ipairs(ordered.faces) do local ins,outs={},{}
    for j,st in ipairs(W.inputs(f)) do ins[j]=assert(index.strands[st]) end
    for j,st in ipairs(W.outputs(f)) do outs[j]=assert(index.strands[st]) end
    spec.faces[i]={membrane=assert(index.membranes[W.membrane(f)]),inputs=ins,outputs=outs} end
  return spec,index
end

function M.compose(parts,equations)
  local exact,maps={},{ }
  for i,p in ipairs(parts) do exact[i],maps[i]=M.instantiate(p) end
  local eqs={}
  for i,e in ipairs(equations or {}) do
    eqs[i]={from=assert(maps[e.from.part].strands[e.from.strand]),
      to=assert(maps[e.to.part].strands[e.to.strand])}
  end
  local c=Construction.join(exact,eqs)
  local result,index=M.symbolize_construction(c,maps)
  local images={}
  for i,p in ipairs(parts) do
    local row={strands={}}
    for si=1,#p.strands do
      local y=c:image(maps[i].strands[si])
      row.strands[si]=y and index.strands[y] or nil
    end
    images[i]=row
  end
  return result,images,c
end

function M.operation(input_count,output_count)
  input_count,output_count=input_count or 0,output_count or 0
  if input_count==0 and output_count==0 then return M.empty(),{inputs={},outputs={}} end
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local inputs,outputs={},{}
  local n=0
  for i=1,input_count do
    n=n+1
 g.points[n]={membrane=1}
 g.strands[n]={membrane=1,points={n}}
 inputs[i]=n
  end
  for i=1,output_count do
    n=n+1
 g.points[n]={membrane=1}
 g.strands[n]={membrane=1,points={n}}
 outputs[i]=n
  end
  g.faces[1]={membrane=1,inputs=array(inputs),outputs=array(outputs)}
  return g,{inputs=inputs,outputs=outputs}
end

function M.face_reaches(spec,ai,bi)
  local g=M.instantiate(spec)
  local a,b=g:faces()[ai],g:faces()[bi]
  if not a or not b then return false end
  local edges={}
  for _,f in ipairs(g:faces()) do edges[f]={} end
  for _,s in ipairs(g:strands()) do
    local p,c=g:producer(s),g:consumer(s)
    if p and c then edges[p][c]=true end
  end
  local seen={}
  local function visit(x)
    if x==b then return true end
    if seen[x] then return false end
    seen[x]=true
    for y in pairs(edges[x]) do if visit(y) then return true end end
    return false
  end
  return visit(a)
end


-- Canonical alpha-normal form for a symbolic Geometry with marked authority boundary.
-- Construction provenance is useful for erasing fresh exact identity, but it must not
-- make Package identity depend on composition parenthesisation. This small research
-- canonicaliser uses structural colour refinement followed by permutation only inside
-- unresolved symmetry cells.
function M.canonical(spec,authority,point_marks)
  spec=M.normal(spec)
  authority=authority or {inputs={},outputs={}}
  local ain=array(authority.inputs or {})
 local aout=array(authority.outputs or {})
  for _,si in ipairs(ain) do assert(spec.strands[si],'canonical authority input missing') end
  for _,si in ipairs(aout) do assert(spec.strands[si],'canonical authority output missing') end

  local nodes,adj,base={},{},{}
  local function key(k,i) return k..tostring(i) end
  local function add(k,i,b)
    local q=key(k,i)
 nodes[#nodes+1]=q
 adj[q]={}
 base[q]=k..':'..b
  end
  local depth={}
  for i,m in ipairs(spec.membranes) do depth[i]=m.parent==0 and 0 or depth[m.parent]+1 end
  for i=1,#spec.membranes do add('M',i,'d'..depth[i]) end
  point_marks=point_marks or {}
  for i=1,#spec.points do
    local q=point_marks[i] or {}
 local marks_copy={}
    for j,x in ipairs(q) do marks_copy[j]=x end
 table.sort(marks_copy)
    add('P',i,table.concat(marks_copy,','))
  end
  local marks={}
  for i,si in ipairs(ain) do local q=marks[si] or {}
 marks[si]=q
 q[#q+1]='I'..i end
  for i,si in ipairs(aout) do local q=marks[si] or {}
 marks[si]=q
 q[#q+1]='O'..i end
  for i=1,#spec.strands do local q=marks[i] or {}
 table.sort(q)
 add('S',i,table.concat(q,',')) end
  local producer={}
  for fi,f in ipairs(spec.faces) do for _,si in ipairs(f.outputs) do producer[si]=fi end end
  local frank,visiting={},{}
  local function face_rank(fi)
    if frank[fi] then return frank[fi] end
    assert(not visiting[fi],'symbolic Geometry retained a causal Face cycle')
    visiting[fi]=true
    local r=0
    for _,si in ipairs(spec.faces[fi].inputs) do local p=producer[si]
      if p then r=math.max(r,face_rank(p)+1) end end
    visiting[fi]=nil
 frank[fi]=r
 return r
  end
  for i=1,#spec.faces do add('F',i,'r'..face_rank(i)) end
  local function edge(a,b,label)
    adj[a][#adj[a]+1]={label=label,to=b}
    adj[b][#adj[b]+1]={label='^'..label,to=a}
  end
  for i,m in ipairs(spec.membranes) do if m.parent~=0 then edge(key('M',i),key('M',m.parent),'parent') end end
  for i,p in ipairs(spec.points) do edge(key('P',i),key('M',p.membrane),'membrane') end
  for i,st in ipairs(spec.strands) do
    edge(key('S',i),key('M',st.membrane),'membrane')
    for j,pi in ipairs(st.points) do edge(key('S',i),key('P',pi),'point:'..j) end
  end
  for i,f in ipairs(spec.faces) do
    edge(key('F',i),key('M',f.membrane),'membrane')
    for j,si in ipairs(f.inputs) do edge(key('F',i),key('S',si),'input:'..j) end
    for j,si in ipairs(f.outputs) do edge(key('F',i),key('S',si),'output:'..j) end
  end

  local colors={}
 for _,q in ipairs(nodes) do colors[q]=base[q] end
  local previous_count=0
  while true do
    local signatures={}
    for _,q in ipairs(nodes) do
      local ns={}
      for _,e in ipairs(adj[q]) do ns[#ns+1]=e.label..'='..colors[e.to] end
      table.sort(ns)
 signatures[q]=colors[q]..'|'..table.concat(ns,';')
    end
    local unique={}
 for _,q in ipairs(nodes) do unique[signatures[q]]=true end
    local ss={}
 for x in pairs(unique) do ss[#ss+1]=x end
 table.sort(ss)
    local ids={}
 for i,x in ipairs(ss) do ids[x]=string.format('%09d',i) end
    local nextc={}
 for _,q in ipairs(nodes) do nextc[q]=ids[signatures[q]] end
    colors=nextc
    if #ss==previous_count then break end
    previous_count=#ss
  end

  local function cells(kind,count,extra)
    local by={}
    for i=1,count do
      local prefix=extra and extra(i) or ''
      local c=prefix..':'..colors[key(kind,i)]
      local row=by[c] or {}
 by[c]=row
 row[#row+1]=i
    end
    local ks={}
 for c in pairs(by) do ks[#ks+1]=c end
 table.sort(ks)
    local out={}
 for _,c in ipairs(ks) do table.sort(by[c])
 out[#out+1]=by[c] end
    return out
  end
  local allcells={}
  local function append(xs) for _,x in ipairs(xs) do allcells[#allcells+1]=x end end
  append(cells('M',#spec.membranes,function(i) return string.format('%09d',depth[i]) end))
  append(cells('P',#spec.points))
  append(cells('S',#spec.strands))
  append(cells('F',#spec.faces,function(i) return string.format('%09d',frank[i]) end))

  local choices=1
  local function fact(n) local x=1
 for i=2,n do x=x*i end
 return x end
  for _,c in ipairs(allcells) do choices=choices*fact(#c) end
  assert(choices<=200000,'research Geometry canonicaliser symmetry search too large')

  local best,bestg,besta,bestmap=nil,nil,nil,nil
  local chosen={}
  local function permutations(xs,visit)
    local used,row={},{}
    local function go()
      if #row==#xs then local r={}
 for i,x in ipairs(row) do r[i]=x end
 visit(r)
 return end
      for i,x in ipairs(xs) do if not used[i] then used[i]=true
 row[#row+1]=x
 go()
 row[#row]=nil
 used[i]=nil end end
    end
    go()
  end
  local function evaluate()
    local order={M={},P={},S={},F={}}
    local ci=0
    local groups={
      cells('M',#spec.membranes,function(i) return string.format('%09d',depth[i]) end),
      cells('P',#spec.points),cells('S',#spec.strands),
      cells('F',#spec.faces,function(i) return string.format('%09d',frank[i]) end)}
    local kinds={'M','P','S','F'}
    for gi,gs in ipairs(groups) do for _=1,#gs do ci=ci+1
 for _,x in ipairs(chosen[ci]) do order[kinds[gi]][#order[kinds[gi]]+1]=x end end end
    local map={M={},P={},S={},F={}}
    for k,xs in pairs(order) do for ni,oi in ipairs(xs) do map[k][oi]=ni end end
    local g=M.empty()
    for ni,oi in ipairs(order.M) do local m=spec.membranes[oi]
 g.membranes[ni]={parent=m.parent==0 and 0 or map.M[m.parent]} end
    for ni,oi in ipairs(order.P) do g.points[ni]={membrane=map.M[spec.points[oi].membrane]} end
    for ni,oi in ipairs(order.S) do local st=spec.strands[oi]
 local ps={}
      for j,pi in ipairs(st.points) do ps[j]=map.P[pi] end
      g.strands[ni]={membrane=map.M[st.membrane],points=ps} end
    for ni,oi in ipairs(order.F) do local f=spec.faces[oi]
 local ins,outs={},{}
      for j,si in ipairs(f.inputs) do ins[j]=map.S[si] end
      for j,si in ipairs(f.outputs) do outs[j]=map.S[si] end
      g.faces[ni]={membrane=map.M[f.membrane],inputs=ins,outputs=outs} end
    local a={inputs={},outputs={}}
    for i,si in ipairs(ain) do a.inputs[i]=map.S[si] end
    for i,si in ipairs(aout) do a.outputs[i]=map.S[si] end
    local bytes=require('speculation.showcases.transactions.transactional_development_calculus.canonical').encode({geometry=g,authority=a})
    if best==nil or bytes<best then best=bytes
 bestg=g
 besta=a
 bestmap=map end
  end
  local function choose(i)
    if i>#allcells then evaluate()
 return end
    permutations(allcells[i],function(p) chosen[i]=p
 choose(i+1) end)
  end
  choose(1)
  return assert(bestg),assert(besta),assert(bestmap)
end

return M
