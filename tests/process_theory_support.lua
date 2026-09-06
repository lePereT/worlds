local T={}

function T.classify(attachments, judge)
  local r={accepted={},rejected={},unknown={}}
  for _,a in ipairs(attachments) do
    local ok,res=pcall(judge,a)
    local k
    if not ok or res==nil or res=='unknown' then k='unknown'
    elseif res==true or res=='accepted' then k='accepted'
    else k='rejected' end
    r[k][#r[k]+1]=a
  end
  return r
end

function T.mod_eq(a,b,n)
  return ((a-b)%n)==0
end

local function scalar(x) return type(x)=='number' and x or nil end
function T.projective_eq(a,b)
  if #a~=#b then return false end
  local scale=nil
  for i=1,#a do
    if a[i]~=0 or b[i]~=0 then
      if a[i]==0 or b[i]==0 then return false end
      scale=b[i]/a[i]; break
    end
  end
  if not scale then return true end
  for i=1,#a do if b[i]~=a[i]*scale then return false end end
  return true
end

function T.term_normal(term)
  if type(term)~='table' then return tostring(term) end
  if term.op=='add' then
    local a,b=T.term_normal(term.a),T.term_normal(term.b)
    if b<a then a,b=b,a end
    return 'add('..a..','..b..')'
  end
  return tostring(term.atom or term.op or term)
end

return T
