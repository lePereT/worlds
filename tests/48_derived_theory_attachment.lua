local S=require('tests.support')
local G,A=S.G,S.A

local function scoped()
  local b=G.builder(); local R=b:membrane(nil,'proc'); local I=b:membrane(R,'transparent'); local c=b:point(R,'Chan')
  b:strand(I,'Send',{c}); b:strand(R,'Recv',{c}); return b:finish(),R,I
end
local function flat()
  local b=G.builder(); local R=b:membrane(nil,'proc'); local c=b:point(R,'Chan')
  b:strand(R,'Send',{c}); b:strand(R,'Recv',{c}); return b:finish(),R
end
local p=G.builder(); local D=p:membrane(nil,'proc'); local c=p:point(D,'Chan')
local s=p:strand(D,'Send',{c}); local r=p:strand(D,'Recv',{c}); local o=p:strand(D,'Done',{c}); p:face(D,'rendezvous',{s,r},{o}); local pat=p:finish()

local exact,R,I=scoped(); local normal,N=flat()
S.eq(#A.all(exact,{R,I},pat),0)

-- A toy derived Theory relation over an equivalence class. Worlds itself is
-- unchanged: the Theory chooses/derives representatives and delegates each
-- exact structural composition question to ordinary Att.
local function att_T(representatives,pattern)
  local out={}
  for _,rep in ipairs(representatives) do
    for _,att in ipairs(A.all(rep.g,rep.selection,pattern)) do
      out[#out+1]={representative=rep.g,attachment=att}
    end
  end
  return out
end
local xs=att_T({{g=exact,selection={R,I}},{g=normal,selection={N}}},pat)
S.eq(#xs,1)
S.ok(xs[1].representative==normal)
local after=A.glue(xs[1].attachment)
S.ok(after)
print('ok 48_derived_theory_attachment')
