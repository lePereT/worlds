local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local P=b:membrane(nil,'place','P'); local C=b:membrane(P,'place','C'); local X=b:point(C,'X'); local r=b:strand(C,'R',{X}); local base=b:finish()

-- Child authority can structurally determine its parent membrane, but that does
-- not grant permission to modify the unselected parent.
local p=G.builder(); local PP=p:membrane(nil,'place','PP'); local CC=p:membrane(PP,'place','CC'); local Q=p:point(CC,'X'); local i=p:strand(CC,'R',{Q}); local out=p:strand(PP,'ParentOutput',{Q}); p:face(CC,'cross',{i},{out}); local cross=p:finish()
S.eq(#A.all(base,{C},cross),0,'structural ancestry is not membrane exposure')
local w=A.one(base,{P,C},cross); S.ok(w)
local g,img=A.glue(w); S.eq(g:cell(img.strands[out]).membrane,P)

-- Likewise, adding a fresh child beneath an inferred existing parent requires
-- that parent membrane to be selected.
local q=G.builder(); local QP=q:membrane(nil,'place'); local QC=q:membrane(QP,'place'); local Fresh=q:membrane(QP,'fresh'); local qp=q:point(QC,'X'); local qi=q:strand(QC,'R',{qp}); local z=q:point(Fresh,'Z'); local zo=q:strand(Fresh,'Z',{z}); q:face(QC,'grow',{qi},{zo}); local grow=q:finish()
S.eq(#A.all(base,{C},grow),0)
S.ok(A.one(base,{P,C},grow))

print('ok 13_selection_entitlement')
