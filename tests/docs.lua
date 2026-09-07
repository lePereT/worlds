-- Documentation discipline is part of the release gate.  Worlds deliberately
-- has a small prose surface: adding a Markdown file is an explicit design act.

local expected = {
  ['README.md']=true,

  ['docs/README.md']=true,
  ['docs/LAWS.md']=true,
  ['docs/MODEL.md']=true,
  ['docs/API.md']=true,
  ['docs/THEOREMS.md']=true,
  ['docs/PERFORMANCE.md']=true,
  ['docs/RESEARCH.md']=true,

  ['tests/README.md']=true,
  ['formal/README.md']=true,

  ['archaeology/README.md']=true,
  ['archaeology/CLEAN_REIMPLEMENTATION.md']=true,
  ['archaeology/FACE_INCIDENCE.md']=true,
  ['archaeology/THEORY_PORT.md']=true,

  ['external/geometric_products/README.md']=true,
  ['external/relay_source/README.md']=true,
}

local function lines(cmd)
  local p=assert(io.popen(cmd,'r'))
  local out={}
  for line in p:lines() do out[#out+1]=line end
  local ok,why,code=p:close()
  assert(ok, 'command failed: '..cmd..' '..tostring(why)..' '..tostring(code))
  return out
end

local seen={}
for _,raw in ipairs(lines("cd .. && find . -type f -name '*.md' -print")) do
  local path=raw:gsub('^%./','')
  assert(expected[path], 'unexpected Markdown file: '..path)
  seen[path]=true
  if not path:find('/',1,true) then
    assert(path=='README.md','top-level Markdown is reserved for README.md: '..path)
  end
end
for path in pairs(expected) do assert(seen[path], 'expected Markdown file missing: '..path) end

local function read(path)
  local f=assert(io.open('../'..path,'rb')); local s=assert(f:read('*a')); f:close(); return s
end
local required_status={
  ['docs/README.md']='**Status: maintained documentation authority map.**',
  ['docs/LAWS.md']='**Status: normative semantic laws for Worlds 0.5.0.**',
  ['docs/MODEL.md']='**Status: maintained explanatory model; `LAWS.md` is authoritative on conflict.**',
  ['docs/API.md']='**Status: maintained public Lua API for Worlds 0.5.0.**',
  ['docs/THEOREMS.md']='**Status: theorem targets and executable evidence; not mathematical proofs.**',
  ['docs/PERFORMANCE.md']='**Status: maintained performance constitution.**',
  ['docs/RESEARCH.md']='**Status: non-authoritative research ledger.**',
  ['tests/README.md']='**Status: maintained test architecture and executable-evidence guide.**',
  ['formal/README.md']='**Status: non-authoritative formalisation programme.**',
}
for path,status in pairs(required_status) do
  assert(read(path):find(status,1,true), path..': missing/changed documentation status')
end

local root=read('README.md')
assert(root:find('docs/README.md',1,true),'README must point to documentation authority map')
local index=read('docs/README.md')
for _,name in ipairs{'LAWS.md','MODEL.md','API.md','THEOREMS.md','PERFORMANCE.md','RESEARCH.md'} do
  assert(index:find(name,1,true),'docs/README missing maintained document '..name)
end

print('PASS docs', 1)
