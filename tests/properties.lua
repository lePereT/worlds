package.path='./src/?.lua;'..package.path
local Model=require('model'); local Audit=require('audit'); local Federation=require('federation')
local Completion=require('completion'); local Choice=require('choice_normalise')

local passed=0
local function test(name,f)
  io.write(string.format('%-92s ',name)); local ok,err=pcall(f)
  if not ok then print('FAIL'); error(err,0) end
  passed=passed+1; print('ok')
end
local function eq(a,b,msg) assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
local function ne(a,b,msg) assert(a~=b,msg or (tostring(a)..' == '..tostring(b))) end
local function expect_fail(f,pat) local ok,e=pcall(f); assert(not ok,'expected failure'); if pat then assert(tostring(e):match(pat),tostring(e)) end end

-- ---------------------------------------------------------------------------
-- World completion / retirement
-- ---------------------------------------------------------------------------

test('1. retained hidden authority keeps a World non-retirable without adding a closed/live bit',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('W',m.actuality); local held=m:strand('held',W,{X},'State')
  local status,res=Completion.status(m,W); eq(status,'live-or-residual'); eq(res[1],held)
  local ok,why=Completion.can_retire(m,W); assert(not ok and why:match('resident authority'))
end)

test('2. explicit discard consumption makes the same World geometrically retirable',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('W',m.actuality); local held=m:strand('held',W,{X},'State'); m:discard('drop',W,held,'structural')
  local ok,why=Audit.check(m); assert(ok,why); assert(Completion.can_retire(m,W))
end)

test('3. authority transported out across the membrane does not block retirement of the source World',function()
  local m=Model.new('O'); local O=m.actuality; local X=m:point('X',O,'X'); local Parent=m:world('Parent',O); local W=m:world('Child',Parent)
  local x=m:strand('x',W,{X},'R'); local y=m:strand('y',Parent,{X},'R'); m:face('return',W,{x},{y},'Transport')
  assert(Completion.can_retire(m,W)); local eg=Completion.egress(m,W); eq(#eg,1); eq(eg[1].strand,y)
end)

test('4. retirement is subtree-local: residual authority in a realised child prevents retiring its ancestor',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local P=m:world('P',m.actuality); local C=m:world('C',P); local x=m:strand('x',C,{X},'R')
  assert(not Completion.can_retire(m,P)); m:discard('drop',C,x,'structural'); assert(Completion.can_retire(m,P))
end)

test('5. no automatic leak oracle is invented: the same residual geometry is merely non-retirable until an exit is attempted',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('stateful',m.actuality); m:strand('state',W,{X},'State')
  eq(Completion.status(m,W),'live-or-residual'); expect_fail(function() Completion.require_retirable(m,W) end,'resident authority')
end)

-- ---------------------------------------------------------------------------
-- Choice normalisation
-- ---------------------------------------------------------------------------

local function spec_basic()
  return {
    resources={{name='r',epsilon=true,delta=true},{name='s',epsilon=true,delta=false}},
    arms={
      {name='left', uses={r=0,s=1}},
      {name='middle',uses={r=1,s=1}},
      {name='right', uses={r=2,s=0}},
    }
  }
end

test('6. old min/max path criterion normalises to certified competing detached stages with copy/discard',function()
  local spec=spec_basic(); assert(Choice.reference_valid(spec)); local x,why=Choice.build(spec); assert(x,why); local ok,cwhy=Choice.certify(x); assert(ok,cwhy)
end)

test('7. every normalised arm consumes each original scarce resource exactly once on the chosen actual path',function()
  local spec=spec_basic()
  for _,name in ipairs({'left','middle','right'}) do
    local r,why=Choice.run_arm(spec,name); assert(r,why); eq(r.uses.r,1,name..' r'); eq(r.uses.s,1,name..' s')
  end
end)

test('8. a generic open-identity join preserves whichever fresh branch identity actually occurred; no phi metadata',function()
  local r=assert(Choice.run_arm(spec_basic(),'right')); eq(r.join.map[r.x.join.q],r.branch.map[r.x.arms.right.qi])
end)

test('9. a zero-use path without discard permission is rejected before geometric normalisation',function()
  local spec={resources={{name='r',epsilon=false,delta=true}},arms={{name='a',uses={r=0}},{name='b',uses={r=1}}}}
  local ok,why=Choice.reference_valid(spec); assert(not ok and why:match('EPSILON')); assert(Choice.build(spec)==nil)
end)

test('10. a multi-use path without copy permission is rejected before geometric normalisation',function()
  local spec={resources={{name='r',epsilon=true,delta=false}},arms={{name='a',uses={r=1}},{name='b',uses={r=2}}}}
  local ok,why=Choice.reference_valid(spec); assert(not ok and why:match('DELTA')); assert(Choice.build(spec)==nil)
end)

-- ---------------------------------------------------------------------------
-- Candidate theorem regressions
-- ---------------------------------------------------------------------------

local function simple_archetype(m,F,prefix)
  local D=m:world(prefix..'D'); local G=m:world(prefix..'G'); local gate=m:strand(prefix..'gate',D,{F},prefix..'A'); local q=m:point(prefix..'q',G,'Fresh'); local out=m:strand(prefix..'out',G,{F,q},prefix..'O'); local body=m:face(prefix..'body',G,{gate},{out},prefix..'B'); return {gate=gate,G=G,q=q,out=out,body=body}
end

test('11. LOCALITY: developing in W leaves an unrelated actual sibling World byte-for-byte unchanged in cells and use counts',function()
  local m=Model.new('O'); local F=m:point('F',m.actuality,'F'); simple_archetype(m,F,'a')
  local W=m:world('W',m.actuality); local U=m:world('U',m.actuality); local f=m:strand('f',W,{F},'aA'); local u=m:strand('u',U,{F},'Unrelated')
  local before={objects=#m.objects,uses=m:_realised_uses(u),children=#m:_children(U)}; m:develop(f)
  eq(m:_realised_uses(u),before.uses); eq(#m:_children(U),before.children); eq(u.world,U)
end)

test('12. FRESHNESS: two developments preserve shared schema identity but generate distinct Worlds, Points and authority',function()
  local m=Model.new('O'); local F=m:point('F',m.actuality,'F'); local a=simple_archetype(m,F,'a'); local W1=m:world('W1',m.actuality); local W2=m:world('W2',m.actuality)
  local f1=m:strand('f1',W1,{F},'aA'); local f2=m:strand('f2',W2,{F},'aA'); local i1=m:develop(f1); local i2=m:develop(f2)
  ne(i1.map[a.G],i2.map[a.G]); ne(i1.map[a.q],i2.map[a.q]); ne(i1.map[a.out],i2.map[a.out]); assert(m:same_point(i1.map[a.out].points[1],F)); assert(m:same_point(i2.map[a.out].points[1],F))
end)

local function commute_signature(reverse)
  local m=Model.new('O'); local F=m:point('F',m.actuality,'F'); simple_archetype(m,F,'a'); simple_archetype(m,F,'b')
  local A=m:world('A',m.actuality); local B=m:world('B',m.actuality); local fa=m:strand('fa',A,{F},'aA'); local fb=m:strand('fb',B,{F},'bA')
  if reverse then m:develop(fb); m:develop(fa) else m:develop(fa); m:develop(fb) end
  local faces,world_origins={},{}
  for _,o in ipairs(m.objects) do if o.dim==2 and m:is_realised(o) then faces[#faces+1]=o.sort end end
  for _,w in ipairs(m.worlds) do if m:is_realised(w) and w.origin then world_origins[#world_origins+1]=w.origin.name end end
  table.sort(faces); table.sort(world_origins)
  return table.concat(faces,'|')..' :: '..table.concat(world_origins,'|')..' :: '..m:_realised_uses(fa)..':'..m:_realised_uses(fb)
end

test('13. NON-INTERFERENCE: resource-disjoint developments commute up to fresh naming/order',function() eq(commute_signature(false),commute_signature(true)) end)

test('14. NON-INTERFERENCE boundary: developments competing for the same scarce local supply cannot both silently succeed',function()
  local m=Model.new('O'); local F=m:point('F',m.actuality,'F'); local R=m:point('R',m.actuality,'R')
  local function arch(prefix)
    local Dg=m:world(prefix..'Dg'); local Dr=m:world(prefix..'Dr'); local G=m:world(prefix..'G'); local gate=m:strand(prefix..'g',Dg,{F},prefix..'A'); local rq=m:strand(prefix..'r?',Dr,{R},'R'); local out=m:strand(prefix..'o',G,{F},prefix..'O'); m:face(prefix..'b',G,{gate,rq},{out},prefix..'B')
  end
  arch('a'); arch('b'); local W=m:world('W',m.actuality); local r=m:strand('r',W,{R},'R'); local fa=m:strand('fa',W,{F},'aA'); local fb=m:strand('fb',W,{F},'bA'); m:develop(fa); expect_fail(function() m:develop(fb) end,'no local realised supply')
end)

test('15. CUSTODY: cross-carrier Point identity may glue literally while provider Strand authority never enters client local supply',function()
  local p=Model.new('P'); local Fp=p:point('F',p.actuality,'F'); local D=p:world('D'); local G=p:world('G'); local gate=p:strand('g',D,{Fp},'A'); local po=p:strand('po',G,{Fp},'O'); p:face('pb',G,{gate},{po},'B')
  local c=Model.new('C'); local Fc=c:point('F',c.actuality,'F'); local link=Federation.link(p,gate,c); assert(c:same_point(Fp,Fc)); local PW=p:world('PW',p.actuality); local secret=p:strand('secret',PW,{Fp},'Secret')
  local CW=c:world('CW',c.actuality); local f=c:strand('f',CW,{Fc},'A'); for _,o in ipairs(c:_offer_pool(f)) do assert(o~=secret) end; link:develop(f); eq(p:_realised_uses(secret),0)
end)

test('16. suspended-stage certification plus actual audit use the same scarcity/provenance geometry on opposite sides of grafting',function()
  local spec=spec_basic(); local x=assert(Choice.build(spec)); local ok,why=Choice.certify(x); assert(ok,why); local r=assert(Choice.run_arm(spec,'middle')); local aok,awhy=Audit.check(r.x.model); assert(aok,awhy)
end)

test('17. CONSERVATION: a locally balanced realised causal cycle is rejected because it has no provenance source',function()
  local m=Model.new('O'); local X=m:point('X',m.actuality,'X'); local W=m:world('W',m.actuality)
  local a=m:strand('a',W,{X},'R'); local b=m:strand('b',W,{X},'S'); m:face('f',W,{a},{b},'F'); m:face('g',W,{b},{a},'G')
  local ok,why=Audit.check(m); assert(not ok and why:match('causality'),tostring(why)); assert(Completion.can_retire(m,W)) -- retirement alone is insufficient; certification supplies the global law
end)

test('18. CONSERVATION: ordinary recursive unfolding remains acyclic because each step produces fresh occurrences',function()
  local m=Model.new('O'); local F=m:point('F',m.actuality,'F'); local S=m:point('S',m.actuality,'S')
  local Dg=m:world('Dg'); local Ds=m:world('Ds'); local G=m:world('G'); local gate=m:strand('f?',Dg,{F},'FA'); local sq=m:strand('s?',Ds,{S},'State'); local nf=m:strand('nf',G,{F},'FA'); local ns=m:strand('ns',G,{S},'State'); m:face('step',G,{gate,sq},{nf,ns},'Step')
  local W=m:world('W',m.actuality); local f=m:strand('f0',W,{F},'FA'); local st=m:strand('s0',W,{S},'State'); local i1=m:develop(f); local i2=m:develop(i1.map[nf]); local ok,why=Audit.check(m); assert(ok,why); ne(i1.map[nf],i2.map[nf])
end)

test('19. CANCELLATION: discard consumes pending authority and leaves its detached future suspended rather than partially realising it',function()
  local m=Model.new('O'); local F=m:point('F',m.actuality,'F'); local a=simple_archetype(m,F,'cancel'); local W=m:world('W',m.actuality); local f=m:strand('f',W,{F},'cancelA'); m:discard('cancel',W,f,'structural')
  expect_fail(function() m:develop(f) end,'already been consumed'); assert(m:is_suspended(a.G)); local ok,why=Audit.check(m); assert(ok,why)
end)

test('20. DEADLOCK: sibling Worlds cannot satisfy each other by hidden matching; explicit transport is required to make both developments local',function()
  local m=Model.new('O'); local O=m.actuality; local F=m:point('F',O,'F'); local Gp=m:point('G',O,'G'); local R=m:point('R',O,'R'); local S=m:point('S',O,'S')
  local function arch(prefix,Id,Need,gateSort,needSort)
    local Dg=m:world(prefix..'Dg'); local Dn=m:world(prefix..'Dn'); local Gw=m:world(prefix..'Gw'); local gate=m:strand(prefix..'?',Dg,{Id},gateSort); local need=m:strand(prefix..'need?',Dn,{Need},needSort); local out=m:strand(prefix..'out',Gw,{Id},prefix..'Out'); m:face(prefix..'body',Gw,{gate,need},{out},prefix..'Body'); return gate
  end
  arch('a',F,R,'FA','R'); arch('b',Gp,S,'GA','S')
  local WA=m:world('WA',O); local WB=m:world('WB',O); local fa=m:strand('fa',WA,{F},'FA'); local sb=m:strand('s-in-A',WA,{S},'S'); local gb=m:strand('gb',WB,{Gp},'GA'); local rb=m:strand('r-in-B',WB,{R},'R')
  expect_fail(function() m:develop(fa) end,'no local realised supply'); expect_fail(function() m:develop(gb) end,'no local realised supply')
  local ra=m:strand('r-in-A',WA,{R},'R'); local sb2=m:strand('s-in-B',WB,{S},'S'); m:face('move-r',WB,{rb},{ra},'Transport'); m:face('move-s',WA,{sb},{sb2},'Transport')
  m:develop(fa); m:develop(gb); local ok,why=Audit.check(m); assert(ok,why)
end)

print(string.format('%d/%d formal/normalisation tests passed',passed,passed))
