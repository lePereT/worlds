-- IVar/promise as a grounded owner protocol. The one state transition is exact authority;
-- stable observations are positive knowledge and do not capture that authority.
local S=require('speculation.relay.computation.concurrency_discovery.state_owner')
local C=require('speculation.relay.computation.development_calculus.calculus')
local M={}
function M.empty(identity) return S.seed_empty(identity) end
function M.put(identity,value) return S.put(identity,value) end
function M.await(identity) return S.read(identity) end
function M.step(state,request) return S.step(state,request) end
function M.view(state) return S.stable_view(state) end
function M.readers(n)
  local xs={}
  for i=1,n do xs[i]=S.stable_reader() end
  return C.each(xs)
end
function M.observe_many(state,n)
  local pairs={}
  for i=1,n do
    pairs[#pairs+1]={from=1,to=2*i-1}
    pairs[#pairs+1]={from=2,to=2*i}
  end
  return C.and_then(state,M.readers(n),{value_pairs=pairs,captures={}})
end
return M
