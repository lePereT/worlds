package.path='./src/?.lua;'..package.path
local Model=require('worlds.harden'); local Sep=require('worlds.separate'); local Att=require('worlds.att')
local Internal=require('worlds.internal')
local passed=0
local function test(name,f) io.write(string.format('%-78s ',name)); local ok,err=pcall(f); if not ok then print('FAIL'); error(err,0) end; passed=passed+1; print('ok') end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,msg) assert(a~=b,msg or (tostring(a)..' == '..tostring(b))) end
local function expect_fail(f,pat) local ok,err=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(err):match(pat),tostring(err)) end end

local function invoke(m,gate,trigger)
  local p=Att.patch(m,gate)
  local q=Att.at(m,trigger.world):query(p,{{demand=gate,supply=trigger}})
  local st,w=q:step(math.huge); assert(st=='hit','expected attachment hit, got '..tostring(st))
  return w:graft()
end

local function provider(private_variant)
  local m=Model.new('ProviderActuality'); local O=m.actuality
  local Mod=m:point('PublicModule',O,'ModuleIdentity')
  local Dep=m:point('PublicDep',O,'DependencyIdentity')
  local Dg=m:world('module-gate'); local Di=m:world('module-import'); local G=m:world('module-body')
  local gate=m:strand('module?',Dg,{Mod},'ModuleAuthority')
  local imp=m:strand('dep?',Di,{Dep},'DependencyAuthority')
  local Private=m:point(private_variant and 'PrivateRenamed' or 'Private',G,'AbstractType')
  local export=m:strand('export',G,{Private},'ModuleExport')
  local body=m:face(private_variant and 'body-v2' or 'body-v1',G,{gate,imp},{export},private_variant and 'DifferentPrivateBody' or 'ModuleBody')
  return m,{Mod=Mod,Dep=Dep,gate=gate,imp=imp,G=G,Private=Private,export=export,body=body}
end

local function client(frontier)
  local m=Model.new('ClientActuality'); local O=m.actuality
  local Mod=m:point('PublicModule',O,'ModuleIdentity'); local Dep=m:point('PublicDep',O,'DependencyIdentity')
  return m,{Mod=Mod,Dep=Dep,expected=frontier}
end

test('1. client frontier contains public demand/output geometry but not private body',function()
  local p,a=provider(false); local f=Sep.frontier(p,a.gate)
  assert(f:match('ModuleAuthority')); assert(f:match('DependencyAuthority')); assert(f:match('ModuleExport')); assert(f:match('AbstractType'))
  assert(not f:match('ModuleBody')); assert(f:match('EGRESS'));  assert(not f:match('body%-v1'))
end)

test('2. private implementation change leaves separate-compilation frontier stable',function()
  local p1,a1=provider(false); local p2,a2=provider(true)
  eq(Sep.frontier(p1,a1.gate),Sep.frontier(p2,a2.gate))
end)

test('3. client can compile from frontier only and link opaque provider later',function()
  local p,a=provider(false); local unit=Sep.export_unit(p,a.gate); local c,ca=client(unit.frontier)
  -- At client compile time only ca.expected is consulted; provider objects are inaccessible.
  local linked=Sep.import_unit(c,unit,ca.expected); assert(linked.stages[1].gate)
  local W=c:world('link-call',c.actuality); local mod=c:strand('mod',W,{ca.Mod},'ModuleAuthority'); local dep=c:strand('dep',W,{ca.Dep},'DependencyAuthority')
  local i=invoke(c,linked.stages[1].gate,mod)
  local export
  for old,new in pairs(i.map) do if type(old)=='table' and old.dim==1 and old.sort=='ModuleExport' then export=new end end
  assert(export and c:is_realised(export)); eq(i.map[linked.stages[1].gate],mod)
  local ok,why=Internal.model(c):check_actual_subcomplex(); assert(ok,why)
end)

test('4. frontier mismatch is rejected before provider geometry is installed',function()
  local p,a=provider(false); local unit=Sep.export_unit(p,a.gate); local c,ca=client(unit.frontier)
  local before=#c.objects; expect_fail(function() Sep.import_unit(c,unit,ca.expected..'x') end,'frontier mismatch'); eq(#c.objects,before)
end)

test('5. missing or ambiguous public anchors reject linking',function()
  local p,a=provider(false); local unit=Sep.export_unit(p,a.gate)
  local c=Model.new('C'); c:point('PublicModule',c.actuality,'ModuleIdentity')
  expect_fail(function() Sep.import_unit(c,unit,unit.frontier) end,'PublicDep')
end)

test('6. imported provider interior remains suspended until local invocation',function()
  local p,a=provider(false); local unit=Sep.export_unit(p,a.gate); local c,ca=client(unit.frontier); local linked=Sep.import_unit(c,unit,ca.expected)
  for _,w in ipairs(linked.stages[1].worlds) do assert(c:is_suspended(w)) end
  local Other=c:world('unrelated',c.actuality); local sentinel=c:point('sentinel',Other,'Sentinel'); local before=#Internal.model(c):_children(Other)
  local W=c:world('link-call',c.actuality); local mod=c:strand('mod',W,{ca.Mod},'ModuleAuthority'); c:strand('dep',W,{ca.Dep},'DependencyAuthority'); local i=invoke(c,linked.stages[1].gate,mod)
  eq(#Internal.model(c):_children(Other),before); eq(sentinel.world,Other); for _,w in ipairs(i.worlds) do eq(w.parent,W) end
end)

-- Provider with a public factory entry stage and a private callable stage. The
-- client frontier reveals only factory authority/result geometry; the second
-- stage is shipped opaque in the unit and becomes usable only after linking.
local function higher_provider()
  local m=Model.new('P'); local O=m.actuality
  local Factory=m:point('PublicFactory',O,'FactoryIdentity')
  local HiddenSchema=m:point('HiddenChildSchema',O,'HiddenChildSchema')
  local D1=m:world('factory-D'); local G1=m:world('factory-G')
  local gate=m:strand('factory?',D1,{Factory},'FactoryAuthority')
  local inst=m:point('hidden-instance',G1,'HiddenInstance')
  local child=m:strand('child-export',G1,{HiddenSchema,inst},'OpaqueChildAuthority')
  m:face('make-child',G1,{gate},{child},'FactoryBody')
  local D2=m:world('child-D'); local G2=m:world('child-G')
  local iq=m:point('hidden-instance?',D2,'HiddenInstance'); local cgate=m:strand('child?',D2,{HiddenSchema,iq},'OpaqueChildAuthority')
  local R=m:point('private-result',G2,'PrivateResult'); local out=m:strand('out',G2,{R},'OpaqueResult'); m:face('child-body',G2,{cgate},{out},'HiddenBody')
  return m,{Factory=Factory,gate=gate,cgate=cgate,child=child}
end

test('7. opaque nested stage survives separate compilation without public contract semantics',function()
  local p,a=higher_provider(); local unit=Sep.export_unit(p,a.gate,{a.cgate})
  assert(not unit.frontier:match('HiddenBody')); assert(not unit.frontier:match('child%?'))
  local c=Model.new('C'); local Factory=c:point('PublicFactory',c.actuality,'FactoryIdentity')
  local linked=Sep.import_unit(c,unit,unit.frontier)
  local W=c:world('call',c.actuality); local f=c:strand('factory',W,{Factory},'FactoryAuthority'); local first=invoke(c,linked.stages[1].gate,f)
  local child
  for old,new in pairs(first.map) do if type(old)=='table' and old.dim==1 and old.sort=='OpaqueChildAuthority' then child=new end end
  assert(child and c:is_realised(child))
  local second=invoke(c,linked.stages[2].gate,child); assert(second.faces[1].sort=='HiddenBody')
end)

test('8. provider stage is independently certified before export',function()
  local m=Model.new('P'); local O=m.actuality; local F=m:point('F',O,'F'); local D=m:world('D'); local G=m:world('G')
  local gate=m:strand('gate',D,{F},'A'); local s=m:strand('s',G,{F},'S'); local o1=m:strand('o1',G,{F},'O'); local o2=m:strand('o2',G,{F},'O')
  -- gate crosses D->G so stage is discoverable; s is illegally consumed twice.
  m:face('f1',G,{gate,s},{o1},'B'); m:face('f2',G,{s},{o2},'B')
  expect_fail(function() Sep.export_unit(m,gate) end,'suspended uses')
end)


test('9. linker-private anchors are isolated from ordinary client locality',function()
  local p,a=higher_provider(); local unit=Sep.export_unit(p,a.gate,{a.cgate})
  local c=Model.new('C'); local Factory=c:point('PublicFactory',c.actuality,'FactoryIdentity')
  local linked=Sep.import_unit(c,unit,unit.frontier); assert(linked.link_world and linked.link_world.parent==c.actuality)
  local private_count=0
  for _,pnt in pairs(linked.anchors) do if pnt.world==linked.link_world then private_count=private_count+1 end end
  assert(private_count>0)
  local W=c:world('ordinary-client-world',c.actuality)
  -- Private linker identity remains in its own World. Att(K) obtains authority
  -- only from exact-local unspent Strands; this Point alone grants none.
  for _,pnt in pairs(linked.anchors) do if pnt.world==linked.link_world then assert(pnt.world~=W) end end
end)

test('10. malformed opaque payload rolls back link installation atomically',function()
  local p,a=provider(false); local unit=Sep.export_unit(p,a.gate); local c,ca=client(unit.frontier)
  -- Corrupt a cell reference after export, simulating damaged/untrusted artefact bytes.
  local bad={format=unit.format,frontier=unit.frontier,anchors=unit.anchors,stages={}}
  for i,st in ipairs(unit.stages) do
    local ns={worlds=st.worlds,cells={},gate=st.gate,frontier=st.frontier}; bad.stages[i]=ns
    for j,x in ipairs(st.cells) do local y={}; for k,v in pairs(x) do y[k]=v end; ns.cells[j]=y end
  end
  for _,x in ipairs(bad.stages[1].cells) do if x.dim==2 then x.inputs={{cell=999999}}; break end end
  local before_o,before_w=#c.objects,#c.worlds
  expect_fail(function() Sep.import_unit(c,bad,ca.expected) end,'invalid input reference')
  eq(#c.objects,before_o); eq(#c.worlds,before_w)
end)

test('11. two independently linked providers keep private anchors nominally disjoint',function()
  local p1,a1=higher_provider(); local p2,a2=higher_provider()
  local u1=Sep.export_unit(p1,a1.gate,{a1.cgate}); local u2=Sep.export_unit(p2,a2.gate,{a2.cgate})
  local c=Model.new('C'); c:point('PublicFactory',c.actuality,'FactoryIdentity')
  local l1=Sep.import_unit(c,u1,u1.frontier); local l2=Sep.import_unit(c,u2,u2.frontier)
  ne(l1.link_world,l2.link_world)
  local a,b
  for _,pnt in pairs(l1.anchors) do if pnt.world==l1.link_world then a=pnt; break end end
  for _,pnt in pairs(l2.anchors) do if pnt.world==l2.link_world then b=pnt; break end end
  assert(a and b); ne(a,b)
end)


test('12. frontier preserves hidden identity correlation without private names',function()
  local function mk(shared)
    local m=Model.new('P'); local O=m.actuality; local F=m:point('F',O,'F'); local D=m:world('D'); local G=m:world('G')
    local gate=m:strand('gate',D,{F},'A')
    local p1=m:point('secret-one',G,'AbstractType'); local p2=shared and p1 or m:point('secret-two',G,'AbstractType')
    local a=m:strand('a',G,{p1},'ExportA'); local b=m:strand('b',G,{p2},'ExportB'); m:face('body',G,{gate},{a,b},'Body')
    return Sep.frontier(m,gate)
  end
  local same=mk(true); local distinct=mk(false); ne(same,distinct)
  assert(not same:match('secret%-one')); assert(not distinct:match('secret%-two'))
end)

test('13. late aliasing across Separate is rejected atomically before grafting',function()
  local p=Model.new('P'); local O=p.actuality; local F=p:point('F',O,'F'); local X=p:point('X',O,'X')
  local Dg=p:world('Dg'); local Da=p:world('Da'); local Db=p:world('Db'); local G=p:world('G')
  local gate=p:strand('gate',Dg,{F},'A'); local a=p:strand('a',Da,{X},'R'); local b=p:strand('b',Db,{X},'R'); local out=p:strand('out',G,{X},'Out'); p:face('body',G,{gate,a,b},{out},'Body')
  local unit=Sep.export_unit(p,gate)
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local Xc=c:point('X',c.actuality,'X'); local linked=Sep.import_unit(c,unit,unit.frontier)
  local W=c:world('call',c.actuality); local f=c:strand('f',W,{Fc},'A'); local r=c:strand('r',W,{Xc},'R'); local before_o,before_w=#c.objects,#c.worlds
  local q=Att.at(c,W):query(Att.patch(c,linked.stages[1].gate),{{demand=linked.stages[1].gate,supply=f}}); local st=q:step(math.huge); eq(st,'retry')
  eq(#c.objects,before_o); eq(#c.worlds,before_w); eq(Internal.model(c):_realised_uses(f),0); eq(Internal.model(c):_realised_uses(r),0)
end)

test('14. generated abstract identities remain fresh across separately-linked invocations',function()
  local p,a=provider(false); local unit=Sep.export_unit(p,a.gate); local c,ca=client(unit.frontier); local linked=Sep.import_unit(c,unit,unit.frontier)
  local function run(n)
    local W=c:world('call'..n,c.actuality); local mod=c:strand('mod'..n,W,{ca.Mod},'ModuleAuthority'); c:strand('dep'..n,W,{ca.Dep},'DependencyAuthority'); return invoke(c,linked.stages[1].gate,mod)
  end
  local i1,i2=run(1),run(2); local p1,p2
  for old,new in pairs(i1.map) do if type(old)=='table' and old.dim==0 and old.sort=='AbstractType' then p1=new end end
  for old,new in pairs(i2.map) do if type(old)=='table' and old.dim==0 and old.sort=='AbstractType' then p2=new end end
  assert(p1 and p2); ne(p1,p2); ne(p1.world,p2.world)
end)

print(string.format('%d/%d separate-compilation tests passed',passed,passed))
