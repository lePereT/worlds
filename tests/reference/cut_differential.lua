package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local random=require('prng').new(12345)
local assertions=0
local function eq(a,b,msg) assertions=assertions+1; assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end

-- Independent exhaustive oracle for a deliberately small flat fragment:
-- imported rigid role Point + one local Point variable per demand, global Strand
-- scarcity, and repeated variables.  This does not share the kernel backtracker.
for case=1,1500 do
  local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local roles={}; for i=1,3 do roles[i]=vb:point(vm,'R'..i) end; vb:finish()
  local sb=W.Geometry.builder(); local sm=sb:membrane(nil,'s'); local exactpts={}; for i=1,4 do exactpts[i]=sb:point(sm,'p'..i) end
  local offers={}; local no=random(0,5)
  for i=1,no do offers[i]=sb:strand(sm,{roles[random(1,3)],exactpts[random(1,4)]}) end
  local live=W.Operational.from_geometry(sb:finish())

  local pb=W.Geometry.builder(); local pm=pb:membrane(nil,'p'); local vars={}; for i=1,3 do vars[i]=pb:point(pm,'x'..i) end
  local ins,specs={},{}; local demands=random(1,4)
  for i=1,demands do
    local role=roles[random(1,3)]; local vi=random(1,3)
    ins[i]=pb:strand(pm,{role,vars[vi]}); specs[i]={role=role,var=vi}
  end
  local out=pb:strand(pm,{roles[1],vars[1]}); pb:face(pm,ins,{out}); local pat=pb:finish()
  local all=W.Operational.all(live,pat,{offers=offers})

  local used,bindings={},{}; local brute=0
  local function rec(i)
    if i>demands then brute=brute+1; return end
    local spec=specs[i]
    for oi,s in ipairs(offers) do if not used[oi] then
      local pts=W.Geometry.points(s)
      if pts[1]==spec.role then
        local old=bindings[spec.var]
        if old==nil or old==pts[2] then
          used[oi]=true; bindings[spec.var]=pts[2]; rec(i+1); used[oi]=nil
          bindings[spec.var]=old
        end
      end
    end end
  end
  rec(1)
  eq(#all,brute,'differential attachment mismatch case '..case)
end

print('PASS differential',assertions,'assertions')
