package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

-- A deliberately asymmetric tree with a three-Membrane causal spine and
-- several off-spine subtrees of different depths.
local function tree(b)
  local R=b:membrane(nil,'R')
  local A=b:membrane(R,'A')
  local B=b:membrane(A,'B')
  local C=b:membrane(B,'C'); local C2=b:membrane(C,'C2')
  local V=b:membrane(A,'V'); local V2=b:membrane(V,'V2')
  local X=b:membrane(R,'X'); local X2=b:membrane(X,'X2')
  return {R,A,B,C,C2,V,V2,X,X2}
end

local function branch_from(base,host)
  local spine={}; local x=base
  while x do spine[x]=true; x=W.parent(x) end
  if spine[host] then return nil end
  local path={}; x=host
  while x and not spine[x] do path[#path+1]=x; x=W.parent(x) end
  assert(x,'host and causal support lost common root')
  return path[#path] -- first off-spine Membrane: branch resource
end

local function predicted(base,hosts)
  local used={}
  for _,h in ipairs(hosts) do
    local branch=branch_from(base,h)
    if branch then
      if used[branch] then return false end
      used[branch]=true
    end
  end
  return true
end

local function build(base_index,host_indices)
  local b=W.builder(); local ms=tree(b); local base=ms[base_index]
  local s={}; for i=0,#host_indices do s[i]=b:strand(base,{},'s'..i) end
  for i,hi in ipairs(host_indices) do b:face(ms[hi],{s[i-1]},{s[i]},'f'..i) end
  return b:finish(),ms
end

print('1. Worlds locality law equals a causal-spine / off-spine-branch resource law')
local expected_counts={[1]=97,[2]=356,[3]=453}
for _,base_index in ipairs{1,2,3} do
  local actual_count,predicted_count=0,0
  for code=0,9^3-1 do
    local x=code; local hs={}; for i=1,3 do hs[i]=(x%9)+1; x=math.floor(x/9) end
    -- Build a throwaway copy solely to compute the prediction on exact Membranes.
    local pb=W.builder(); local pms=tree(pb); local expect=predicted(pms[base_index],{pms[hs[1]],pms[hs[2]],pms[hs[3]]})
    if expect then predicted_count=predicted_count+1 end
    local good,g=pcall(build,base_index,hs); local actual=good and g:is_developable()
    if actual then actual_count=actual_count+1 end
    eq(actual,expect,'causal-spine law mismatch at base '..base_index..' code '..code)
  end
  eq(actual_count,predicted_count); eq(actual_count,expected_counts[base_index])
end

print('2. moving causal authority down a Membrane path rebases which locality choices are reusable')
local function path_build(depth,states)
  local b=W.builder(); local M={}; M[1]=b:membrane(nil,'root'); for i=2,4 do M[i]=b:membrane(M[i-1],'M'..i) end
  local base=M[depth+1]; local s={}; for i=0,#states do s[i]=b:strand(base,{},'s'..i) end
  for i,h in ipairs(states) do b:face(M[h+1],{s[i-1]},{s[i]},'f'..i) end
  return b:finish()
end
local counts={13,80,189,256}
for depth=0,3 do
  local c=0
  for code=0,4^4-1 do
    local x=code; local st={}; for i=1,4 do st[i]=x%4; x=math.floor(x/4) end
    local good,g=pcall(path_build,depth,st); if good and g:is_developable() then c=c+1 end
  end
  eq(c,counts[depth+1],'path support depth '..depth)
end

print('3. at deepest support every host choice is independent; at root all descendants share one exclusive branch')
do
  local all_root=path_build(0,{0,0,0,0}); ok(all_root:is_developable())
  local good=pcall(path_build,0,{1,2,0,0}); ok(not good,'two different sites in one off-spine branch unexpectedly coexist')
  local deepest=path_build(3,{0,1,2,3}); ok(deepest:is_developable())
  local repeated=path_build(3,{3,3,3,3}); ok(repeated:is_developable(),'spine-local support should be reusable when authority itself lives there')
end

print('PASS causal-spine support law',n,'assertions')
