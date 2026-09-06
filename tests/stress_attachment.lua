package.path='./src/?.lua;'..package.path
local W=require('worlds'); local Model,Att=W.Model,W.Attachment; local Ref=require('worlds.attachment_reference')
local rounds=800
for n=1,rounds do
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local X=m:point('X',O,'X')
  local Dg=m:world('Dg'); local Dr=m:world('Dr'); local G=m:world('G')
  local gate=m:strand('g?',Dg,{F},'Call'); local r=m:strand('r?',Dr,{X},'R'); local out=m:strand('o',G,{X},'O'); m:face('body',G,{gate,r},{out},'Body')
  local K=m:world('K',O); local f=m:strand('f',K,{F},'Call'); local supplies=(n*17)%4
  for i=1,supplies do m:strand('r'..i,K,{X},'R') end
  local fixed={{demand=gate,supply=f}}; local rs=Ref.matches(m,K,gate,fixed)
  local q=Att.query(m,K,Att.patch(m,gate),fixed); local st,w=q:step(math.huge)
  if #rs==0 then assert(st=='retry') else assert(st=='hit' and Att.is_witness(w)) end
  if #rs==1 and n%7==0 then local i=Att.graft(w); assert(m:is_realised(i.map[G])) end
end
print(string.format('%d deterministic attachment stress cases passed',rounds))
