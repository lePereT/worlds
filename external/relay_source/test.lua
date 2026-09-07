package.path='../../src/?.lua;../../src/?/init.lua;./?.lua;'..package.path
local Relay=require('relay'); local W=require('worlds'); local G=W.Geometry
local N=0; local function ok(x,m) N=N+1; assert(x,m or ('assertion '..N)) end; local function eq(a,b,m) N=N+1; assert(a==b,'#'..N..' '..(m or 'eq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function val(s,p) return s.theory[p] end
local function state_value(c,s,name)
  local rid=s.env[name]; local d=s.resources[rid]; assert(d,'not resource '..name); local role=c:state_role(d)
  local xs={}; for _,st in ipairs(s.geometry:egress()) do local pts=G.points(st); if pts[1]==role and pts[2]==rid then xs[#xs+1]=st end end
  assert(#xs==1,'expected one current state Strand'); return s.theory[G.points(xs[1])[3]]
end
local function compile(src) return Relay.compile_text(src) end

-- 1 pleasant surface: function generic, interface provider and effect handler share ordinary geometry/theory substrate.
do local c,ss=Relay.compile_file('examples/core.relay'); eq(#ss,1); local s=ss[1]; eq(s.env.c,s.env.same); eq(val(s,s.env.r),0); eq(val(s,s.env.answer),23); eq(state_value(c,s,'c'),0); ok(W.Generic==nil and W.Interface==nil and W.Effect==nil,'no lower source-form carriers') end
-- 2 higher-order provider requirement closes through ordinary provider composition.
do local c,ss=Relay.compile_file('examples/higher_order.relay'); eq(#ss,1); eq(val(ss[1],ss[1].env.result),0); eq(state_value(c,ss[1],'w'),0); local via=false; for _,e in ipairs(ss[1].trace) do if e.kind=='provider' and e.via and e.via>0 then via=true end end; ok(via) end
-- 3 multiple providers remain distinct exact source outcomes.
do local _,ss=Relay.compile_file('examples/dynamic_choice.relay'); eq(#ss,2); local v={}; for _,s in ipairs(ss) do v[val(s,s.env.result)]=true end; ok(v[0] and v[1]) end
-- 4 nested handler topology shadows outer source handler.
do local _,ss=Relay.compile_file('examples/nested_handlers.relay'); eq(#ss,1); eq(val(ss[1],ss[1].env.answer),20) end
-- 5 repeated calls create distinct fresh result identities.
do local _,ss=compile([[interface Reset
 op reset
end
resource Cell
 state CellState
 provides Reset.reset = 0
end
main
 let c = Cell(8)
 let a = Reset.reset(c)
 let b = Reset.reset(c)
end]]); eq(#ss,1); local s=ss[1]; eq(val(s,s.env.a),0); eq(val(s,s.env.b),0); ok(s.env.a~=s.env.b) end
-- 6 generic syntax remains source metadata only.
do local c=select(1,Relay.compile_file('examples/core.relay')); eq(c.functions.identity.generic,'T'); ok(W.Generic==nil) end
-- 7 cyclic provider requirement is Unknown, not Retry.
do local _,ss=Relay.compile_file('examples/cyclic_requirements.relay'); eq(#ss,1); ok(ss[1].unknown) end
-- 8 choice preserves known alternatives.
do local _,ss=compile([[interface Reset
 op reset
end
resource C
 state S
 provides Reset.reset = 0
 provides Reset.reset = 1
end
main
 let c = C(9)
 let r = choice(Reset.reset(c), 42)
end]]); eq(#ss,3); local v={}; for _,s in ipairs(ss) do v[val(s,s.env.r)]=true end; ok(v[0] and v[1] and v[42]) end
-- 9 old Fibers example: Retry fallback and failed and_then leave original state.
do local c,ss=Relay.compile_file('examples/fibers.relay'); eq(#ss,1); local s=ss[1]; eq(val(s,s.env.each_fallback),88); eq(val(s,s.env.rollback),99); eq(state_value(c,s,'d'),0) end
-- 10 each accepts independent resources and rejects duplicate scarce state.
do local c,ss=compile([[interface Up
 op up
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
end
main
 let a = Counter(0)
 let b = Counter(0)
 each(Up.up(a), Up.up(b))
end]]); eq(#ss,1); eq(state_value(c,ss[1],'a'),1); eq(state_value(c,ss[1],'b'),1)
local c2,bs=compile([[interface Up
 op up
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
end
main
 let a = Counter(0)
 let z = or_else(each(Up.up(a), Up.up(a)), 71)
end]]); eq(#bs,1); eq(val(bs[1],bs[1].env.z),71); eq(state_value(c2,bs[1],'a'),0) end
-- 11 together permits source-order-independent sibling state supply.
do local c,ss=compile([[interface Up
 op up
end
interface Down
 op down
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
 provides Down.down 1 -> 0
end
main
 let c = Counter(0)
 let r = together(Down.down(c), Up.up(c))
end]]); eq(#ss,1); eq(state_value(c,ss[1],'c'),0); eq(val(ss[1],ss[1].env.r),1) end
-- 12 same pair under each cannot borrow sibling-produced state.
do local c,ss=compile([[interface Up
 op up
end
interface Down
 op down
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
 provides Down.down 1 -> 0
end
main
 let c = Counter(0)
 let r = or_else(each(Down.down(c), Up.up(c)), 66)
end]]); eq(#ss,1); eq(val(ss[1],ss[1].env.r),66); eq(state_value(c,ss[1],'c'),0) end
-- 13 or_else must not turn bounded/open provider Unknown into Retry.
do local _,ss=Relay.compile_file('examples/fibers_unknown.relay'); eq(#ss,1); ok(ss[1].unknown); ok(ss[1].env.r==nil) end
-- 14 task lifetime is ordinary live Strand obligation; join consumes it.
do local c,ss=compile([[fn identity[T](x) = x
main
 let x = 7
 let t = spawn(identity(x))
 let y = join(t)
end]]); eq(#ss,1); eq(val(ss[1],ss[1].env.y),7); ok(c:can_retire(ss[1])) end
-- 15 unjoined task prevents retirement.
do local c,ss=compile([[fn identity[T](x) = x
main
 let x = 7
 let t = spawn(identity(x))
end]]); eq(#ss,1); ok(not c:can_retire(ss[1])) end
-- 16 together quotients independent execution schedule multiplicity at source outcome.
do local _,ss=compile([[interface Up
 op up
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
end
main
 let a = Counter(0)
 let b = Counter(0)
 let r = together(Up.up(a), Up.up(b))
end]]); eq(#ss,1) end
-- 17 losing provisional spawn does not admit task obligation.
do local c,ss=compile([[interface Missing
 op missing
end
fn identity[T](x) = x
main
 let x = 7
 let r = or_else(and_then(spawn(identity(x)), Missing.missing(x)), 55)
end]]); eq(#ss,1); eq(val(ss[1],ss[1].env.r),55); ok(c:can_retire(ss[1])) end
-- 18 known choice Hit may survive an Unknown alternative.
do local _,ss=compile([[interface A
 op a
end
interface B
 op b
end
resource Loop
 state LoopState
 provides A.a via B.b
 provides B.b via A.a
end
main
 let x = Loop(0)
 let r = choice(A.a(x), 314)
end]]); eq(#ss,1); eq(val(ss[1],ss[1].env.r),314) end
-- 19 three-stage state chain is discovered irrespective of source lane order.
do local c,ss=compile([[interface A
 op a
end
interface B
 op b
end
interface C
 op c
end
resource Cycle
 state CycleState
 provides A.a 0 -> 1
 provides B.b 1 -> 2
 provides C.c 2 -> 0
end
main
 let x = Cycle(0)
 let r = together(C.c(x), B.b(x), A.a(x))
end]]); eq(#ss,1); eq(state_value(c,ss[1],'x'),0) end
-- 20 failure after successful together remains provisional under and_then.
do local c,ss=compile([[interface Up
 op up
end
interface Down
 op down
end
interface Missing
 op missing
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
 provides Down.down 1 -> 0
end
main
 let c = Counter(0)
 let r = or_else(and_then(together(Down.down(c), Up.up(c)), Missing.missing(c)), 707)
end]]); eq(#ss,1); eq(val(ss[1],ss[1].env.r),707); eq(state_value(c,ss[1],'c'),0) end
-- 21 dependent and_then carries the provisional result identity through `_`.
do local _,ss=compile([[interface Up
 op up
end
resource Counter
 state CounterState
 provides Up.up 0 -> 1
end
fn identity[T](x) = x
main
 let c = Counter(0)
 let r = and_then(Up.up(c), identity(_))
end]]); eq(#ss,1); eq(val(ss[1],ss[1].env.r),1) end
print('PASS external relay_source',N,'assertions')
