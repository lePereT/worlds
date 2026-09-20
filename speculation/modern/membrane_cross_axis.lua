-- Worlds 0.6.2 membrane pressure test: one laminar support tree cannot make two
-- crossing classifications simultaneously structural enclosing contexts.

package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local Q=require('worlds.query')

local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function solve_one(world, pattern, sources, targets)
  local admissible={}
  for _,s in ipairs(sources) do for _,t in ipairs(targets) do admissible[#admissible+1]={from=s,to=t} end end
  local q=Q.match(world,pattern,{sources=sources,targets=targets,required_sources=sources,required_targets=targets,admissible=admissible})
  local solver=Q.solve(q)
  while true do
    local tag,e=solver:step(math.huge)
    if tag~='more' then return tag,e end
  end
end

local function shared_parent_pattern(name)
  local b=W.builder(); local r=b:membrane(nil,name..'.root'); local common=b:membrane(r,name..'.common')
  local c1=b:membrane(common,name..'.left'); local c2=b:membrane(common,name..'.right')
  local d1=b:strand(c1,{},name..'.d1'); local d2=b:strand(c2,{},name..'.d2')
  return b:finish(),{common=common,d1=d1,d2=d2}
end

local function host_first()
  local b=W.builder(); local root=b:membrane(nil,'root')
  local H1=b:membrane(root,'H1'); local H2=b:membrane(root,'H2')
  local H1R=b:membrane(H1,'H1/R'); local H1B=b:membrane(H1,'H1/B')
  local H2R=b:membrane(H2,'H2/R'); local H2B=b:membrane(H2,'H2/B')
  local s={H1R=b:strand(H1R,{},'H1R'),H1B=b:strand(H1B,{},'H1B'),H2R=b:strand(H2R,{},'H2R'),H2B=b:strand(H2B,{},'H2B')}
  return b:finish(),s,{H1=H1,H2=H2}
end

local function security_first()
  local b=W.builder(); local root=b:membrane(nil,'root')
  local R=b:membrane(root,'R'); local B=b:membrane(root,'B')
  local RH1=b:membrane(R,'R/H1'); local RH2=b:membrane(R,'R/H2')
  local BH1=b:membrane(B,'B/H1'); local BH2=b:membrane(B,'B/H2')
  local s={H1R=b:strand(RH1,{},'H1R'),H2R=b:strand(RH2,{},'H2R'),H1B=b:strand(BH1,{},'H1B'),H2B=b:strand(BH2,{},'H2B')}
  return b:finish(),s,{R=R,B=B}
end

local pat,p=shared_parent_pattern('pair')
local wh,sh,mh=host_first()
local tag_host,eq_host=solve_one(wh,pat,{sh.H1R,sh.H1B},{p.d1,p.d2})
eq(tag_host,'yes','host-first tree recognises common host')
local _,ih=W.join({W.boundary(wh),pat},eq_host)
eq(ih[p.common],mh.H1,'common target support maps to H1')
local tag_red=solve_one(wh,pat,{sh.H1R,sh.H2R},{p.d1,p.d2})
eq(tag_red,'no','host-first tree cannot also make Red a crossing common parent')

local ws,ss,ms=security_first()
local tag_sec,eq_sec=solve_one(ws,pat,{ss.H1R,ss.H2R},{p.d1,p.d2})
eq(tag_sec,'yes','security-first tree recognises common security')
local _,is=W.join({W.boundary(ws),pat},eq_sec)
eq(is[p.common],ms.R,'common target support maps to R')
local tag_h1=solve_one(ws,pat,{ss.H1R,ss.H1B},{p.d1,p.d2})
eq(tag_h1,'no','security-first tree cannot also make H1 a crossing common parent')

-- The desired sets genuinely cross rather than nest or separate.
local H1={H1R=true,H1B=true}; local RED={H1R=true,H2R=true}
local function subset(a,b) for x in pairs(a) do if not b[x] then return false end end; return true end
local function disjoint(a,b) for x in pairs(a) do if b[x] then return false end end; return true end
ok(not subset(H1,RED) and not subset(RED,H1) and not disjoint(H1,RED),'crossing classes are non-laminar')

-- Escape hatch: if the Red classification is external policy/structure rather
-- than causal enclosing support, independent target roots may map to the pair.
local b=W.builder(); local a=b:membrane(nil,'policy.a'); local c=b:membrane(nil,'policy.b')
local d1=b:strand(a,{},'d1'); local d2=b:strand(c,{},'d2'); local independent=b:finish()
local tag_policy=solve_one(wh,independent,{sh.H1R,sh.H2R},{d1,d2})
eq(tag_policy,'yes','cross-host Red pair is admissible when no common membrane is asserted')

print('modern membrane cross-axis: '..n..' assertions passed')
