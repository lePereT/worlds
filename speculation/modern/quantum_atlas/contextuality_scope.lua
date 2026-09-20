-- Atlas-derived quantum attack: contextuality as overlapping Point-Strand scope.
-- Worlds carries the compatibility cover; a tiny external parity Theory carries
-- the local value constraints. No crossing membranes or new geometry required.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local b=W.builder(); local m=b:membrane(nil,'Mermin-Peres')
local P={}
for r=1,3 do P[r]={}; for c=1,3 do P[r][c]=b:point(m,'O'..r..c) end end
local contexts={}
for r=1,3 do contexts[#contexts+1]={name='R'..r, strand=b:strand(m,{P[r][1],P[r][2],P[r][3]},'row '..r), sign=1} end
for c=1,3 do contexts[#contexts+1]={name='C'..c, strand=b:strand(m,{P[1][c],P[2][c],P[3][c]},'column '..c), sign=(c==3 and -1 or 1)} end
local g=b:finish()

eq(#g:faces(),0,'compatibility cover is face-free')
eq(#g:strands(),6,'six measurement contexts')
eq(#g:points(),9,'nine observable identities')

-- Every observable occurs in exactly two crossing contexts: its row and column.
local degree={}
for _,ctx in ipairs(contexts) do
  for _,p in ipairs(W.points(ctx.strand)) do degree[p]=(degree[p] or 0)+1 end
end
for r=1,3 do for c=1,3 do eq(degree[P[r][c]],2,'observable belongs to row and column') end end

-- Each local parity context is individually satisfiable by exactly four +/-1 assignments.
local function local_count(sign)
  local k=0
  for a=-1,1,2 do for bb=-1,1,2 do for c=-1,1,2 do if a*bb*c==sign then k=k+1 end end end end
  return k
end
for _,ctx in ipairs(contexts) do eq(local_count(ctx.sign),4,'each context locally satisfiable') end

-- Global noncontextual assignments would give one +/-1 value to each exact Point.
-- The Mermin-Peres parity cover has none: multiplying all six constraints gives
-- +1 on the left (each variable occurs twice) and -1 on the right.
local function global_count(skip)
  local count=0
  for bits=0,511 do
    local vals={}
    for i=0,8 do vals[i+1]=(math.floor(bits/(2^i))%2==0) and -1 or 1 end
    local good=true
    for ci,ctx in ipairs(contexts) do
      if ci~=skip then
        local prod=1
        for _,p in ipairs(W.points(ctx.strand)) do
          local idx
          for r=1,3 do for c=1,3 do if P[r][c]==p then idx=(r-1)*3+c end end end
          prod=prod*vals[idx]
        end
        if prod~=ctx.sign then good=false; break end
      end
    end
    if good then count=count+1 end
  end
  return count
end

eq(global_count(nil),0,'no global noncontextual section')
for i=1,6 do eq(global_count(i),16,'removing one context restores exactly 16 global sections') end

-- Boundary retains the entire crossing cover without inventing a membrane semilattice.
local bg=W.boundary(g)
eq(#bg:egress(),6,'all context factors remain open')
eq(#bg:faces(),0,'boundary remains purely configurational')

print('contextuality scope: '..n..' assertions passed')
print('  overlapping Point-Strand incidence carries the compatibility cover')
print('  local Theory constraints are satisfiable; no global noncontextual assignment exists')
