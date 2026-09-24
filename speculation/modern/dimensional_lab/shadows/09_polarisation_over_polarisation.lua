package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local D=require('speculation.modern.dimensional_lab.common'); local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('1. causal polarisations of one structural pentagon are themselves exact higher histories')
local surfaces={}; local bymask={}
for mask=1,30 do local g=C.cycle(5,mask); local s=D.surface(C.mask_bits(mask,5),g,{mask=mask}); surfaces[#surfaces+1]=s; bymask[mask]=s end
eq(#surfaces,30)

print('2. a next-rank face-free atlas can expose the one-edge-flip geometry of that fibre')
local edges={}
for a=1,30 do for bit=0,4 do local b=a~(1<<bit); if b>=1 and b<=30 and a<b then edges[#edges+1]={bymask[a],bymask[b]} end end end
local atlas=D.deformation_atlas(surfaces,edges,'polarisation-of-polarisation space')
eq(#atlas.world:points(),30); eq(#atlas.world:strands(),70); eq(#atlas.world:faces(),0)

print('3. the next-rank shadow sees structure invisible to the common filled-disk topology below')
local h=C.cycle_homology(5,true); eq(h.b0,1); eq(h.b1,0); eq(h.b2,0)
-- Yet the fibre graph itself has cycle rank 41.
eq(#atlas.world:strands()-#atlas.world:points()+1,41)
ok(atlas.point[bymask[5]]~=atlas.point[bymask[26]],'causal reversal remains two exact higher alternatives')
print('PASS polarisation-over-polarisation shadow',n,'assertions')
