local function quote(s)
    return string.format('%q', s)
end

local lua = os.getenv('LUA') or arg[-1] or 'lua'
local root = arg[1] or 'bench'
local p = assert(io.popen("find " .. quote(root) .. " -type f -name '*_bench.lua' -print | sort"))
local ran = 0
for path in p:lines() do
    ran = ran + 1
    io.write('== ', path, ' ==\n')
    local ok = os.execute(lua .. ' ' .. quote(path))
    if ok ~= true and ok ~= 0 then os.exit(1) end
end
assert(p:close())
if ran == 0 then io.write('no benchmarks yet\n') end
