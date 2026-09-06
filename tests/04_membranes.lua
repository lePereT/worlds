local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder()
local Root=b:membrane(nil,'place','root')
local Ssrc=b:membrane(Root,'place','S')
local T=b:membrane(Root,'place','T')
local U=b:membrane(Root,'place','U')
local X=b:point(Root,'Resource','x')
local TargetT=b:point(T,'Place','target-T')
local resource=b:strand(Ssrc,'Resource',{X},'resource')
local admitT=b:strand(T,'Admission',{TargetT},'admit-T')
local admitU=b:strand(U,'Admission',{b:point(U,'Place','target-U')},'admit-U')
local base=b:finish()

-- Sibling handoff is ordinary gluing over two membranes.
local p=G.builder()
local Pr=p:membrane(nil,'place','root-pattern')
local Ds=p:membrane(Pr,'place','source')
local Dt=p:membrane(Pr,'place','target')
local px=p:point(Pr,'Resource','x')
local pt=p:point(Dt,'Place','target')
local rin=p:strand(Ds,'Resource',{px},'resource-in')
local ain=p:strand(Dt,'Admission',{pt},'admission-in')
local rout=p:strand(Dt,'Resource',{px},'resource-out')
p:face(Ds,'handoff',{rin,ain},{rout})
local handoff=p:finish()

local all=A.all(base,{Ssrc,T,U},handoff)
S.eq(#all,2,'two target admissions give two exact handoffs')
local chosen
for _,w in ipairs(all) do if w:point(pt)==TargetT then chosen=w end end
S.ok(chosen)
S.eq(chosen:membrane(Ds),Ssrc)
S.eq(chosen:membrane(Dt),T)
local moved,img=A.glue(chosen)
S.eq(moved:cell(img.strands[rout]).membrane,T)
S.no(moved:is_terminal(resource),'source authority was consumed')
S.ok(moved:is_terminal(img.strands[rout]))

-- Without target-local authority no attachment can name/use that existing World.
S.eq(#A.all(base,{Ssrc},handoff),0)

-- Two locality variables may alias one existing membrane when distinct authority supports them.
local a=G.builder(); local K=a:membrane(nil,'place','K'); local P=a:point(K,'X');
local r1=a:strand(K,'R',{P}); local r2=a:strand(K,'R',{P}); local ab=a:finish()
local q=G.builder(); local A1=q:membrane(nil,'place'); local A2=q:membrane(nil,'place')
local Q=q:point(A1,'X'); q:strand(A1,'R',{Q}); q:strand(A2,'R',{Q}); local alias=q:finish()
local aw=A.one(ab,{K},alias); S.ok(aw)
S.eq(aw:membrane(A1),K); S.eq(aw:membrane(A2),K)

print('ok 04_membranes')
