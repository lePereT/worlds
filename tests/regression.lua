package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Att=W.Model,W.Attachment
local Internal=require('worlds.internal')

local passed=0
local function test(name,f)
  io.write(string.format('%-88s ',name))
  local ok,err=pcall(f)
  if not ok then print('FAIL'); error(err,0) end
  passed=passed+1; print('ok')
end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,msg) assert(a~=b,msg or (tostring(a)..' == '..tostring(b))) end

local function attach(m,world,seed,fixed)
  local p=Att.patch(m,seed)
  local q=Att.query(m,world,p,fixed)
  local status,w=q:step(math.huge)
  eq(status,'hit','expected complete attachment')
  return Att.graft(w),w
end
local function status(m,world,seed,fixed)
  local q=Att.query(m,world,Att.patch(m,seed),fixed)
  return q:step(math.huge)
end

local function nested_factory(m)
  local O=m.actuality
  local Make=m:point('Make',O,'ConstructorIdentity')
  local FactorySchema=m:point('FactorySchema',O,'FactorySchema')
  local ChildSchema=m:point('ChildSchema',O,'ChildSchema')

  local D1=m:world('make-D'); local G1=m:world('make-G')
  local make_gate=m:strand('make?',D1,{Make},'ConstructorAuthority')
  local fi=m:point('factory-instance',G1,'FactoryInstance')
  local factory=m:strand('factory',G1,{FactorySchema,fi},'FactoryAuthority')
  m:face('construct',G1,{make_gate},{factory},'Construct')

  local D2=m:world('factory-D'); local G2=m:world('factory-G')
  local fiq=m:point('factory-instance?',D2,'FactoryInstance')
  local fgate=m:strand('factory?',D2,{FactorySchema,fiq},'FactoryAuthority')
  local ci=m:point('child-instance',G2,'ChildInstance')
  local child=m:strand('child',G2,{ChildSchema,ci},'ChildAuthority')
  m:face('factory-body',G2,{fgate},{child},'FactoryBody')

  local D3=m:world('child-D'); local G3=m:world('child-G')
  local ciq=m:point('child-instance?',D3,'ChildInstance')
  local cgate=m:strand('child?',D3,{ChildSchema,ciq},'ChildAuthority')
  local R=m:point('R',G3,'ResultIdentity')
  local out=m:strand('child-result',G3,{R},'ChildResult')
  m:face('child-body',G3,{cgate},{out},'ChildBody')

  return {Make=Make,G1=G1,make_gate=make_gate,fi=fi,factory=factory,
          G2=G2,fiq=fiq,fgate=fgate,ci=ci,child=child,
          G3=G3,ciq=ciq,cgate=cgate}
end

test('1. higher order remains repeated fresh attachment through stable and generated identity',function()
  local m=Model.new('O'); local a=nested_factory(m); local K=m:world('call',m.actuality)
  local make=m:strand('make',K,{a.Make},'ConstructorAuthority')
  local i1=attach(m,K,a.make_gate,{{demand=a.make_gate,supply=make}})
  local factory=i1.map[a.factory]
  local i2=attach(m,factory.world,a.fgate,{{demand=a.fgate,supply=factory}})
  local child=i2.map[a.child]
  local i3=attach(m,child.world,a.cgate,{{demand=a.cgate,supply=child}})
  eq(i1.map[a.G1].parent,K)
  eq(i2.map[a.G2].parent,factory.world)
  eq(i3.map[a.G3].parent,child.world)
  eq(i2.map[a.fiq],i1.map[a.fi])
  eq(i3.map[a.ciq],i2.map[a.ci])
end)

test('2. independent higher-order paths retain fresh generated identities',function()
  local m=Model.new('O'); local a=nested_factory(m)
  local K1=m:world('K1',m.actuality); local K2=m:world('K2',m.actuality)
  local make1=m:strand('make1',K1,{a.Make},'ConstructorAuthority')
  local make2=m:strand('make2',K2,{a.Make},'ConstructorAuthority')
  local x=attach(m,K1,a.make_gate,{{demand=a.make_gate,supply=make1}})
  local y=attach(m,K2,a.make_gate,{{demand=a.make_gate,supply=make2}})
  ne(x.map[a.fi],y.map[a.fi])
  local fx=attach(m,x.map[a.factory].world,a.fgate,{{demand=a.fgate,supply=x.map[a.factory]}})
  local fy=attach(m,y.map[a.factory].world,a.fgate,{{demand=a.fgate,supply=y.map[a.factory]}})
  ne(fx.map[a.ci],fy.map[a.ci])
end)

local function dynamic_capture(m)
  local O=m.actuality
  local Make=m:point('Make',O,'ConstructorIdentity')
  local ChildSchema=m:point('ChildSchema',O,'ChildSchema')
  local X=m:point('X',O,'Resource')
  local Dg=m:world('make-gate-D'); local Dx=m:world('make-x-D'); local G=m:world('closure-G')
  local gate=m:strand('make?',Dg,{Make},'ConstructorAuthority')
  local xin=m:strand('x?',Dx,{X},'ResourceOccurrence')
  local ci=m:point('child-instance',G,'ChildInstance')
  local held=m:strand('held-x',G,{X},'HeldResource')
  local child=m:strand('child',G,{ChildSchema,ci},'ChildAuthority')
  local construct=m:face('construct',G,{gate,xin},{held,child},'Construct')

  local Dc=m:world('child-D'); local Dh=m:world('held-D'); local Gc=m:world('child-G')
  local ciq=m:point('child-instance?',Dc,'ChildInstance')
  local cgate=m:strand('child?',Dc,{ChildSchema,ciq},'ChildAuthority')
  local heldq=m:strand('held?',Dh,{X},'HeldResource')
  local out=m:strand('out',Gc,{X},'Result')
  local body=m:face('body',Gc,{cgate,heldq},{out},'ChildBody')
  return {Make=Make,X=X,gate=gate,xin=xin,G=G,held=held,child=child,construct=construct,
          cgate=cgate,heldq=heldq,body=body}
end

test('3. dynamic capture is still explicit authority transfer into fresh locality',function()
  local m=Model.new('O'); local a=dynamic_capture(m); local K=m:world('call',m.actuality)
  local make=m:strand('make',K,{a.Make},'ConstructorAuthority')
  local x=m:strand('x',K,{a.X},'ResourceOccurrence')
  local i=attach(m,K,a.gate,{{demand=a.gate,supply=make}})
  local held=i.map[a.held]
  ne(held,x); eq(i.map[a.construct].inputs[2],x); eq(held.world,i.map[a.G])
  local child=i.map[a.child]
  local j=attach(m,child.world,a.cgate,{{demand=a.cgate,supply=child}})
  eq(j.map[a.heldq],held); eq(j.map[a.body].inputs[2],held)
end)

test('4. recursive/re-entrant behaviour is repeated attachment, never cyclic actual geometry',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'CallableIdentity')
  local D=m:world('D'); local G=m:world('G')
  local gate=m:strand('f?',D,{F},'CallableAuthority')
  local nextf=m:strand('next',G,{F},'CallableAuthority')
  m:face('body',G,{gate},{nextf},'Body')
  local K=m:world('initial',O); local f0=m:strand('f0',K,{F},'CallableAuthority')
  local i1=attach(m,K,gate,{{demand=gate,supply=f0}})
  local f1=i1.map[nextf]
  local i2=attach(m,f1.world,gate,{{demand=gate,supply=f1}})
  local f2=i2.map[nextf]
  local i3=attach(m,f2.world,gate,{{demand=gate,supply=f2}})
  eq(i2.map[G].parent,f1.world); eq(i3.map[G].parent,f2.world)
  local ok,why=Internal.model(m):check_actual_subcomplex(); assert(ok,why)
end)

local function choice_model()
  local m=Model.new('O'); local O=m.actuality
  local C=m:point('Choice',O,'ChoiceIdentity')
  local True=m:point('True',O,'BranchTag')
  local False=m:point('False',O,'BranchTag')
  local X=m:point('X',O,'Resource')
  local function branch(tag,name)
    local Dg=m:world(name..'-Dg'); local Dx=m:world(name..'-Dx'); local G=m:world(name..'-G')
    local gate=m:strand(name..'-gate',Dg,{C,tag},'ChoiceAuthority')
    local x=m:strand(name..'-x?',Dx,{X},'R')
    local out=m:strand(name..'-out',G,{X},'Out')
    local body=m:face(name..'-body',G,{gate,x},{out},'BranchBody')
    return {gate=gate,x=x,G=G,body=body}
  end
  return m,{C=C,True=True,False=False,X=X,t=branch(True,'true'),f=branch(False,'false')}
end

test('5. alternatives are separate patches selected by identity incidence, not an implicit chooser',function()
  local m,a=choice_model(); local K=m:world('choice-call',m.actuality)
  local r=m:strand('r',K,{a.X},'R')
  local choose=m:strand('choose-true',K,{a.C,a.True},'ChoiceAuthority')
  local stt,wt=status(m,K,a.t.gate,{{demand=a.t.gate,supply=choose}}); eq(stt,'hit')
  local stf=status(m,K,a.f.gate,{{demand=a.f.gate,supply=choose}}); eq(stf,'retry')
  local i=Att.graft(wt); eq(i.map[a.t.x],r); assert(m:is_suspended(a.f.G))
  eq(Internal.model(m):_realised_uses(r),1)
end)

test('6. one-shot continuation is authority plus detached resume geometry',function()
  local m=Model.new('O'); local O=m.actuality
  local H=m:point('Handler',O,'HandlerIdentity')
  local KId=m:point('Continuation',O,'ContinuationIdentity')
  local V=m:point('V',O,'Value')

  local D1=m:world('handle-D'); local G1=m:world('handle-G')
  local gate=m:strand('op?',D1,{H},'OperationAuthority')
  local inst=m:point('resume-inst',G1,'ResumeInstance')
  local held=m:strand('held-state',G1,{V,inst},'HeldState')
  local k=m:strand('k',G1,{KId,inst},'ContinuationAuthority')
  m:face('handle',G1,{gate},{held,k},'HandlerBody')

  local D2=m:world('resume-D'); local G2=m:world('resume-G')
  local iq=m:point('resume-inst?',D2,'ResumeInstance')
  local kg=m:strand('k?',D2,{KId,iq},'ContinuationAuthority')
  local hq=m:strand('held?',D2,{V,iq},'HeldState')
  local rv=m:strand('resume-value?',D2,{V},'ResumeValue')
  local out=m:strand('done',G2,{V},'Result')
  local resume=m:face('resume',G2,{kg,hq,rv},{out},'ResumeBody')

  local Wc=m:world('handler-call',O); local op=m:strand('op',Wc,{H},'OperationAuthority')
  local first=attach(m,Wc,gate,{{demand=gate,supply=op}})
  local kk,hh=first.map[k],first.map[held]
  local value=m:strand('v',kk.world,{V},'ResumeValue')
  local second=attach(m,kk.world,kg,{{demand=kg,supply=kk}})
  eq(second.map[hq],hh); eq(second.map[rv],value); eq(second.map[resume].sort,'ResumeBody')
  local st=status(m,kk.world,kg,{{demand=kg,supply=kk}}); eq(st,'retry')
end)

print(string.format('%d/%d high-value semantic regression tests passed',passed,passed))
