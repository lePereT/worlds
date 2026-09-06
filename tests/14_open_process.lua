local S=require('tests.support')
local G,A=S.G,S.A

local b=G.builder(); local K=b:membrane(nil,'place'); local X=b:point(K,'X'); local a=b:strand(K,'A',{X}); local c=b:strand(K,'C',{X}); local base=b:finish()

-- One supplied Geometry is one possible open process. It may contain several
-- authority-independent causal pieces; no component-discovery layer decides
-- whether they "really" belong together.
local p=G.builder(); local D=p:membrane(nil,'place'); local Q=p:point(D,'X')
local ai=p:strand(D,'A',{Q}); local ao=p:strand(D,'A2',{Q}); p:face(D,'fa',{ai},{ao})
local ci=p:strand(D,'C',{Q}); local co=p:strand(D,'C2',{Q}); p:face(D,'fc',{ci},{co})
local together=p:finish()
local w=A.one(base,{K},together); S.ok(w)
local g,img=A.glue(w)
S.ok(g:is_terminal(img.strands[ao])); S.ok(g:is_terminal(img.strands[co]))

-- If the programmer/theory wants the pieces as separate possible actions, it
-- supplies separate Geometries. The kernel does not infer a hidden process split.
local function one(sort,outsort)
  local x=G.builder(); local m=x:membrane(nil,'place'); local q=x:point(m,'X'); local i=x:strand(m,sort,{q}); local o=x:strand(m,outsort,{q}); x:face(m,'f',{i},{o}); return x:finish()
end
S.ok(A.one(base,{K},one('A','A2')))
S.ok(A.one(base,{K},one('C','C2')))

print('ok 14_open_process')
