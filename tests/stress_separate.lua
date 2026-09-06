package.path='./src/?.lua;'..package.path
local Model=require('model'); local Sep=require('separate')
math.randomseed(0xC011AB1E)
local total=0
for n=1,1200 do
  local p=Model.new('P'); local O=p.actuality
  local F=p:point('F',O,'F'); local T=p:point('T',O,'Type')
  local Dg=p:world('Dg'); local Da=p:world('Da'); local G=p:world('G')
  local gate=p:strand('gate',Dg,{F},'A'); local arg=p:strand('arg',Da,{T},'Arg')
  local P=p:point('hidden'..n,G,'Private'); local out=p:strand('out',G,{P},'Out'); p:face('body-private-'..n,G,{gate,arg},{out},'Body')
  local unit=Sep.export_unit(p,gate)

  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local Tc=c:point('T',c.actuality,'Type')
  Sep.import_unit(c,unit,unit.frontier)
  local W=c:world('call',c.actuality); local f=c:strand('f',W,{Fc},'A'); c:strand('x',W,{Tc},'Arg')
  if n%13==0 then c:strand('x2',W,{Tc},'Arg'); local ok=pcall(function() c:develop(f) end); assert(not ok)
  else local i=c:develop(f); assert(i.event and c:is_realised(i.event)) end
  local ok,why=c:check_actual_subcomplex(); assert(ok,why)
  total=total+1
end
print(string.format('%d generated separate-compilation stress cases passed',total))
