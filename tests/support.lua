local Worlds=require('worlds')
local G,A=Worlds.Geometry,Worlds.Attach

local S={Worlds=Worlds,G=G,A=A}

function S.eq(a,b,msg)
  assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b))
end

function S.ok(x,msg) assert(x,msg or 'expected truth') end
function S.no(x,msg) assert(not x,msg or 'expected falsehood') end

function S.raises(fn,needle)
  local ok,err=pcall(fn)
  assert(not ok,'expected error')
  if needle then assert(tostring(err):find(needle,1,true), 'error did not contain '..needle..': '..tostring(err)) end
end

function S.set(xs)
  local r={}; for _,x in ipairs(xs) do r[x]=true end; return r
end

function S.permutations(xs)
  local out={}
  local function rec(a,i)
    if i>#a then local z={}; for j=1,#a do z[j]=a[j] end; out[#out+1]=z; return end
    for j=i,#a do a[i],a[j]=a[j],a[i]; rec(a,i+1); a[i],a[j]=a[j],a[i] end
  end
  local a={}; for i=1,#xs do a[i]=xs[i] end; rec(a,1); return out
end

return S
