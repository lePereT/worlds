local W=require('worlds')
local function parent_arrays(n)
  local out,row={},{}
  local function go(i) if i>n then local x={}
  for k=1,n do x[k]=row[k] end
  out[#out+1]=x
  return end
  for p=0,i-1 do row[i]=p
  go(i+1) end end
  go(1)
  return out
end
local function patterns()
  local out={}
  for mask=0,63 do local es,fs,ts={}, {}, {}
  local ok=true
  local bit=0
  for i=1,3 do for j=1,3 do if i~=j then if math.floor(mask/2^bit)%2==1 then if fs[i] or ts[j]
      then ok=false else fs[i]=true
  ts[j]=true
  es[#es+1]={from=i,to=j} end end
  bit=bit+1 end end end
  if ok then out[#out+1]=es end end
  return out
end
local function make(parents,where)
  local b=W.builder()
  local ms={}
  for i=1,#parents do ms[i]=b:membrane(parents[i]==0 and nil or ms[parents[i]],nil) end
  local ps,ss={},{}
  for i=1,3 do ps[i]=b:point(ms[where[i]],nil)
  ss[i]=b:strand(ms[where[i]],{ps[i]},nil) end
  return b:finish(),ms,ps,ss
end
local function check_image(g,image)
  for _,m in ipairs(g:membranes()) do local im=assert(image[m])
  local p=W.parent(m)
  if p then local ip=assert(image[p])
  if im~=ip and W.parent(im)~=ip then return false,
      'Membrane parent incidence did not commute with image' end end end
  for _,p in ipairs(g:points()) do local ip=assert(image[p])
  if W.membrane(ip)~=assert(image[W.membrane(p)]) then return false,
      'Point placement did not commute with image' end end
  for _,s in ipairs(g:strands()) do local is=image[s]
  if is then if W.membrane(is)~=assert(image[W.membrane(s)]) then return false,
      'Strand placement did not commute with image' end
  local a,b=W.points(s),W.points(is)
  if #a~=#b then return false,'Strand arity changed' end
  for i,p in ipairs(a) do local q=image[p] or p
  if b[i]~=q then return false,'ordered Point incidence did not commute with image' end end end end
  return true
end
return function()
  local eqsets=patterns()
  local checks=0
  for n=1,3 do for _,parents in ipairs(parent_arrays(n)) do for a=1,n do for b=1,n do for c=1,n
      do local g,_,_,ss=make(parents,{a,b,c})
  for _,pat in ipairs(eqsets) do local es={}
  for _,e in ipairs(pat) do es[#es+1]={from=ss[e.from],to=ss[e.to]} end
  local ok,r,img=pcall(W.join,{g},es)
  checks=checks+1
  if ok then local good,why=check_image(g,img)
  assert(good,why) end end end end end end end
  return tostring(checks)..' generated quotient attempts preserve image-relative ' ..
      'parent/placement/ordered-Point incidence whenever lawful'
end
