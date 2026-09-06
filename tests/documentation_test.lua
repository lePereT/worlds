local allowed = {
  ['LAWS.md'] = true,
  ['README.md'] = true,
  ['RESEARCH.md'] = true,
  ['tests/README.md'] = true,
}

local p = assert(io.popen("find . -type f -name '*.md' -print | sed 's#^./##' | sort"))
local seen = {}
for path in p:lines() do
  assert(allowed[path], 'unexpected documentation file: ' .. path)
  seen[path] = true
end
assert(p:close())

for path in pairs(allowed) do
  assert(seen[path], 'missing documentation file: ' .. path)
end

print('ok documentation set')
