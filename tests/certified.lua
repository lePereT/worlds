package.path='./src/?.lua;'..package.path
local K={Model=require('model'),Certified=require('certified')}
local Model=K.Model
local Certified=K.Certified
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

test('kernel handles and incidence arrays are opaque outside Model methods',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); local a=m:admit('a',W,{P},'A')
  fail(function() a.sort='FORGED' end,'opaque')
  fail(function() W.parent=nil end,'opaque')
  fail(function() m.next_serial=1 end,'opaque')
  local ps=a.points; ps[1]=nil; assert(a.points[1]==P,'mutating returned incidence array changed kernel state')
  local objects=m.objects; objects[1]=nil; assert(m.objects[1]==m.actuality,'mutating returned object list changed Model state')
  fail(function() m:face('forged',W,{{dim=1}}, {},'F') end,'Strand of this Model')
  fail(function() m:_cell({name='forged',dim=0,sort='P',world=W}) end,'internal Model mutation is not a public capability')
  fail(function() m:_face('forged',W,{}, {a},'F','admission') end,'internal Model mutation is not a public capability')
  fail(function() m:_clone_generated({},a,{}, {}) end,'internal Model mutation is not a public capability')
  fail(function() Certified.certify({actuality=W,same_point=function() return true end,objects={}}) end,'certify expects World Model')
  Certified.certify(m)
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

test('certification checks developable detached stages as well as actuality',function()
  local m=Model.new('O'); local O=m.actuality; local Schema=m:point('S',O,'Schema')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('gate',D,{Schema},'Call')
  local x=m:strand('x',G,{Schema},'X'); local y=m:strand('y',G,{Schema},'X')
  m:face('bad',G,{gate},{x,y},'ordinary')
  fail(function() Certified.certify(m) end,'structural duplication requires explicit copy operation')
end)


test('rawset shadow fields cannot alter certification observations',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); m:strand('minted',W,{P},'A')
  fail(function() Certified.certify(m) end,'actual authority requires exactly one producer or explicit admission')
  rawset(m,'objects',{m.actuality})
  fail(function() Certified.certify(m) end,'non-opaque handle')

  local n=Model.new('O'); local NW=n:world('W',n.actuality); local NP=n:point('P',NW,'P'); local a=n:admit('a',NW,{NP},'A')
  local x=n:strand('x',NW,{NP},'A'); local y=n:strand('y',NW,{NP},'A')
  local f1=n:face('one',NW,{a},{x},'F'); n:face('two',NW,{a},{y},'F')
  fail(function() Certified.certify(n) end,'scarcity')
  rawset(f1,'inputs',{})
  fail(function() Certified.certify(n) end,'non-opaque handle')
end)

test('certification detects mutation of its pinned Lua trust modules',function()
  local Audit=require('audit')
  local original=Audit.check_certified
  rawset(Audit,'check_certified',function() return true end)
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); m:strand('minted',W,{P},'A')
  fail(function() Certified.certify(m) end,'trust surface changed')
  rawset(Audit,'check_certified',original)

  local original_same=Model.same_point
  rawset(Model,'same_point',function() return true end)
  local n=Model.new('O'); local NW=n:world('W',n.actuality); local NP=n:point('P',NW,'P'); n:admit('a',NW,{NP},'A')
  fail(function() Certified.certify(n) end,'trust surface changed')
  rawset(Model,'same_point',original_same)
  Certified.certify(n)
end)

test('successful develop preserves certification for a certified model',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F')
  local D=m:world('D'); local G=m:world('G'); local gate=m:strand('gate',D,{F},'Call'); local out=m:strand('out',G,{F},'Out'); m:face('body',G,{gate},{out},'Body')
  local W=m:world('W',O); local trigger=m:admit('trigger',W,{F},'Call')
  Certified.certify(m); m:develop(trigger); Certified.certify(m)
end)

print(string.format('%d/%d certified World tests passed',passed,passed))
