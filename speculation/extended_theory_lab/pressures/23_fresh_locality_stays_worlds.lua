local W=require('worlds')
return function()
  local ok,err=pcall(function()
    local b=W.builder()
    local a=b:membrane(nil,'available')
    local z=b:membrane(nil,'unanchored')
    local i=b:strand(a,{},'in')
    local o=b:strand(z,{},'out')
    b:face(a,{i},{o},'illegal')
    return b:finish()
  end)
  assert(not ok and
      tostring(err):match('fresh locality must descend from causally available locality'),
          'extended Theory should not need to duplicate fresh-locality law')
  return 'fresh support anchoring remains a Worlds Geometry law, not a Theory predicate'
end
