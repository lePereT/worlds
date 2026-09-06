package.path='./src/?.lua;'..package.path

-- Lua 5.1 provides global `unpack`; later Lua provides `table.unpack`.
-- Simulate the 5.1 standard-library shape even when this suite runs on a later
-- interpreter, before Worlds modules are loaded.
local saved_table_unpack=table.unpack
table.unpack=nil

local Worlds=require('worlds')
local Harden=require('worlds.harden')
local Certified=require('worlds.certified')
local Separate=require('worlds.separate')

local passed=0
local function test(name,f)
  io.write(string.format('%-76s ',name))
  local ok,err=pcall(f)
  if not ok then print('FAIL'); error(err,0) end
  passed=passed+1; print('ok')
end

test('1. public entry and namespaced modules load with Lua 5.1 unpack shape',function()
  assert(Worlds.Model==Harden)
  assert(Worlds.Certified==Certified)
  assert(Worlds.Separate==Separate)
end)

test('2. transactional multiple returns preserve nil slots without table.unpack',function()
  local m=Worlds.Model.new('O')
  local a,b,c=m:atomic(function() return 'left',nil,'right' end)
  assert(a=='left' and b==nil and c=='right')
end)

test('3. ordinary construction/certification works without table.unpack',function()
  local m=Worlds.Model.new('O')
  local P=m:point('P',m.actuality,'Identity')
  local W=m:world('W',m.actuality)
  local s=m:admit('s',W,{P},'Authority')
  assert(Worlds.Certified.is_view(Worlds.Certified.certify(m)))
end)

-- Restore the host library for embedders which choose to execute test files in
-- one VM rather than one process per file.
table.unpack=saved_table_unpack
print(string.format('%d/%d Lua 5.1 compatibility smoke tests passed',passed,passed))
