package.path='./src/?.lua;'..package.path
local W=require('worlds')
local passed=0
local function test(name,f) io.write(string.format('%-82s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end

test('1. public package version is 0.3.0',function() assert(W.VERSION=='0.3.0') end)
test('2. public semantic surface is carrier plus one Att relation',function()
  for _,k in ipairs{'Model','Att','Certified','Separate','Completion'} do assert(type(W[k])=='table',k) end
  assert(W.Attachment==nil and W.Residual==nil and W.Frontier==nil)
  for _,k in ipairs{'patch','patches','at','same','coherence','is_patch','is_frontier','is_witness','is_certificate','is_cut'} do assert(type(W.Att[k])=='function','missing Att.'..k) end
end)
test('3. Model remains carrier-only',function()
  local M=W.Model
  for _,k in ipairs{'new','is_model','world','point','strand','face','glue_points','admit','copy','discard','same_point','is_realised','is_suspended','find_actual_point','atomic'} do assert(type(M[k])=='function','missing Model operation '..k) end
  for _,k in ipairs{'develop','query','graft','residual','coherence'} do assert(M[k]==nil,k) end
end)
test('4. geometric/search helpers are not Model API',function()
  local M=W.Model
  for _,k in ipairs{'_stage_component','_entry_gate','_infer','_offer_pool','_graft_attachment','_uses','_parents'} do assert(M[k]==nil,k) end
  local m=M.new('O'); assert(m._graft_attachment==nil and m._uses==nil)
end)
test('5. portable schemas remain neutral Worlds formats',function()
  assert(W.Certified.SCHEMA=='worlds.certified/1')
  assert(W.Separate.FORMAT=='worlds.unit/1')
end)
test('6. live carrier objects keep stable public identity across collection',function()
  local m=W.Model.new('O'); local p=m:point('p',m.actuality,'P'); local s=m:strand('s',m.actuality,{p},'S')
  local a=s.points[1]; collectgarbage('collect'); collectgarbage('collect'); local b=s.points[1]
  assert(a==b and a==p,'live raw Point acquired a different public proxy')
end)
print(string.format('%d/%d public API tests passed',passed,passed))
