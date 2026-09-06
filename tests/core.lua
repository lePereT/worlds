package.path='./src/?.lua;'..package.path
local Model=require('model')
local passed=0
local function test(name,f)
  io.write(string.format('%-76s ',name)); local ok,err=pcall(f); if not ok then print('FAIL'); error(err,0) end; passed=passed+1; print('ok')
end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,msg) assert(a~=b,msg or (tostring(a)..' == '..tostring(b))) end
local function expect_fail(f,pat) local ok,err=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(err):match(pat),tostring(err)) end end

local function call_world(m,parent,name) return m:world(name,parent) end
local function occurrence(m,name,w,id,sort) return m:strand(name,w,{id},sort or 'CallableAuthority') end

local function generic_template(m,name)
  local O=m.actuality
  local Fn=m:point(name..'-id',O,'CallableIdentity')
  local D=m:world(name..'-demand')
  local G=m:world(name..'-generate')
  local gate=m:strand(name..'-auth?',D,{Fn},'CallableAuthority')
  local T=m:point(name..'-T?',D,'Type')
  local arg=m:strand(name..'-arg?',D,{T},'Argument')
  local result=m:strand(name..'-result',G,{T},'Result')
  local body=m:face(name..'-body',G,{gate,arg},{result},'CallableBody')
  return {Fn=Fn,D=D,G=G,gate=gate,T=T,arg=arg,result=result,body=body}
end

test('1. there is no latency integer and no World state bit',function()
  local m=Model.new('O'); local A=m:world('archetype'); local p=m:point('p',A,'P')
  assert(A.latent==nil and A.state==nil and p.latency==nil and p.polarity==nil)
  assert(m:is_realised(m.actuality)); assert(m:is_suspended(A))
end)

test('2. actuality is reachability in the World forest',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local N=m:world('N',W); local A=m:world('A'); local B=m:world('B',A)
  assert(m:is_realised(W) and m:is_realised(N)); assert(m:is_suspended(A) and m:is_suspended(B))
end)

test('3. actual geometry cannot depend on suspended geometry',function()
  local m=Model.new('O'); local A=m:world('A'); local p=m:point('p',A,'T')
  expect_fail(function() m:strand('bad',m.actuality,{p},'S') end,'actuality%-boundary')
end)

test('4. generic call develops detached Worlds into actual locality',function()
  local m=Model.new('O'); local g=generic_template(m,'id'); local W=call_world(m,m.actuality,'call')
  local f=occurrence(m,'f',W,g.Fn); local Int=m:point('Int',m.actuality,'Type'); local x=m:strand('x',W,{Int},'Argument')
  local i=m:develop(f)
  eq(i.map[g.T],Int); eq(i.map[g.arg],x); eq(i.map[g.body].inputs[1],f); eq(i.map[g.body].inputs[2],x)
  assert(m:is_realised(i.map[g.G])); eq(i.map[g.G].parent,W)
end)

test('5. two occurrences graft fresh World instances but share actual anchors',function()
  local m=Model.new('O'); local g=generic_template(m,'id'); local Int=m:point('Int',m.actuality,'Type')
  local W1=call_world(m,m.actuality,'c1'); local W2=call_world(m,m.actuality,'c2')
  local x1=m:strand('x1',W1,{Int},'Argument'); local x2=m:strand('x2',W2,{Int},'Argument')
  local a=m:develop(occurrence(m,'f1',W1,g.Fn)); local b=m:develop(occurrence(m,'f2',W2,g.Fn))
  ne(a.map[g.G],b.map[g.G]); eq(a.map[g.T],Int); eq(b.map[g.T],Int); eq(a.map[g.arg],x1); eq(b.map[g.arg],x2)
end)

test('6. local supply cannot leak from another actual World',function()
  local m=Model.new('O'); local g=generic_template(m,'id'); local Int=m:point('Int',m.actuality,'Type')
  local Call=call_world(m,m.actuality,'call'); local Other=call_world(m,m.actuality,'other')
  local f=occurrence(m,'f',Call,g.Fn); m:strand('x',Other,{Int},'Argument')
  expect_fail(function() m:develop(f) end,'no local realised supply')
end)

test('7. two indistinguishable supplies in one World are rejected',function()
  local m=Model.new('O'); local g=generic_template(m,'id'); local T=m:point('T',m.actuality,'Type'); local W=call_world(m,m.actuality,'call')
  local f=occurrence(m,'f',W,g.Fn); m:strand('x1',W,{T},'Argument'); m:strand('x2',W,{T},'Argument')
  expect_fail(function() m:develop(f) end,'ambiguous local supply')
end)

test('8. late aliasing is resolved geometrically and rejected before grafting',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'CallableIdentity'); local X=m:point('X',O,'X')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('gate',D,{F},'CallableAuthority')
  local a=m:strand('a',D,{X},'R'); local b=m:strand('b',D,{X},'R'); local out=m:strand('out',G,{X},'Out'); m:face('body',G,{gate,a,b},{out},'Body')
  local W=call_world(m,O,'call'); local f=occurrence(m,'f',W,F); local r=m:strand('r',W,{X},'R')
  local before_o,before_w=#m.objects,#m.worlds
  expect_fail(function() m:develop(f) end,'would use realised Strand')
  eq(#m.objects,before_o); eq(#m.worlds,before_w); eq(m:_realised_uses(f),0); eq(m:_realised_uses(r),0)
end)

-- Higher-order stage 1 generates an authority with a stable schema Point and a
-- fresh instance Point. Stage 2 is a separate detached component. Its gate
-- shares the stable schema Point and demands an instance Point structurally.
local function nested_factory(m)
  local O=m.actuality
  local Make=m:point('Make',O,'ConstructorIdentity')
  local FactorySchema=m:point('FactorySchema',O,'FactorySchema')
  local ChildSchema=m:point('ChildSchema',O,'ChildSchema')
  local D1=m:world('make-D'); local G1=m:world('make-G')
  local make_gate=m:strand('make?',D1,{Make},'ConstructorAuthority')
  local fi=m:point('factory-instance',G1,'FactoryInstance')
  local factory=m:strand('factory',G1,{FactorySchema,fi},'FactoryAuthority')
  local make_face=m:face('construct',G1,{make_gate},{factory},'Construct')

  local D2=m:world('factory-D'); local G2=m:world('factory-G')
  local fiq=m:point('factory-instance?',D2,'FactoryInstance')
  local fgate=m:strand('factory?',D2,{FactorySchema,fiq},'FactoryAuthority')
  local ci=m:point('child-instance',G2,'ChildInstance')
  local child=m:strand('child',G2,{ChildSchema,ci},'ChildAuthority')
  local factory_face=m:face('factory-body',G2,{fgate},{child},'FactoryBody')

  local D3=m:world('child-D'); local G3=m:world('child-G')
  local ciq=m:point('child-instance?',D3,'ChildInstance')
  local cgate=m:strand('child?',D3,{ChildSchema,ciq},'ChildAuthority')
  local R=m:point('R',G3,'ResultIdentity'); local out=m:strand('child-result',G3,{R},'ChildResult')
  local child_face=m:face('child-body',G3,{cgate},{out},'ChildBody')
  return {Make=Make,FactorySchema=FactorySchema,ChildSchema=ChildSchema,D1=D1,G1=G1,make_gate=make_gate,fi=fi,factory=factory,make_face=make_face,D2=D2,G2=G2,fiq=fiq,fgate=fgate,ci=ci,child=child,factory_face=factory_face,D3=D3,G3=G3,ciq=ciq,cgate=cgate,child_face=child_face}
end

test('9. higher order is repeated grafting, not stored or nested latency',function()
  local m=Model.new('O'); local a=nested_factory(m); local W=call_world(m,m.actuality,'call')
  local i1=m:develop(occurrence(m,'make',W,a.Make,'ConstructorAuthority')); local factory=i1.map[a.factory]
  local i2=m:develop(factory); local child=i2.map[a.child]
  local i3=m:develop(child)
  eq(i1.map[a.G1].parent,W); eq(i2.map[a.G2].parent,factory.world); eq(i3.map[a.G3].parent,child.world)
  eq(i2.map[a.fiq],i1.map[a.fi]); eq(i3.map[a.ciq],i2.map[a.ci])
  assert(a.D2.parent==nil and a.G2.parent==nil and a.D3.parent==nil and a.G3.parent==nil)
end)

test('10. independent higher-order paths retain fresh instance identities',function()
  local m=Model.new('O'); local a=nested_factory(m)
  local x=m:develop(occurrence(m,'mx',call_world(m,m.actuality,'wx'),a.Make,'ConstructorAuthority'))
  local y=m:develop(occurrence(m,'my',call_world(m,m.actuality,'wy'),a.Make,'ConstructorAuthority'))
  ne(x.map[a.fi],y.map[a.fi]); local fx=m:develop(x.map[a.factory]); local fy=m:develop(y.map[a.factory]); ne(fx.map[a.ci],fy.map[a.ci])
end)

local function dynamic_capture(m)
  local O=m.actuality; local Make=m:point('Make',O,'ConstructorIdentity'); local ChildSchema=m:point('ChildSchema',O,'ChildSchema'); local X=m:point('X',O,'Resource')
  local Dg=m:world('make-gate-D'); local Dx=m:world('make-x-D'); local G=m:world('closure-G')
  local gate=m:strand('make?',Dg,{Make},'ConstructorAuthority'); local xin=m:strand('x?',Dx,{X},'ResourceOccurrence')
  local ci=m:point('child-instance',G,'ChildInstance'); local held=m:strand('held-x',G,{X},'HeldResource'); local child=m:strand('child',G,{ChildSchema,ci},'ChildAuthority')
  local construct=m:face('construct',G,{gate,xin},{held,child},'Construct')
  local Dc=m:world('child-D'); local Dh=m:world('held-D'); local Gc=m:world('child-G')
  local ciq=m:point('child-instance?',Dc,'ChildInstance'); local cgate=m:strand('child?',Dc,{ChildSchema,ciq},'ChildAuthority'); local heldq=m:strand('held?',Dh,{X},'HeldResource')
  local out=m:strand('out',Gc,{X},'Result'); local body=m:face('body',Gc,{cgate,heldq},{out},'ChildBody')
  return {Make=Make,X=X,gate=gate,xin=xin,G=G,ci=ci,held=held,child=child,construct=construct,cgate=cgate,ciq=ciq,heldq=heldq,body=body}
end

test('11. dynamic capture is explicit transfer into a fresh actual World',function()
  local m=Model.new('O'); local a=dynamic_capture(m); local W=call_world(m,m.actuality,'call'); local make=occurrence(m,'make',W,a.Make,'ConstructorAuthority'); local x=m:strand('x',W,{a.X},'ResourceOccurrence')
  local i=m:develop(make); local held=i.map[a.held]; ne(held,x); eq(i.map[a.construct].inputs[2],x); eq(held.world,i.map[a.G])
  local j=m:develop(i.map[a.child]); eq(j.map[a.heldq],held); eq(j.map[a.body].inputs[2],held)
end)

test('12. re-entrant use grows actual World ancestry without trigger paths',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'CallableIdentity'); local D=m:world('D'); local G=m:world('G')
  local gate=m:strand('f?',D,{F},'CallableAuthority'); local nextf=m:strand('next',G,{F},'CallableAuthority'); local body=m:face('body',G,{gate},{nextf},'Body')
  local W=call_world(m,O,'initial'); local f0=occurrence(m,'f0',W,F)
  local i1=m:develop(f0); local i2=m:develop(i1.map[nextf]); local i3=m:develop(i2.map[nextf])
  eq(i2.map[G].parent,i1.map[nextf].world); eq(i3.map[G].parent,i2.map[nextf].world)
  assert(i1.trigger_path==nil and i2.trigger_path==nil)
end)

test('13. development failure is transactional',function()
  local m=Model.new('O'); local g=generic_template(m,'id'); local W=call_world(m,m.actuality,'call'); local f=occurrence(m,'f',W,g.Fn)
  local before=#m.objects; expect_fail(function() m:develop(f) end,'no local realised supply'); eq(#m.objects,before); eq(m:_uses(f),0)
end)

test('14. actual geometry remains an honest subcomplex after many developments',function()
  local m=Model.new('O'); local g=generic_template(m,'id')
  for n=1,25 do local W=call_world(m,m.actuality,'w'..n); local f=occurrence(m,'f'..n,W,g.Fn); local T=m:point('T'..n,m.actuality,'Type'); m:strand('x'..n,W,{T},'Argument'); m:develop(f) end
  local ok,why=m:check_actual_subcomplex(); assert(ok,why)
end)

test('15. the public kernel has develop but no latency/glue/root-selection API',function()
  local m=Model.new('O'); assert(type(m.develop)=='function'); assert(m.realise==nil and m.glue==nil and m.depth==nil)
end)


test('16. a developable gate requires a realised schema anchor shared with trigger',function()
  local m=Model.new('O'); local O=m.actuality; local D=m:world('D'); local G=m:world('G')
  local openId=m:point('anonymous?',D,'CallableIdentity'); local gate=m:strand('gate',D,{openId},'CallableAuthority')
  local R=m:point('R',G,'R'); local out=m:strand('out',G,{R},'Out'); m:face('body',G,{gate},{out},'Body')
  local W=m:world('call',O); local actualId=m:point('Actual',O,'CallableIdentity'); local f=m:strand('f',W,{actualId},'CallableAuthority')
  expect_fail(function() m:develop(f) end,'no suspended development stage')
end)


test('17. Point-equivalent representatives are one identity during development',function()
  local m=Model.new('O'); local O=m.actuality
  local F=m:point('F',O,'CallableIdentity')
  local Dg=m:world('Dg'); local Da=m:world('Da'); local Db=m:world('Db'); local G=m:world('G')
  local gate=m:strand('gate',Dg,{F},'CallableAuthority')
  local q=m:point('q?',Da,'T')
  local a=m:strand('a?',Da,{q},'A')
  local b=m:strand('b?',Db,{q},'B')
  local r=m:strand('r',G,{q},'R')
  local body=m:face('body',G,{gate,a,b},{r},'Body')

  local W=m:world('call',O)
  local f=m:strand('f',W,{F},'CallableAuthority')
  local p1=m:point('p1',W,'T'); local p2=m:point('p2',W,'T')
  m:glue_points(p1,p2); assert(m:same_point(p1,p2))
  local av=m:strand('av',W,{p1},'A'); local bv=m:strand('bv',W,{p2},'B')

  local i=m:develop(f)
  eq(i.map[a],av); eq(i.map[b],bv)
  assert(m:same_point(i.map[q],p1) and m:same_point(i.map[q],p2))
  eq(i.map[body].inputs[2],av); eq(i.map[body].inputs[3],bv)
end)


test('18. generated geometry may return authority causally through a generic open output frontier',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'CallableIdentity')
  local D=m:world('D'); local G=m:world('G')
  local gate=m:strand('gate',D,{F},'CallableAuthority')
  local R=m:point('result-id',G,'ResultIdentity')
  local out=m:strand('result?',D,{R},'ResultAuthority')
  local body=m:face('body',G,{gate},{out},'Body')
  local W=m:world('call',O); local f=m:strand('f',W,{F},'CallableAuthority')
  local i=m:develop(f)
  local actual=i.map[out]; assert(actual and m:is_realised(actual)); eq(actual.world,W)
  eq(i.egress[1],actual); eq(i.map[body].outputs[1],actual)
  assert(m:is_realised(i.map[R]) and i.map[R].world==i.map[G])
end)

print(string.format('%d/%d topology-directed tests passed',passed,passed))
