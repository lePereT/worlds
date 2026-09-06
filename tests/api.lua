package.path='./src/?.lua;'..package.path
local W=require('worlds')
local passed=0
local function test(name,f) io.write(string.format('%-78s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end

test('1. public package version is 0.2.0',function() assert(W.VERSION=='0.2.0') end)
test('2. attachment is the public actualisation surface',function()
  for _,k in ipairs{'Model','Attachment','Certified','Separate','Frontier','Completion'} do assert(type(W[k])=='table',k) end
  for _,k in ipairs{'patch','patches','query','graft','is_patch','is_witness','is_certificate'} do assert(type(W.Attachment[k])=='function','missing Attachment.'..k) end
end)
test('3. Model is carrier-only: trigger-centred develop is gone',function()
  local M=W.Model
  for _,k in ipairs{'new','is_model','world','point','strand','face','glue_points','admit','copy','discard','same_point','is_realised','is_suspended','find_actual_point','atomic'} do
    assert(type(M[k])=='function','missing Model operation '..k)
  end
  assert(M.develop==nil,'v0.1 trigger-centred develop leaked into v0.2')
end)
test('4. geometric/search helpers are not Model API',function()
  local M=W.Model
  for _,k in ipairs{'_stage_component','_entry_gate','_infer','_offer_pool','_graft_attachment','_uses','_parents'} do assert(M[k]==nil,k) end
  local m=M.new('O'); assert(m.develop==nil and m._graft_attachment==nil and m._uses==nil)
end)
test('5. portable schemas remain neutral Worlds formats',function()
  assert(W.Certified.SCHEMA=='worlds.certified/1')
  assert(W.Separate.FORMAT=='worlds.unit/1')
  assert(W.Frontier.FORMAT=='worlds.frontier-artifact/1')
end)
test('6. live carrier objects keep stable public identity across collection',function()
  local m=W.Model.new('O'); local p=m:point('p',m.actuality,'P'); local s=m:strand('s',m.actuality,{p},'S')
  local a=s.points[1]; collectgarbage('collect'); collectgarbage('collect'); local b=s.points[1]
  assert(a==b and a==p,'live raw Point acquired a different public proxy')
end)
print(string.format('%d/%d public API tests passed',passed,passed))
