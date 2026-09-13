-- Runtime-independent deterministic PRNG for generated tests.
-- Park-Miller's product stays below 2^53 for every valid state, so integer
-- arithmetic is exact on both LuaJIT numbers and ordinary double-number Lua.
local M={}
local MOD=2147483647
local MUL=16807
function M.new(seed)
  seed=math.floor(tonumber(seed) or 1)%MOD; if seed<=0 then seed=seed+MOD-1 end
  local state=seed
  return function(a,b)
    state=(state*MUL)%MOD
    if a==nil then return state/MOD end
    if b==nil then assert(a>=1 and a==math.floor(a)); return 1+(state%a) end
    assert(a<=b and a==math.floor(a) and b==math.floor(b)); return a+(state%(b-a+1))
  end
end
return M
