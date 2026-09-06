package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Att=W.Model,W.Att
local Ref=require('tests.reference.cut')

local function witness(m,K,seed,fixed)
  local q=Att.at(m,K):query(Att.patch(m,seed),fixed); local st,w=q:step(math.huge); assert(st=='hit'); return w
end
local function serial_state(r)
  local out={}; for _,x in ipairs(r:past()) do out[#out+1]='D'..x.serial end
  for _,x in ipairs(r:cut()) do out[#out+1]='L'..x.serial end
  table.sort(out); return table.concat(out,'|')
end
local function production_reachable(r)
  local seen={}
  local function visit(cur)
    local sig=serial_state(cur); if seen[sig] then return end; seen[sig]=true
    local enabled=cur:enabled()
    for _,f in ipairs(enabled) do visit(cur:after(f)) end
  end
  visit(r); return seen
end

local cases=0
local shapes={}
for chains=1,5 do for depth=1,2 do shapes[#shapes+1]={chains,depth} end end
for chains=1,3 do shapes[#shapes+1]={chains,3} end
for _,shape in ipairs(shapes) do
  local chains,depth=shape[1],shape[2]
  for variant=1,2 do
    local m=Model.new('O'); local O=m.actuality; local G=m:world('G'); local K=m:world('K',O)
    local fixed,first={},nil
    for c=1,chains do
      local P=m:point('P'..c,O,'P'); local D=m:world('D'..c)
      local gate=m:strand('g'..c..'?',D,{P},'R'); first=first or gate
      local prev=gate
      for d=1,depth do
        local last=(d==depth)
        local out=m:strand('s'..c..'.'..d,last and D or G,{P},'R')
        m:face('f'..c..'.'..d,G,{prev},{out},'A'); prev=out
      end
      local supply=m:strand('supply'..c,K,{P},'R'); fixed[#fixed+1]={demand=gate,supply=supply}
    end
    local w=witness(m,K,first,fixed); local r=w:cut()
    local initial=r:enabled(); if #initial>1 then local ok=Att.coherence(r,initial); assert(ok,'initial enabled family failed coherence') end
    local prod=production_reachable(r); local ref=Ref.reachable(m,w)
    local n=0; for _ in pairs(prod) do n=n+1 end
    assert(n==#ref,string.format('reachable mismatch chains=%d depth=%d: %d vs %d',chains,depth,n,#ref))
    local expected=(depth+1)^chains
    assert(n==expected,string.format('grid vertex count mismatch: got %d expected %d',n,expected))
    cases=cases+1
  end
end
print(string.format('%d residual grid stress cases passed',cases))
