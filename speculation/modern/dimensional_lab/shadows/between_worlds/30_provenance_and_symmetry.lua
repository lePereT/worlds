package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function fact(k)local z=1;for i=2,k do z=z*i end;return z end

local function vocabulary(k)
  local b=W.builder();local m=b:membrane(nil,'V');local r={}
  for i=1,k do r[i]=b:point(m,'R'..i) end
  b:finish();return r
end
local function symmetric(k,roles)
  local b=W.builder();local m=b:membrane(nil,'S')
  for i=1,k do
    local p=b:point(m,'p'..i);local row=roles and {roles[i],p} or {p}
    local ii=b:strand(m,row,'i'..i);local oo=b:strand(m,row,'o'..i);b:face(m,{ii},{oo},'f'..i)
  end
  return b:finish()
end
local function frame()
  local b=W.builder();b:membrane(nil,'F');return b:finish()
end
local function match_count(S)
  local F=frame()
  local G1,i1=W.join({F,S},{})
  local G2,i2=W.join({F,S},{})
  local solver=W.solve(G1,G2);local c=0
  while true do local tag=solver:step(math.huge);if tag=='yes' then c=c+1 elseif tag=='done' or tag=='no' then break else error('unexpected solve tag '..tostring(tag)) end end
  return c,G1,G2,i1,i2
end

print('1. forgetting exact provenance exposes factorial boundary symmetry')
for k=1,5 do
  local c=match_count(symmetric(k,nil));eq(c,fact(k),'unmarked k-channel boundary symmetry')
end
print('2. rigid exact role Points kill that symmetry without changing causal shape')
for k=2,5 do
  local roles=vocabulary(k);local c=match_count(symmetric(k,roles));eq(c,1,'rigid role marking selects one boundary correspondence')
end

print('3. common source images nevertheless select one exact marked correspondence between fresh outcomes')
do
  local S=symmetric(3,nil);local F=frame();local G1,i1=W.join({F,S},{});local G2,i2=W.join({F,S},{})
  local marked={}
  for _,kind in ipairs{'membranes','points','strands','faces'} do
    for _,x in ipairs(S[kind](S)) do marked[i1[x]]=i2[x] end
  end
  -- The marked lift is functional and covers every carrier materialised from S.
  local covered=0;for _ in pairs(marked) do covered=covered+1 end
  eq(covered,#S:membranes()+#S:points()+#S:strands()+#S:faces())
  -- Bare composition matching still sees 3! permutations of the unmarked ports.
  local solver=W.solve(G1,G2);local c=0;while true do local tag=solver:step(math.huge);if tag=='yes' then c=c+1 elseif tag=='done' or tag=='no' then break end end
  eq(c,6)
end

print('PASS provenance marking removes factorial matching isotropy',n,'assertions')
