package.path='./src/?.lua;'..package.path
local Model=require('worlds.harden')
local Certified=require('worlds.certified')
local Attachment=require('worlds.attachment')
local passed=0
local function test(name,f)
  io.write(string.format('%-76s ',name)); local ok,err=pcall(f); if not ok then print('FAIL'); error(err,0) end; passed=passed+1; print('ok')
end
local function fail(f,pat) local ok,err=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(err):find(pat,1,true),tostring(err)) end end

test('kernel handles and incidence arrays are opaque outside Model methods',function()
  local m=Model.new('O'); local W=m:world('W',m.actuality); local P=m:point('P',W,'P'); local a=m:admit('a',W,{P},'A')
  fail(function() a.sort='FORGED' end,'opaque')
  fail(function() W.parent=nil end,'opaque')
  fail(function() m.next_serial=1 end,'opaque')
  local ps=a.points; ps[1]=nil; assert(a.points[1]==P,'mutating returned incidence array changed kernel state')
  local objects=m.objects; objects[1]=nil; assert(m.objects[1]==m.actuality,'mutating returned object list changed Model state')
  fail(function() m:face('forged',W,{{dim=1}}, {},'F') end,'Strand of this Model')
  assert(m._cell==nil and m._face==nil and m._clone_generated==nil)
  assert(m._stage_component==nil and m._parents==nil and m._realised_uses==nil and m._offer_pool==nil)
  fail(function() Certified.certify({actuality=W,same_point=function() return true end,objects={}}) end,'certify expects World Model')
  Certified.certify(m)
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
  local Audit=require('worlds.audit')
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


test('attachment handles keep semantic state outside user-mutable tables',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local D=m:world('D'); local G=m:world('G')
  local d=m:strand('d',D,{X},'R'); local o=m:strand('o',G,{X},'O'); m:face('f',G,{d},{o},'F'); local K=m:world('K',O); m:strand('r',K,{X},'R')
  local p=Attachment.patch(m,d); fail(function() p.foo='bar' end,'immutable'); rawset(p,'foo','shadow')
  local fixed={}; local q=Attachment.query(m,K,p,fixed); fixed[1]={demand=d,supply=nil}
  local st,w=q:step(math.huge); assert(st=='hit' and Attachment.is_witness(w))
  fail(function() w.signature='forged' end,'immutable'); rawset(w,'signature','forged')
  local i=Attachment.graft(w); assert(i and i.faces[1])
  fail(function() Attachment.graft({}) end,'Witness')
end)

test('failed atomic mutation invalidates adjacency caches',function()
  local Internal=require('worlds.internal'); local m=Model.new('O'); local W=m:world('W',m.actuality); local im=Internal.model(m)
  assert(#im:_children(W)==0)
  local ok=pcall(function()
    m:atomic(function() m:world('temporary',W); assert(#im:_children(W)==1); error('rollback') end)
  end)
  assert(not ok and #im:_children(W)==0)
  local keep=m:world('keep',W); local xs=im:_children(W); assert(#xs==1 and xs[1]==keep)
end)


print(string.format('%d/%d Lua hardening tests passed',passed,passed))
