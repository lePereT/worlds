-- Repository Lua style gate.
-- Every physical Lua line is at most 100 characters and Lua code contains no semicolon token.

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

local function check_code(path, line, state)
    local index = 1
    while index <= #line do
        if state.kind == 'short' then
            local char = line:sub(index, index)
            if char == '\\' then
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
            if line:sub(index, index + 1) == '--' then
                local equals, finish = long_open(line, index + 2)
                if equals then
                    state.kind = 'long-comment'
                    state.equals = equals
                    index = finish
                else
                    return
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
                    index = index + 1
                end
            elseif char == ';' then
                error(path .. ': Lua code semicolon at column ' .. index, 0)
            else
                index = index + 1
            end
        end
    end
    if state.kind == 'short' then
        error(path .. ': unfinished short string', 0)
    end
end

local function check_file(path)
    local file = assert(io.open(path, 'rb'))
    local state = { kind = 'code' }
    local number = 0
    for line in file:lines() do
        number = number + 1
        if #line > 100 then
            error(path .. ':' .. number .. ': line is ' .. #line .. ' characters', 0)
        end
        local ok, message = pcall(check_code, path, line, state)
        if not ok then
            error(path .. ':' .. number .. ': ' .. message, 0)
        end
    end
    file:close()
    assert(state.kind == 'code', path .. ': unfinished long string or comment')
end

-- Relay research laboratories are executable archives with their own check.
-- Production and historical speculation retain the compact repository style gate.
local command = "find src tests bench tools speculation compat " ..
    "-type f -name '*.lua' ! -path 'speculation/relay/theory/*' " ..
    "! -path 'speculation/relay/computation/*' -print | sort"
local files = assert(io.popen(command, 'r'))
local count = 0
for path in files:lines() do
    check_file(path)
    count = count + 1
end
assert(files:close())
print('PASS Lua style: ' .. count .. ' files, zero code semicolons, max 100 characters')
