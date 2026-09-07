local W=require('worlds')
local H={W=W,G=W.Geometry,Cut=W.Cut}
function H.vocab(names)
  local b=W.Geometry.builder(); local m=b:membrane(nil,'theory-vocabulary'); local r={}
  for _,n in ipairs(names) do r[n]=b:point(m,n) end
  b:finish(); return r
end
function H.annotation()
  local a={}
  function a:set(p,v) self[p]=v; return p end
  function a:get(p) return self[p] end
  return a
end
function H.structural(source,pattern)
  return assert(W.Cut.all(pattern,{offers=source:egress()}))
end
function H.classify(cuts,judge)
  local r={accepted={},rejected={},unknown={}}
  for _,c in ipairs(cuts) do
    local ok,v=pcall(judge,c); local k
    if not ok or v==nil or v=='unknown' then k='unknown' elseif v==true or v=='accepted' then k='accepted' else k='rejected' end
    r[k][#r[k]+1]=c
  end
  return r
end
function H.tri_eq(a,b,eq)
  local ok,v=pcall(eq,a,b); if not ok or v==nil then return 'unknown' end; return v and 'equal' or 'distinct'
end
function H.projective_eq(a,b)
  if #a~=#b then return false end; local scale=nil
  for i=1,#a do if a[i]~=0 or b[i]~=0 then if a[i]==0 or b[i]==0 then return false end; scale=b[i]/a[i]; break end end
  if not scale then return true end; for i=1,#a do if b[i]~=a[i]*scale then return false end end; return true
end
function H.term_normal(term)
  if type(term)~='table' then return tostring(term) end
  if term.op=='add' then local a,b=H.term_normal(term.a),H.term_normal(term.b); if b<a then a,b=b,a end; return 'add('..a..','..b..')' end
  return tostring(term.atom or term.op or term)
end
return H
