local function quote(s)
    return string.format('%q', s)
end

local lua = os.getenv('LUA') or arg[-1] or 'lua'
local root = arg[1] or 'tests'

local p = assert(io.popen("find " .. quote(root) .. " -maxdepth 1 -type f -name '*.lua' -print | sort"))
local tests = {}
for path in p:lines() do
    local name = path:match('([^/]+)$') or path
    if name:match('^%d%d_.*%.lua$') or name:match('_test%.lua$') then
        tests[#tests + 1] = path
    end
end
assert(p:close())

if #tests == 0 then
    io.stderr:write('no tests found\n')
    os.exit(1)
end

for _, path in ipairs(tests) do
    io.write('== ', path, ' ==\n')
    local ok = os.execute(lua .. ' ' .. quote(path))
    if ok ~= true and ok ~= 0 then os.exit(1) end
end

io.write(string.format('ok - %d test file(s)\n', #tests))
