-- Generic test continuations for closing or refining an arbitrary packaged Development.
-- They are not channel operations.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local M={}

function M.finish(p,result)
  local a=p:alternative(1)
  local n=#a.authority.outputs
  local right=C.operation(n,0,{}, {'result'},
    {variables={'result'},equalities={T.eq(T.var('result'),result or 'done')}})
  local captures={}
  for i=1,n do captures[i]={from=i,to=i} end
  return C.and_then(p,right,{value_pairs={},captures=captures})
end

function M.accept(p,position,accepted,result)
  local a=p:alternative(1)
  local n=#a.authority.outputs
  local right=C.operation(n,0,{'payload'},{'result'},
    {variables={'payload','result'},equalities={
      T.eq(T.var('payload'),accepted),T.eq(T.var('result'),result or 'accepted')}})
  local captures={}
  for i=1,n do captures[i]={from=i,to=i} end
  return C.and_then(p,right,{value_pairs={{from=position,to=1}},captures=captures})
end

return M
