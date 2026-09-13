package.path='./src/?.lua;./?.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local seed=24681357
local function random(a,b) seed=(1103515245*seed+12345)%2147483648; return a+(seed%(b-a+1)) end
local assertions=0
local function eq(a,b,msg) assertions=assertions+1; assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function count_solve(world,pat,opts)
  local q=Query.solve(Query.new(world,pat,{sources=opts.egress,targets=opts.ingress})); local n=0
  while true do local k=q:step(math.huge); if k=='yes' then n=n+1 elseif k=='done' or k=='no' then return n else error(k) end end
end
local function subset(xs)
  local out={}; for _,x in ipairs(xs) do if random(0,1)==1 then out[#out+1]=x end end; return out
end
for case=1,5000 do
  local vb=W.builder(); local vm=vb:membrane(nil,'v'); local roles={}; for i=1,3 do roles[i]=vb:point(vm,'R'..i) end; vb:finish()
  local sb=W.builder(); local sm=sb:membrane(nil,'s'); local exactpts={}; for i=1,4 do exactpts[i]=sb:point(sm,'p'..i) end
  local offers={}; local no=random(0,6); for i=1,no do offers[i]=sb:strand(sm,{roles[random(1,3)],exactpts[random(1,4)]}) end; local world=sb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil,'p'); local vars={}; for i=1,3 do vars[i]=pb:point(pm,'x'..i) end
  local specs,demands={},{}; local nd=random(1,5)
  for i=1,nd do local role=roles[random(1,3)]; local vi=random(1,3); demands[i]=pb:strand(pm,{role,vars[vi]}); specs[demands[i]]={role=role,var=vi} end
  local pat=pb:finish()

  local selected_offers,selected_demands=subset(offers),subset(demands)
  local used,bindings={},{}; local brute=0
  local function rec(i)
    if i>#selected_demands then brute=brute+1; return end
    local d=selected_demands[i]; local spec=specs[d]
    for oi,s in ipairs(selected_offers) do if not used[oi] then local pts=W.points(s); if pts[1]==spec.role then local old=bindings[spec.var]; if old==nil or old==pts[2] then used[oi]=true; bindings[spec.var]=pts[2]; rec(i+1); used[oi]=nil; bindings[spec.var]=old end end end end
  end
  rec(1)
  local got=count_solve(world,pat,{ingress=selected_demands,egress=selected_offers})
  eq(got,brute,'restricted case '..case)
end
print('PASS restricted differential',assertions,'cases')
