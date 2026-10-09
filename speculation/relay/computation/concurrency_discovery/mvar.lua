-- MVar-like one-place state protocol over the grounded owner experiment.
local S=require('speculation.relay.computation.concurrency_discovery.state_owner')
local M={}
M.empty=S.seed_empty
M.full=S.seed_full
M.put=S.put
M.take=S.take
M.read=S.read
M.step=S.step
M.view=S.stable_view
M.ground=S.ground
return M
