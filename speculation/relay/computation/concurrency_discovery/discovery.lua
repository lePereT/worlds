-- Disposable cooperative discovery strategies. These are deliberately not semantic
-- runtime objects: every function returns ordinary packaged Development meaning.
local C=require('speculation.relay.computation.development_calculus.calculus')
local M={}

function M.whole(actions)
  return C.together(actions)
end

function M.pairs(actions,pairs)
  local closed={}
  for i,pair in ipairs(pairs) do
    closed[i]=C.together({actions[pair[1]],actions[pair[2]]})
  end
  return C.each(closed)
end

return M
