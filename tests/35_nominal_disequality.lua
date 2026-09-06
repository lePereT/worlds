local S=require('tests.support')
local G,A=S.G,S.A

local function source(shared)
  local b=G.builder(); local K=b:membrane(nil,'names')
  local a=b:point(K,'Name'); local bpt=shared and a or b:point(K,'Name')
  b:strand(K,'Left',{a}); b:strand(K,'Right',{bpt})
  return b:finish(),K
end

-- Structurally generic: two independent variables may alias or not.
local p=G.builder(); local D=p:membrane(nil,'names'); local x=p:point(D,'Name'); local y=p:point(D,'Name')
p:strand(D,'Left',{x}); p:strand(D,'Right',{y}); local generic=p:finish()
local same,K=source(true); local split,K2=source(false)
local es=A.one(same,{K},generic); local ed=A.one(split,{K2},generic)
S.ok(es and ed)
local function nominal_distinct(e) return e:point(x)~=e:point(y) end
S.no(nominal_distinct(es)); S.ok(nominal_distinct(ed))
print('ok 35_nominal_disequality')
