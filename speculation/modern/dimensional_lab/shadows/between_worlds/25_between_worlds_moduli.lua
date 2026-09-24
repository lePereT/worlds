package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function tree(b)
  local R=b:membrane(nil,'R')
  local A=b:membrane(R,'A')
  local B=b:membrane(A,'B')
  local C=b:membrane(B,'C'); local C2=b:membrane(C,'C2')
  local V=b:membrane(A,'V'); local V2=b:membrane(V,'V2')
  local X=b:membrane(R,'X'); local X2=b:membrane(X,'X2')
  return {R,A,B,C,C2,V,V2,X,X2}
end

local function build(base_index,hosts)
  local b=W.builder(); local ms=tree(b); local base=ms[base_index]
  local s={}; for i=0,#hosts do s[i]=b:strand(base,{},'s'..i) end
  local faces={}
  for i,hi in ipairs(hosts) do faces[i]=b:face(ms[hi],{s[i-1]},{s[i]},'f'..i) end
  return b:finish(),ms,faces
end

local function code(h) return ((h[1]-1)*9+(h[2]-1))*9+(h[3]-1) end
local function key(h) return table.concat(h,',') end
local function decode(c)
  local h={}; for i=3,1,-1 do h[i]=(c%9)+1; c=math.floor(c/9) end; return h
end
local function diff1(a,b)
  local d=0; local coord
  for i=1,3 do if a[i]~=b[i] then d=d+1; coord=i end end
  return d==1,coord
end
local function shadow_signature(g)
  -- Deliberately forget Membrane hosting and exact identity.  Every realisation
  -- is the same three-Face causal chain at this observation level.
  local adj=0
  for _,s in ipairs(g:strands()) do if g:producer(s) and g:consumer(s) then adj=adj+1 end end
  return table.concat({#g:points(),#g:strands(),#g:faces(),#g:ingress(),#g:egress(),adj},'/')
end

local profiles={
  {name='R',base=1,V=97,E=468,S=378},
  {name='A',base=2,V=356,E=2652,S=5241},
  {name='B',base=3,V=453,E=3960,S=9891},
}

print('1. one fixed lower causal shadow supports a finite space of exact Worlds')
for _,p in ipairs(profiles) do
  local worlds,hosts={},{}
  for c=0,9^3-1 do
    local h=decode(c); local good,g=pcall(function() return (build(p.base,h)) end)
    if good and g:is_developable() then worlds[c]=g; hosts[c]=h end
  end
  local vc=0; local sig
  for c,g in pairs(worlds) do
    vc=vc+1; local s=shadow_signature(g); sig=sig or s; eq(s,sig,p.name..' fixed lower shadow')
  end
  eq(vc,p.V,p.name..' exact Worlds over one shadow')

  local edges={}; local ec=0
  local codes={}; for c in pairs(worlds) do codes[#codes+1]=c end; table.sort(codes)
  for ii=1,#codes do for jj=ii+1,#codes do
    local a,b=codes[ii],codes[jj]; local yes=diff1(hosts[a],hosts[b])
    if yes then ec=ec+1; edges[#edges+1]={a,b} end
  end end
  eq(ec,p.E,p.name..' one-host jump edges')

  local squares=0
  -- A square is four lawful exact Worlds obtained by changing two Face-host
  -- coordinates independently.  Count each by its coordinatewise-low corner.
  for _,c in ipairs(codes) do
    local h=hosts[c]
    for i=1,2 do for j=i+1,3 do
      for ai=h[i]+1,9 do for aj=h[j]+1,9 do
        local hi={h[1],h[2],h[3]}; hi[i]=ai
        local hj={h[1],h[2],h[3]}; hj[j]=aj
        local hij={h[1],h[2],h[3]}; hij[i]=ai; hij[j]=aj
        if worlds[code(hi)] and worlds[code(hj)] and worlds[code(hij)] then squares=squares+1 end
      end end
    end end
  end
  eq(squares,p.S,p.name..' commuting move squares')

  if p.name=='A' then
    print('2. materialise the between-Worlds 1-skeleton as a face-free higher atlas')
    local b=W.builder(); local m=b:membrane(nil,'between Worlds'); local point,lift={},{}
    for _,c in ipairs(codes) do point[c]=b:point(m,'world.'..c); lift[point[c]]=worlds[c] end
    for ei,e in ipairs(edges) do b:strand(m,{point[e[1]],point[e[2]]},'rehost.'..ei) end
    local atlas=b:finish()
    eq(#atlas:points(),p.V); eq(#atlas:strands(),p.E); eq(#atlas:faces(),0,'the move atlas itself adds no lower causality')
    for hp,g in pairs(lift) do ok(W.is_geometry(g),'atlas Point lifts to an exact World'); eq(shadow_signature(g),sig) end
    -- The higher square data is not present in any lifted World and cannot be
    -- neutrally filled by an ordinary Worlds Face without causalising it.
    eq(squares,5241); ok(#atlas:faces()==0,'commuting squares remain inter-World structure')
  end
end

print('3. topology is therefore carried by relations among exact Worlds, not by any one member')
do
  local g=select(1,build(2,{1,1,1})); eq(#g:faces(),3); eq(#g:strands(),4)
  ok(g:is_developable()); eq(shadow_signature(g),'0/4/3/1/1/2')
end
print('PASS exact Worlds as vertices of a higher realisation space',n,'assertions')
