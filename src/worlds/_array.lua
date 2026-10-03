-- Dense-array validation for finite Worlds API sections.
--
-- Worlds is an in-process kernel for trusted clients. Arrays are borrowed
-- read-only values: validation checks their shape once, but does not clone them.

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

return M
