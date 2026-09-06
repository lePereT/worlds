local T={}

function T.annotation()
  local a={}
  function a:set(point,value) self[point]=value; return point end
  function a:get(point) return self[point] end
  function a:transport(pattern_values,image)
    for pp,v in pairs(pattern_values or {}) do
      local gp=image.points[pp]
      if gp then self[gp]=v end
    end
  end
  return a
end

function T.tri_eq(a,b,eq)
  local ok,res=pcall(eq,a,b)
  if not ok or res==nil then return 'unknown' end
  return res and 'equal' or 'distinct'
end

function T.projective_eq(a,b)
  -- Tiny real-vector projective equality: vectors are equal up to non-zero scalar.
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

return T
