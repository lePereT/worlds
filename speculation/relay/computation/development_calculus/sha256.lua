-- speculation.relay.computation.development_calculus.sha256 -- old Relay content identity
-- Mechanical only, no Relay semantic logic or transport format.

local M={}

-- SHA-256 content identity
-- Small SHA-256 implementation used for stable content identities during the
-- Lua 5.1/LuaJIT bootstrap. Prefer a native bit library when one is present,
-- but retain a pure arithmetic fallback so stock Lua 5.1 needs no extra module.

local MOD = 4294967296
local bit=rawget(_G,'bit') or rawget(_G,'bit32')
if not bit and rawget(_G,'jit') then bit=require('bit') end

local band, bxor, bnot, rshift, ror
if bit then
    band, bxor, bnot = bit.band, bit.bxor, bit.bnot
    rshift = bit.rshift
    ror = bit.ror or bit.rrotate
else
    local function u32(x) return x % MOD end
    local function band2(a,b)
        a,b=u32(a),u32(b)
        local out,place=0,1
        for _=1,32 do
            local aa,bb=a%2,b%2
            if aa==1 and bb==1 then out=out+place end
            a=(a-aa)/2
 b=(b-bb)/2
 place=place*2
        end
        return out
    end
    local function bxor2(a,b)
        a,b=u32(a),u32(b)
        local out,place=0,1
        for _=1,32 do
            local aa,bb=a%2,b%2
            if aa~=bb then out=out+place end
            a=(a-aa)/2
 b=(b-bb)/2
 place=place*2
        end
        return out
    end
    band=function(a,b,...)
        local out=band2(a,b)
        for i=1,select('#',...) do out=band2(out,select(i,...)) end
        return out
    end
    bxor=function(a,b,...)
        local out=bxor2(a,b)
        for i=1,select('#',...) do out=bxor2(out,select(i,...)) end
        return out
    end
    bnot=function(a) return 4294967295-u32(a) end
    rshift=function(a,n) return math.floor(u32(a)/(2^n)) end
    ror=function(a,n)
        n=n%32
 a=u32(a)
        if n==0 then return a end
        local low=a%(2^n)
        return (math.floor(a/(2^n))+low*(2^(32-n)))%MOD
    end
end

local function u32mod(x) return x % MOD end
local function add(...)
    local n=0
    for i=1,select('#',...) do n=n+(select(i,...)) end
    return n % MOD
end
local function ch(x,y,z) return bxor(band(x,y), band(bnot(x),z)) end
local function maj(x,y,z) return bxor(band(x,y),band(x,z),band(y,z)) end
local function S0(x) return bxor(ror(x,2),ror(x,13),ror(x,22)) end
local function S1(x) return bxor(ror(x,6),ror(x,11),ror(x,25)) end
local function s0(x) return bxor(ror(x,7),ror(x,18),rshift(x,3)) end
local function s1(x) return bxor(ror(x,17),ror(x,19),rshift(x,10)) end

local K={
  0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
  0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
  0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
  0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
  0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
  0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
  0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
  0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
}

local function be32(n)
    n=u32mod(n)
    local a=math.floor(n/16777216)%256
    local b=math.floor(n/65536)%256
    local c=math.floor(n/256)%256
    local d=n%256
    return string.char(a,b,c,d)
end

local function word(s,i)
    local a,b,c,d=s:byte(i,i+3)
    return ((a*256+b)*256+c)*256+d
end

local function pad(s)
    local bitlen=#s*8
    local high=math.floor(bitlen/MOD)
    local low=bitlen%MOD
    local zeros=(56-((#s+1)%64))%64
    return s..string.char(0x80)..string.rep('\0',zeros)..be32(high)..be32(low)
end

function M.sha256(s)
    assert(type(s)=='string','sha256 input must be a string')
    s=pad(s)
    local h0,h1,h2,h3=0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a
    local h4,h5,h6,h7=0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
    for off=1,#s,64 do
        local w={}
        for i=1,16 do w[i]=word(s,off+(i-1)*4) end
        for i=17,64 do w[i]=add(s1(w[i-2]),w[i-7],s0(w[i-15]),w[i-16]) end
        local a,b,c,d,e,f,g,h=h0,h1,h2,h3,h4,h5,h6,h7
        for i=1,64 do
            local t1=add(h,S1(e),ch(e,f,g),K[i],w[i])
            local t2=add(S0(a),maj(a,b,c))
            h,g,f,e,d,c,b,a=g,f,e,add(d,t1),c,b,a,add(t1,t2)
        end
        h0,h1,h2,h3=add(h0,a),add(h1,b),add(h2,c),add(h3,d)
        h4,h5,h6,h7=add(h4,e),add(h5,f),add(h6,g),add(h7,h)
    end
    local raw=be32(h0)..be32(h1)..be32(h2)..be32(h3)..be32(h4)..be32(h5)..be32(h6)..be32(h7)
    return (raw:gsub('.',function(c) return string.format('%02x',c:byte()) end))
end


function M.semantic_bytes(bytes) assert(type(bytes)=='string')
return 'semantic:sha256:'..M.sha256(bytes) end
return M
