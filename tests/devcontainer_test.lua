local function read(path)
    local f = assert(io.open(path, 'rb'))
    local text = assert(f:read('*a'))
    f:close()
    return text
end

local dockerfile = read('.devcontainer/Dockerfile')
local zshrc = read('.devcontainer/zshrc')

assert(dockerfile:match('^FROM alpine:3%.24'), 'devcontainer must remain Alpine 3.24 based')
assert(dockerfile:find('github.com/LuaJIT/LuaJIT/archive/', 1, true), 'LuaJIT must come from upstream')
assert(dockerfile:find('LUAJIT_COMMIT=', 1, true), 'LuaJIT source must be pinned')
assert(dockerfile:find('LUAJIT_SHA256=', 1, true), 'LuaJIT archive must be checksummed')
assert(not dockerfile:match('apk add[^\n]*luajit'), "do not silently use Alpine's LuaJIT package")
assert(not dockerfile:lower():find('python', 1, true), 'Worlds devcontainer must not depend on Python')
assert(dockerfile:match('%s+zsh%s*\\'), 'devcontainer must install zsh')
assert(dockerfile:find('-s /bin/zsh worlds', 1, true), 'Worlds devcontainer user must use zsh')
assert(dockerfile:find('COPY zshrc /home/worlds/.zshrc', 1, true), 'devcontainer must install its small zsh configuration')
assert(zshrc:find('compinit', 1, true), 'zsh configuration should provide completion')
assert(zshrc:find('PROMPT=', 1, true), 'zsh configuration should provide a useful prompt')

print('devcontainer: ok')
