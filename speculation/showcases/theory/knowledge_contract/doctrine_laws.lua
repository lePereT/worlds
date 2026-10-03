local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function same(a,b,msg) ok(R.equal(a,b),msg) end

local x,y,z,w='x','y','z','w'
local xyz={x,y,z}
local top=R.top(xyz)
local a=R.relation(xyz,function(r) return r[x]==r[y] end)
local b=R.relation(xyz,function(r) return r[y]==r[z] end)
local c=R.relation(xyz,function(r) return r[x]==0 or r[z]==1 end)

-- Bounded meet-semilattice laws.
same(R.meet(a,b),R.meet(b,a),'meet not commutative')
same(R.meet(a,a),a,'meet not idempotent')
same(R.meet(R.meet(a,b),c),R.meet(a,R.meet(b,c)),'meet not associative')
same(R.meet(a,top),a,'top not meet identity')
same(R.meet(a,R.bottom(xyz)),R.bottom(xyz),'bottom not absorbing')
ok(R.leq(R.meet(a,b),a),'conjunction did not entail left conjunct')
ok(R.leq(R.meet(a,b),b),'conjunction did not entail right conjunct')

-- Substitution/reindexing preserves finite meets and identity/composition.
local xy={x,y}
local relxy=R.relation(xy,function(r) return r[x]~=r[y] end)
local sigma={ [x]=x,[y]=z }
local re=R.reindex(relxy,xyz,sigma)
local relxy2=R.relation(xy,function(r) return r[x]==1 end)
same(R.reindex(R.meet(relxy,relxy2),xyz,sigma),
  R.meet(R.reindex(relxy,xyz,sigma),R.reindex(relxy2,xyz,sigma)),
  'reindex did not preserve meet')
same(R.reindex(R.top(xy),xyz,sigma),R.top(xyz),'reindex did not preserve top')
local id={ [x]=x,[y]=y,[z]=z }
same(R.reindex(a,xyz,id),a,'identity reindex changed knowledge')

-- Existential hiding is left adjoint to reindex along an inclusion/projection.
local keep={x,z}
local exists_ab=R.exists(R.meet(a,b),keep)
local q=R.relation(keep,function(r) return not (r[x]==1 and r[z]==0) end)
local inclusion={ [x]=x,[z]=z }
local pulled=R.reindex(q,xyz,inclusion)
eq(R.leq(exists_ab,q),R.leq(R.meet(a,b),pulled),'existential adjunction failed')

-- Frobenius reciprocity: exists(phi & p*psi) = exists(phi) & psi.
local left=R.exists(R.meet(R.meet(a,b),pulled),keep)
local right=R.meet(R.exists(R.meet(a,b),keep),q)
same(left,right,'Frobenius reciprocity failed')

-- Projection composes and is idempotent on an already projected context.
same(R.exists(R.exists(R.meet(a,b),keep),keep),exists_ab,'projection not idempotent')
local onlyx={x}
same(R.exists(R.exists(R.meet(a,b),keep),onlyx),R.exists(R.meet(a,b),onlyx),
  'iterated existential hiding did not compose')

-- Hiding is not a meet homomorphism in general.
local separate=R.meet(R.exists(a,keep),R.exists(b,keep))
ok(not R.equal(exists_ab,separate),'existential hiding incorrectly distributed over meet')

-- Beck-Chevalley on a representative pullback square. Start with phi(x,y),
-- hide y, then substitute x<-z. This must equal substitute in the extended
-- context and hide the corresponding y.
local phi=R.relation({x,y},function(r) return r[x]==r[y] end)
local ex=R.exists(phi,{x})
local lhs=R.reindex(ex,{z},{[x]=z})
local phi_sub=R.reindex(phi,{z,w},{[x]=z,[y]=w})
local rhs=R.exists(phi_sub,{z})
same(lhs,rhs,'Beck-Chevalley substitution/hiding square failed')

print('doctrine laws: '..n..' assertions passed')
