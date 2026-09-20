-- Worlds 0.6.2 research speculation: one factor-incidence shape, several
-- external elimination algebras. No external CAS or Python dependency.
--
-- The point is not to implement production Theories here. It is to hold the
-- Point-Strand dependency geometry fixed and compare pre-determined domain
-- results for different meanings of "eliminate the shared Point".

package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

-- Common face-free factor geometry R(x,y), S(y,z).
local b=W.builder(); local m=b:membrane(nil,'factor-scope')
local x=b:point(m,'x'); local y=b:point(m,'y'); local z=b:point(m,'z')
local R=b:strand(m,{x,y},'R(x,y)')
local S=b:strand(m,{y,z},'S(y,z)')
local G=b:finish()
eq(#G:faces(),0,'factor scope is non-causal')
eq(W.points(R)[2],y,'R uses shared coordinate y')
eq(W.points(S)[1],y,'S uses the same exact coordinate y')

-- Boolean existential composition.
local implication={['00']=true,['01']=true,['11']=true}
local xor={['01']=true,['10']=true}
local bool_out={}
for xv=0,1 do
  for zv=0,1 do
    for yv=0,1 do
      local a=tostring(xv)..tostring(yv)
      local c=tostring(yv)..tostring(zv)
      if implication[a] and xor[c] then
        bool_out[tostring(xv)..tostring(zv)]=true
      end
    end
  end
end
local keys={}; for k in pairs(bool_out) do keys[#keys+1]=k end; table.sort(keys)
eq(table.concat(keys,','),'00,01,10','pre-determined Boolean projection is NAND')

-- Tropical/min-plus elimination over the same x-y-z shape.
local TA={{0,3},{2,1}}
local TB={{4,0},{1,5}}
local TC={{0,0},{0,0}}
for i=1,2 do
  for k=1,2 do
    local best=math.huge
    for j=1,2 do best=math.min(best,TA[i][j]+TB[j][k]) end
    TC[i][k]=best
  end
end
eq(TC[1][1],4); eq(TC[1][2],0); eq(TC[2][1],2); eq(TC[2][2],2)

-- Sum-product elimination over the identical dependency shape.
local PA={{1,2},{3,4}}
local PB={{5,6},{7,8}}
local PC={{0,0},{0,0}}
for i=1,2 do
  for k=1,2 do
    local total=0
    for j=1,2 do total=total+PA[i][j]*PB[j][k] end
    PC[i][k]=total
  end
end
eq(PC[1][1],19); eq(PC[1][2],22); eq(PC[2][1],43); eq(PC[2][2],50)

-- Pre-determined nonlinear algebraic elimination.
--   y^2 = x
--   z   = y^3
-- eliminates y to the boundary relation x^3 - z^2 = 0.
-- We deliberately do not run a symbolic eliminator here. The expected resultant
-- is fixed in the experiment and checked on representative exact integer points.
local expected='x^3-z^2=0'
for yv=-5,5 do
  local xv=yv*yv
  local zv=yv*yv*yv
  eq(xv*xv*xv-zv*zv,0,'pre-determined polynomial resultant '..expected)
end

-- Add w=z^2. The corresponding pre-determined final boundary relation is
-- w=x^3. Again compare the known relation rather than invoking a CAS.
for yv=-5,5 do
  local xv=yv*yv
  local zv=yv*yv*yv
  local wv=zv*zv
  eq(wv,xv*xv*xv,'pre-determined three-stage polynomial relation w=x^3')
end

print('modern theory algebras: '..n..' assertions passed')
print('  one Point-Strand scope supports Boolean exists, min-plus, sum-product and fixed polynomial elimination')
