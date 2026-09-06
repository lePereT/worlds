local files={
  'src/worlds.lua','src/worlds/geometry.lua','src/worlds/attach.lua',
}
local p=io.popen("find tests -maxdepth 1 -name '*.lua' -print")
for f in p:lines() do files[#files+1]=f end
p:close()
for _,f in ipairs(files) do assert(loadfile(f),f) end
print('ok syntax')
