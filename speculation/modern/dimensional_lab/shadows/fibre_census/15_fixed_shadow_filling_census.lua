package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local F=require('speculation.modern.dimensional_lab.shadows.fibre_census.common')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local lawful,developable,invalid=0,0,0
local byfaces={}; local homclasses={}; local coarseclasses={}; local boundaryclasses={}
local function add(t,k) t[k]=(t[k] or 0)+1 end
local function boundary_key(g,x)
  local z={}; for i,s in ipairs(x.edges) do z[i]=(g:is_input(s) and 'I' or '-')..(g:is_terminal(s) and 'O' or '-') end; return table.concat(z,',')
end

print('1. hold the complete cubical Point/Strand skeleton fixed and enumerate all 64 cellular fillings')
for mask=0,63 do
  local h=F.cube_homology(mask); add(homclasses,F.key_homology(h))
  local good,g,x=pcall(F.cube_subset,mask)
  byfaces[F.popcount(mask)]=byfaces[F.popcount(mask)] or {candidate=0,lawful=0,developable=0}
  local row=byfaces[F.popcount(mask)]; row.candidate=row.candidate+1
  if not good then
    invalid=invalid+1; ok(tostring(g):find('existing Point used without causal input incidence',1,true)~=nil,'unexpected invalidity reason')
  else
    lawful=lawful+1; row.lawful=row.lawful+1
    local dev=g:is_developable(); if dev then developable=developable+1; row.developable=row.developable+1 end
    local src,sink=F.source_sink_counts(g)
    add(coarseclasses,table.concat({F.key_homology(h),#g:ingress(),#g:egress(),dev and 1 or 0,src,sink},'|'))
    add(boundaryclasses,boundary_key(g,x))
  end
end
eq(lawful,32,'half of the combinatorial fillings materialise under the chosen causal polarity')
eq(invalid,32); eq(developable,10,'only ten are executable/developable')
local expect={{1,1,1},{6,3,2},{15,5,2},{20,7,2},{15,9,2},{6,6,1},{1,1,0}}
for f=0,6 do local r=byfaces[f]; eq(r.candidate,expect[f+1][1]); eq(r.lawful,expect[f+1][2]); eq(r.developable,expect[f+1][3]) end

print('2. topology, causality and lawfulness are successive non-equivalent filters over that one lower skeleton')
local hc=0; for _ in pairs(homclasses) do hc=hc+1 end; eq(hc,7,'all seven cube-boundary homology stages occur')
local cc,cmax=0,0; for _,v in pairs(coarseclasses) do cc=cc+1; if v>cmax then cmax=v end end
eq(cc,29,'coarse topology+boundary-count+developability still has collisions'); eq(cmax,2)
local bc,bmax=0,0; for _,v in pairs(boundaryclasses) do bc=bc+1; if v>bmax then bmax=v end end
eq(bc,32,'exact ingress/egress status of every fixed edge distinguishes every lawful filling'); eq(bmax,1)

print('3. this exact-boundary faithfulness is itself evidence of leakage from causalising the higher filler')
local full=F.cube_homology(63); eq(full.b2,1)
local source=F.cube_homology(62); local sink=F.cube_homology(31); eq(source.b2,0); eq(sink.b2,0)
local gs=F.cube_subset(62); local gt=F.cube_subset(31); local gf=F.cube_subset(63)
ok(gs:is_developable(),'puncturing the causal source activates a disk'); ok(not gt:is_developable(),'same disk topology punctured at sink stays dead'); ok(not gf:is_developable(),'closed sphere stays nondevelopable')
-- In a genuinely neutral higher filling one would expect some filling information
-- not to be forced into this lower causal boundary.  Today's Face vocabulary does.
print('PASS fixed-shadow filling census',n,'assertions','lawful',lawful,'developable',developable,'boundary-classes',bc)
