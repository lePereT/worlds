package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Model,Sep,Frontier=W.Model,W.Separate,W.Frontier

local passed=0
local function test(name,f)
  io.write(string.format('%-86s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end
  passed=passed+1; print('ok')
end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function expect_fail(f,pat) local ok,e=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(e):match(pat),tostring(e)) end end

local function provider(two_stages)
  local m=Model.new('Provider'); local O=m.actuality
  local Fn=m:point('Fn',O,'FnIdentity')
  local proto=Frontier.prototype(m,'tail')
  local function stage(name,sort)
    local D=m:world(name..'-D'); local G=m:world(name..'-G')
    local row=m:point(name..'-row?',D,proto.marker_sort)
    local gate=m:strand(name..'-gate',D,{Fn,row},sort or 'Call')
    local out=m:strand(name..'-out',D,{row},'Return')
    m:face(name..'-body',G,{gate},{out},'Body')
    return gate,out
  end
  local gate,out=stage('entry','Call'); local extras={}
  if two_stages then local g2=stage('helper','Helper'); extras={g2} end
  local unit=Sep.export_unit(m,gate,extras)
  return m,Fn,proto,gate,out,Frontier.abstract_unit(unit,{proto})
end

local function externalise(unit)
  for _,a in ipairs(unit.anchors or {}) do a.external=true end
  return unit
end

test('1. abstraction removes marker Points and produces an artefact, not kernel geometry',function()
  local _,_,proto,_,_,a=provider(false); assert(a.format=='worlds.frontier-artifact/1'); Frontier.validate(a)
  for _,st in ipairs(a.unit.stages) do for _,c in ipairs(st.cells) do assert(c.sort~=proto.marker_sort) end end
  local found=false; for _,st in ipairs(a.unit.stages) do for _,c in ipairs(st.cells) do if c.dim==1 then for _,r in ipairs(c.points or {}) do if r.frontier=='tail' then found=true end end end end end
  assert(found,'frontier token was not retained')
end)

test('2. shape preserves order and Point-equivalence correlation rather than occurrence identity',function()
  local m=Model.new('Shapes'); local O=m.actuality
  local a=m:point('a',O,'A'); local b=m:point('b',O,'B'); local a2=m:point('a2',O,'A'); m:glue_points(a,a2)
  local s=Frontier.shape(m,{a,b,a2}); eq(Frontier.shape_key(s),'A@1|B@2|A@1')
end)

test('3. specialisation expands every row occurrence coherently and yields an ordinary Separate unit',function()
  local _,_,_,_,_,a=provider(false)
  local shape={positions={{sort='A',class=1},{sort='A',class=1},{sort='B',class=2}}}
  local u=Frontier.specialise(a,{tail=shape}); assert(u.format=='worlds.unit/1'); Sep.validate_unit(u)
  local gate=u.stages[1].cells[u.stages[1].gate]; eq(#gate.points,4) -- fixed Fn + A,A,B
  eq(gate.points[2].cell,gate.points[3].cell); assert(gate.points[4].cell~=gate.points[2].cell)
  local ret
  for _,c in ipairs(u.stages[1].cells) do if c.dim==1 and c.name:match('out') then ret=c end end
  assert(ret and #ret.points==3 and ret.points[1].cell==gate.points[2].cell and ret.points[2].cell==gate.points[3].cell and ret.points[3].cell==gate.points[4].cell)
end)

test('4. empty frontier rows are valid and simply remove the abstract seam position',function()
  local _,_,_,_,_,a=provider(false); local u=Frontier.specialise(a,{tail={positions={}}}); Sep.validate_unit(u)
  local gate=u.stages[1].cells[u.stages[1].gate]; eq(#gate.points,1)
end)

test('5. one variable occurring in provider-private stages receives the same row shape',function()
  local _,_,_,_,_,a=provider(true); local u=Frontier.specialise(a,{tail={positions={{sort='X',class=1},{sort='Y',class=2}}}}); eq(#u.stages,2)
  for _,st in ipairs(u.stages) do local gate=st.cells[st.gate]; eq(#gate.points,3); assert(gate.points[2].cell~=gate.points[3].cell) end
end)

test('6. specialisation records shape only; separate developments bind distinct generative identities',function()
  local _,_,_,_,_,a=provider(false); local u=externalise(Frontier.specialise(a,{tail={positions={{sort='T',class=1},{sort='T',class=1},{sort='R',class=2}}}}))
  local m=Model.new('Client'); local O=m.actuality; local Fn=m:point('Fn',O,'FnIdentity'); local linked=Sep.import_unit(m,u); local gate=linked.stages[1].gate
  local results={}
  for i=1,2 do
    local w=m:world('call'..i,O); local t=m:point('t'..i,O,'T'); local r=m:point('r'..i,O,'R')
    local trig=m:admit('call'..i,w,{Fn,t,t,r},'Call'); local inst=m:develop(trig); results[i]=inst.egress[1]
    assert(m:same_point(results[i].points[1],t) and m:same_point(results[i].points[2],t) and m:same_point(results[i].points[3],r))
  end
  assert(not m:same_point(results[1].points[1],results[2].points[1]),'specialisation accidentally fixed caller identity')
  W.Certified.certify(m)
end)

test('7. two frontier variables specialise independently',function()
  local m=Model.new('Provider'); local O=m.actuality; local Fn=m:point('Fn',O,'FnIdentity'); local a=Frontier.prototype(m,'a'); local b=Frontier.prototype(m,'b')
  local D=m:world('D'); local G=m:world('G'); local pa=m:point('a?',D,a.marker_sort); local pb=m:point('b?',D,b.marker_sort)
  local gate=m:strand('gate',D,{Fn,pa,pb},'Call'); local out=m:strand('out',D,{pa,pb},'Return'); m:face('body',G,{gate},{out},'Body')
  local art=Frontier.abstract_unit(Sep.export_unit(m,gate),{a,b})
  local u=Frontier.specialise(art,{a={positions={{sort='A',class=1}}},b={positions={{sort='B',class=1},{sort='C',class=2}}}}); Sep.validate_unit(u)
  eq(#u.stages[1].cells[u.stages[1].gate].points,4)
end)

test('8. malformed, unknown and partial substitutions are rejected without mutating artefact',function()
  local _,_,_,_,_,a=provider(false); local before=Frontier.FORMAT..':'..#a.unit.stages[1].cells
  expect_fail(function() Frontier.specialise(a,{other={positions={}}}) end,'unknown frontier')
  expect_fail(function() Frontier.specialise(a,{tail={positions={{sort='A',class=0}}}}) end,'malformed frontier')
  expect_fail(function() Frontier.specialise(a,{}) end,'missing substitution')
  eq(Frontier.FORMAT..':'..#a.unit.stages[1].cells,before)
end)

test('9. FrontierVar cannot cross the kernel import boundary',function()
  local _,_,_,_,_,a=provider(false); expect_fail(function() Sep.import_unit(Model.new('C'),a) end,'unsupported unit format')
end)

print(string.format('%d/%d frontier abstraction tests passed',passed,passed))
