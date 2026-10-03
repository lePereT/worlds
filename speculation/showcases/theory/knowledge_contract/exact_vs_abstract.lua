local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end

local ctx={'x','y','z'}
local exact=R.relation(ctx,function(v) return v.x==v.y and v.y==v.z end)
local public=R.exists(exact,{'x','z'})
local xeqz=R.relation({'x','z'},function(v) return v.x==v.z end)
ok(R.leq(public,xeqz) and R.leq(xeqz,public),'exact doctrine lost public correlation')

-- Deliberately coarse non-relational abstraction: for each coordinate retain only
-- which individual values remain possible; all correlations are forgotten.
local function alpha(rel)
  local out={ctx=rel.ctx,poss={}}
  for i,v in ipairs(rel.ctx) do out.poss[v]={} end
  for row in pairs(rel.rows) do
    for i,v in ipairs(rel.ctx) do out.poss[v][row:sub(i,i)]=true end
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
ok(R.leq(public,abstract_public),'coarse projection was not a sound over-approximation')
ok(not R.leq(abstract_public,xeqz),'coarse abstraction spuriously proved hidden correlation')

-- Therefore exact semantic Unknown must not be conflated with implementation
-- inability to prove. The exact doctrine entails x=z; the abstraction simply cannot see it.
ok(R.leq(public,xeqz),'exact semantic consequence missing')
ok(not R.leq(abstract_public,xeqz),'abstract solver unexpectedly complete')

print('exact vs abstract: '..n..' assertions passed')
