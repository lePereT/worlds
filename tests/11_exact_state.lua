local S=require('tests.support')
local G,A,Same=S.G,S.A,S.Worlds.same

local b=G.builder(); local K=b:membrane(nil,'place','K'); local base=b:finish()

local function hidden(sort)
  local p=G.builder(); local H=p:membrane(nil,'private','H'); local X=p:point(H,'X'); local R=p:strand(H,sort,{X}); p:face(H,'create',{}, {R}); return p:finish(),H,R
end
local PR,HR,RR=hidden('R')
local PS,HS,RS=hidden('S')
local gr,ir=A.glue(A.one(base,{K},PR))
local gs,is=A.glue(A.one(base,{K},PS))

-- The currently selected membrane exposes the same thing in both cases.
S.eq(#gr:offers({K}),0)
S.eq(#gs:offers({K}),0)
-- The exact geometries are nevertheless different. Hidden state is state.
S.no(Same(gr,gs))
S.eq(gr:cell(gr:offers({ir.membranes[HR]})[1]).sort,'R')
S.eq(gs:cell(gs:offers({is.membranes[HS]})[1]).sort,'S')

print('ok 11_exact_state')
