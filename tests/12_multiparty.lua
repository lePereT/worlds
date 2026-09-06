local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local Root=b:membrane(nil,'place'); local A0=b:membrane(Root,'place','A'); local B0=b:membrane(Root,'place','B'); local C0=b:membrane(Root,'place','C')
local pa=b:point(A0,'Role'); local pb=b:point(B0,'Role'); local pc=b:point(C0,'Role')
local sa=b:strand(A0,'A',{pa}); local sb=b:strand(B0,'B',{pb}); local sc=b:strand(C0,'C',{pc}); local base=b:finish()

local p=G.builder(); local A1=p:membrane(nil,'place'); local B1=p:membrane(nil,'place'); local C1=p:membrane(nil,'place')
local qa=p:point(A1,'Role'); local qb=p:point(B1,'Role'); local qc=p:point(C1,'Role')
local ia=p:strand(A1,'A',{qa}); local ib=p:strand(B1,'B',{qb}); local ic=p:strand(C1,'C',{qc})
local oa=p:strand(A1,'A2',{qa}); local ob=p:strand(B1,'B2',{qb}); local oc=p:strand(C1,'C2',{qc})
p:face(A1,'rendezvous',{ia,ib,ic},{oa,ob,oc})
local rendezvous=p:finish()

local w=A.one(base,{A0,B0,C0},rendezvous); S.ok(w)
S.eq(w:membrane(A1),A0); S.eq(w:membrane(B1),B0); S.eq(w:membrane(C1),C0)
local g,img=A.glue(w)
S.eq(g:cell(img.strands[oa]).membrane,A0)
S.eq(g:cell(img.strands[ob]).membrane,B0)
S.eq(g:cell(img.strands[oc]).membrane,C0)

print('ok 12_multiparty')
