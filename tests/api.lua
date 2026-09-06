package.path='./src/?.lua;'..package.path
local W=require('worlds')
local passed=0
local function test(name,f) io.write(string.format('%-76s ',name)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end

test('1. public package version is 0.1.0',function() assert(W.VERSION=='0.1.0') end)
test('2. public surface is the supported semantic/artefact boundary',function()
  for _,k in ipairs{'Model','Certified','Separate','Frontier','Completion'} do assert(type(W[k])=='table',k) end
end)
test('3. research helpers are not accidentally part of the 0.1 public surface',function()
  assert(W.Audit==nil and W.Federation==nil and W.Choice==nil)
end)
test('4. portable schemas are neutral Worlds formats',function()
  assert(W.Certified.SCHEMA=='worlds.certified/1')
  assert(W.Separate.FORMAT=='worlds.unit/1')
  assert(W.Frontier.FORMAT=='worlds.frontier-artifact/1')
end)

print(string.format('%d/%d public API tests passed',passed,passed))
