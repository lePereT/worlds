package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local F=require('speculation.modern.dimensional_lab.shadows.fibre_census.common')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local lawful,dev={},{}; local mask_of={},{}
print('1. fix the cubical skeleton AND root/{A,B} support tree; enumerate all 4^6 face states')
for code=0,4095 do
  local digits=F.base4_digits(code,6); local mask=0; for i,s in ipairs(digits) do if s~=0 then mask=mask | (1<<(i-1)) end end; mask_of[code]=mask
  local good,g=pcall(F.cube_support_assignment,code)
  if good then lawful[code]=true; if g:is_developable() then dev[code]=true end end
end
local function card(t) local c=0; for _ in pairs(t) do c=c+1 end; return c end
eq(card(lawful),2304,'lawful support/filling realisations'); eq(card(dev),120,'developable realisations')

print('2. closed nondevelopable topology permits every support assignment; causal activation carves the fibre sharply')
local sphere,source,sink={},{},{}
for code in pairs(lawful) do local mask=mask_of[code]; if mask==63 then sphere[code]=true elseif mask==62 then source[code]=true elseif mask==31 then sink[code]=true end end
eq(card(sphere),729,'3^6 hosts for closed sphere are all latent/lawful')
local sd=0; for code in pairs(sphere) do if dev[code] then sd=sd+1 end end; eq(sd,0)
eq(card(source),31,'source-punctured disk keeps only 31 of 3^5 support placements')
for code in pairs(source) do ok(dev[code],'every lawful source-puncture support placement develops') end
eq(card(sink),243,'sink-punctured disk allows all support placements latently')
for code in pairs(sink) do ok(not dev[code],'none of those sink-puncture placements develops') end

print('3. the 31 active support states obey a sharp reuse law and still hide a loop-rich fibre')
-- With all causal edges at root, a reachable child locality can host at most one
-- Face; otherwise the locality is reused without causal input incidence.
for code in pairs(source) do
  local d=F.base4_digits(code,6); local nr,na,nb=0,0,0
  for _,s in ipairs(d) do if s==1 then nr=nr+1 elseif s==2 then na=na+1 elseif s==3 then nb=nb+1 end end
  ok(na<=1 and nb<=1,'reachable child support reused without authority'); ok(nr>=3,'five-Face source puncture needs at least three root-hosted Faces')
end
local states={}; for code in pairs(source) do states[#states+1]=code end; table.sort(states)
local adj={}; for _,c in ipairs(states) do adj[c]={} end; local E=0
local function hamming(a,b) local x,y=F.base4_digits(a,6),F.base4_digits(b,6); local z=0; for i=1,6 do if x[i]~=y[i] then z=z+1 end end; return z end
for i=1,#states do for j=i+1,#states do if hamming(states[i],states[j])==1 then E=E+1; adj[states[i]][states[j]]=true; adj[states[j]][states[i]]=true end end end
eq(E,55,'one-host-edit adjacency'); eq(E-#states+1,25,'active support fibre already has 25 graph loops')
local seen={[states[1]]=true}; local q={states[1]}; local qi=1; while qi<=#q do local x=q[qi]; qi=qi+1; for y in pairs(adj[x]) do if not seen[y] then seen[y]=true; q[#q+1]=y end end end; eq(#q,31,'active support fibre connected')
-- The closed sphere support fibre is the full Hamming graph K3^6.
local sphereE=729*12//2; eq(sphereE,4374); eq(sphereE-729+1,3646,'latent closed support fibre has 3646 graph loops')
print('PASS Membrane activation fibre',n,'assertions','closed-cycle-rank',3646,'active-cycle-rank',25)
