package.path='./src/?.lua;'..package.path
local K={Model=require('worlds.harden'),Certified=require('worlds.certified'),Attachment=require('worlds.attachment')}
local Model=K.Model
local Certified=K.Certified
local Attachment=K.Attachment
local passed=0
local function test(name,f)
  io.write(string.format('%-76s ',name)); local ok,err=pcall(f); if not ok then print('FAIL'); error(err,0) end; passed=passed+1; print('ok')
end
local function fail(f,pat) local ok,err=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(err):find(pat,1,true),tostring(err)) end end

test('certification yields immutable primitive World observation',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); local a=m:admit('a',W,{P},'A'); local b=m:strand('b',W,{P},'B'); m:face('f',W,{a},{b},'F')
  local view=Certified.certify(m); assert(Certified.is_view(view)); local r=Certified.read(view); assert(Certified.is_reader(r))
  local sr=r:strand(a.serial); sr.points[1]=999; assert(r:strand(a.serial).points[1]==P.serial)
  local ok=pcall(function() view.foo='bar' end); assert(not ok)
end)

test('certified observation is a snapshot rather than live Model authority',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); local a=m:admit('a',W,{P},'A')
  local old=Certified.certify(m); assert(#Certified.read(old):faces(nil,nil,true)==1)
  local b=m:strand('b',W,{P},'B'); m:face('later',W,{a},{b},'F')
  assert(#Certified.read(old):faces(nil,nil,true)==1,'old certified view changed after Model mutation')
  assert(#Certified.read(Certified.certify(m)):faces(nil,nil,true)==2)
end)

test('certification rejects invalid realised scarcity',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); local a=m:admit('a',W,{P},'A')
  local x=m:strand('x',W,{P},'X'); local y=m:strand('y',W,{P},'Y')
  m:face('one',W,{a},{x},'F1'); m:face('two',W,{a},{y},'F2')
  fail(function() Certified.certify(m) end,'scarcity')
end)

test('certification rejects unadmitted actual authority',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); m:strand('minted',W,{P},'A')
  fail(function() Certified.certify(m) end,'actual authority requires exactly one producer or explicit admission')
end)

test('Face labels confer no copy or discard authority',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); local a=m:admit('a',W,{P},'A')
  local x=m:strand('x',W,{P},'A'); local y=m:strand('y',W,{P},'A'); m:face('pretend-delta',W,{a},{x,y},'DELTA')
  fail(function() Certified.certify(m) end,'explicit copy operation')

  local n=Model.new('O'); local NW=n:world('W',n.actuality); local NP=n:point('P',NW,'P'); local na=n:admit('a',NW,{NP},'A')
  n:face('pretend-epsilon',NW,{na},{},'EPSILON')
  fail(function() Certified.certify(n) end,'explicit discard operation')
end)

test('certification checks attachable detached patches as well as actuality',function()
  local m=Model.new('O'); local O=m.actuality; local Schema=m:point('S',O,'Schema')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('gate',D,{Schema},'Call')
  local x=m:strand('x',G,{Schema},'X'); local y=m:strand('y',G,{Schema},'X')
  m:face('bad',G,{gate},{x,y},'ordinary')
  fail(function() Certified.certify(m) end,'structural duplication requires explicit copy operation')
end)


test('successful witnessed graft preserves certification for a certified model',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('gate',D,{F},'Call'); local out=m:strand('out',G,{F},'Out'); m:face('body',G,{gate},{out},'Body')
  local W=m:world('W',O); local trigger=m:admit('trigger',W,{F},'Call')
  Certified.certify(m)
  local p=Attachment.patch(m,gate); local q=Attachment.query(m,W,p,{{demand=gate,supply=trigger}}); local st,w=q:step(math.huge); assert(st=='hit')
  Attachment.graft(w); Certified.certify(m)
end)

print(string.format('%d/%d certified World tests passed',passed,passed))
