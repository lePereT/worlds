-- Shared disposable matching implementation.
local Kernel=require('worlds._kernel')
local K=Kernel.private
local Fast=require('worlds._fast')(K)
K.try_match_join=K.try_match_join or Fast.try_match_join
local Public,Private=require('worlds.query_factory')(Kernel.public,K)
return {public=Public,private=Private}
