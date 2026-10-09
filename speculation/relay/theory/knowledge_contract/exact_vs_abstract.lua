local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function entails(a,b) local yes,why=K.entails(a,b); assert(why==nil,why); return yes end

local ctx={'x','y','z'}
local exact=R.relation(ctx,function(v) return v.x==v.y and v.y==v.z end)
local public=K.exists(exact,{'x','z'})
local xeqz=R.relation({'x','z'},function(v) return v.x==v.z end)
ok(entails(public,xeqz) and entails(xeqz,public),'exact doctrine lost public correlation')

-- Deliberately coarse non-relational abstraction: retain only per-coordinate values.
local function alpha(rel)
  local ctx2=K.context(rel)
  local out={ctx=ctx2,poss={}}
  for _,v in ipairs(ctx2) do out.poss[v]={} end
  for _,row in ipairs(R.rows(rel)) do
    for i,v in ipairs(ctx2) do out.poss[v][row:sub(i,i)]=true end
  end
  return out
end
local function gamma(a)
  return R.relation(a.ctx,function(env)
    for _,v in ipairs(a.ctx) do if not a.poss[v][tostring(env[v])] then return false end end
    return true
  end)
end
local function project_abs(a,keep)
  local out={ctx=keep,poss={}}
  for _,v in ipairs(keep) do out.poss[v]=a.poss[v] end
  return out
end

local abstract=alpha(exact)
local abstract_public=gamma(project_abs(abstract,{'x','z'}))
ok(entails(public,abstract_public),'coarse projection was not a sound over-approximation')
ok(not entails(abstract_public,xeqz),'coarse abstraction spuriously proved hidden correlation')
ok(entails(public,xeqz),'exact semantic consequence missing')
ok(not entails(abstract_public,xeqz),'abstract solver unexpectedly complete')

print('exact vs abstract: '..n..' assertions passed')
