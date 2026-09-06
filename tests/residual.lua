package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Att=W.Model,W.Att
local Ref=require('tests.reference.cut')
local passed=0
local function test(name,f) io.write(string.format('%-96s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end
local function eq(a,b,m) assert(a==b,m or (tostring(a)..' ~= '..tostring(b))) end

local function witness(m,K,seed,fixed)
  local q=Att.at(m,K):query(Att.patch(m,seed),fixed); local st,w=q:step(math.huge); eq(st,'hit'); return w
end

local function chain()
  local m=Model.new('O'); local O=m.actuality; local P=m:point('P',O,'P')
  local D=m:world('D'); local G=m:world('G')
  local gate=m:strand('gate?',D,{P},'R')
  local mid=m:strand('mid',G,{P},'R')
  local out=m:strand('out',D,{P},'R')
  local a=m:face('a',G,{gate},{mid},'A')
  local b=m:face('b',G,{mid},{out},'B')
  local K=m:world('K',O); local supply=m:strand('supply',K,{P},'R')
  local w=witness(m,K,gate,{{demand=gate,supply=supply}})
  return m,w,gate,supply,a,b,out
end

local function independent(n)
  local m=Model.new('O'); local O=m.actuality; local G=m:world('G'); local K=m:world('K',O)
  local faces,gates,supplies,fixed={},{},{},{}
  for i=1,n do
    local P=m:point('P'..i,O,'P')
    local D=m:world('D'..i)
    local gate=m:strand('gate'..i..'?',D,{P},'R')
    local out=m:strand('out'..i,D,{P},'R')
    local face=m:face('a'..i,G,{gate},{out},'A')
    local supply=m:strand('supply'..i,K,{P},'R')
    faces[i]=face; gates[i]=gate; supplies[i]=supply
    fixed[i]={demand=gate,supply=supply}
  end
  local w=witness(m,K,gates[1],fixed)
  return m,w,faces,gates,supplies
end

local function production_reachable(r)
  local seen,out={},{}
  local function visit(cur)
    local sig=cur:signature():match('D%{.*')
    if seen[sig] then return end
    seen[sig]=true; out[#out+1]=sig
    for _,f in ipairs(cur:enabled()) do visit(cur:after(f)) end
  end
  visit(r); table.sort(out); return out
end

test('1. pointed residual begins at exact boundary and never rematches',function()
  local m,w,gate,supply,a=chain(); local r=w:cut()
  eq(r:binding(gate),supply); eq(#r:past(),0); eq(#r:enabled(),1); eq(r:enabled()[1],a)
end)

test('2. causal residual exposes successor only after exact predecessor',function()
  local m,w,gate,supply,a,b=chain(); local r=w:cut()
  local ok=Att.coherence(r,{a,b}); assert(not ok,'causal chain incorrectly formed a square')
  local r1=r:after(a); eq(#r1:enabled(),1); eq(r1:enabled()[1],b); assert(not r1:terminal())
  local r2=r1:after(b); assert(r2:terminal()); eq(#r2:past(),2)
end)

test('3. stale attachment witness cannot seed residual development',function()
  local m,w=chain(); assert(w:valid()); w:graft(); assert(not w:valid())
  local ok=pcall(function() w:cut() end); assert(not ok)
end)

test('4. two simultaneously enabled exact developments derive a commuting square',function()
  local m,w,faces=independent(2); local r=w:cut()
  eq(#r:enabled(),2); local ok,proof=Att.coherence(r,faces); assert(ok); eq(proof.dimension,2); eq(proof.vertex_count,4)
  local ab=r:after(faces[1]):after(faces[2]); local ba=r:after(faces[2]):after(faces[1]); assert(Att.same(ab,ba))
end)

test('5. three enabled developments derive a coherent 3-cube without cube metadata',function()
  local m,w,faces=independent(3); local r=w:cut()
  local ok,proof=Att.coherence(r,faces); assert(ok); eq(proof.dimension,3); eq(proof.vertex_count,8)
end)

test('6. five enabled developments derive a coherent 5-cube across all 120 linearisations',function()
  local m,w,faces=independent(5); local r=w:cut()
  local ok,proof=Att.coherence(r,faces); assert(ok); eq(proof.dimension,5); eq(proof.vertex_count,32)
end)

test('7. exact residual state space agrees with independent set-theoretic reference semantics',function()
  local m,w=independent(4); local r=w:cut()
  local prod=production_reachable(r); local refs=Ref.reachable(m,w); local rr={}
  for i,x in ipairs(refs) do rr[i]=x.signature end; table.sort(rr)
  eq(#prod,#rr); for i=1,#prod do if prod[i]~=rr[i] then print('PROD',prod[i]); print('REF ',rr[i]) end; eq(prod[i],rr[i],'reference residual mismatch at '..i) end
  eq(#prod,16,'four independent faces should expose Boolean 4-cube vertices')
end)

test('8. structural copy causally creates a new commuting square',function()
  local m=Model.new('O'); local O=m.actuality; local P=m:point('P',O,'P')
  local D=m:world('D'); local G=m:world('G'); local K=m:world('K',O)
  local gate=m:strand('gate?',D,{P},'R')
  local left=m:strand('left',G,{P},'R'); local right=m:strand('right',G,{P},'R')
  local split=m:copy('split',G,gate,{left,right},'R')
  local o1=m:strand('o1',D,{P},'R'); local o2=m:strand('o2',D,{P},'R')
  local a=m:face('a',G,{left},{o1},'A'); local b=m:face('b',G,{right},{o2},'B')
  local supply=m:strand('supply',K,{P},'R')
  local w=witness(m,K,gate,{{demand=gate,supply=supply}}); local r=w:cut()
  eq(#r:enabled(),1); eq(r:enabled()[1],split)
  local after=r:after(split); eq(#after:enabled(),2)
  local ok,proof=Att.coherence(after,{a,b}); assert(ok); eq(proof.dimension,2)
end)

test('9. Point aliasing does not weaken exact Strand pointing',function()
  local m=Model.new('O'); local O=m.actuality; local P=m:point('P',O,'P')
  local D=m:world('D'); local G=m:world('G'); local K=m:world('K',O)
  local gate=m:strand('gate?',D,{P},'R'); local out=m:strand('out',D,{P},'R'); m:face('body',G,{gate},{out},'A')
  local s1=m:strand('s1',K,{P},'R'); local s2=m:strand('s2',K,{P},'R')
  local w=witness(m,K,gate,{{demand=gate,supply=s2}}); local r=w:cut()
  eq(r:binding(gate),s2); assert(r:binding(gate)~=s1)
end)



test('10. an already-started residual refuses development after its exact boundary becomes stale',function()
  local m,w=chain(); local r=w:cut(); w:graft()
  local ok=pcall(function() r:enabled() end); assert(not ok)
end)

test('11. residual exploration is non-generative and cannot mutate the carrier',function()
  local m,w,faces=independent(3); local before=#m.objects; local r=w:cut()
  local ok=Att.coherence(r,faces); assert(ok); eq(#m.objects,before)
end)

test('12. pointed Cut is derived only from its exact Witness and is immutable',function()
  local _,w=chain(); local c=w:cut(); local ok=pcall(function() c.foo='bar' end); assert(not ok)
end)

print(string.format('%d/%d residual tests passed',passed,passed))
