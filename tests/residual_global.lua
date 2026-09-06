package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Att=W.Model,W.Att
local passed=0
local function test(name,f)
  io.write(string.format('%-92s ',name))
  local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end
  passed=passed+1; print('ok')
end
local function eq(a,b,m) assert(a==b,m or (tostring(a)..' ~= '..tostring(b))) end
local function witness(m,K,seed,fixed)
  local q=Att.at(m,K):query(Att.patch(m,seed),fixed)
  local st,w=q:step(math.huge); eq(st,'hit'); return w
end

local function pair(shared)
  local m=Model.new('O'); local O=m.actuality; local P=m:point('P',O,'P')
  local K=m:world('K',O)
  local s1=m:strand('s1',K,{P},'R')
  local s2=m:strand('s2',K,{P},'R')

  local D1=m:world('D1'); local G1=m:world('G1')
  local g1=m:strand('g1?',D1,{P},'R'); local o1=m:strand('o1',D1,{P},'R')
  local a=m:face('a',G1,{g1},{o1},'A')

  local D2=m:world('D2'); local G2=m:world('G2')
  local g2=m:strand('g2?',D2,{P},'R'); local o2=m:strand('o2',D2,{P},'R')
  local b=m:face('b',G2,{g2},{o2},'B')

  local root=Att.at(m,K)
  local wa=root:witnesses(Att.patch(m,g1),{{demand=g1,supply=s1}})[1]
  local wb=root:witnesses(Att.patch(m,g2),{{demand=g2,supply=shared and s1 or s2}})[1]
  assert(wa and wb)
  return m,K,wa,wb,s1,s2,a,b
end

local function triple()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O)
  local ws,gates,supplies,patches={},{},{},{}
  for i=1,3 do
    local P=m:point('P'..i,O,'P')
    supplies[i]=m:strand('s'..i,K,{P},'R')
    local D=m:world('D'..i); local G=m:world('G'..i)
    gates[i]=m:strand('g'..i..'?',D,{P},'R'); local o=m:strand('o'..i,D,{P},'R')
    m:face('f'..i,G,{gates[i]},{o},'A')
    patches[i]=Att.patch(m,gates[i])
  end
  local root=Att.at(m,K)
  for i=1,3 do ws[i]=root:witnesses(patches[i],{{demand=gates[i],supply=supplies[i]}})[1]; assert(ws[i]) end
  return m,K,ws
end

test('1. exact witnesses on distinct scarce Strands derive cross-patch compatibility',function()
  local _,K,wa,wb,s1,s2=pair(false)
  local root=wa:frontier(); local ok,p=Att.coherence(root,{wa,wb}); assert(ok); eq(p.dimension,2); eq(p.vertex_count,4)
  eq(#wa:support(),1); eq(#wb:support(),1); eq(wa:support()[1],s1); eq(wb:support()[1],s2)
end)

test('2. exact witnesses competing for the same scarce Strand derive conflict',function()
  local _,_,wa,wb,s1=pair(true)
  local ok,p=Att.coherence(wa:frontier(),{wa,wb}); assert(not ok); assert(p.reason)
end)

test('3. Point alias does not create conflict when exact Strand authority is distinct',function()
  local _,_,wa,wb=pair(false)
  -- Both supplies denote the same Point P.  Only exact Strand occurrence matters.
  local ok=Att.coherence(wa:frontier(),{wa,wb}); assert(ok)
end)

test('4. compatible exact family is downward closed',function()
  local _,_,ws=triple()
  local root=ws[1]:frontier(); local ok3,p3=Att.coherence(root,ws); assert(ok3); eq(p3.dimension,3)
  for i=1,3 do
    local ok1=Att.coherence(root,{ws[i]}); assert(ok1)
    for j=i+1,3 do local ok2=Att.coherence(root,{ws[i],ws[j]}); assert(ok2) end
  end
end)

test('5. grafting one compatible witness preserves the exact other witness',function()
  local _,_,wa,wb=pair(false); assert(wa:valid() and wb:valid())
  wa:graft(); assert(not wa:valid()); assert(wb:valid())
end)

test('6. grafting one conflicting witness invalidates the exact competitor',function()
  local _,_,wa,wb=pair(true); assert(wa:valid() and wb:valid())
  wa:graft(); assert(not wa:valid()); assert(not wb:valid())
end)

test('7. compatibility classification is non-generative',function()
  local m,_,wa,wb=pair(false); local before=#m.objects
  local ok=Att.coherence(wa:frontier(),{wa,wb}); assert(ok); eq(#m.objects,before)
end)

test('8. family requires one actual locality rather than inventing global compatibility',function()
  local m1,_,wa=pair(false); local m2,_,wb=pair(false)
  assert(m1~=m2)
  local ok=pcall(function() Att.coherence(wa:frontier(),{wa,wb}) end); assert(not ok)
end)

print(string.format('%d/%d cross-patch residual tests passed',passed,passed))
