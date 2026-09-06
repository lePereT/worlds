local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

local b=G.builder(); local K=b:membrane(nil,'place','K'); local X=b:point(K,'X')
local sa=b:strand(K,'A',{X},'a'); local sb=b:strand(K,'B',{X},'b'); local sc=b:strand(K,'C',{X},'c'); local base=b:finish()

local function transition(sort)
  local p=G.builder(); local D=p:membrane(nil,'place'); local Q=p:point(D,'X'); local i=p:strand(D,sort,{Q}); local o=p:strand(D,sort,{Q}); p:face(D,'step-'..sort,{i},{o}); return p:finish()
end
local PA,PB,PC=transition('A'),transition('B'),transition('C')

local function step(g,pat)
  local w=A.one(g,{K},pat); S.ok(w); return A.glue(w)
end

local ga=step(base,PA)
local gab=step(ga,PB)
local gb=step(base,PB)
local gba=step(gb,PA)
S.ok(Same(gab,gba),'independent square must commute')

-- Three independent occurrences yield the same exact geometry in all six orders.
local endstates={}
for _,perm in ipairs(S.permutations({PA,PB,PC})) do
  local g=base
  for _,pat in ipairs(perm) do g=step(g,pat) end
  endstates[#endstates+1]=g
end
for i=2,#endstates do S.ok(Same(endstates[1],endstates[i]),'3-cube path mismatch') end

-- Conflict is scarcity: two alternatives consuming the same Strand cannot co-complete.
local function consume_to(face_sort,out_sort)
  local p=G.builder(); local D=p:membrane(nil,'place'); local Q=p:point(D,'X'); local i=p:strand(D,'A',{Q}); local o=p:strand(D,out_sort,{Q}); p:face(D,face_sort,{i},{o}); return p:finish()
end
local X1,X2=consume_to('x1','AX'),consume_to('x2','AY')
local gx=step(base,X1)
S.eq(#A.all(gx,{K},X2),0)

-- Causality is production: a later pattern is impossible until its input exists.
local later=consume_to('later','AZ')
-- rewrite its demanded sort by building it explicitly for AX
local lp=G.builder(); local LD=lp:membrane(nil,'place'); local LQ=lp:point(LD,'X'); local li=lp:strand(LD,'AX',{LQ}); local lo=lp:strand(LD,'Done',{LQ}); lp:face(LD,'later',{li},{lo}); later=lp:finish()
S.eq(#A.all(base,{K},later),0)
S.eq(#A.all(gx,{K},later),1)

print('ok 07_concurrency')
