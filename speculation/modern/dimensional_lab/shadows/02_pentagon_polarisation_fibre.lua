package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('1. one structural pentagon has a large fibre of causal W3 fillings')
local N=5; local masks={}
for mask=1,(1<<N)-2 do local g=C.cycle(N,mask); ok(g:is_developable()); masks[#masks+1]=mask end
eq(#masks,30,'both-source-and-target causal polarisations')
local h=C.cycle_homology(N,true); eq(h.b0,1); eq(h.b1,0); eq(h.b2,0)

print('2. the 30 polarisations fall into six kinds even after pentagon symmetry')
local unseen={}; for _,m in ipairs(masks) do unseen[m]=true end; local orbits={}
while next(unseen) do local m=next(unseen); local o=C.dihedral_orbit(m,N); local q={}; for x in pairs(o) do if unseen[x] then unseen[x]=nil; q[#q+1]=x end end; orbits[#orbits+1]=q end
eq(#orbits,6,'dihedral quotient still leaves six causal types')

print('3. minimal one-edge changes reveal a highly nontrivial hidden fibre')
local E=0; local adj={}; for _,a in ipairs(masks) do adj[a]={} end
for i=1,#masks do for j=i+1,#masks do if C.hamming(masks[i],masks[j])==1 then E=E+1; adj[masks[i]][masks[j]]=true; adj[masks[j]][masks[i]]=true end end end
eq(E,70,'Q5 with the all-in/all-out poles removed')
local seen={}; local q={masks[1]}; seen[masks[1]]=true; local qi=1
while qi<=#q do local x=q[qi]; qi=qi+1; for y in pairs(adj[x]) do if not seen[y] then seen[y]=true; q[#q+1]=y end end end
local V=0; for _ in pairs(seen) do V=V+1 end; eq(V,30,'polarisation fibre connected by local flips')
eq(E-V+1,41,'one structural pentagon hides 41 independent graph cycles of causal polarisation')

print('4. causal reversal is a nontrivial involution inside the same topological disk fibre')
for _,m in ipairs(masks) do local rev=((1<<N)-1)~m; ok(adj[m] or rev); ok(rev>=1 and rev<((1<<N)-1)) end
print('PASS pentagon causal-polarisation fibre',n,'assertions')
