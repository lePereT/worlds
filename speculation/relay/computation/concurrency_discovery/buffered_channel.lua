-- One-place buffered channel derived entirely from the MVar protocol.
-- There is no buffer semantic object: empty/full state is the buffer.
local V=require('speculation.relay.computation.concurrency_discovery.mvar')
local M={}
M.empty=V.empty
M.send=V.put
M.recv=V.take
M.step=V.step
return M
