package.path='./src/?.lua;'..package.path
local W=require('worlds')
math.randomseed(515151)
local N=3000
local function arrmap(xs) local m={}; for i,x in ipairs(xs) do m[x]=i end; return m end
local function brute(world,pat)
  local demands=pat:ingress(); local offers=world:egress(); local out={}; local used,pmap,mmap,ass={},{},{},{}
  local function chain(pm,gm,trail)
    while pm and pat:owns_membrane(pm) do
      if not gm then return false end
      local old=mmap[pm]; if old and old~=gm then return false end
      if not old then mmap[pm]=gm; trail[#trail+1]={'m',pm} end
      pm=W.parent(pm); gm=W.parent(gm)
    end
    return true
  end
  local function undo(tr) for i=#tr,1,-1 do local e=tr[i]; if e[1]=='m' then mmap[e[2]]=nil elseif e[1]=='p' then pmap[e[2]]=nil else used[e[2]]=nil end end end
  local function bind(d,o)
    if used[o] then return nil end
    local tr={}; if not chain(W.membrane(d),W.membrane(o),tr) then undo(tr); return nil end
    local a,b=W.points(d),W.points(o); if #a~=#b then for i=#tr,1,-1 do mmap[tr[i][2]]=nil end; return nil end
    for i,p in ipairs(a) do local q=b[i]
      if pat:owns_point(p) then
        local old=pmap[p]; if old and old~=q then for j=#tr,1,-1 do local e=tr[j]; if e[1]=='m' then mmap[e[2]]=nil else pmap[e[2]]=nil end end; return nil end
        if not old then pmap[p]=q; tr[#tr+1]={'p',p} end
        if not chain(W.membrane(p),W.membrane(q),tr) then for j=#tr,1,-1 do local e=tr[j]; if e[1]=='m' then mmap[e[2]]=nil else pmap[e[2]]=nil end end; return nil end
      elseif p~=q then for j=#tr,1,-1 do local e=tr[j]; if e[1]=='m' then mmap[e[2]]=nil else pmap[e[2]]=nil end end; return nil end
    end
    used[o]=true; tr[#tr+1]={'u',o}; return tr
  end
  local oi=arrmap(offers)
  local function rec(i)
    if i>#demands then local sig={}; for j,d in ipairs(demands) do sig[j]=oi[ass[d]] end; out[table.concat(sig,',')]=true; return end
    local d=demands[i]; for _,o in ipairs(offers) do local tr=bind(d,o); if tr then ass[d]=o; rec(i+1); ass[d]=nil; undo(tr) end end
  end
  rec(1); return out,demands,offers
end
local function solveall(world,pat,demands,offers)
  local oi=arrmap(offers); local out={}; local q=W.solve(world,pat)
  while true do local k,x=q:step(math.huge); if k=='yes' then local map={}; for _,e in ipairs(x) do map[e.to]=e.from end; local sig={}; for i,d in ipairs(demands) do sig[i]=oi[map[d]] end; out[table.concat(sig,',')]=true elseif k=='done' or k=='no' then break else error(k) end end
  return out
end
local function same(a,b) for k in pairs(a) do if not b[k] then return false,k,'missing' end end; for k in pairs(b) do if not a[k] then return false,k,'extra' end end; return true end
local function sample_case()
  local wb=W.builder(); local wr=wb:membrane(nil); local wm={wr}; if math.random()<0.7 then wm[#wm+1]=wb:membrane(wr) end; if #wm>1 and math.random()<0.35 then wm[#wm+1]=wb:membrane(wm[2]) end
  local wp={}; for _,m in ipairs(wm) do for j=1,math.random(1,2) do wp[#wp+1]=wb:point(m) end end
  for i=1,math.random(2,5) do local ps={}; for j=1,math.random(1,2) do ps[j]=wp[math.random(#wp)] end; wb:strand(wm[math.random(#wm)],ps) end
  local world=wb:finish()
  local pb=W.builder(); local pr=pb:membrane(nil); local pm={pr}; if math.random()<0.6 then pm[#pm+1]=pb:membrane(pr) end
  local pp={}; for _,m in ipairs(pm) do pp[#pp+1]=pb:point(m) end
  for i=1,math.random(1,3) do local ps={}; for j=1,math.random(1,2) do if math.random()<0.2 then ps[j]=wp[math.random(#wp)] else ps[j]=pp[math.random(#pp)] end end; pb:strand(pm[math.random(#pm)],ps) end
  return world,pb:finish()
end
for i=1,N do local w,p=sample_case(); local a,d,o=brute(w,p); local b=solveall(w,p,d,o); local yes,key,why=same(a,b); assert(yes,'nested differential case '..i..' '..tostring(why)..' '..tostring(key)) end
print('PASS nested differential',N,'cases')
