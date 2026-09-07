package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local assertions=0
local function ok(x,msg) assertions=assertions+1; assert(x,msg or 'expected truthy') end
local function eq(a,b,msg) assertions=assertions+1; assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local random=require('prng').new(20260906)

-- Vocabulary.
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local roles={}; for i=1,6 do roles[i]=vb:point(vm,'R'..i) end; vb:finish()

local function role_counts(strands)
  local c={}; for _,s in ipairs(strands) do local r=W.Geometry.points(s)[1]; c[r]=(c[r] or 0)+1 end; return c
end
local function same_counts(a,b)
  local ca,cb=role_counts(a),role_counts(b)
  for _,r in ipairs(roles) do eq(ca[r] or 0,cb[r] or 0,'boundary/history role multiplicity diverged') end
end

-- Start with five exact live authorities. Operational and history occurrences are
-- initially literally the same; thereafter corr maps operational -> history.
local hb=W.Geometry.builder(); local hm=hb:membrane(nil,'root'); local initial={}
for i=1,5 do initial[i]=hb:strand(hm,{roles[(i-1)%#roles+1]}) end
local history=hb:finish(); local boundary=W.Operational.from_geometry(history); local corr={}; for _,s in ipairs(initial) do corr[s]=s end

for step=1,1000 do
  local offers=boundary:offers(); ok(#offers>0)
  local take=math.min(#offers,random(1,math.min(3,#offers)))
  -- choose distinct operational authorities
  for i=#offers,2,-1 do local j=random(i); offers[i],offers[j]=offers[j],offers[i] end
  local chosen={}; for i=1,take do chosen[i]=offers[i] end

  local pb=W.Geometry.builder(); local pm=pb:membrane(nil,'p'); local pins={},{} -- dummy second value ignored
  local inputs={}; local exact_op={},{}; local exact_hist={}
  for i,s in ipairs(chosen) do
    local pts=W.Geometry.points(s); local pi=pb:strand(pm,{pts[1]}); inputs[i]=pi; exact_op[pi]=s; exact_hist[pi]=corr[s]
  end
  local outn=random(1,3); local outputs={}
  for i=1,outn do outputs[i]=pb:strand(pm,{roles[random(#roles)]}) end
  pb:face(pm,inputs,outputs); local proc=pb:finish()

  local w=W.Operational.one(boundary,proc,{strands=exact_op}); ok(w); local _,opimg=W.Operational.commit(w)
  local links={}; for pi,hs in pairs(exact_hist) do links[#links+1]={hs,pi} end
  local h2,himg=W.Algebra.close({history,proc},links)

  local consumed={}; for _,s in ipairs(chosen) do consumed[s]=true end
  local nextcorr={}
  for os,hs in pairs(corr) do if not consumed[os] then nextcorr[os]=himg[1].strands[hs] end end
  for _,po in ipairs(outputs) do nextcorr[opimg.strands[po]]=himg[2].strands[po] end
  corr=nextcorr; history=h2

  eq(boundary:size(),#history:egress(),'boundary size must equal exact-history egress size')
  same_counts(boundary:offers(),history:egress())
  for os,hs in pairs(corr) do ok(boundary:contains(os)); ok(history:is_terminal(hs)); eq(W.Geometry.points(os)[1],W.Geometry.points(hs)[1]) end
end

-- Tensor permutation does not change independent boundary facts.
local parts={}
for i=1,7 do local b=W.Geometry.builder(); local m=b:membrane(nil,'T'..i); local s=b:strand(m,{roles[i%#roles+1]}); parts[i]=b:finish() end
for trial=1,100 do
  local ps={}; for i,p in ipairs(parts) do ps[i]=p end; for i=#ps,2,-1 do local j=random(i); ps[i],ps[j]=ps[j],ps[i] end
  local g=W.Algebra.tensor(ps); eq(#g:faces(),0); eq(#g:egress(),7); eq(#g:ingress(),7)
  local c=role_counts(g:egress()); local expected=role_counts((function() local x={} for _,p in ipairs(parts) do x[#x+1]=p:egress()[1] end return x end)())
  for _,r in ipairs(roles) do eq(c[r] or 0,expected[r] or 0) end
end

-- Generated cyclic support rings: part order and link order must not affect SCC
-- contraction or LCA locality.  Every ring has one external control ingress.
local Control=roles[1]
for n=2,12 do
  local R={}; for i=1,n do R[i]=roles[(i-1)%#roles+1] end
  local ps,ins,outs,faces={}, {}, {}, {}
  for i=1,n do
    local b=W.Geometry.builder(); local root=b:membrane(nil,'r'..i); local zone=b:membrane(root,'z'); local leaf=b:membrane(zone,'l')
    ins[i]=b:strand(zone,{R[(i-2)%n+1]}); local ii={ins[i]}; if i==1 then ii[#ii+1]=b:strand(zone,{Control}) end
    outs[i]=b:strand(zone,{R[i]}); faces[i]=b:face(leaf,ii,{outs[i]}); ps[i]=b:finish()
  end
  local links={}; for i=1,n do links[i]={outs[i],ins[i%n+1]} end
  for trial=1,20 do
    local porder={}; for i,p in ipairs(ps) do porder[i]=p end; for i=#porder,2,-1 do local j=random(i); porder[i],porder[j]=porder[j],porder[i] end
    local ls={}; for i,e in ipairs(links) do ls[i]=e end; for i=#ls,2,-1 do local j=random(i); ls[i],ls[j]=ls[j],ls[i] end
    local g=W.Algebra.close(porder,ls); eq(#g:faces(),1); eq(#g:ingress(),1); eq(#g:egress(),0)
  end
end
print('PASS whole_torture',assertions,'assertions')
