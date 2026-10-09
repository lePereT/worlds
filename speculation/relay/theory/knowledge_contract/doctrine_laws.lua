local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function same(a,b,msg) ok(K.equal(a,b),msg) end
local function entails(a,b) local yes,why=K.entails(a,b); assert(why==nil,why); return yes end


-- The executable doctrine surface is deliberately closed.  Derived order,
-- judgement, transport and persistence machinery must not leak back into a
-- domain specification as a second semantic authority.
do
  local function noop() return K.TOP end
  local accepted=pcall(function()
    K.domain{
      name='too-thick',
      equal=function() return true end,
      meet=noop,
      reindex=noop,
      exists=noop,
      leq=function() return true end,
    }
  end)
  ok(not accepted,'host accepted a non-core doctrine operation')
end

local x,y,z,w='x','y','z','w'
local xyz={x,y,z}
local top=K.top(xyz)
local a=R.relation(xyz,function(r) return r[x]==r[y] end)
local b=R.relation(xyz,function(r) return r[y]==r[z] end)
local c=R.relation(xyz,function(r) return r[x]==0 or r[z]==1 end)

-- Bounded meet-semilattice laws are host laws; the domain supplies only meet.
same(K.meet(a,b),K.meet(b,a),'meet not commutative')
same(K.meet(a,a),a,'meet not idempotent')
same(K.meet(K.meet(a,b),c),K.meet(a,K.meet(b,c)),'meet not associative')
same(K.meet(a,top),a,'top not meet identity')
same(K.meet(a,K.bottom(xyz)),K.bottom(xyz),'bottom not absorbing')
ok(entails(K.meet(a,b),a),'conjunction did not entail left conjunct')
ok(entails(K.meet(a,b),b),'conjunction did not entail right conjunct')

-- Reindexing preserves finite meets and identity/composition.
local xy={x,y}
local relxy=R.relation(xy,function(r) return r[x]~=r[y] end)
local sigma={ [x]=x,[y]=z }
local re=K.reindex(relxy,xyz,sigma)
local relxy2=R.relation(xy,function(r) return r[x]==1 end)
same(K.reindex(K.meet(relxy,relxy2),xyz,sigma),
  K.meet(K.reindex(relxy,xyz,sigma),K.reindex(relxy2,xyz,sigma)),
  'reindex did not preserve meet')
same(K.reindex(K.top(xy),xyz,sigma),K.top(xyz),'reindex did not preserve top')
local id={ [x]=x,[y]=y,[z]=z }
same(K.reindex(a,xyz,id),a,'identity reindex changed knowledge')

-- Existential hiding is left adjoint to reindex along an inclusion/projection.
local keep={x,z}
local exists_ab=K.exists(K.meet(a,b),keep)
local q=R.relation(keep,function(r) return not (r[x]==1 and r[z]==0) end)
local inclusion={ [x]=x,[z]=z }
local pulled=K.reindex(q,xyz,inclusion)
eq(entails(exists_ab,q),entails(K.meet(a,b),pulled),'existential adjunction failed')

-- Frobenius reciprocity: exists(phi & p*psi) = exists(phi) & psi.
local left=K.exists(K.meet(K.meet(a,b),pulled),keep)
local right=K.meet(K.exists(K.meet(a,b),keep),q)
same(left,right,'Frobenius reciprocity failed')

-- Projection composes and is idempotent on an already projected context.
same(K.exists(K.exists(K.meet(a,b),keep),keep),exists_ab,'projection not idempotent')
local onlyx={x}
same(K.exists(K.exists(K.meet(a,b),keep),onlyx),K.exists(K.meet(a,b),onlyx),
  'iterated existential hiding did not compose')

-- Hiding is not a meet homomorphism in general.
local separate=K.meet(K.exists(a,keep),K.exists(b,keep))
ok(not K.equal(exists_ab,separate),'existential hiding incorrectly distributed over meet')

-- Beck-Chevalley on a representative pullback square.
local phi=R.relation({x,y},function(r) return r[x]==r[y] end)
local ex=K.exists(phi,{x})
local lhs=K.reindex(ex,{z},{[x]=z})
local phi_sub=K.reindex(phi,{z,w},{[x]=z,[y]=w})
local rhs=K.exists(phi_sub,{z})
same(lhs,rhs,'Beck-Chevalley substitution/hiding square failed')

print('doctrine laws: '..n..' assertions passed')
