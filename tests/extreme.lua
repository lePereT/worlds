package.path='./src/?.lua;'..package.path
local Model=require('model'); local Audit=require('audit'); local Federation=require('federation'); local Separate=require('separate')
local passed=0
local function test(name,f) io.write(string.format('%-94s ',name)); local ok,err=pcall(f); if not ok then print('FAIL'); error(err,0) end; passed=passed+1; print('ok') end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,msg) assert(a~=b,msg or (tostring(a)..' == '..tostring(b))) end
local function expect_fail(f,pat) local ok,e=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(e):match(pat),tostring(e)) end end

local function choice_join_model()
  local m=Model.new('O'); local O=m.actuality
  local C=m:point('Choice',O,'Choice'); local T=m:point('True',O,'Tag'); local F=m:point('False',O,'Tag'); local J=m:point('Join',O,'Join'); local Ty=m:point('Ty',O,'Type')
  local function branch(tag,name)
    local D=m:world(name..'-D'); local G=m:world(name..'-G'); local gate=m:strand(name..'-gate',D,{C,tag},'ChoiceA')
    local qi=m:point(name..'-identity',G,'BranchIdentity'); local out=m:strand(name..'-out',G,{J,qi,Ty},'JoinA'); local body=m:face(name..'-body',G,{gate},{out},'Branch')
    return {gate=gate,qi=qi,out=out,body=body,G=G}
  end
  local t=branch(T,'true'); local f=branch(F,'false')
  local Dj=m:world('join-D'); local Gj=m:world('join-G'); local q=m:point('branch?',Dj,'BranchIdentity'); local jg=m:strand('join?',Dj,{J,q,Ty},'JoinA')
  local done=m:strand('done',Gj,{Ty},'Done'); local jb=m:face('join-body',Gj,{jg},{done},'JoinBody')
  return m,{C=C,T=T,F=F,J=J,Ty=Ty,t=t,f=f,jq=q,jg=jg,done=done,jb=jb}
end

test('1. join after true branch binds branch-fresh identity through ordinary Point incidence; no phi object',function()
  local m,a=choice_join_model(); local W=m:world('W',m.actuality); local c=m:strand('choose',W,{a.C,a.T},'ChoiceA')
  local bi=m:develop(c); local bo=bi.map[a.t.out]; local ji=m:develop(bo)
  eq(ji.event.sort,'JoinBody'); eq(ji.map[a.jq],bi.map[a.t.qi]); assert(m:is_suspended(a.f.G)); local ok,why=Audit.check(m); assert(ok,why)
end)

test('2. the same join stage accepts false-branch fresh identity without path environment or alternative metadata',function()
  local m,a=choice_join_model(); local W=m:world('W',m.actuality); local c=m:strand('choose',W,{a.C,a.F},'ChoiceA')
  local bi=m:develop(c); local ji=m:develop(bi.map[a.f.out]); eq(ji.map[a.jq],bi.map[a.f.qi]); assert(m:is_suspended(a.t.G))
end)

test('3. an unchosen branch contributes neither resource use nor join provenance',function()
  local m,a=choice_join_model(); local W=m:world('W',m.actuality); local c=m:strand('choose',W,{a.C,a.T},'ChoiceA'); local bi=m:develop(c); m:develop(bi.map[a.t.out])
  assert(not m:is_realised(a.f.body)); assert(not m:is_realised(a.f.out)); local ok,why=Audit.check(m); assert(ok,why)
end)

test('4. genuinely unlabelled alternatives remain ambiguous rather than acquiring an implicit nondeterministic chooser',function()
  local m=Model.new('O'); local O=m.actuality; local C=m:point('C',O,'C')
  local function alt(name)
    local D=m:world(name..'D'); local G=m:world(name..'G'); local gate=m:strand(name..'g',D,{C},'A'); local out=m:strand(name..'o',G,{C},'O'); m:face(name..'b',G,{gate},{out},'B')
  end
  alt('a'); alt('b'); local W=m:world('W',O); local t=m:strand('t',W,{C},'A'); expect_fail(function() m:develop(t) end,'ambiguous')
end)

test('5. concurrent join cannot implicitly read sibling-World results; explicit transport to a common World makes it local',function()
  local m=Model.new('O'); local O=m.actuality; local J=m:point('Join',O,'J'); local AId=m:point('A',O,'A'); local BId=m:point('B',O,'B')
  local Dg=m:world('JDg'); local Db=m:world('JDb'); local G=m:world('JG'); local gate=m:strand('a?',Dg,{J,AId},'JA'); local bq=m:strand('b?',Db,{BId},'BOut'); local done=m:strand('done',G,{J},'Done'); m:face('join',G,{gate,bq},{done},'Join')
  local WA=m:world('taskA',O); local WB=m:world('taskB',O); local a=m:strand('a',WA,{J,AId},'JA'); local b=m:strand('b',WB,{BId},'BOut')
  expect_fail(function() m:develop(a) end,'no local realised supply')
  local WJ=m:world('joinWorld',O); local aj=m:strand('aj',WJ,{J,AId},'JA'); local bj=m:strand('bj',WJ,{BId},'BOut'); m:face('move-a',WA,{a},{aj},'Transport'); m:face('move-b',WB,{b},{bj},'Transport')
  local i=m:develop(aj); eq(i.map[bq],bj); eq(i.event.sort,'Join')
end)

test('6. recursive state threading consumes each state occurrence once and returns fresh authority for the next call',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local S=m:point('StateType',O,'S')
  local Dg=m:world('Dg'); local Ds=m:world('Ds'); local G=m:world('G'); local iq=m:point('i?',Dg,'I'); local gate=m:strand('f?',Dg,{F,iq},'FA'); local sq=m:strand('s?',Ds,{S,iq},'State')
  local ni=m:point('next-i',G,'I'); local nf=m:strand('next-f',G,{F,ni},'FA'); local ns=m:strand('next-s',G,{S,ni},'State'); m:face('step',G,{gate,sq},{nf,ns},'Step')
  local W=m:world('W',O); local i0=m:point('i0',W,'I'); local f0=m:strand('f0',W,{F,i0},'FA'); local s0=m:strand('s0',W,{S,i0},'State')
  local r1=m:develop(f0); eq(r1.map[sq],s0); local f1,s1=r1.map[nf],r1.map[ns]; local r2=m:develop(f1); eq(r2.map[sq],s1); eq(m:_realised_uses(s0),1); eq(m:_realised_uses(s1),1); local ok,why=Audit.check(m); assert(ok,why)
end)

test('7. mutually recursive detached modules do not self-satisfy; cycles require an explicit common bootstrap stage',function()
  local m=Model.new('O'); local O=m.actuality; local A=m:point('A',O,'A'); local B=m:point('B',O,'B'); local Boot=m:point('Boot',O,'Boot')
  local function module_stage(id,other,name)
    local Dg=m:world(name..'Dg'); local Do=m:world(name..'Do'); local G=m:world(name..'G'); local gate=m:strand(name..'?',Dg,{id},name..'A'); local oq=m:strand('other?',Do,{other},'Dep'); local out=m:strand(name..'-ready',G,{id},'Ready'); m:face(name..'-init',G,{gate,oq},{out},'Init'); return gate
  end
  local ag=module_stage(A,B,'Amod'); local bg=module_stage(B,A,'Bmod'); local W=m:world('W',O); local a=m:strand('a',W,{A},'AmodA')
  expect_fail(function() m:develop(a) end,'no local realised supply')
  -- Explicit bootstrap jointly produces the two dependency authorities.
  local seed=m:strand('seed',W,{Boot},'Seed'); local aa=m:strand('a-dep',W,{A},'Dep'); local bb=m:strand('b-dep',W,{B},'Dep'); m:face('knot',W,{seed},{aa,bb},'RecursiveBootstrap')
  -- New trigger occurrences use the explicit dependencies. They still remain ordinary scarce authority.
  local at=m:strand('at',W,{A},'AmodA'); local ar=m:develop(at); eq(ar.event.sort,'Init')
end)

test('8. linear borrowing is authority flow: owner is consumed, loan is consumed, restored authority is a new occurrence',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local W=m:world('W',O); local owner=m:strand('owner',W,{X},'R'); local loan=m:strand('loan',W,{X},'R'); m:face('lend',W,{owner},{loan},'Loan')
  local restored=m:strand('restored',W,{X},'R'); m:face('use-and-return',W,{loan},{restored},'BorrowUse')
  eq(m:_realised_uses(owner),1); eq(m:_realised_uses(loan),1); eq(m:_realised_uses(restored),0); local ok,why=Audit.check(m); assert(ok,why)
end)

test('9. branch-local early exit bypasses normal continuation without making its geometry actual',function()
  local m=Model.new('O'); local O=m.actuality; local C=m:point('C',O,'C'); local Ok=m:point('Ok',O,'Tag'); local Err=m:point('Err',O,'Tag'); local H=m:point('Handler',O,'H')
  local function branch(tag,name,outSort)
    local D=m:world(name..'D'); local G=m:world(name..'G'); local gate=m:strand(name..'g',D,{C,tag},'Choice'); local out=m:strand(name..'out',G,{H},outSort); local body=m:face(name..'body',G,{gate},{out},name); return {gate=gate,out=out,body=body,G=G}
  end
  local normal=branch(Ok,'normal','NormalK'); local thrown=branch(Err,'throw','ExceptionK')
  local Dh=m:world('handlerD'); local Gh=m:world('handlerG'); local hg=m:strand('exc?',Dh,{H},'ExceptionK'); local done=m:strand('handled',Gh,{H},'Done'); m:face('handle',Gh,{hg},{done},'Handle')
  local W=m:world('W',O); local t=m:strand('choose-err',W,{C,Err},'Choice'); local br=m:develop(t); local hi=m:develop(br.map[thrown.out]); eq(hi.event.sort,'Handle'); assert(m:is_suspended(normal.G))
end)

test('10. Point gluing is literal cross-carrier identity: provider and client Points become one equivalence class',function()
  local p=Model.new('P'); local Fp=p:point('F',p.actuality,'F'); local D=p:world('D'); local G=p:world('G'); local gate=p:strand('g',D,{Fp},'A'); local out=p:strand('o',G,{Fp},'O'); p:face('b',G,{gate},{out},'B')
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local link=Federation.link(p,gate,c); assert(c:same_point(Fp,Fc)); assert(link.anchor_map==nil)
  local W=c:world('W',c.actuality); local f=c:strand('f',W,{Fc},'A'); local i=link:develop(f); assert(c:same_point(i.map[out].points[1],Fp))
end)

test('11. private provider identity can be carried literally by returned authority without becoming client-local authority',function()
  local p=Model.new('P'); local O=p.actuality; local F=p:point('F',O,'F'); local Hidden=p:point('Hidden',O,'Hidden'); local D=p:world('D'); local G=p:world('G'); local gate=p:strand('g',D,{F},'A'); local child=p:strand('child',G,{Hidden},'Child'); p:face('mk',G,{gate},{child},'Mk')
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local link=Federation.link(p,gate,c); local W=c:world('W',c.actuality); local f=c:strand('f',W,{Fc},'A'); local i=link:develop(f); local ch=i.map[child]
  eq(ch.points[1],Hidden); assert(c:is_realised(Hidden)); local found=false; for _,o in ipairs(c.objects) do if o==Hidden then found=true end end; assert(not found)
  -- Identity is visible through incidence; provider authority remains unavailable to client supply search.
  for _,o in ipairs(c:_offer_pool(ch)) do assert(not (o.dim==1 and o.world and p:_root(o.world)==p.actuality),'provider authority leaked into client pool') end
end)

test('12. Point gluing is transitive across three carrier custodians while authority remains carrier-local',function()
  local a=Model.new('A'); local b=Model.new('B'); local c=Model.new('C'); local pa=a:point('X',a.actuality,'T'); local pb=b:point('X',b.actuality,'T'); local pc=c:point('X',c.actuality,'T')
  b:glue_points(pa,pb); c:glue_points(pb,pc); assert(a:same_point(pa,pc) and b:same_point(pa,pc) and c:same_point(pa,pc))
  local WA=a:world('WA',a.actuality); local sa=a:strand('sa',WA,{pa},'R'); local WC=c:world('WC',c.actuality); local trigger=c:strand('sc',WC,{pc},'Other')
  for _,o in ipairs(c:_offer_pool(trigger)) do assert(o~=sa) end
end)

test('13. failed cross-carrier Point gluing is non-mutating',function()
  local a=Model.new('A'); local b=Model.new('B'); local p=a:point('p',a.actuality,'A'); local q=b:point('q',b.actuality,'B'); expect_fail(function() a:glue_points(p,q) end,'sort mismatch'); assert(not a:same_point(p,q))
end)

test('14. developments sharing identity Points but disjoint Strands still commute; identity sharing is not authority sharing',function()
  local function run(reverse)
    local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local D=m:world('D'); local G=m:world('G'); local gate=m:strand('g',D,{F},'A'); local out=m:strand('o',G,{F},'O'); m:face('b',G,{gate},{out},'B')
    local A=m:world('A',O); local B=m:world('B',O); local fa=m:strand('fa',A,{F},'A'); local fb=m:strand('fb',B,{F},'A'); local ia,ib; if reverse then ib=m:develop(fb); ia=m:develop(fa) else ia=m:develop(fa); ib=m:develop(fb) end
    return ia.event.sort..':'..ib.event.sort..':'..m:_realised_uses(fa)..':'..m:_realised_uses(fb)
  end
  eq(run(false),run(true))
end)



test('15. an invalid unchosen alternative is rejected by suspended-stage certification before it becomes actual',function()
  local m=Model.new('O'); local O=m.actuality; local C=m:point('C',O,'C'); local T=m:point('T',O,'Tag'); local F=m:point('F',O,'Tag'); local X=m:point('X',O,'X')
  local function branch(tag,name,bad)
    local D=m:world(name..'D'); local G=m:world(name..'G'); local gate=m:strand(name..'g',D,{C,tag},'Choice'); local x=m:strand(name..'x',D,{X},'R'); local o1=m:strand(name..'o1',G,{X},'O'); m:face(name..'b1',G,{gate,x},{o1},'B')
    if bad then local o2=m:strand(name..'o2',G,{X},'O2'); m:face(name..'b2',G,{x},{o2},'B2') end
    return gate
  end
  local good=branch(T,'good',false); local bad=branch(F,'bad',true); local ok,why=Audit.check_stage(m,good); assert(ok,why); ok,why=Audit.check_stage(m,bad); assert(not ok and why:match('scarcity'))
end)

test('16. higher-rank generic callable authority can be copied structurally and specialised independently',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('PolyF',O,'F'); local Dg=m:world('Dg'); local Da=m:world('Da'); local G=m:world('G'); local T=m:point('T?',Da,'Type'); local gate=m:strand('f?',Dg,{F},'FA'); local arg=m:strand('arg?',Da,{T},'Arg'); local out=m:strand('out',G,{T},'Out'); m:face('poly-body',G,{gate,arg},{out},'Poly')
  local Owner=m:world('Owner',O); local W1=m:world('call-Int',O); local W2=m:world('call-String',O); local f=m:strand('f',Owner,{F},'FA'); local f1=m:strand('f1',W1,{F},'FA'); local f2=m:strand('f2',W2,{F},'FA'); m:copy('copy-f',Owner,f,{f1,f2},'structural')
  local Int=m:point('Int',O,'Type'); local Str=m:point('String',O,'Type'); local xi=m:strand('xi',W1,{Int},'Arg'); local xs=m:strand('xs',W2,{Str},'Arg')
  local i1=m:develop(f1); local i2=m:develop(f2); eq(i1.map[T],Int); eq(i2.map[T],Str); ne(i1.map[out],i2.map[out]); local ok,why=Audit.check(m); assert(ok,why)
end)



test('17. existential/generative package carries a fresh hidden Point in ordinary authority and unpacks later',function()
  local m=Model.new('O'); local O=m.actuality; local Make=m:point('MakePkg',O,'Make'); local Pkg=m:point('Package',O,'Pkg')
  local D1=m:world('makeD'); local G1=m:world('makeG'); local mg=m:strand('make?',D1,{Make},'MakeA'); local T=m:point('hidden-T',G1,'Type'); local pkg=m:strand('pkg',G1,{Pkg,T},'PkgA'); m:face('pack',G1,{mg},{pkg},'Pack')
  local D2=m:world('unpackD'); local G2=m:world('unpackG'); local Tq=m:point('T?',D2,'Type'); local pg=m:strand('pkg?',D2,{Pkg,Tq},'PkgA'); local val=m:strand('value',G2,{Tq},'Value'); m:face('unpack',G2,{pg},{val},'Unpack')
  local W=m:world('W',O); local make=m:strand('make',W,{Make},'MakeA'); local a=m:develop(make); local p=a.map[pkg]; local hidden=a.map[T]; local W2=m:world('receiver',O); local p2=m:strand('pkg2',W2,{Pkg,hidden},'PkgA'); m:face('move-package',p.world,{p},{p2},'Transport')
  local u=m:develop(p2); eq(u.map[Tq],hidden); eq(u.map[val].points[1],hidden)
end)

test('18. two generative packages cannot accidentally mix their hidden identities',function()
  local m=Model.new('O'); local O=m.actuality; local Make=m:point('Make',O,'Make'); local Pkg=m:point('Pkg',O,'Pkg')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('make?',D,{Make},'MakeA'); local T=m:point('T',G,'Type'); local pkg=m:strand('pkg',G,{Pkg,T},'PkgA'); local val=m:strand('val',G,{T},'Val'); m:face('pack',G,{gate},{pkg,val},'Pack')
  local Du=m:world('Du'); local Dv=m:world('Dv'); local Gu=m:world('Gu'); local Tq=m:point('T?',Du,'Type'); local pg=m:strand('pkg?',Du,{Pkg,Tq},'PkgA'); local vq=m:strand('val?',Dv,{Tq},'Val'); local out=m:strand('out',Gu,{Tq},'Out'); m:face('use-package',Gu,{pg,vq},{out},'Use')
  local W1=m:world('W1',O); local W2=m:world('W2',O); local a=m:develop(m:strand('m1',W1,{Make},'MakeA')); local b=m:develop(m:strand('m2',W2,{Make},'MakeA')); ne(a.map[T],b.map[T])
  local W=m:world('mix',O); local p1=m:strand('p1',W,{Pkg,a.map[T]},'PkgA'); local v2=m:strand('v2',W,{b.map[T]},'Val'); m:face('tp',a.map[pkg].world,{a.map[pkg]},{p1},'Transport'); m:face('tv',b.map[val].world,{b.map[val]},{v2},'Transport')
  expect_fail(function() m:develop(p1) end,'no local realised supply')
end)

test('19. World completion is not yet derived: held authority is valid while a World remains semantically live',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('live-state',m.actuality); local held=m:strand('held',W,{X},'Held')
  local ok,why=Audit.check(m); assert(ok,why); eq(m:_realised_uses(held),0)
  -- This is intentionally not called a leak: the current theory has no geometric
  -- completion predicate for Worlds. It is a recorded open problem.
end)

print(string.format('%d/%d extreme semantic tests passed',passed,passed))
