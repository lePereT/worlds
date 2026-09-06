package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Att=W.Model,W.Att
local Ref=require('tests.reference.attachment')
local Internal=require('worlds.internal')
local passed=0
local function test(name,f) io.write(string.format('%-84s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end
local function eq(a,b,m) assert(a==b,m or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,m) assert(a~=b,m or (tostring(a)..' == '..tostring(b))) end

local function generic(m,name)
  local O=m.actuality
  local Fn=m:point(name..'.Fn',O,'Fn')
  local D=m:world(name..'.D'); local G=m:world(name..'.G')
  local gate=m:strand(name..'.gate',D,{Fn},'Call')
  local T=m:point(name..'.T?',D,'Type'); local arg=m:strand(name..'.arg?',D,{T},'Arg')
  local result=m:strand(name..'.result',G,{T},'Result'); local body=m:face(name..'.body',G,{gate,arg},{result},'Body')
  return {Fn=Fn,D=D,G=G,gate=gate,T=T,arg=arg,result=result,body=body}
end
local function unique(m,world,seed,fixed)
  local rs=Ref.matches(m,world,seed,fixed); eq(#rs,1,'expected unique complete attachment')
  local p=Att.patch(m,seed); local q=Att.at(m,world):query(p,fixed); local st,w=q:step(math.huge)
  eq(st,'hit'); return w
end

test('1. attachment is complete frontier matching followed by fresh graft',function()
  local m=Model.new('O'); local g=generic(m,'id'); local Wc=m:world('call',m.actuality)
  local f=m:strand('f',Wc,{g.Fn},'Call'); local Int=m:point('Int',m.actuality,'Type'); local x=m:strand('x',Wc,{Int},'Arg')
  local p=Att.patch(m,g.gate); eq(#p:inputs(),2); assert(#p:demands()>=2)
  local before=#m.objects; local w=unique(m,Wc,g.gate,{{demand=g.gate,supply=f}}); eq(#m.objects,before,'query mutated actuality')
  local i=w:graft(); eq(i.map[g.T],Int); eq(i.map[g.arg],x); eq(i.map[g.body].inputs[1],f); eq(i.map[g.body].inputs[2],x); assert(m:is_realised(i.map[g.G]))
end)

test('2. triggerless complete attachment exists without a privileged gate selection',function()
  local m=Model.new('O'); local O=m.actuality
  local D1=m:world('D1'); local D2=m:world('D2'); local G=m:world('G')
  local A=m:point('A?',D1,'A'); local B=m:point('B?',D2,'B')
  local a=m:strand('a?',D1,{A},'RA'); local b=m:strand('b?',D2,{B},'RB')
  local out=m:strand('out',G,{},'Out'); m:face('joint',G,{a,b},{out},'Joint')
  local K=m:world('K',O); local AP=m:point('A',O,'A'); local BP=m:point('B',O,'B'); m:strand('a',K,{AP},'RA'); m:strand('b',K,{BP},'RB')
  local rs=Ref.matches(m,K,a); eq(#rs,1)
  local q=Att.at(m,K):query(Att.patch(m,b)); local st=q:step(math.huge); eq(st,'hit')
end)

test('3. global constraint can make a locally ambiguous first demand uniquely attachable',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X'); local Y=m:point('Y',O,'Y')
  local Dg=m:world('Dg'); local Dx=m:world('Dx'); local Dy=m:world('Dy'); local G=m:world('G')
  local gate=m:strand('g?',Dg,{F},'Call')
  local V=m:point('V?',Dx,'V'); local x=m:strand('x?',Dx,{V},'R')
  -- Same suspended Point identity is achieved by using V in both demands.
  local y=m:strand('y?',Dy,{V},'S')
  local out=m:strand('o',G,{V},'Out'); m:face('body',G,{gate,x,y},{out},'Body')
  local K=m:world('K',O); local f=m:strand('f',K,{F},'Call')
  local px=m:point('px',O,'V'); local py=m:point('py',O,'V')
  local r1=m:strand('r1',K,{px},'R'); local r2=m:strand('r2',K,{py},'R'); local s=m:strand('s',K,{py},'S')
  local rs=Ref.matches(m,K,gate,{{demand=gate,supply=f}}); eq(#rs,1); eq(rs[1].bindings[x],r2); eq(rs[1].bindings[y],s)
end)

test('4. early local ambiguity can mask complete emptiness; Att reports empty',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X'); local Dg=m:world('Dg'); local Da=m:world('Da'); local Db=m:world('Db'); local G=m:world('G')
  local gate=m:strand('g?',Dg,{F},'Call'); local a=m:strand('a?',Da,{X},'R'); local b=m:strand('b?',Db,{X},'Missing'); local out=m:strand('o',G,{X},'Out'); m:face('body',G,{gate,a,b},{out},'Body')
  local K=m:world('K',O); local f=m:strand('f',K,{F},'Call'); m:strand('r1',K,{X},'R'); m:strand('r2',K,{X},'R')
  eq(#Ref.matches(m,K,gate,{{demand=gate,supply=f}}),0)
  local q=Att.at(m,K):query(Att.patch(m,gate),{{demand=gate,supply=f}}); local st,c=q:step(math.huge); eq(st,'retry'); assert(Att.is_certificate(c))
end)

test('5. multiple complete witnesses are possibility, not an error in Worlds',function()
  local m=Model.new('O'); local g=generic(m,'g'); local K=m:world('K',m.actuality); local f=m:strand('f',K,{g.Fn},'Call'); local T=m:point('T',m.actuality,'Type'); m:strand('x1',K,{T},'Arg'); m:strand('x2',K,{T},'Arg')
  local rs=Ref.matches(m,K,g.gate,{{demand=g.gate,supply=f}}); eq(#rs,2)
  local q=Att.at(m,K):query(Att.patch(m,g.gate),{{demand=g.gate,supply=f}}); local st,w=q:step(math.huge); eq(st,'hit'); assert(Att.is_witness(w))
end)

test('6. exact locality is preserved by complete attachment',function()
  local m=Model.new('O'); local g=generic(m,'g'); local K=m:world('K',m.actuality); local Other=m:world('Other',m.actuality); local f=m:strand('f',K,{g.Fn},'Call'); local T=m:point('T',m.actuality,'Type'); m:strand('x',Other,{T},'Arg')
  eq(#Ref.matches(m,K,g.gate,{{demand=g.gate,supply=f}}),0)
end)

test('7. scarce authority cannot satisfy two demanded Strands',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X'); local Dg=m:world('Dg'); local Da=m:world('Da'); local Db=m:world('Db'); local G=m:world('G')
  local gate=m:strand('g?',Dg,{F},'Call'); local a=m:strand('a?',Da,{X},'R'); local b=m:strand('b?',Db,{X},'R'); local out=m:strand('o',G,{X},'Out'); m:face('body',G,{gate,a,b},{out},'Body')
  local K=m:world('K',O); local f=m:strand('f',K,{F},'Call'); m:strand('r',K,{X},'R')
  eq(#Ref.matches(m,K,gate,{{demand=gate,supply=f}}),0)
end)

test('8. repeated grafts of one archetype generate fresh Worlds and identity',function()
  local m=Model.new('O'); local O=m.actuality; local Make=m:point('Make',O,'Make'); local D=m:world('D'); local G=m:world('G'); local gate=m:strand('g?',D,{Make},'Call'); local I=m:point('I',G,'Instance'); local out=m:strand('out',G,{I},'Out'); m:face('body',G,{gate},{out},'Body')
  local K1=m:world('K1',O); local K2=m:world('K2',O); local f1=m:strand('f1',K1,{Make},'Call'); local f2=m:strand('f2',K2,{Make},'Call')
  local a=unique(m,K1,gate,{{demand=gate,supply=f1}}):graft(); local b=unique(m,K2,gate,{{demand=gate,supply=f2}}):graft()
  ne(a.map[G],b.map[G]); ne(a.map[I],b.map[I]); eq(a.map[G].parent,K1); eq(b.map[G].parent,K2)
end)


test('9. sibling/fixed-binding enumeration order has no causal meaning',function()
  local m=Model.new('O'); local O=m.actuality; local A=m:point('A',O,'A'); local B=m:point('B',O,'B')
  local Da=m:world('Da'); local Db=m:world('Db'); local G=m:world('G'); local a=m:strand('a?',Da,{A},'RA'); local b=m:strand('b?',Db,{B},'RB'); local out=m:strand('o',G,{},'O'); m:face('joint',G,{a,b},{out},'F')
  local K=m:world('K',O); local ra=m:strand('ra',K,{A},'RA'); local rb=m:strand('rb',K,{B},'RB'); local p=Att.patch(m,a)
  local q1=Att.at(m,K):query(p,{{demand=a,supply=ra},{demand=b,supply=rb}}); local s1,w1=q1:step(math.huge); eq(s1,'hit')
  local q2=Att.at(m,K):query(p,{{demand=b,supply=rb},{demand=a,supply=ra}}); local s2,w2=q2:step(math.huge); eq(s2,'hit'); eq(w1:signature(),w2:signature())
  local ds=p:demands(); ds[1],ds[#ds]=ds[#ds],ds[1]; eq(#p:demands(),#ds,'mutating returned traversal changed patch')
end)

print(string.format('%d/%d attachment tests passed',passed,passed))
