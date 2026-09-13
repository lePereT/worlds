-- Worlds 0.6.0 speculative multiplicative-linear-logic/process model.
-- This models the structural multiplicative/linear skeleton (closer to MILL / a
-- symmetric monoidal process category) rather than claiming full MLL with par
-- and negation already derived.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S=require('speculation.support')
local W=S.W
local G=S.G
local A=S.A
local O=S.O

local function ok(x,msg) assert(x,msg) end
local function eq(a,b,msg) assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

-- Rigid atomic proposition vocabulary.
local vb=G.builder(); local vm=vb:membrane(nil,'logic-vocabulary')
local PA=vb:point(vm,'A'); local PB=vb:point(vm,'B'); local PC=vb:point(vm,'C'); local PD=vb:point(vm,'D')
vb:finish()

local function atom_name(s) return G.name(G.points(s)[1]) end
local function boundary_multiset(g,which)
  local xs=(which=='in') and g:ingress() or g:egress()
  local c={}
  for _,s in ipairs(xs) do local n=atom_name(s); c[n]=(c[n] or 0)+1 end
  return c
end
local function same_multiset(a,b)
  for k,v in pairs(a) do if b[k]~=v then return false end end
  for k,v in pairs(b) do if a[k]~=v then return false end end
  return true
end

-- Identity proof/process A |- A is literally one open Strand: no rule node.
local function identity(P,label)
  local b=G.builder(); local r=b:membrane(nil,label or ('Id '..G.name(P)))
  local s=b:strand(r,{P},'identity')
  return b:finish(),s
end

-- Primitive linear implication/process A -> B is a Face consuming one A
-- occurrence and producing one B occurrence.
local function arrow(P,Q,label)
  local b=G.builder(); local r=b:membrane(nil,label or (G.name(P)..'->'..G.name(Q)))
  local i=b:strand(r,{P},'in '..G.name(P)); local o=b:strand(r,{Q},'out '..G.name(Q))
  b:face(r,{i},{o},label or 'rule')
  return b:finish(),i,o
end

local IdA,idA=identity(PA,'IdA')
local IdB,idB=identity(PB,'IdB')
local F,fi,fo=arrow(PA,PB,'f:A->B')
local Gp,gi,go=arrow(PB,PC,'g:B->C')
local Hp,hi,ho=arrow(PC,PD,'h:C->D')

-- 1. Identity/cut law: composing Id_A with f introduces no extra Face and
--    leaves the same external A -> B interface.
do
  local c,img=A.close({IdA,F},{{idA,fi}})
  eq(#c:faces(),1,'left identity adds no rule occurrence')
  local ins=boundary_multiset(c,'in'); local outs=boundary_multiset(c,'out')
  eq(ins.A,1); eq(outs.B,1)
  eq(#c:ingress(),1); eq(#c:egress(),1)
end

do
  local c=A.close({F,IdB},{{fo,idB}})
  eq(#c:faces(),1,'right identity adds no rule occurrence')
  local ins=boundary_multiset(c,'in'); local outs=boundary_multiset(c,'out')
  eq(ins.A,1); eq(outs.B,1)
end

-- 2. Cut/composition hides the intermediate formula occurrence from the open
--    boundary. f:A->B cut with g:B->C yields A->C externally.
do
  local fg,img=A.close({F,Gp},{{fo,gi}})
  eq(#fg:faces(),2,'proof history retains both rule Faces')
  eq(#fg:ingress(),1); eq(#fg:egress(),1)
  local ins=boundary_multiset(fg,'in'); local outs=boundary_multiset(fg,'out')
  eq(ins.A,1); eq(outs.C,1); eq(ins.B,nil); eq(outs.B,nil)
end

-- 3. Cut-family presentation order is irrelevant. The two ways of listing
--    internal cuts in A->B->C->D expose the same formula boundary and face count.
do
  local c1=A.close({F,Gp,Hp},{{fo,gi},{go,hi}})
  local c2=A.close({F,Gp,Hp},{{go,hi},{fo,gi}})
  eq(#c1:faces(),3); eq(#c2:faces(),3)
  ok(same_multiset(boundary_multiset(c1,'in'),boundary_multiset(c2,'in')),'cut order ingress')
  ok(same_multiset(boundary_multiset(c1,'out'),boundary_multiset(c2,'out')),'cut order egress')
  eq(boundary_multiset(c1,'in').A,1); eq(boundary_multiset(c1,'out').D,1)
end

-- 4. Multiplicative tensor is literally Worlds tensor/juxtaposition. f⊗g has
--    independent A,B inputs and B,C outputs; no scheduling relation is added.
do
  local t=A.tensor({F,Gp})
  eq(#t:faces(),2); eq(#t:ingress(),2); eq(#t:egress(),2)
  local ins=boundary_multiset(t,'in'); local outs=boundary_multiset(t,'out')
  eq(ins.A,1); eq(ins.B,1); eq(outs.B,1); eq(outs.C,1)
end

-- 5. Exchange is structural rather than a rule. Tensor order has no semantic
--    effect on the open formula multiset.
do
  local fg=A.tensor({F,Gp})
  local gf=A.tensor({Gp,F})
  ok(same_multiset(boundary_multiset(fg,'in'),boundary_multiset(gf,'in')),'tensor exchange ingress')
  ok(same_multiset(boundary_multiset(fg,'out'),boundary_multiset(gf,'out')),'tensor exchange egress')
end

-- 6. No implicit contraction. A rule requiring two A assumptions cannot be
--    grounded by one exact A authority because Cut is injective.
local db=G.builder(); local dr=db:membrane(nil,'two-A-demand')
local da1=db:strand(dr,{PA},'A1'); local da2=db:strand(dr,{PA},'A2'); local dout=db:strand(dr,{PB},'B')
db:face(dr,{da1,da2},{dout},'A,A -> B')
local TWO_A=db:finish()
do
  local ib=G.builder(); local ir=ib:membrane(nil,'assumptions'); local oneA=ib:strand(ir,{PA},'one A'); local live=O.from_geometry(ib:finish())
  eq(O.one(live,TWO_A,{offers={oneA}}),nil,'one A cannot contract into two assumptions')
end

-- 7. No implicit weakening. Tensoring an unused C identity with f does not make
--    C vanish: it remains both ingress and egress. To discard C one must provide
--    an explicit C->I Face/generator.
do
  local IdC,idC=identity(PC,'IdC')
  local t=A.tensor({F,IdC})
  local ins=boundary_multiset(t,'in'); local outs=boundary_multiset(t,'out')
  eq(ins.A,1); eq(ins.C,1); eq(outs.B,1); eq(outs.C,1)
  eq(#t:ingress(),2); eq(#t:egress(),2)
end

-- 8. But copy/drop can be explicitly postulated as processes. Hence Worlds
--    derives *structural* linearity of composition, not a complete linear logic
--    by itself. Domain logic/Theory decides which generators are lawful.
do
  local cb=G.builder(); local cr=cb:membrane(nil,'explicit-copy')
  local ci=cb:strand(cr,{PA},'A'); local co1=cb:strand(cr,{PA},'A1'); local co2=cb:strand(cr,{PA},'A2')
  cb:face(cr,{ci},{co1,co2},'explicit contraction-like generator')
  local COPY=cb:finish()
  local ib=G.builder(); local ir=ib:membrane(nil,'source'); local a=ib:strand(ir,{PA},'A'); local live=O.from_geometry(ib:finish())
  local w=O.one(live,COPY,{strands={[ci]=a}}); ok(w,'explicit copy Face is structurally lawful unless Theory forbids it')
  O.commit(w); eq(live:size(),2,'explicit Face produces two fresh scarce occurrences')
end

-- 9. Operational cut elimination / boundary sufficiency: execute f then g on a
--    single live A. The intermediate B exists only as the transient boundary;
--    after g the future-relevant boundary is exactly C.
do
  local ib=G.builder(); local ir=ib:membrane(nil,'runtime'); local a=ib:strand(ir,{PA},'A'); local live=O.from_geometry(ib:finish())
  local wf=O.one(live,F,{strands={[fi]=a}}); ok(wf); local _,imf=O.commit(wf); local b=imf.strands[fo]
  eq(live:size(),1); eq(G.points(b)[1],PB)
  local wg=O.one(live,Gp,{strands={[gi]=b}}); ok(wg); local _,img=O.commit(wg); local c=img.strands[go]
  eq(live:size(),1); eq(G.points(c)[1],PC)
end

print('Worlds linear-logic toy: PASS')
print('NOTE: kernel gives multiplicative/resource process structure; par/negation/exponentials are not yet derived here.')
