math.randomseed(97531)
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
local function same(a,b)
  for k in pairs(a) do if not b[k] then return false end end
  for k in pairs(b) do if not a[k] then return false end end
  return true
end
local function subset(a,b)
  for k in pairs(a) do if not b[k] then return false end end
  return true
end
local function clone(a) local o={}
 for k in pairs(a) do o[k]=true end
 return o end

local function close(seed,rules,order)
  local s=clone(seed)
  local changed=true
  while changed do
    changed=false
    for _,ri in ipairs(order) do
      local r=rules[ri]
 local ready=true
      for _,p in ipairs(r.premises) do if not s[p] then ready=false break end end
      if ready and not s[r.conclusion] then s[r.conclusion]=true
 changed=true end
    end
  end
  return s
end

for case=1,150 do
  local atoms={'a','b','c','d','e'}
  local rules={}
  for i=1,math.random(3,8) do
    local premises={}
    for _,a in ipairs(atoms) do if math.random()<0.25 then premises[#premises+1]=a end end
    rules[#rules+1]={premises=premises,conclusion=atoms[math.random(1,#atoms)]}
  end
  local seed={}
 for _,a in ipairs(atoms) do if math.random()<0.25 then seed[a]=true end end
  local order1={}
 for i=1,#rules do order1[i]=i end
  local order2={}
 for i=#rules,1,-1 do order2[#order2+1]=i end
  local c1=close(seed,rules,order1)
 local c2=close(seed,rules,order2)
  ok(subset(seed,c1),'closure retracted seed knowledge')
  ok(same(c1,c2),'positive least closure depended on fair order')
  ok(same(close(c1,rules,order2),c1),'closure was not idempotent')

  local more=clone(seed)
 more[atoms[math.random(1,#atoms)]]=true
  ok(subset(c1,close(more,rules,order1)),'positive closure was not monotone')
end

-- Absence-sensitive consequence is not monotone and is constitutionally excluded.
local function anti(s)
  local out=clone(s)
 if not s.b then out.a=true end
 return out
end
local x=anti({})
 local y=anti({b=true})
ok(x.a and not y.a,'absence-sensitive counterexample failed to violate monotonicity')

print('closure laws: '..n..' assertions passed')
