-- Internal edge capability: verified centre observations plus disposable fast paths.
-- The centre never imports this module.
local Centre=require('worlds._centre')
local K={}
setmetatable(K,{__index=Centre.private})
for k,v in pairs(require('worlds._fast')(Centre.private)) do K[k]=v end
return {centre=Centre,private=K}
