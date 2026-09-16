package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local total=0
local function ok(x,m) total=total+1; assert(x,m) end
local function eq(a,b,m) total=total+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local seed=0x61c88647
local function rnd(n) seed=(1103515245*seed+12345)%2147483648; return (seed%n)+1 end

local atoms=W.builder(); local am=atoms:membrane(nil,'atoms'); local R=atoms:point(am,'R'); atoms:finish()
local function world(n)
  local b=W.builder(); local m=b:membrane(nil,'world'); local xs={}; for i=1,n do xs[i]=b:strand(m,{R},'o'..i) end; return b:finish(),xs
end
local function pattern(n)
  local b=W.builder(); local m=b:membrane(nil,'pattern'); local xs={}; for i=1,n do xs[i]=b:strand(m,{R},'d'..i) end; return b:finish(),xs
end
local function key(from,to) return tostring(from)..'>'..tostring(to) end

local function brute(offers,demands,forbidden,seeds)
  local used,forced={},{}; for _,e in ipairs(seeds) do used[e.from]=true; forced[e.to]=e.from end
  local count=0
  local function walk(i)
    if i>#demands then count=count+1; return end
    local d=demands[i]; local f=forced[d]
    if f then walk(i+1); return end
    walk(i+1) -- leave open
    for _,o in ipairs(offers) do if not used[o] and not forbidden[key(o,d)] then used[o]=true; walk(i+1); used[o]=nil end end
  end
  walk(1); return count
end

for case=1,1000 do
  local no,nd=rnd(4),rnd(4); local wg,offers=world(no); local pg,demands=pattern(nd)
  local forbid,forbidden={},{}
  for _,d in ipairs(demands) do for _,o in ipairs(offers) do if rnd(5)==1 then forbid[#forbid+1]={from=o,to=d}; forbidden[key(o,d)]=true end end end
  local seeds={}; local seeded_d,seeded_o={},{}
  if rnd(3)==1 then
    local ds={}; for _,d in ipairs(demands) do ds[#ds+1]=d end
    for _=1,math.min(2,#demands,#offers) do
      local d=ds[rnd(#ds)]; if not seeded_d[d] then
        local choices={}; for _,o in ipairs(offers) do if not seeded_o[o] and not forbidden[key(o,d)] then choices[#choices+1]=o end end
        if #choices>0 then local o=choices[rnd(#choices)]; seeds[#seeds+1]={from=o,to=d}; seeded_d[d]=true; seeded_o[o]=true end
      end
    end
  end
  local expected=brute(offers,demands,forbidden,seeds)
  local admissible={}
  for _,d in ipairs(demands) do for _,o in ipairs(offers) do if not forbidden[key(o,d)] then admissible[#admissible+1]={from=o,to=d} end end end
  local q=Query.solve(Query.match(wg,pg,{sources=offers,targets=(case%2==0) and {table.unpack(demands)} or demands,required_targets={},admissible=admissible,seeds=seeds}))
  local hits=0
  while true do
    local tag,value=q:step(17)
    if tag=='yes' then
      hits=hits+1; local seenf,seent={},{}
      for _,e in ipairs(value) do ok(not seenf[e.from],'partial witness reuses scarce offer'); ok(not seent[e.to],'partial witness closes demand twice'); seenf[e.from]=true; seent[e.to]=true; ok(not forbidden[key(e.from,e.to)],'partial witness uses forbidden pair') end
      for _,s in ipairs(seeds) do local found=false; for _,e in ipairs(value) do if e.from==s.from and e.to==s.to then found=true; break end end; ok(found,'partial witness dropped seed') end
    elseif tag=='more' then
    elseif tag=='done' then break
    elseif tag=='no' then error('partial relation always contains at least the mandatory/empty witness in generated case')
    else error('unexpected tag '..tostring(tag)) end
  end
  eq(hits,expected,'partial exact witness count')
end
print('PASS partial differential',total,'assertions')
