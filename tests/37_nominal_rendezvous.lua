local S=require('tests.support')
local G,A=S.G,S.A

local function source(shared)
  local b=G.builder(); local K=b:membrane(nil,'proc')
  local c1=b:point(K,'Chan'); local c2=shared and c1 or b:point(K,'Chan')
  b:strand(K,'Send',{c1}); b:strand(K,'Recv',{c2})
  return b:finish(),K,c1,c2
end

-- Nominal rendezvous: reusing one pattern Point means literal same channel name.
local p=G.builder(); local D=p:membrane(nil,'proc'); local c=p:point(D,'Chan')
local s=p:strand(D,'Send',{c}); local r=p:strand(D,'Recv',{c}); local done=p:strand(D,'Done',{c})
p:face(D,'rendezvous',{s,r},{done}); local rendezvous=p:finish()

local gs,Ks=source(true); local gd,Kd=source(false)
S.eq(#A.all(gs,{Ks},rendezvous),1)
S.eq(#A.all(gd,{Kd},rendezvous),0)
print('ok 37_nominal_rendezvous')
