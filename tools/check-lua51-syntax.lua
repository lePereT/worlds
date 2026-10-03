-- Reject syntax introduced after Lua 5.1.

local function long_open(text, index)
    if text:sub(index, index) ~= '[' then
        return nil
    end
    local cursor = index + 1
    while text:sub(cursor, cursor) == '=' do
        cursor = cursor + 1
    end
    if text:sub(cursor, cursor) ~= '[' then
        return nil
    end
    return cursor - index - 1, cursor + 1
end

local function long_close(text, index, equals)
    if text:sub(index, index) ~= ']' then
        return nil
    end
    local cursor = index + 1
    for _ = 1, equals do
        if text:sub(cursor, cursor) ~= '=' then
            return nil
        end
        cursor = cursor + 1
    end
    if text:sub(cursor, cursor) ~= ']' then
        return nil
    end
    return cursor + 1
end

local function fail(path, line, message)
    error(path .. ':' .. line .. ': Lua 5.1 syntax: ' .. message, 0)
end

local function check_line(path, number, line, state)
    local visible = {}
    local index = 1
    while index <= #line do
        if state.kind == 'short' then
            local char = line:sub(index, index)
            if char == '\\' then
                local escape = line:sub(index + 1, index + 1)
                if escape == 'x' or escape == 'z' or escape == 'u' then
                    fail(path, number, 'post-5.1 string escape \\' .. escape)
                end
                index = index + 2
            elseif char == state.quote then
                state.kind = 'code'
                state.quote = nil
                index = index + 1
            else
                index = index + 1
            end
        elseif state.kind == 'long' or state.kind == 'long-comment' then
            local finish = long_close(line, index, state.equals)
            if finish then
                state.kind = 'code'
                state.equals = nil
                index = finish
            else
                index = index + 1
            end
        else
            local char = line:sub(index, index)
            local pair = line:sub(index, index + 1)
            if pair == '--' then
                local equals, finish = long_open(line, index + 2)
                if equals then
                    state.kind = 'long-comment'
                    state.equals = equals
                    index = finish
                else
                    break
                end
            elseif char == "'" or char == '"' then
                state.kind = 'short'
                state.quote = char
                index = index + 1
            elseif char == '[' then
                local equals, finish = long_open(line, index)
                if equals then
                    state.kind = 'long'
                    state.equals = equals
                    index = finish
                else
                    visible[#visible + 1] = char
                    index = index + 1
                end
            else
                visible[#visible + 1] = char
                index = index + 1
            end
        end
    end
    if state.kind == 'short' then
        fail(path, number, 'unfinished short string')
    end
    local code = table.concat(visible)
    if code:find('::', 1, true) then
        fail(path, number, 'labels (::) require Lua 5.2')
    end
    if code:find('//', 1, true) then
        fail(path, number, 'floor division (//) requires Lua 5.3')
    end
    if code:find('<<', 1, true) or code:find('>>', 1, true) then
        fail(path, number, 'bit shifts require Lua 5.3')
    end
    if code:find('&', 1, true) or code:find('|', 1, true) then
        fail(path, number, 'bitwise operators require Lua 5.3')
    end
    local cursor = 1
    while true do
        local at = code:find('~', cursor, true)
        if not at then
            break
        end
        if code:sub(at + 1, at + 1) ~= '=' then
            fail(path, number, 'bitwise xor/not requires Lua 5.3')
        end
        cursor = at + 2
    end
    if code:match('%f[%a_]goto%f[^%w_]') then
        fail(path, number, 'goto requires Lua 5.2')
    end
    if code:match('<%s*const%s*>') or code:match('<%s*close%s*>') then
        fail(path, number, 'variable attributes require Lua 5.4')
    end
    if code:match('0[xX][%da-fA-F]+[%.pP]') then
        fail(path, number, 'hexadecimal floating literals require Lua 5.2')
    end
end

local function check_file(path)
    local file = assert(io.open(path, 'rb'))
    local state = { kind = 'code' }
    local number = 0
    for line in file:lines() do
        number = number + 1
        check_line(path, number, line, state)
    end
    file:close()
    assert(state.kind == 'code', path .. ': unfinished long string or comment')
end

local command = "find src tests bench tools speculation compat " ..
    "-type f -name '*.lua' -print | sort"
local files = assert(io.popen(command, 'r'))
local count = 0
for path in files:lines() do
    check_file(path)
    count = count + 1
end
assert(files:close())
print('PASS Lua 5.1 syntax: ' .. count .. ' files')
