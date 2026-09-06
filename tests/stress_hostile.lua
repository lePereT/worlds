package.path='./src/?.lua;'..package.path
local Model=require('model'); local Audit=require('audit'); local Federation=require('federation')
math.randomseed(0xD15EA5E)
local total=0

-- Federated generic specialisation/ambiguity/late aliasing across independent carriers.
for n=1,700 do
  local p=Model.new('P'); local O=p.actuality; local F=p:point('F',O,'F'); local X=p:point('X',O,'X')
  local Dg=p:world('Dg'); local Da=p:world('Da'); local G=p:world('G'); local gate=p:strand('gate',Dg,{F},'A'); local a=p:strand('a',Da,{X},'R'); local out=p:strand('out',G,{X},'O'); p:face('body',G,{gate,a},{out},'B')
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local Xc=c:point('X',c.actuality,'X'); local link=Federation.link(p,gate,c)
  local W=c:world('W',c.actuality); local f=c:strand('f',W,{Fc},'A'); local r=c:strand('r',W,{Xc},'R')
  if n%11==0 then c:strand('r2',W,{Xc},'R'); local ok=pcall(function() link:develop(f) end); assert(not ok)
  else local i=link:develop(f); assert(i.map[a]==r and i.event.inputs[2]==r) end
  total=total+1
end

-- Choice: only the structurally selected branch is grafted; unchosen branch cannot count as use.
for n=1,700 do
  local m=Model.new('O'); local O=m.actuality; local C=m:point('C',O,'C'); local T=m:point('T',O,'Tag'); local F=m:point('F',O,'Tag'); local X=m:point('X',O,'X')
  local function branch(tag,name)
    local Dg=m:world(name..'Dg'); local Dx=m:world(name..'Dx'); local G=m:world(name..'G'); local gate=m:strand(name..'gate',Dg,{C,tag},'Choice'); local x=m:strand(name..'x',Dx,{X},'R'); local o=m:strand(name..'o',G,{X},'O'); local b=m:face(name..'body',G,{gate,x},{o},'B'); return gate,x,b,G
  end
  local tg,tx,tb,tG=branch(T,'t'); local fg,fx,fb,fG=branch(F,'f'); local W=m:world('W',O); local r=m:strand('r',W,{X},'R'); local choose=(n%2==0) and T or F; local trig=m:strand('choose',W,{C,choose},'Choice')
  local i=m:develop(trig); assert(m:_realised_uses(r)==1); if choose==T then assert(i.map[tb] and m:is_suspended(fG)) else assert(i.map[fb] and m:is_suspended(tG)) end
  total=total+1
end

-- Structural resources under concurrent sibling Worlds.
for n=1,700 do
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('owner',m.actuality); local r=m:strand('r',W,{X},'R')
  local A=m:world('A',m.actuality); local B=m:world('B',m.actuality); local ra=m:strand('ra',A,{X},'R'); local rb=m:strand('rb',B,{X},'R')
  if n%9==0 then m:face('copy',W,{r},{ra,rb},'Ordinary'); local ok=Audit.check(m); assert(not ok)
  else m:copy('copy',W,r,{ra,rb},'structural'); local ok,why=Audit.check(m); assert(ok,why) end
  total=total+1
end

-- Portable one-shot continuation locality.
for n=1,700 do
  local m=Model.new('O'); local O=m.actuality; local K=m:point('K',O,'K'); local I=m:point('I',O,'I'); local V=m:point('V',O,'V')
  local D=m:world('D'); local G=m:world('G'); local iq=m:point('iq',D,'I'); local gate=m:strand('kg',D,{K,iq},'KA'); local hq=m:strand('hq',D,{V,iq},'Held'); local vq=m:strand('vq',D,{V},'RV'); local out=m:strand('out',G,{V},'O'); m:face('resume',G,{gate,hq,vq},{out},'Resume')
  local A=m:world('A',O); local inst=m:point('i',A,'I'); local k=m:strand('k',A,{K,inst},'KA'); local h=m:strand('h',A,{V,inst},'Held'); local B=m:world('B',O); local k2=m:strand('k2',B,{K,inst},'KA')
  if n%10==0 then m:face('transport',A,{k},{k2},'Transport'); m:strand('v',B,{V},'RV'); local ok=pcall(function() m:develop(k2) end); assert(not ok)
  else local h2=m:strand('h2',B,{V,inst},'Held'); m:face('transport',A,{k,h},{k2,h2},'Transport'); m:strand('v',B,{V},'RV'); local i=m:develop(k2); assert(i.event.sort=='Resume') end
  total=total+1
end

print(string.format('%d nasty generated stress cases passed',total))
