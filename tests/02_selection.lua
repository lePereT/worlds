local S=require('tests.support')
local G=S.G

local b=G.builder()
local P=b:membrane(nil,'place','parent')
local C=b:membrane(P,'place','child')
local shared=b:point(P,'Identity','shared')
local parent_only=b:point(P,'Identity','parent-only')
local child_local=b:point(C,'Identity','child-local')
local ps=b:strand(P,'R',{shared},'parent-r')
local cs=b:strand(C,'R',{shared,child_local},'child-r')
local spent=b:strand(C,'R',{child_local},'spent')
local gone=b:strand(C,'R',{child_local},'gone')
b:face(C,'consume',{spent},{gone})
local g=b:finish()

local sp=S.set(g:offers({P})); local sc=S.set(g:offers({C}))
S.ok(sp[ps]); S.no(sp[cs]); S.ok(sc[cs]); S.no(sc[spent]); S.ok(sc[gone])

local vp=S.set(g:visible_points({P}))
local vc=S.set(g:visible_points({C}))
S.ok(vp[shared]); S.ok(vp[parent_only]); S.no(vp[child_local])
S.ok(vc[shared]); S.ok(vc[child_local]); S.no(vc[parent_only], 'parent identity is not ambient in child')

local both=S.set(g:offers({C,P}))
S.ok(both[ps]); S.ok(both[cs])
print('ok 02_selection')
