-- Worlds 0.6.1 speculative chemistry model
-- Open compartmental reaction networks over exact scarce molecule authority.

package.path = './src/?.lua;./src/?/init.lua;' .. package.path
local S=require('speculation.support')
local W=S.W
local G=S.G
local O=S.O
local A=S.A

local function ok(x,msg) assert(x,msg) end
local function eq(a,b,msg) assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

-- Rigid chemical vocabulary: species are Theory/domain identities, not molecule identity.
local vb=G.builder(); local vm=vb:membrane(nil,'chemical-vocabulary')
local SA=vb:point(vm,'species:A')
local SB=vb:point(vm,'species:B')
local SC=vb:point(vm,'species:C')
local SD=vb:point(vm,'species:D')
local SE=vb:point(vm,'species:E')
local SITE=vb:point(vm,'transport-site')
vb:finish()

-- Build an exact vessel boundary. Each molecule is one scarce Strand occurrence.
local function vessel(species_by_compartment)
  local b=G.builder(); local root=b:membrane(nil,'vessel')
  local membranes={}
  local strands={}
  for comp,items in pairs(species_by_compartment) do
    local m=b:membrane(root,comp); membranes[comp]=m; strands[comp]={}
    for i,p in ipairs(items) do strands[comp][i]=b:strand(m,{p},comp..':'..G.name(p)..':'..i) end
  end
  local g=b:finish()
  return g,O.from_geometry(g),root,membranes,strands
end

-- Local elementary reaction 2A + B -> C. All reactants and product share one
-- relative local reaction membrane. Cut therefore requires co-local offers.
local rb=G.builder(); local rr=rb:membrane(nil,'reaction-context'); local rc=rb:membrane(rr,'local-compartment')
local rA1=rb:strand(rc,{SA},'A1')
local rA2=rb:strand(rc,{SA},'A2')
local rB =rb:strand(rc,{SB},'B')
local rC =rb:strand(rc,{SC},'C')
rb:face(rc,{rA1,rA2,rB},{rC},'2A+B->C')
local R1=rb:finish()

-- C + D -> E, similarly local.
local sb=G.builder(); local sr=sb:membrane(nil,'reaction-context'); local sc=sb:membrane(sr,'local-compartment')
local sC=sb:strand(sc,{SC},'C')
local sD=sb:strand(sc,{SD},'D')
local sE=sb:strand(sc,{SE},'E')
sb:face(sc,{sC,sD},{sE},'C+D->E')
local R2=sb:finish()

-- 1. Stoichiometric scarcity: one exact A cannot satisfy two A demands.
do
  local _,live,_,_,s=vessel({cell={SA,SB}})
  eq(O.one(live,R1,{offers={s.cell[1],s.cell[2]}}),nil,'one A cannot satisfy 2A+B')
end

-- 2. Two A + B in one compartment is executable and consumes exactly those
--    molecule occurrences, producing one new C authority in that compartment.
do
  local _,live,_,m,s=vessel({cell={SA,SA,SB}})
  local w=O.one(live,R1,{offers={s.cell[1],s.cell[2],s.cell[3]}})
  ok(w,'2A+B should react')
  eq(w:membrane(rc),m.cell,'reaction local membrane must map to the cell')
  local _,img=O.commit(w)
  eq(live:size(),1,'three reactants replaced by one product')
  local c=img.strands[rC]; ok(live:contains(c),'C must be live')
  eq(G.points(c)[1],SC,'product species C')
  eq(G.membrane(c),m.cell,'product remains in reacting compartment')
end

-- 3. Compartment locality is semantic: if A and B are split across distinct
--    membranes, the one-locality reaction pattern has no Cut witness.
do
  local _,live,_,_,s=vessel({left={SA,SA},right={SB}})
  eq(O.one(live,R1,{offers={s.left[1],s.left[2],s.right[1]}}),nil,'local reaction must reject split compartments')
end

-- 4. Open-network composition: close the intermediate C between R1 and R2.
--    External interface should be 2A+B+D -> E; C disappears from the boundary.
do
  local network,img=A.close({R1,R2},{{rC,sC}})
  eq(#network:ingress(),4,'network ingress is 2A+B+D')
  eq(#network:egress(),1,'network egress is E')
  local out=img[2].strands[sE]
  eq(G.points(out)[1],SE,'composed output E')
  -- Execute whole open network as one development on a cell boundary.
  local _,live,_,_,str=vessel({cell={SA,SA,SB,SD}})
  local offers={str.cell[1],str.cell[2],str.cell[3],str.cell[4]}
  local w=O.one(live,network,{offers=offers})
  ok(w,'composed reaction network should execute from external reactants')
  local _,oi=O.commit(w)
  eq(live:size(),1,'all external reactants replaced by final product')
  local e=oi.strands[out]; ok(live:contains(e),'E live after network execution')
  eq(G.points(e)[1],SE)
end

-- 5. Cross-compartment transport must be causally grounded in both localities.
-- Pattern has source and destination child membranes. It consumes the molecule
-- from source plus a destination SITE authority, then reissues SITE and creates
-- a molecule in destination. The Face itself lives at their LCA (pattern root).
local tb=G.builder(); local tr=tb:membrane(nil,'transport-context')
local tsrc=tb:membrane(tr,'src'); local tdst=tb:membrane(tr,'dst')
local tin=tb:strand(tsrc,{SA},'A@src')
local sitein=tb:strand(tdst,{SITE},'site@dst')
local tout=tb:strand(tdst,{SA},'A@dst')
local siteout=tb:strand(tdst,{SITE},'site@dst-again')
tb:face(tr,{tin,sitein},{tout,siteout},'transport A src->dst')
local TRANSPORT=tb:finish()

do
  local _,live,root,m,s=vessel({left={SA},right={SITE}})
  local w=O.one(live,TRANSPORT,{strands={[tin]=s.left[1],[sitein]=s.right[1]}})
  ok(w,'transport should be grounded by source molecule and destination site')
  eq(w:membrane(tsrc),m.left)
  eq(w:membrane(tdst),m.right)
  eq(w:membrane(tr),root,'compound transport context is LCA/root')
  local _,img=O.commit(w)
  local moved=img.strands[tout]
  eq(G.membrane(moved),m.right,'molecule authority moved to destination locality')
  eq(G.points(moved)[1],SA)
  eq(live:size(),2,'molecule plus reissued destination site remain live')
end

-- 6. Exact Cut witness multiplicity exposes a stochastic-chemistry symmetry
--    issue. For 3 exact A and 2 exact B offers, the face has two distinct exact
--    A demand occurrences. Raw Cut witnesses count ordered assignments to these
--    slots. Chemical Theory would normally quotient by the 2! automorphism of
--    identical A reactant slots before using witness counts as mass-action rates.
do
  local _,live,_,_,s=vessel({cell={SA,SA,SA,SB,SB}})
  local all=O.all(live,R1,{offers=live:offers()})
  local raw=#all
  local expected_ordered=3*2*2 -- A1 choice * A2 remaining * B
  local expected_unordered=3*2 -- C(3,2)*2 B
  eq(raw,expected_ordered,'raw exact Cut matching count')
  eq(raw/2,expected_unordered,'divide by identical-reactant automorphism 2!')
  print(string.format('chemistry witnesses: raw=%d, chemical unordered=%d',raw,raw/2))
end

print('Worlds chemistry toy: PASS')
