package.path='./src/?.lua;./src/?/init.lua;'..package.path

local Persistent=require('worlds._persistent')

local base={}
for i=1,100 do base[i]=i end
local internal=Persistent.sequence_concat(base,{101})

assert(Persistent.length(internal)==101,'persistent sequence length mismatch')
assert(#internal==0,'internal sequence became a table-length proxy again')

local public=Persistent.array(internal)
assert(#public==101,'public sequence view is not a dense Lua array')
for i=1,101 do assert(public[i]==i,'public sequence view changed order') end
assert(Persistent.array(internal)==public,'public sequence materialisation is not cached')

print('PASS Lua 5.1 persistent/public sequence shape',105,'assertions')
