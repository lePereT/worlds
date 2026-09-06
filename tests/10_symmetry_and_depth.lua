local S=require('tests.support')
local G,A=S.G,S.A

-- Six completely symmetric locality variables have 6! exact attachments.
local b=G.builder(); local worlds={}
for i=1,6 do
  local w=b:membrane(nil,'place','W'..i); worlds[i]=w
  local p=b:point(w,'X','x'..i); b:strand(w,'R',{p},'r'..i)
end
local base=b:finish()
local p=G.builder()
for i=1,6 do local d=p:membrane(nil,'place','D'..i); local q=p:point(d,'X'); p:strand(d,'R',{q}) end
local pat=p:finish()
S.eq(#A.all(base,worlds,pat),720)

-- Deep fresh membrane geometry is ordinary finite structure, not recursive
-- runtime stack state.
local d=G.builder(); local parent=nil; local deepest
for i=1,25 do deepest=d:membrane(parent,'nest','N'..i); parent=deepest end
local pt=d:point(deepest,'X'); local rs=d:strand(deepest,'R',{pt}); d:face(deepest,'create',{}, {rs}); local deep=d:finish()
local empty=G.builder(); local e=empty:finish()
local w=A.one(e,{},deep); S.ok(w)
local gd,img=A.glue(w)
local x=img.membranes[deepest]; local n=0
while x do n=n+1; x=gd:parent(x) end
S.eq(n,25)

print('ok 10_symmetry_and_depth')
