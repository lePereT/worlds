package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common')
local ok,eq,count=D.counter()

-- One exact W1-like fibre: three scarce occurrences have the same structural row,
-- while three exact demands enumerate all 3! allocations.
local b=W.builder(); local m=b:membrane(nil,'fibre'); local q=b:point(m,'state')
local offers={b:strand(m,{q},'o1'),b:strand(m,{q},'o2'),b:strand(m,{q},'o3')}; local source=b:finish()
local t=W.builder(); local tm=t:membrane(nil,'demands'); local x=t:point(tm,'state')
local demands={t:strand(tm,{x},'d1'),t:strand(tm,{x},'d2'),t:strand(tm,{x},'d3')}; local target=t:finish()
local solver=W.solve(source,target); local sols={}
while true do local tag,s=solver:step(math.huge); if tag=='yes' then sols[#sols+1]=s elseif tag=='done' or tag=='no' then break end end
eq(#sols,6,'exact fibre exposes S3 allocation action')

local oi,di={},{}; for i,s in ipairs(offers) do oi[s]=i end; for i,s in ipairs(demands) do di[s]=i end
local function perm(es) local p={}; for _,e in ipairs(es) do p[di[e.to]]=oi[e.from] end; return p end
local function sign(p) local n=0; for i=1,#p do for j=i+1,#p do if p[i]>p[j] then n=n+1 end end end; return n%2==0 and 1 or -1 end
local trivial,alternating=0,0; local unordered={}
for _,es in ipairs(sols) do
  local p=perm(es); trivial=trivial+1; alternating=alternating+sign(p)
  local a={p[1],p[2],p[3]}; table.sort(a); unordered[table.concat(a,',')]=true
end
eq(trivial,6,'quantum bosonic/trivial character sums all exact allocations')
eq(alternating,0,'fermionic/sign character cancels the repeated-state allocation fibre')
local classes=0; for _ in pairs(unordered) do classes=classes+1 end
eq(classes,1,'chemical indistinguishable-slot quotient sees one unordered allocation class')

-- Geometry supplies the same exact permutation fibre; Theory decides whether to
-- quotient it (chemical counting) or carry a representation over it (quantum).
ok(source:owns_strand(offers[1]) and source:owns_strand(offers[2]) and source:owns_strand(offers[3]),'no domain semantics erase exact scarcity')
print('PASS exact-fibre symmetry substrate',count(),'assertions')
