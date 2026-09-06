package.path='./src/?.lua;'..package.path
local W=require('worlds'); local Model,Att=W.Model,W.Att
local passed=0
local function test(name,f) io.write(string.format('%-86s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end
local function eq(a,b,m) assert(a==b,m or (tostring(a)..' ~= '..tostring(b))) end

local function permutation_problem(n_supply,n_demand)
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local G=m:world('G'); local ds={}
  for i=1,n_demand do local D=m:world('D'..i); ds[i]=m:strand('d'..i,D,{X},'R') end
  local out=m:strand('out',G,{X},'Out'); m:face('joint',G,ds,{out},'Body')
  local K=m:world('K',O); for i=1,n_supply do m:strand('r'..i,K,{X},'R') end
  return m,K,ds[1]
end

test('1. retained query finds one witness without materialising a 60,480-witness space',function()
  local m,K,seed=permutation_problem(9,6); local q=Att.at(m,K):query(Att.patch(m,seed))
  local st,w=q:step(20); eq(st,'hit'); assert(Att.is_witness(w)); assert(q:steps()<=20)
end)

test('2. insufficient budget is Unknown; retained search later proves Retry without restart',function()
  local m,K,seed=permutation_problem(5,6); local q=Att.at(m,K):query(Att.patch(m,seed))
  local st=q:step(5); eq(st,'unknown'); eq(q:restarts(),0)
  local guard=0; repeat st=q:step(50); guard=guard+1; assert(guard<100) until st~='unknown'
  eq(st,'retry'); eq(q:restarts(),0)
end)

test('3. Retry certificate survives unrelated change and is invalidated by relevant supply',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local D=m:world('D'); local G=m:world('G'); local d=m:strand('d',D,{X},'R'); local out=m:strand('o',G,{X},'O'); m:face('f',G,{d},{out},'F'); local K=m:world('K',O)
  local q=Att.at(m,K):query(Att.patch(m,d)); local st,c=q:step(math.huge); eq(st,'retry'); assert(c:valid())
  local U=m:point('U',O,'U'); m:strand('unrelated',K,{U},'Other'); assert(c:valid(),'unrelated boundary change invalidated certificate')
  m:strand('r',K,{X},'R'); assert(not c:valid(),'relevant supply did not invalidate certificate')
end)

test('4. Point gluing invalidates Retry without moving authority and can make attachment possible',function()
  local m=Model.new('O'); local O=m.actuality; local A=m:point('A',O,'Identity'); local B=m:point('B',O,'Identity'); local D=m:world('D'); local G=m:world('G'); local d=m:strand('d',D,{A},'R'); local out=m:strand('o',G,{A},'O'); m:face('f',G,{d},{out},'F'); local K=m:world('K',O); m:strand('r',K,{B},'R')
  local p=Att.patch(m,d); local q=Att.at(m,K):query(p); local st,c=q:step(math.huge); eq(st,'retry'); assert(c:valid())
  m:glue_points(A,B); assert(not c:valid())
  local q2=Att.at(m,K):query(p); st=q2:step(math.huge); eq(st,'hit')
end)

test('5. a retained Unknown query restarts only when its relevant frontier changes',function()
  local m,K,seed=permutation_problem(5,6); local q=Att.at(m,K):query(Att.patch(m,seed)); eq(q:step(3),'unknown')
  local U=m:point('U',m.actuality,'U'); m:strand('u',K,{U},'Other'); eq(q:step(3),'unknown'); eq(q:restarts(),0)
  local X
  for _,o in ipairs(m.objects) do if o.dim==0 and o.name=='X' then X=o; break end end
  m:strand('extra',K,{X},'R'); local st=q:step(1); assert(st=='unknown' or st=='hit'); eq(q:restarts(),1)
end)

test('6. a stale witness cannot be grafted after its authority is consumed',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local D=m:world('D'); local G=m:world('G'); local d=m:strand('d',D,{X},'R'); local out=m:strand('o',G,{X},'O'); m:face('f',G,{d},{out},'F'); local K=m:world('K',O); local r=m:strand('r',K,{X},'R')
  local q=Att.at(m,K):query(Att.patch(m,d)); local st,w=q:step(math.huge); eq(st,'hit')
  local spent=m:strand('spent',K,{X},'Spent'); m:face('consume',K,{r},{spent},'Consume')
  local before=#m.objects; local ok=pcall(function() w:graft() end); assert(not ok); eq(#m.objects,before,'stale graft partially mutated model')
end)

test('7. fixed Strand bindings cannot bypass exact-World locality',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X')
  local D=m:world('D'); local G=m:world('G'); local d=m:strand('d',D,{X},'R'); local out=m:strand('out',G,{X},'S'); m:face('f',G,{d},{out},'F')
  local K1=m:world('K1',O); local K2=m:world('K2',O); local foreign=m:strand('foreign',K2,{X},'R')
  local q=Att.at(m,K1):query(Att.patch(m,d),{{demand=d,supply=foreign}}); local st=q:step(math.huge); eq(st,'retry')
end)

test('8. completed retained queries revalidate when their frontier changes',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X')
  local D=m:world('D'); local G=m:world('G'); local d=m:strand('d',D,{X},'R'); local out=m:strand('out',G,{X},'S'); m:face('f',G,{d},{out},'F')
  local K=m:world('K',O); local p=Att.patch(m,d); local q=Att.at(m,K):query(p); local st=q:step(math.huge); eq(st,'retry')
  m:strand('r',K,{X},'R'); st=q:step(math.huge); eq(st,'hit'); assert(q:restarts()>=1)
end)

test('9. Retry certificate validity is false rather than exceptional when its patch ceases to be attachable',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X')
  local D=m:world('D'); local G=m:world('G'); local d=m:strand('d',D,{X},'R'); local out=m:strand('out',G,{X},'S'); m:face('f',G,{d},{out},'F')
  local K=m:world('K',O); local p=Att.patch(m,d); local q=Att.at(m,K):query(p); local st,c=q:step(math.huge); eq(st,'retry'); assert(c:valid())
  local D2=m:world('D2'); local x=m:strand('x',D2,{X},'Q'); m:face('producer',D2,{x},{d},'F')
  assert(not c:valid())
end)

print(string.format('%d/%d attachment-query tests passed',passed,passed))
