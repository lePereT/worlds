-- Small non-negative integer bit operations for Lua 5.1-compatible experiments.
local M = {}

local function bit_pair(a, b, mode)
    local out = 0
    local place = 1
    while a > 0 or b > 0 do
        local aa = a % 2
        local bb = b % 2
        local take = false
        if mode == 'and' then
            take = aa == 1 and bb == 1
        elseif mode == 'or' then
            take = aa == 1 or bb == 1
        else
            take = aa ~= bb
        end
        if take then
            out = out + place
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        place = place * 2
    end
    return out
end

function M.band(a, b)
    return bit_pair(a, b, 'and')
end

function M.bor(a, b)
    return bit_pair(a, b, 'or')
end

function M.bxor(a, b)
    return bit_pair(a, b, 'xor')
end

function M.lshift(a, n)
    return a * (2 ^ n)
end

function M.rshift(a, n)
    return math.floor(a / (2 ^ n))
end

function M.idiv(a, b)
    return math.floor(a / b)
end

return M
