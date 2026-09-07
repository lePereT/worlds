package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local assertions=0
local function ok(x,msg) assertions=assertions+1; assert(x,msg or 'expected truthy') end
local function eq(a,b,msg) assertions=assertions+1; assert(a==b,msg or 'values differ') end

-- Scarcity grid: d simultaneous live demands require d distinct offered Strands.
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local R=vb:point(vm,'R'); vb:finish()
for n=1,8 do
  local b=W.Geometry.builder(); local m=b:membrane(nil,'s'); local offers={}; for i=1,n do offers[i]=b:strand(m,{R}) end; local live=W.Operational.from_geometry(b:finish())
  for d=1,8 do
    local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local ins={}; for i=1,d do ins[i]=p:strand(pm,{R}) end; local o=p:strand(pm,{R}); p:face(pm,ins,{o}); local pat=p:finish()
    local w=W.Operational.one(live,pat,{offers=offers}); eq(w~=nil,n>=d,'scarcity mismatch n='..n..' d='..d)
  end
end

-- Repeated variable equations: x,x only matches source pairs with exact equality.
local b=W.Geometry.builder(); local bm=b:membrane(nil,'b'); local P=b:point(bm,'P'); local Q=b:point(bm,'Q'); local ss=b:strand(bm,{P,P}); local sd=b:strand(bm,{P,Q}); local live=W.Operational.from_geometry(b:finish())
local p=W.Geometry.builder(); local pm=p:membrane(nil,'p'); local x=p:point(pm,'x'); local i=p:strand(pm,{x,x}); local pat=p:finish()
local all=W.Operational.all(live,pat,{offers={ss,sd}}); eq(#all,1); eq(all[1]:strand(i),ss)

-- Deep topology: exact root authority carries an identity originating at depth;
-- matching that Strand must induce the complete membrane path without selection.
for depth=1,40 do
  local b=W.Geometry.builder(); local root=b:membrane(nil,'root'); local child=root
  for _=1,depth do child=b:membrane(child,'c') end
  local id=b:point(child,'id'); local h=b:strand(root,{id},'handle'); local live=W.Operational.from_geometry(b:finish())
  local p=W.Geometry.builder(); local pr=p:membrane(nil,'pr'); local pc=pr
  for _=1,depth do pc=p:membrane(pc,'pc') end
  local x=p:point(pc,'x'); local hi=p:strand(pr,{x}); local ho=p:strand(pr,{x}); local state=p:strand(pc,{x}); p:face(pr,{hi},{ho,state}); local pat=p:finish()
  local w=W.Operational.one(live,pat,{strands={[hi]=h}}); ok(w,'depth mapping failed '..depth); eq(w:point(x),id); eq(w:membrane(pc),child)
  local _,img=W.Operational.commit(w); ok(img.strands[state])
end

-- Long deterministic evolution: no history is retained and exact authority
-- remains sufficient after many commits.
local vb2=W.Geometry.builder(); local vm2=vb2:membrane(nil,'v'); local roles={}; for i=1,8 do roles[i]=vb2:point(vm2,'S') end; vb2:finish()
local sb=W.Geometry.builder(); local root=sb:membrane(nil,'root'); local current=sb:strand(root,{roles[1]}); local state=W.Operational.from_geometry(sb:finish())
local transitions={}
for i=1,8 do
  transitions[i]={}
  for j=1,8 do
    if i~=j then local p2=W.Geometry.builder(); local m=p2:membrane(nil,'p'); local pin=p2:strand(m,{roles[i]}); local pout=p2:strand(m,{roles[j]}); p2:face(m,{pin},{pout}); transitions[i][j]={p2:finish(),pin,pout} end
  end
end
local cur=1
local random=require('prng').new(1)
for step=1,3000 do
  local to=random(1,7); if to>=cur then to=to+1 end
  local tr=transitions[cur][to]; local w=W.Operational.one(state,tr[1],{strands={[tr[2]]=current}}); ok(w); local _,img=W.Operational.commit(w); current=img.strands[tr[3]]; cur=to
end
eq(state:size(),1)

-- Symmetric close torture: support rings of varying size contract to one joint
-- occurrence when grounded by one external Control input.
do
  local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'cycle-v'); local Control=vb:point(vm,'Control'); local roles={}; for i=1,10 do roles[i]=vb:point(vm,'R'..i) end; vb:finish()
  for n=2,10 do
    local parts,ins,outs,ctl={},{},{},nil
    for i=1,n do
      local b=W.Geometry.builder(); local m=b:membrane(nil,'ring'..i); local input=b:strand(m,{roles[i==1 and n or i-1]}); local xs={input}; if i==1 then ctl=b:strand(m,{Control}); xs[#xs+1]=ctl end; local output=b:strand(m,{roles[i]}); b:face(m,xs,{output}); parts[i]=b:finish(); ins[i]=input; outs[i]=output
    end
    local links={}; for i=1,n do local j=(i%n)+1; links[#links+1]={outs[i],ins[j]} end
    local g,img=W.Algebra.close(parts,links); eq(#g:faces(),1,'ring must contract n='..n); eq(#g:strands(),1,'only grounding Control remains n='..n); ok(g:grounded(),'joint ring grounded n='..n)
  end
end

print('PASS torture',assertions,'assertions')
