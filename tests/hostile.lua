package.path='./src/?.lua;'..package.path
local Model=require('model'); local Audit=require('audit'); local Federation=require('federation')
local passed=0
local function test(name,f) io.write(string.format('%-84s ',name)); local ok,err=pcall(f); if not ok then print('FAIL'); error(err,0) end; passed=passed+1; print('ok') end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,msg) assert(a~=b,msg or (tostring(a)..' == '..tostring(b))) end
local function expect_fail(f,pat) local ok,e=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(e):match(pat),tostring(e)) end end

local function provider_generic()
  local p=Model.new('ProviderActuality'); local O=p.actuality
  local F=p:point('PublicF',O,'CallableIdentity'); local T0=p:point('TypeAnchor',O,'TypeKind')
  local D=p:world('D'); local G=p:world('G')
  local gate=p:strand('gate',D,{F},'CallableAuthority')
  local T=p:point('T?',D,'Type'); local arg=p:strand('arg?',D,{T},'Argument')
  local out=p:strand('out',G,{T},'Result'); local body=p:face('provider-body',G,{gate,arg},{out},'Body')
  return p,{F=F,T0=T0,D=D,G=G,gate=gate,T=T,arg=arg,out=out,body=body}
end

test('1. federated provider archetype remains in provider custody; client imports no suspended Worlds',function()
  local p,a=provider_generic(); local c=Model.new('ClientActuality'); local F=c:point('PublicF',c.actuality,'CallableIdentity')
  local beforeP=#p.objects; local beforeC=#c.worlds
  local link=Federation.link(p,a.gate,c)
  eq(#p.objects,beforeP); eq(#c.worlds,beforeC) -- all provider anchors are external in this stage
  assert(p:is_suspended(a.G)); assert(c:is_realised(a.F)); assert(c:same_point(a.F,F))
  local W=c:world('call',c.actuality); local f=c:strand('f',W,{F},'CallableAuthority'); local Int=c:point('Int',c.actuality,'Type'); local x=c:strand('x',W,{Int},'Argument')
  local i=link:develop(f); eq(i.map[a.arg],x); eq(i.map[a.T],Int); eq(i.event.inputs[1],f); assert(p:is_suspended(a.G))
  eq(#p.objects,beforeP) -- execution did not mutate provider carrier
end)

test('2. federated higher-order private stage remains provider-owned across client invocations',function()
  local p=Model.new('P'); local O=p.actuality
  local Factory=p:point('Factory',O,'FactoryIdentity'); local Hidden=p:point('HiddenSchema',O,'HiddenSchema')
  local D1=p:world('D1'); local G1=p:world('G1'); local gate=p:strand('factory?',D1,{Factory},'FactoryAuthority')
  local inst=p:point('inst',G1,'Instance'); local child=p:strand('child',G1,{Hidden,inst},'ChildAuthority'); p:face('mk',G1,{gate},{child},'FactoryBody')
  local D2=p:world('D2'); local G2=p:world('G2'); local iq=p:point('inst?',D2,'Instance'); local cg=p:strand('child?',D2,{Hidden,iq},'ChildAuthority')
  local R=p:point('R',G2,'ResultIdentity'); local out=p:strand('out',G2,{R},'Result'); p:face('child-body',G2,{cg},{out},'ChildBody')
  local before=#p.objects
  local c=Model.new('C'); local Fc=c:point('Factory',c.actuality,'FactoryIdentity'); local link=Federation.link(p,gate,c):add_gate(cg)
  local W=c:world('call',c.actuality); local f=c:strand('f',W,{Fc},'FactoryAuthority'); local first=link:develop(f)
  local ch=first.map[child]; assert(ch and c:is_realised(ch)); local second=link:develop(ch); eq(second.event.sort,'ChildBody')
  eq(#p.objects,before); assert(p:is_suspended(G1) and p:is_suspended(G2))
end)

local function choice_model()
  local m=Model.new('O'); local O=m.actuality
  local C=m:point('Choice',O,'ChoiceIdentity'); local True=m:point('True',O,'BranchTag'); local False=m:point('False',O,'BranchTag'); local X=m:point('X',O,'Resource')
  local function branch(tag,name)
    local Dg=m:world(name..'-Dg'); local Dx=m:world(name..'-Dx'); local G=m:world(name..'-G')
    local gate=m:strand(name..'-gate',Dg,{C,tag},'ChoiceAuthority'); local x=m:strand(name..'-x?',Dx,{X},'R'); local out=m:strand(name..'-out',G,{X},'Out'); local body=m:face(name..'-body',G,{gate,x},{out},'BranchBody')
    return {gate=gate,x=x,body=body,G=G}
  end
  return m,{C=C,True=True,False=False,X=X,t=branch(True,'true'),f=branch(False,'false')}
end

test('3. alternatives are competing detached stages; only selected branch becomes an actual resource use',function()
  local m,a=choice_model(); local W=m:world('choice-call',m.actuality); local r=m:strand('r',W,{a.X},'R')
  local choose=m:strand('choose-true',W,{a.C,a.True},'ChoiceAuthority'); local i=m:develop(choose)
  eq(i.map[a.t.x],r); assert(m:is_suspended(a.f.G)); local uses=m:_realised_uses(r); eq(uses,1)
  local ok,why=m:check_scarcity(); assert(ok,why)
end)

test('4. one choice occurrence cannot realise both alternatives; branch selection is ordinary anchor incidence',function()
  local m,a=choice_model(); local W=m:world('choice-call',m.actuality); m:strand('r',W,{a.X},'R')
  local choose=m:strand('choose-false',W,{a.C,a.False},'ChoiceAuthority'); local i=m:develop(choose); eq(i.event,i.map[a.f.body]); assert(m:is_suspended(a.t.G))
  expect_fail(function() m:develop(choose) end,'already been consumed')
end)

test('5. resource-disjoint sibling Worlds develop independently and commute operationally',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X')
  local Dg=m:world('Dg'); local Dx=m:world('Dx'); local G=m:world('G'); local gate=m:strand('gate',Dg,{F},'A'); local xq=m:strand('x?',Dx,{X},'R'); local out=m:strand('out',G,{X},'O'); m:face('body',G,{gate,xq},{out},'B')
  local A=m:world('task-A',O); local B=m:world('task-B',O); local fa=m:strand('fa',A,{F},'A'); local xa=m:strand('xa',A,{X},'R'); local fb=m:strand('fb',B,{F},'A'); local xb=m:strand('xb',B,{X},'R')
  local ia=m:develop(fa); assert(m:_realised_uses(xb)==0); local ib=m:develop(fb)
  eq(ia.map[xq],xa); eq(ib.map[xq],xb); eq(m:_realised_uses(xa),1); eq(m:_realised_uses(xb),1)
end)

test('6. concurrency cannot implicitly share scarce authority across sibling Worlds',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X')
  local Dg=m:world('Dg'); local Dx=m:world('Dx'); local G=m:world('G'); local gate=m:strand('gate',Dg,{F},'A'); local xq=m:strand('x?',Dx,{X},'R'); local out=m:strand('out',G,{X},'O'); m:face('body',G,{gate,xq},{out},'B')
  local Owner=m:world('owner',O); local r=m:strand('r',Owner,{X},'R'); local Task=m:world('task',O); local f=m:strand('f',Task,{F},'A')
  expect_fail(function() m:develop(f) end,'no local realised supply'); eq(m:_realised_uses(r),0)
end)

test('7. explicit copy creates independent authority for concurrent Worlds; no duplicability metadata',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local Owner=m:world('owner',O); local r=m:strand('r',Owner,{X},'R')
  local A=m:world('task-A',O); local B=m:world('task-B',O); local ra=m:strand('ra',A,{X},'R'); local rb=m:strand('rb',B,{X},'R'); m:copy('copy',Owner,r,{ra,rb},'structural')
  local ok,why=Audit.check(m); assert(ok,why); eq(m:_realised_uses(r),1); eq(m:_realised_uses(ra),0); eq(m:_realised_uses(rb),0)
end)

test('8. structural duplication by an ordinary Face is rejected; copy is an actual geometric permission',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('W',m.actuality); local r=m:strand('r',W,{X},'R'); local a=m:strand('a',W,{X},'R'); local b=m:strand('b',W,{X},'R'); m:face('bad-copy',W,{r},{a,b},'Ordinary')
  local ok,why=Audit.check(m); assert(not ok and why:match('copy'))
end)

test('9. explicit discard is ordinary geometry and satisfies conservation audit',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('W',m.actuality); local r=m:strand('r',W,{X},'R'); m:discard('drop',W,r,'structural')
  local ok,why=Audit.check(m); assert(ok,why); eq(m:_realised_uses(r),1)
end)

test('10. produced authority has unique provenance; double production of one occurrence is rejected',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('W',m.actuality); local a=m:strand('a',W,{X},'A'); local b=m:strand('b',W,{X},'B'); local out=m:strand('out',W,{X},'Out'); m:face('f1',W,{a},{out},'Transform'); m:face('f2',W,{b},{out},'Transform')
  local ok,why=Audit.check(m); assert(not ok and why:match('provenance'))
end)

test('11. hidden state is ordinary held authority in a private World and survives until a future Face consumes it',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local W=m:world('private-instance',O); local seed=m:strand('seed',W,{X},'StateSeed'); local held=m:strand('held',W,{X},'HeldState'); m:face('init',W,{seed},{held},'Init')
  local ok,why=Audit.check(m); assert(ok,why); eq(m:_realised_uses(held),0)
  local next=m:strand('next',W,{X},'HeldState2'); m:face('step',W,{held},{next},'Step'); ok,why=Audit.check(m); assert(ok,why); eq(m:_realised_uses(held),1)
end)

test('12. actuality is carrier-relative under federation; provider actuality never becomes client actuality',function()
  local p,a=provider_generic(); local c=Model.new('C'); c:point('PublicF',c.actuality,'CallableIdentity'); local link=Federation.link(p,a.gate,c)
  assert(p:is_realised(a.F)); assert(c:is_realised(a.F)); assert(c:same_point(a.F,c:find_actual_point('PublicF','CallableIdentity')))
end)



test('13. continuation capture is returned authority plus a detached resume stage; one-shot follows scarcity',function()
  local m=Model.new('O'); local O=m.actuality
  local H=m:point('Handler',O,'HandlerIdentity'); local K=m:point('Continuation',O,'ContinuationIdentity'); local V=m:point('V',O,'Value')
  -- handle stage
  local D1=m:world('handle-D'); local G1=m:world('handle-G'); local gate=m:strand('op?',D1,{H},'OperationAuthority')
  local inst=m:point('resume-inst',G1,'ResumeInstance'); local held=m:strand('held-state',G1,{V,inst},'HeldState'); local k=m:strand('k',G1,{K,inst},'ContinuationAuthority')
  m:face('handle',G1,{gate},{held,k},'HandlerBody')
  -- resume stage
  local D2=m:world('resume-D'); local G2=m:world('resume-G'); local iq=m:point('resume-inst?',D2,'ResumeInstance'); local kg=m:strand('k?',D2,{K,iq},'ContinuationAuthority')
  local hq=m:strand('held?',D2,{V,iq},'HeldState'); local rv=m:strand('resume-value?',D2,{V},'ResumeValue'); local out=m:strand('done',G2,{V},'Result')
  m:face('resume',G2,{kg,hq,rv},{out},'ResumeBody')
  local W=m:world('handler-call',O); local op=m:strand('op',W,{H},'OperationAuthority'); local first=m:develop(op); local kk=first.map[k]; local hh=first.map[held]
  local value=m:strand('v',kk.world,{V},'ResumeValue'); local second=m:develop(kk); eq(second.map[hq],hh); eq(second.map[rv],value); eq(second.event.sort,'ResumeBody')
  expect_fail(function() m:develop(kk) end,'already been consumed')
end)

test('14. duplicating a continuation authority does not duplicate captured state; second resume fails unless state is copied',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:point('K',O,'K'); local I=m:point('I',O,'I'); local V=m:point('V',O,'V')
  local D=m:world('D'); local G=m:world('G'); local iq=m:point('i?',D,'I'); local gate=m:strand('k?',D,{K,iq},'KA'); local hq=m:strand('h?',D,{V,iq},'Held'); local rv=m:strand('v?',D,{V},'RV'); local out=m:strand('o',G,{V},'O'); m:face('resume',G,{gate,hq,rv},{out},'Resume')
  local W=m:world('W',O); local inst=m:point('i',W,'I'); local k=m:strand('k',W,{K,inst},'KA'); local h=m:strand('h',W,{V,inst},'Held'); local k1=m:strand('k1',W,{K,inst},'KA'); local k2=m:strand('k2',W,{K,inst},'KA'); m:copy('copy-k',W,k,{k1,k2},'structural')
  local v1=m:strand('v1',W,{V},'RV'); local i1=m:develop(k1); eq(i1.map[hq],h)
  local v2=m:strand('v2',W,{V},'RV'); expect_fail(function() m:develop(k2) end,'no local realised supply')
  local ok,why=Audit.check(m); assert(ok,why) -- failure left no partial second resume
end)

test('15. federated late aliasing remains literal client incidence and is caught by conservation audit',function()
  local p=Model.new('P'); local O=p.actuality; local F=p:point('F',O,'F'); local X=p:point('X',O,'X')
  local Dg=p:world('Dg'); local Da=p:world('Da'); local Db=p:world('Db'); local G=p:world('G'); local gate=p:strand('gate',Dg,{F},'A'); local a=p:strand('a',Da,{X},'R'); local b=p:strand('b',Db,{X},'R'); local out=p:strand('out',G,{X},'O'); p:face('body',G,{gate,a,b},{out},'B')
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local Xc=c:point('X',c.actuality,'X'); local link=Federation.link(p,gate,c)
  local W=c:world('W',c.actuality); local f=c:strand('f',W,{Fc},'A'); local r=c:strand('r',W,{Xc},'R'); local i=link:develop(f); eq(i.event.inputs[2],r); eq(i.event.inputs[3],r)
  local ok,why=Audit.check(c); assert(not ok and why:match('scarcity'))
end)

test('16. federated link checks frontier and rolls back private anchor installation on failure',function()
  local p,a=provider_generic(); local frontier=require('separate').frontier(p,a.gate); local c=Model.new('C'); c:point('PublicF',c.actuality,'CallableIdentity')
  local o,w=#c.objects,#c.worlds; expect_fail(function() Federation.link(p,a.gate,c,frontier..'corrupt') end,'frontier mismatch'); eq(#c.objects,o); eq(#c.worlds,w)
end)

test('17. one provider carrier can serve two client actuality trees without mutation or shared client authority',function()
  local p,a=provider_generic(); local before=#p.objects
  local c1=Model.new('C1'); local F1=c1:point('PublicF',c1.actuality,'CallableIdentity'); local l1=Federation.link(p,a.gate,c1)
  local c2=Model.new('C2'); local F2=c2:point('PublicF',c2.actuality,'CallableIdentity'); local l2=Federation.link(p,a.gate,c2)
  local T1=c1:point('T1',c1.actuality,'Type'); local W1=c1:world('W1',c1.actuality); local f1=c1:strand('f1',W1,{F1},'CallableAuthority'); c1:strand('x1',W1,{T1},'Argument')
  local T2=c2:point('T2',c2.actuality,'Type'); local W2=c2:world('W2',c2.actuality); local f2=c2:strand('f2',W2,{F2},'CallableAuthority'); c2:strand('x2',W2,{T2},'Argument')
  local i1=l1:develop(f1); local i2=l2:develop(f2); eq(i1.map[a.T],T1); eq(i2.map[a.T],T2); eq(#p.objects,before)
  ne(i1.map[a.out],i2.map[a.out]); assert(not c1:is_realised(i2.map[a.out]))
end)

test('18. independent developments commute up to fresh renaming and leave the same observable resource facts',function()
  local function run(reverse)
    local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X'); local Dg=m:world('Dg'); local Dx=m:world('Dx'); local G=m:world('G'); local gate=m:strand('gate',Dg,{F},'A'); local xq=m:strand('x?',Dx,{X},'R'); local out=m:strand('out',G,{X},'O'); m:face('body',G,{gate,xq},{out},'B')
    local A=m:world('A',O); local B=m:world('B',O); local fa=m:strand('fa',A,{F},'A'); local xa=m:strand('xa',A,{X},'R'); local fb=m:strand('fb',B,{F},'A'); local xb=m:strand('xb',B,{X},'R')
    local ia,ib; if reverse then ib=m:develop(fb); ia=m:develop(fa) else ia=m:develop(fa); ib=m:develop(fb) end
    return {ua=m:_realised_uses(xa),ub=m:_realised_uses(xb),ea=ia.event.sort,eb=ib.event.sort,wa=ia.worlds[1].parent.name,wb=ib.worlds[1].parent.name}
  end
  local a,b=run(false),run(true); for k,v in pairs(a) do eq(v,b[k],k) end
end)

test('19. private suspended output is hidden only by geometric consumption, not visibility metadata',function()
  local Sep=require('separate'); local m=Model.new('P'); local O=m.actuality; local F=m:point('F',O,'F'); local D=m:world('D'); local G=m:world('G'); local gate=m:strand('gate',D,{F},'A')
  local public=m:strand('public',G,{F},'Public'); local secret=m:strand('secret',G,{F},'Secret'); m:face('body',G,{gate},{public,secret},'Body'); m:discard('discard-secret',G,secret,'structural')
  local fr=Sep.frontier(m,gate); assert(fr:match('public')); assert(not fr:match('secret'))
end)



test('20. detached future cannot smuggle realised Strand authority from another World',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local Owner=m:world('owner',m.actuality); local r=m:strand('r',Owner,{X},'R'); local G=m:world('future'); local out=m:strand('out',G,{X},'O')
  expect_fail(function() m:face('bad-hidden-capture',G,{r},{out},'Body') end,'cannot depend directly on realised Strand')
end)

test('21. dynamic handler selection is ordinary stable-Point incidence, not an effect table',function()
  local m=Model.new('O'); local O=m.actuality; local Op=m:point('ReadOp',O,'OperationIdentity'); local HA=m:point('HandlerA',O,'HandlerIdentity'); local HB=m:point('HandlerB',O,'HandlerIdentity'); local V=m:point('V',O,'Value')
  local function handler(H,name,sort)
    local D=m:world(name..'-D'); local G=m:world(name..'-G'); local gate=m:strand(name..'-op?',D,{Op,H},'OperationAuthority'); local out=m:strand(name..'-out',G,{V},'Result'); local body=m:face(name..'-body',G,{gate},{out},sort); return {gate=gate,body=body}
  end
  local A=handler(HA,'A','HandleA'); local B=handler(HB,'B','HandleB'); local W=m:world('task',O)
  local op=m:strand('read',W,{Op,HB},'OperationAuthority'); local i=m:develop(op); eq(i.event.sort,'HandleB'); assert(m:is_suspended(A.body))
end)

test('22. portable continuation requires explicit transport of both authority and held state',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:point('K',O,'K'); local I=m:point('I',O,'I'); local V=m:point('V',O,'V')
  local D=m:world('resume-D'); local G=m:world('resume-G'); local iq=m:point('i?',D,'I'); local gate=m:strand('k?',D,{K,iq},'KA'); local hq=m:strand('h?',D,{V,iq},'Held'); local rv=m:strand('v?',D,{V},'RV'); local out=m:strand('out',G,{V},'O'); m:face('resume',G,{gate,hq,rv},{out},'Resume')
  local A=m:world('captured',O); local inst=m:point('inst',A,'I'); local k=m:strand('k',A,{K,inst},'KA'); local h=m:strand('h',A,{V,inst},'Held')
  local B=m:world('receiver',O); local k2=m:strand('k2',B,{K,inst},'KA'); local h2=m:strand('h2',B,{V,inst},'Held'); m:face('transport',A,{k,h},{k2,h2},'Transport')
  local v=m:strand('v',B,{V},'RV'); local i=m:develop(k2); eq(i.map[hq],h2); eq(i.map[rv],v); eq(i.event.sort,'Resume')
end)

test('23. transporting only continuation authority does not leak its remote held state',function()
  local m=Model.new('O'); local O=m.actuality; local K=m:point('K',O,'K'); local I=m:point('I',O,'I'); local V=m:point('V',O,'V')
  local D=m:world('D'); local G=m:world('G'); local iq=m:point('i?',D,'I'); local gate=m:strand('k?',D,{K,iq},'KA'); local hq=m:strand('h?',D,{V,iq},'Held'); local rv=m:strand('v?',D,{V},'RV'); local out=m:strand('o',G,{V},'O'); m:face('resume',G,{gate,hq,rv},{out},'Resume')
  local A=m:world('A',O); local inst=m:point('inst',A,'I'); local k=m:strand('k',A,{K,inst},'KA'); local h=m:strand('h',A,{V,inst},'Held')
  local B=m:world('B',O); local k2=m:strand('k2',B,{K,inst},'KA'); m:face('transport-k-only',A,{k},{k2},'Transport'); m:strand('v',B,{V},'RV')
  expect_fail(function() m:develop(k2) end,'no local realised supply'); eq(m:_realised_uses(h),0)
end)



test('24. ordinary transformation may produce two distinct authorities of one type when identity Points are fresh',function()
  local m=Model.new('O'); local O=m.actuality; local Ty=m:point('T',O,'Type'); local W=m:world('W',O)
  local Rin=m:point('rin',W,'AuthorityIdentity'); local Ra=m:point('ra',W,'AuthorityIdentity'); local Rb=m:point('rb',W,'AuthorityIdentity')
  local input=m:strand('input',W,{Ty,Rin},'R'); local a=m:strand('a',W,{Ty,Ra},'R'); local b=m:strand('b',W,{Ty,Rb},'R'); m:face('split-semantic',W,{input},{a,b},'SemanticSplit')
  local ok,why=Audit.check(m); assert(ok,why)
end)

print(string.format('%d/%d nasty semantic tests passed',passed,passed))
