package.path='./src/?.lua;'..package.path
local Model=require('model')
math.randomseed(0x51A7E)
local total=0
for n=1,2500 do
  local m=Model.new('O'); local O=m.actuality
  local F=m:point('F',O,'CallableIdentity'); local D=m:world('D'); local G=m:world('G')
  local gate=m:strand('gate',D,{F},'CallableAuthority'); local T=m:point('T?',D,'Type'); local arg=m:strand('arg?',D,{T},'Argument'); local out=m:strand('out',G,{T},'Result'); m:face('body',G,{gate,arg},{out},'Body')
  local W=m:world('call',O); local f=m:strand('f',W,{F},'CallableAuthority'); local Actual=m:point('T',O,'Type'); local x=m:strand('x',W,{Actual},'Argument')
  if n%7==0 then m:strand('x2',W,{Actual},'Argument'); local ok=pcall(function() m:develop(f) end); assert(not ok)
  else local i=m:develop(f); assert(i.map[T]==Actual and i.map[arg]==x and m:is_realised(i.map[G])) end
  local ok,why=m:check_actual_subcomplex(); assert(ok,why)
  total=total+1
end
print(string.format('%d generated topology stress cases passed',total))
