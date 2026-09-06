package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Att=W.Model,W.Att
local passed=0
local function test(name,f) io.write(string.format('%-92s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end
local function eq(a,b,m) assert(a==b,m or (tostring(a)..' ~= '..tostring(b))) end
local function status(m,K,seed,fixed)
  local q=Att.at(m,K):query(Att.patch(m,seed),fixed); return q:step(math.huge)
end
local function witness(m,K,seed,fixed)
  local st,w=status(m,K,seed,fixed); eq(st,'hit'); return w
end

local function causal_chain()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O)
  local Start=m:point('Start',O,'Start'); local Mid=m:point('Mid',O,'Mid'); local End=m:point('End',O,'End')
  local s=m:strand('start',K,{Start},'State')

  local Da=m:world('Da'); local Ga=m:world('Ga')
  local ag=m:strand('a?',Da,{Start},'State'); local amid=m:strand('mid',Da,{Mid},'State')
  m:face('a',Ga,{ag},{amid},'Step')

  local Db=m:world('Db'); local Gb=m:world('Gb')
  local bg=m:strand('b?',Db,{Mid},'State'); local bout=m:strand('end',Db,{End},'State')
  m:face('b',Gb,{bg},{bout},'Step')

  local wa=witness(m,K,ag,{{demand=ag,supply=s}})
  return m,K,wa,bg,bout
end

local function independent_pair()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O)
  local patches,gates,supplies,ws={},{},{},{}
  for i=1,2 do
    local P=m:point('P'..i,O,'P'); local Q=m:point('Q'..i,O,'Q')
    supplies[i]=m:strand('s'..i,K,{P},'R')
    local D=m:world('D'..i); local G=m:world('G'..i)
    gates[i]=m:strand('g'..i..'?',D,{P},'R'); local out=m:strand('o'..i,D,{Q},'R')
    m:face('f'..i,G,{gates[i]},{out},'A')
    patches[i]=Att.patch(m,gates[i])
  end
  local root=Att.at(m,K)
  for i=1,2 do ws[i]=root:witnesses(patches[i],{{demand=gates[i],supply=supplies[i]}})[1]; assert(ws[i]) end
  return m,K,patches,ws
end

test('1. residual frontier derives cross-patch causal enablement without grafting',function()
  local m,K,wa,bg=causal_chain(); local before=#m.objects
  local st=status(m,K,bg); eq(st,'retry','b should not be currently attachable')
  local r=wa:after(); local bs=r:witnesses(Att.patch(m,bg)); eq(#bs,1)
  eq(#m.objects,before,'symbolic residual frontier mutated carrier')
end)

test('2. symbolic causal development advances again without carrier mutation',function()
  local m,_,wa,bg=causal_chain(); local before=#m.objects
  local r=wa:after(); local wb=r:witnesses(Att.patch(m,bg))[1]; assert(wb)
  local r2=wb:after(); assert(r2:signature()~=r:signature()); eq(#m.objects,before)
end)

test('3. actual graft confirms the causal enablement predicted by residual frontier',function()
  local m,K,wa,bg=causal_chain(); local predicted=wa:after():witnesses(Att.patch(m,bg)); eq(#predicted,1)
  wa:graft(); local st=status(m,K,bg); eq(st,'hit')
end)

test('4. independent cross-patch developments commute as residual frontiers',function()
  local m,_,patches,ws=independent_pair()
  local ra=ws[1]:after(); local wb=ra:witnesses(patches[2]); eq(#wb,1); local rab=wb[1]:after()
  local rb=ws[2]:after(); local wa=rb:witnesses(patches[1]); eq(#wa,1); local rba=wa[1]:after()
  assert(Att.same(rab,rba),rab:signature()..' != '..rba:signature())
end)

test('5. residual frontier preserves exact conflict: consumed actual authority is unavailable',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O); local P=m:point('P',O,'P')
  local s=m:strand('s',K,{P},'R')
  local function patch(name)
    local D=m:world('D'..name); local G=m:world('G'..name)
    local g=m:strand('g'..name..'?',D,{P},'R')
    local o=m:strand('o'..name,D,{P},'Done'..name)
    m:face('f'..name,G,{g},{o},'A')
    return g,Att.patch(m,g)
  end
  local ga,pa=patch('a'); local gb,pb=patch('b')
  local wa=witness(m,K,ga,{{demand=ga,supply=s}}); local wb=witness(m,K,gb,{{demand=gb,supply=s}}); assert(wb)
  local r=wa:after(); eq(#r:witnesses(pb),0)
end)


-- Additional global configuration tests deliberately exercise the transition
-- system from the current frontier, rather than seeding it after one event.
local AttRef=require('tests.reference.attachment')

test('6. global root witnesses agree with exhaustive Att on current actuality',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O); local P=m:point('P',O,'P')
  m:strand('s1',K,{P},'R'); m:strand('s2',K,{P},'R')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('g?',D,{P},'R'); local out=m:strand('o',D,{P},'R'); m:face('f',G,{gate},{out},'A')
  local patch=Att.patch(m,gate); local exact=AttRef.matches(m,K,gate); local symbolic=Att.at(m,K):witnesses(patch)
  eq(#symbolic,#exact); eq(#symbolic,2)
end)

test('7. two independent patches span a derived global square from current frontier',function()
  local m,K,patches=independent_pair(); local root=Att.at(m,K)
  local a=root:witnesses(patches[1])[1]; local b=root:witnesses(patches[2])[1]; assert(a and b)
  local ok,cube=Att.coherence(root,{a,b}); assert(ok); eq(cube.dimension,2); eq(cube.vertex_count,4)
end)

test('8. three independent patches span a derived global 3-cell',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O); local patches={}
  for i=1,3 do
    local P=m:point('P'..i,O,'P'); local Q=m:point('Q'..i,O,'Q'); m:strand('s'..i,K,{P},'R')
    local D=m:world('D'..i); local G=m:world('G'..i); local g=m:strand('g'..i..'?',D,{P},'R'); local o=m:strand('o'..i,D,{Q},'R'); m:face('f'..i,G,{g},{o},'A')
    patches[i]=Att.patch(m,g)
  end
  local root=Att.at(m,K); local family={}
  for i=1,3 do family[i]=root:witnesses(patches[i])[1]; assert(family[i]) end
  local ok,cube=Att.coherence(root,family); assert(ok); eq(cube.dimension,3); eq(cube.vertex_count,8)
end)

test('9. competing current occurrences fail global square completion rather than carrying Conflict metadata',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O); local P=m:point('P',O,'P'); m:strand('s',K,{P},'R')
  local patches={}
  for i=1,2 do
    local D=m:world('D'..i); local G=m:world('G'..i); local g=m:strand('g'..i..'?',D,{P},'R'); local o=m:strand('o'..i,D,{P},'Done'..i); m:face('f'..i,G,{g},{o},'A'); patches[i]=Att.patch(m,g)
  end
  local root=Att.at(m,K); local a=root:witnesses(patches[1])[1]; local b=root:witnesses(patches[2])[1]; assert(a and b)
  local ok,why=Att.coherence(root,{a,b}); assert(not ok); eq(why.reason,'exact-event-not-residual')
end)

test('10. two exact witnesses of one reusable patch can form a square when distinct supplies exist',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:world('K',O); local P=m:point('P',O,'P')
  m:strand('s1',K,{P},'R'); m:strand('s2',K,{P},'R')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('g?',D,{P},'R'); local out=m:strand('o',D,{P},'Done'); m:face('f',G,{gate},{out},'A')
  local patch=Att.patch(m,gate); local root=Att.at(m,K); local ws=root:witnesses(patch); eq(#ws,2)
  local ok,cube=Att.coherence(root,{ws[1],ws[2]}); assert(ok); eq(cube.vertex_count,4)
end)



test('11. causal successor derives its exact predecessor from symbolic egress',function()
  local m,_,wa,bg=causal_chain(); local r=wa:after()
  local wb=r:witnesses(Att.patch(m,bg))[1]; assert(wb)
  local ps=wb:predecessors(); eq(#ps,1)
end)

test('12. independent residual event does not acquire a false causal predecessor',function()
  local m,K,patches,ws=independent_pair(); local root=Att.at(m,K)
  local a=root:witnesses(patches[1])[1]; local b0=root:witnesses(patches[2])[1]
  eq(#b0:predecessors(),0)
  local ra=a:after(); local b1=nil
  for _,w in ipairs(ra:witnesses(patches[2])) do if w:key()==b0:key() then b1=w; break end end
  assert(b1); eq(#b1:predecessors(),0)
end)

print(string.format('%d/%d global causal residual tests passed',passed,passed))
