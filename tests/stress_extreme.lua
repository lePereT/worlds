package.path='./src/?.lua;'..package.path
local Model=require('model'); local Audit=require('audit'); local Federation=require('federation')
math.randomseed(0x51A7E)
local total=0

-- Choice followed by generic join over a branch-fresh identity.
for n=1,500 do
  local m=Model.new('O'); local O=m.actuality; local C=m:point('C',O,'C'); local T=m:point('T',O,'Tag'); local F=m:point('F',O,'Tag'); local J=m:point('J',O,'J'); local Ty=m:point('Ty',O,'Ty')
  local function branch(tag,name)
    local D=m:world(name..'D'); local G=m:world(name..'G'); local g=m:strand(name..'g',D,{C,tag},'Choice'); local q=m:point(name..'q',G,'Q'); local o=m:strand(name..'o',G,{J,q,Ty},'JoinA'); m:face(name..'b',G,{g},{o},'Branch'); return {g=g,q=q,o=o,G=G}
  end
  local a=branch(T,'a'); local b=branch(F,'b'); local Dj=m:world('Dj'); local Gj=m:world('Gj'); local q=m:point('q?',Dj,'Q'); local j=m:strand('j?',Dj,{J,q,Ty},'JoinA'); local d=m:strand('done',Gj,{Ty},'Done'); m:face('join',Gj,{j},{d},'Join')
  local W=m:world('W',O); local pick=(n%2==0) and T or F; local t=m:strand('t',W,{C,pick},'Choice'); local bi=m:develop(t); local br=(pick==T) and a or b; local ji=m:develop(bi.map[br.o]); assert(ji.map[q]==bi.map[br.q]); assert(m:is_suspended(((pick==T) and b or a).G)); total=total+1
end

-- Literal Point gluing across provider/client custody.
for n=1,500 do
  local p=Model.new('P'); local Fp=p:point('F',p.actuality,'F'); local Xp=p:point('X',p.actuality,'X'); local Dg=p:world('Dg'); local Dx=p:world('Dx'); local G=p:world('G'); local g=p:strand('g',Dg,{Fp},'A'); local x=p:strand('x?',Dx,{Xp},'R'); local o=p:strand('o',G,{Xp},'O'); p:face('b',G,{g,x},{o},'B')
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local Xc=c:point('X',c.actuality,'X'); local link=Federation.link(p,g,c); assert(c:same_point(Fp,Fc) and c:same_point(Xp,Xc)); local W=c:world('W',c.actuality); local f=c:strand('f',W,{Fc},'A'); local r=c:strand('r',W,{Xc},'R'); local i=link:develop(f); assert(i.map[x]==r and c:same_point(i.map[o].points[1],Xp)); total=total+1
end

-- Recursive state threading through many fresh Worlds.
for n=1,500 do
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local S=m:point('S',O,'S'); local Dg=m:world('Dg'); local Ds=m:world('Ds'); local G=m:world('G'); local iq=m:point('i?',Dg,'I'); local g=m:strand('f?',Dg,{F,iq},'FA'); local sq=m:strand('s?',Ds,{S,iq},'State'); local ni=m:point('ni',G,'I'); local nf=m:strand('nf',G,{F,ni},'FA'); local ns=m:strand('ns',G,{S,ni},'State'); m:face('step',G,{g,sq},{nf,ns},'Step')
  local W=m:world('W',O); local i0=m:point('i0',W,'I'); local f=m:strand('f0',W,{F,i0},'FA'); local s=m:strand('s0',W,{S,i0},'State'); local rounds=(n%5)+1
  for _=1,rounds do local r=m:develop(f); assert(r.map[sq]==s); f,s=r.map[nf],r.map[ns] end
  local ok,why=Audit.check(m); assert(ok,why); total=total+1
end

-- Concurrent join requires explicit common locality.
for n=1,500 do
  local m=Model.new('O'); local O=m.actuality; local J=m:point('J',O,'J'); local A=m:point('A',O,'A'); local B=m:point('B',O,'B'); local Dg=m:world('Dg'); local Db=m:world('Db'); local G=m:world('G'); local g=m:strand('a?',Dg,{J,A},'JA'); local bq=m:strand('b?',Db,{B},'BO'); local done=m:strand('done',G,{J},'D'); m:face('join',G,{g,bq},{done},'Join')
  local WA=m:world('WA',O); local WB=m:world('WB',O); local a=m:strand('a',WA,{J,A},'JA'); local b=m:strand('b',WB,{B},'BO'); local ok=pcall(function() m:develop(a) end); assert(not ok)
  local WJ=m:world('WJ',O); local aj=m:strand('aj',WJ,{J,A},'JA'); local bj=m:strand('bj',WJ,{B},'BO'); m:face('ta',WA,{a},{aj},'Transport'); m:face('tb',WB,{b},{bj},'Transport'); local i=m:develop(aj); assert(i.map[bq]==bj); total=total+1
end

print(string.format('%d extreme generated stress cases passed',total))
