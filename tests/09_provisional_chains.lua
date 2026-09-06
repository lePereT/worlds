local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local R=b:membrane(nil,'place','root'); local WA=b:membrane(R,'place','A'); local WB=b:membrane(R,'place','B'); local WC=b:membrane(R,'place','C')
local X=b:point(R,'Resource','x'); local PB=b:point(WB,'Place','B'); local PC=b:point(WC,'Place','C')
local resource=b:strand(WA,'Resource',{X},'resource'); b:strand(WB,'Admission',{PB},'admit-B'); b:strand(WC,'Admission',{PC},'admit-C'); local base=b:finish()

local function handoff(target_place_sort)
  local p=G.builder(); local PR=p:membrane(nil,'place','root-pattern'); local S0=p:membrane(PR,'place','S'); local T0=p:membrane(PR,'place','T'); local x=p:point(PR,'Resource'); local t=p:point(T0,'Place'); local r=p:strand(S0,'Resource',{x}); local a=p:strand(T0,'Admission',{t}); local o=p:strand(T0,'Resource',{x}); p:face(S0,'move',{r,a},{o}); return p:finish(),S0,T0,o,t
end
local move1,S1,T1,o1,t1=handoff()
local w1
for _,w in ipairs(A.all(base,{WA,WB},move1)) do if w:point(t1)==PB then w1=w end end
S.ok(w1)
local g1,im1=A.glue(w1)
S.eq(#base:faces(),0)
local rB=im1.strands[o1]; S.eq(g1:cell(rB).membrane,WB)

local move2,S2,T2,o2,t2=handoff()
local w2
for _,w in ipairs(A.all(g1,{WB,WC},move2)) do if w:point(t2)==PC then w2=w end end
S.ok(w2)
local g2,im2=A.glue(w2)
S.eq(g2:cell(im2.strands[o2]).membrane,WC)
S.no(g2:is_terminal(rB)); S.ok(g2:is_terminal(im2.strands[o2]))

-- Create a fresh child, then operate inside it before any external runtime has
-- chosen to commit the intermediate Geometry value.
local m=G.builder(); local D=m:membrane(nil,'place'); local Child=m:membrane(D,'worker'); local gatep=m:point(D,'Place'); local gate=m:strand(D,'Admission',{gatep}); local cp=m:point(Child,'Child'); local cr=m:strand(Child,'ChildR',{cp}); m:face(D,'create',{gate},{cr}); local create=m:finish()
local cw
for _,w in ipairs(A.all(base,{WB},create)) do if w:point(gatep)==PB then cw=w end end
S.ok(cw)
local gv,cim=A.glue(cw)
local child=cim.membranes[Child]
local use=G.builder(); local U=use:membrane(nil,'worker'); local up=use:point(U,'Child'); local ui=use:strand(U,'ChildR',{up}); local uo=use:strand(U,'ChildR2',{up}); use:face(U,'use',{ui},{uo}); local usep=use:finish()
local uw=A.one(gv,{child},usep); S.ok(uw)
local gv2,uim=A.glue(uw)
S.eq(gv2:cell(uim.strands[uo]).membrane,child)

print('ok 09_provisional_chains')
