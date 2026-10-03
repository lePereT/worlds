local W=require('worlds')
math.randomseed(771931)
local N=2000
local assertions=0
local function eq(a,b,m) assertions=assertions+1; assert(a==b,m or (tostring(a)..' ~= '..tostring(b))) end
local function ok(x,m) assertions=assertions+1; assert(x,m or 'expected truthy') end

-- Exact imported labels let us compare fresh result Strands structurally without
-- relying on their freshly allocated identity.
local ub=W.builder(); local um=ub:membrane(nil,'u'); ub:finish(); local mint=W.minter(um)
local ROLE=mint('R'); local labels={}; for i=1,256 do labels[i]=mint('L'..i) end

local function world(count)
  local b=W.builder(); local m=b:membrane(nil,'world'); local ss={}
  for i=1,count do ss[i]=b:strand(m,{ROLE,labels[i]},'w'..i) end
  return b:finish(),ss
end

local function development(ningress,nsteps)
  local b=W.development_builder(); local m=b:membrane(nil,'dev')
  local open,all={},{ }
  for i=1,ningress do
    local s=b:strand(m,{ROLE,labels[i]},'in'..i); open[#open+1]=s; all[#all+1]=s
  end
  local nextlabel=ningress+1
  for step=1,nsteps do
    if #open==0 then break end
    local nin=(#open>=2 and math.random()<0.35) and 2 or 1
    local ins={}
    for j=1,nin do local ix=math.random(#open); ins[j]=table.remove(open,ix) end
    local nout=(math.random()<0.28) and 2 or 1
    local outs={}
    for j=1,nout do
      local s=b:strand(m,{ROLE,labels[nextlabel]},'s'..nextlabel); nextlabel=nextlabel+1
      outs[j]=s; open[#open+1]=s; all[#all+1]=s
    end
    b:face(m,ins,outs,'f'..step)
  end
  return b:finish(),all,open
end

local function incidence_key(s)
  local ps=W.points(s); return tostring(ps[1])..'/'..tostring(ps[2])
end
local function multiset(g)
  local out={}
  for _,s in ipairs(g:egress()) do local k=incidence_key(s); out[k]=(out[k] or 0)+1 end
  return out
end
local function same_set(a,b,case)
  for k,v in pairs(a) do eq(b[k],v,'case '..case..' missing/different '..k) end
  for k,v in pairs(b) do eq(a[k],v,'case '..case..' extra/different '..k) end
end

for case=1,N do
  local frame_count=64+math.random(80)
  local w,ws=world(frame_count)
  local ningress=math.random(1,math.min(4,frame_count))
  local d,all,terminal=development(ningress,math.random(1,10))
  local es={}
  for i=1,ningress do if math.random()<0.75 then es[#es+1]={from=ws[i],to=all[i]} end end
  local joined,jimg=W.join({W.boundary(w),d},es); local ref=W.boundary(joined)
  local fast,fimg=W.advance(w,d,es)
  eq(#fast:egress(),#ref:egress(),'case '..case..' egress arity')
  same_set(multiset(ref),multiset(fast),case)
  -- Unrelated exact frame authority must survive literally.
  local untouched=ws[frame_count]
  if frame_count>ningress then ok(ref:owns_strand(untouched) and fast:owns_strand(untouched),'case '..case..' lost untouched exact frame') end
  -- Terminal Development carriers must map to terminal live authority with the
  -- same rigid imported incidence under both implementations.
  for _,s in ipairs(terminal) do
    local a,b=jimg[s],fimg[s]; ok(a and b,'case '..case..' missing terminal image')
    local ap,bp=W.points(a),W.points(b); eq(#ap,#bp,'case '..case..' terminal point arity')
    for i=1,#ap do eq(ap[i],bp[i],'case '..case..' terminal incidence') end
  end
end
print('PASS advance partial differential',N,'cases',assertions,'assertions')
