package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

-- Two squares glued along one edge.  The underlying cellular disk is fixed;
-- only which coherence Face produces the shared edge is reversed.
local function rectangle(reverse)
 local b=W.builder(); local m=b:membrane(nil,'rectangle'); local p={}
 for i=1,6 do p[i]=b:point(m,'p'..i) end
 -- grid vertices: 1-2-3 / 4-5-6; shared middle vertical edge 2-5.
 local ends={{1,2},{2,3},{4,5},{5,6},{1,4},{2,5},{3,6}}; local e={}
 for i,x in ipairs(ends) do e[i]=b:strand(m,{p[x[1]],p[x[2]]},'e'..i) end
 local left={e[1],e[6],e[3],e[5]}; local right={e[2],e[7],e[4],e[6]}
 local lf,rf
 if not reverse then
   -- left produces shared edge; right consumes it.  Extra boundary inputs seed left.
   lf=b:face(m,{e[1],e[3],e[5]},{e[6]},'left coherence')
   rf=b:face(m,{e[6],e[2]},{e[7],e[4]},'right coherence')
 else
   rf=b:face(m,{e[2],e[4],e[7]},{e[6]},'right coherence')
   lf=b:face(m,{e[6],e[1]},{e[5],e[3]},'left coherence')
 end
 return b:finish(),{lf=lf,rf=rf,ends=ends,top={{1,6,3,5},{2,7,4,6}}}
end

print('1. one cellular disk supports opposite causal orders between its two coherence 2-cells')
local A,a=rectangle(false); local B,b=rectangle(true)
ok(A:is_developable() and B:is_developable()); eq(#A:points(),#B:points()); eq(#A:strands(),#B:strands()); eq(#A:faces(),#B:faces())
local ha=C.homology(6,a.ends,a.top); local hb=C.homology(6,b.ends,b.top); eq(ha.b0,1); eq(ha.b1,0); eq(ha.b2,0); eq(hb.b0,ha.b0); eq(hb.b1,ha.b1); eq(hb.b2,ha.b2)

print('2. topology cannot tell which higher cell causes which')
local function reaches(g,x,y)
 local seen={}; local function go(f) if f==y then return true end; if seen[f] then return false end; seen[f]=true; for _,s in ipairs(g:strands()) do if g:producer(s)==f then local c=g:consumer(s); if c and go(c) then return true end end end; return false end; return go(x)
end
ok(reaches(A,a.lf,a.rf)); ok(not reaches(A,a.rf,a.lf)); ok(reaches(B,b.rf,b.lf)); ok(not reaches(B,b.lf,b.rf))
print('PASS topology versus higher causality',n,'assertions')
