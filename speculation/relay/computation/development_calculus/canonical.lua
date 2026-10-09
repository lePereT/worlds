-- speculation.relay.computation.development_calculus.canonical -- old Relay canonical transport
-- Canonical transport for plain finite Lua data.

local M = {}

local function plain_table(value)
    return type(value) == 'table' and getmetatable(value) == nil
end

local function keys(value)
    local out = {}
    for key in pairs(value) do
        out[#out + 1] = key
    end
    table.sort(out, function(a, b)
        local ta = type(a)
        local tb = type(b)
        if ta ~= tb then
            return ta < tb
        end
        if ta == 'number' then
            return a < b
        end
        return tostring(a) < tostring(b)
    end)
    return out
end

local function encode_into(value, out, seen)
    local kind = type(value)
    if kind == 'nil' then
        out[#out + 1] = 'z'
    elseif kind == 'boolean' then
        out[#out + 1] = value and 'T' or 'F'
    elseif kind == 'number' then
        assert(value % 1 == 0, 'canonical transport only carries integers')
        assert(math.abs(value) <= 9007199254740991,
            'canonical transport integer outside exact host range')
        out[#out + 1] = 'i' .. string.format('%.0f', value) .. ';'
    elseif kind == 'string' then
        out[#out + 1] = 's' .. #value .. ':' .. value
    elseif kind == 'table' then
        assert(plain_table(value), 'canonical transport requires plain finite data')
        assert(not seen[value], 'canonical transport data must be acyclic')
        seen[value] = true
        local ordered = keys(value)
        out[#out + 1] = 't' .. #ordered .. '{'
        for _, key in ipairs(ordered) do
            encode_into(key, out, seen)
            encode_into(value[key], out, seen)
        end
        out[#out + 1] = '}'
        seen[value] = nil
    else
        error('canonical transport cannot encode ' .. kind, 3)
    end
end

function M.encode(value)
    local out = {}
    encode_into(value, out, {})
    return table.concat(out)
end

local function parser(bytes)
    local index = 1

    local function take(count)
        local value = bytes:sub(index, index + count - 1)
        assert(#value == count, 'truncated canonical bytes')
        index = index + count
        return value
    end

    local function number_until(marker)
        local stop = assert(bytes:find(marker, index, true),
            'truncated canonical integer')
        local text = bytes:sub(index, stop - 1)
        index = stop + 1
        assert(text:match('^-?%d+$'), 'invalid canonical integer')
        local value = assert(tonumber(text), 'canonical integer outside host range')
        assert(math.abs(value) <= 9007199254740991,
            'canonical integer outside exact host range')
        return value
    end

    local decode
    decode = function()
        local tag = take(1)
        if tag == 'z' then
            return nil
        end
        if tag == 'T' then
            return true
        end
        if tag == 'F' then
            return false
        end
        if tag == 'i' then
            return number_until(';')
        end
        if tag == 's' then
            local count = number_until(':')
            assert(count >= 0, 'negative canonical string size')
            return take(count)
        end
        if tag == 't' then
            local count = number_until('{')
            assert(count >= 0, 'negative canonical table size')
            local value = {}
            for _ = 1, count do
                local key = decode()
                assert(key ~= nil, 'nil canonical table key')
                assert(value[key] == nil, 'duplicate canonical table key')
                value[key] = decode()
            end
            assert(take(1) == '}', 'malformed canonical table')
            return value
        end
        error('invalid canonical transport tag ' .. tostring(tag), 2)
    end

    return function()
        local value = decode()
        assert(index == #bytes + 1, 'trailing canonical bytes')
        return value
    end
end

function M.decode(bytes)
    assert(type(bytes) == 'string', 'canonical bytes required')
    return parser(bytes)()
end

return M
