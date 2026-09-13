-- Private dense-array validation for public Worlds finite inputs.
-- Internal kernel arrays are already trusted and should not pay this check.

local M={}

function M.length(xs,label)
  assert(type(xs)=='table',(label or 'value')..' must be an array')
  local n,count=0,0
  for k in next,xs do
    assert(type(k)=='number' and k>=1 and k%1==0,(label or 'value')..' must be a dense array')
    if k>n then n=k end
    count=count+1
  end
  assert(n==count,(label or 'value')..' must be a dense array')
  return n
end

function M.copy(xs,label)
  local n=M.length(xs,label)
  local out={}
  for i=1,n do out[i]=xs[i] end
  return out
end

return M
