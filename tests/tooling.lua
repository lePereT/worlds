-- The top-level developer interface is part of the maintained bootstrap.
-- These checks prevent release/documentation edits from silently changing how
-- Worlds selects Lua or which gate a plain `make`/`make test` runs.

local function read(path)
  local f=assert(io.open(path,'rb')); local s=assert(f:read('*a')); f:close(); return s
end

local make=read('../Makefile')
local assertions=0
local function ok(x,msg) assertions=assertions+1; assert(x,msg or ('tooling assertion '..assertions)) end

ok(make:find('LUA_CANDIDATES := luajit lua lua5.4 lua5.3 texlua',1,true),
   'ordered Lua selection changed')
ok(make:find('LUA ?= $(shell',1,true),'Lua selection must permit explicit LUA override')
ok(make:find('No Lua interpreter found. Tried: $(LUA_CANDIDATES)',1,true),
   'missing hard error when no Lua interpreter is available')
ok(make:find('.DEFAULT_GOAL := test',1,true),'plain make must run the complete test gate')
ok(make:match('\ntest:%s*check%s*\n'),'make test must run the complete check gate')
ok(make:match('\ncheck:%s*docs tooling architecture laws torture differential whole shape external%s*\n'),
   'check gate lost a maintained test family')
ok(make:find('\ndoctor:',1,true),'doctor target missing')

local docs=read('docs.lua')
ok(not docs:find('-printf',1,true),'docs test must not require GNU find -printf')


-- Generated tests must not depend on VM-specific math.random sequences.
do
  local p=assert(io.popen("find . -type f -name '*.lua' -print"))
  for path in p:lines() do
    if path~='./tooling.lua' then
      local f=assert(io.open(path,'rb')); local src=f:read('*a'); f:close()
      ok(not src:find('math.random',1,true),path..' uses runtime-specific math.random; use tests/prng.lua')
    end
  end
  assert(p:close())
end
print('PASS tooling',assertions,'assertions')
