package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local D=require('speculation.showcases.theory.lifecycle_and_correspondence.positive_development')
local T=require('speculation.showcases.theory.lifecycle_and_correspondence.positive_theory')
local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1
assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local value_schema={value={arity=2,key={1}}}

print('1. strict positive Theory rejects a retract channel')
do
  local b=W.builder()
  local m=b:membrane(nil,'r')
  local s=b:strand(m,{},'s')
  local g=b:finish()
  ok(not pcall(function() T.rule(g,{retracts={T.fact('value',s,'old')}}) end),
    'strict positive Theory still accepts semantic retraction')
end

print('2. contradictory mutation on the same surviving exact support is rejected')
do
  local b=W.builder()
  local m=b:membrane(nil,'state')
  local p=b:point(m,'object')
  local s=b:strand(m,{p},'support')
  local st=D.state(b:finish(),{T.fact('value',p,'red')},value_schema)
  local q=W.builder()
  local qm=q:membrane(nil,'mutate-point')
  local qp=q:point(qm,'object')
  local i=q:strand(qm,{qp},'support.in')
  local rule=D.rule(q:finish(),{asserts={T.fact('value',qp,'blue')},schemas=value_schema})
  local next,why=D.apply(st,rule,{{from=s,to=i}})
  ok(next==nil,'persistent Point knowledge mutated without renewed support')
  eq(why,'functional-conflict:value','wrong persistent-mutation failure')
end

print('3. surviving exact support may accumulate compatible positive knowledge')
do
  local b=W.builder()
  local m=b:membrane(nil,'state')
  local p=b:point(m,'object')
  local s=b:strand(m,{p},'support')
  local st=D.state(b:finish(),{T.fact('colour',p,'red')})
  local q=W.builder()
  local qm=q:membrane(nil,'learn')
  local qp=q:point(qm,'object')
  local i=q:strand(qm,{qp},'support.in')
  local rule=D.rule(q:finish(),{asserts={T.fact('shape',qp,'round')}})
  local next,why=D.apply(st,rule,{{from=s,to=i}})
  ok(next,why)
  eq(next:count('colour'),1,'old compatible knowledge disappeared')
  eq(next:count('shape'),1,'new compatible knowledge did not accumulate')
end

print('4. mutation by exact support renewal needs no retraction')
do
  local b=W.builder()
  local m=b:membrane(nil,'state')
  local p=b:point(m,'object')
  local s=b:strand(m,{p},'state.0')
  local st=D.state(b:finish(),{T.fact('value',s,'red')},value_schema)
  local q=W.builder()
  local qm=q:membrane(nil,'renew')
  local qp=q:point(qm,'object')
  local i=q:strand(qm,{qp},'state.in')
  local o=q:strand(qm,{qp},'state.1')
  q:face(qm,{i},{o},'renew')
  local rule=D.rule(q:finish(),{requires={T.fact('value',i,'red')},
    asserts={T.fact('value',o,'blue')},schemas=value_schema})
  local next,detail=D.apply(st,rule,{{from=s,to=i}})
  ok(next,detail)
  eq(next:count('value'),1,'old occurrence knowledge survived boundary projection')
  local f=next:select('value')[1]
  eq(f.args[2],'blue','renewed support did not carry new knowledge')
  ok(next.geometry:owns_strand(f.args[1]),'new fact lost exact live support')
end

print('5. stale knowledge disappears when its exact support is consumed')
do
  local b=W.builder()
  local m=b:membrane(nil,'world')
  local token=b:strand(m,{},'token')
  local flag=b:strand(m,{},'flag')
  local st=D.state(b:finish(),{T.fact('enabled',flag)})
  local q=W.builder()
  local qm=q:membrane(nil,'guarded')
  local ti=q:strand(qm,{},'token.in')
  local out=q:strand(qm,{},'out')
  q:face(qm,{ti},{out},'guarded')
  local F=T.var('F')
  local guarded=D.rule(q:finish(),{requires={T.fact('enabled',F)}})
  local prepared=assert(D.prepare(st,guarded,{{from=token,to=ti}}))
  local r=W.builder()
  local rm=r:membrane(nil,'retire')
  local fi=r:strand(rm,{},'flag.in')
  r:face(rm,{fi},{},'retire')
  local retired,why=D.apply(st,D.rule(r:finish(),{}),{{from=flag,to=fi}})
  ok(retired,why)
  eq(retired:count('enabled'),0,'consumed support left stale public knowledge')
  local final,fail=D.commit(retired,prepared)
  ok(final==nil,'prepared transaction survived disappearance of knowledge support')
  eq(fail,'unsatisfied-theory-requirement','wrong stale-knowledge result')
end

print('PASS exact support gives positive Theory its lifecycle without retraction',n,'assertions')
