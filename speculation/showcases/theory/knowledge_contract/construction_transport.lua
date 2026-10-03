local W=require('worlds')
local Construction=require('worlds.construction')
local R=require('speculation.showcases.theory.knowledge_contract.relation_doctrine')
local n=0
local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
local function same(a,b,msg) ok(R.equal(a,b),msg) end

local function stage(label)
  local b=W.builder()
 local m=b:membrane(nil,label)
 local p=b:point(m,label..'.p')
  local i=b:strand(m,{p},label..'.in')
 local o=b:strand(m,{p},label..'.out')
  local f=b:face(m,{i},{o},label..'.face')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

-- Use an actual Worlds feedback Construction whose cyclic Strands are annihilated.
local X,x=stage('X')
 local Y,y=stage('Y')
 local Z,z=stage('Z')
local product=Construction.join({X,Y,Z},{})
local xi,yi,zi={},{},{}
for k,v in pairs(x) do xi[k]=product:image(v) end
for k,v in pairs(y) do yi[k]=product:image(v) end
for k,v in pairs(z) do zi[k]=product:image(v) end
local c=Construction.join({product:result()},{{from=xi.o,to=yi.i},{from=yi.o,to=xi.i}})
local hidden=xi.o
ok(c:image(hidden)==nil,'control Construction did not annihilate chosen carrier')
ok(c:image(xi.p)~=nil and c:image(zi.p)~=nil,'control survivors disappeared')
ok(c:image(xi.p)~=c:image(zi.p),'control survivors were accidentally identified')

-- Correlation through an annihilated exact coordinate must survive as boundary knowledge.
local source={xi.p,hidden,zi.p}
local target={c:image(xi.p),c:image(zi.p)}
local phi=R.relation(source,function(v) return v[xi.p]==v[hidden] and v[hidden]==v[zi.p] end)
local image={}
for _,v in ipairs(source) do image[v]=c:image(v) end
local proper=R.transport(phi,target,image)
local expected=R.relation(target,function(v) return v[target[1]]==v[target[2]] end)
same(proper,expected,'Construction existential transport lost hidden correlation')

-- Demonstrate why pointwise/drop-dead transport is not a valid general law.
-- Treat the two conjuncts as if they were independently discarded because they mention hidden.
local naive=R.top(target)
ok(not R.equal(proper,naive),'naive drop-dead transport accidentally preserved correlation')

-- Many-to-one exact identification can create contradiction after transport.
local a,bv='a','b'
local source2={a,bv}
 local t='t'
 local target2={t}
local conflict=R.relation(source2,function(v) return v[a]==0 and v[bv]==1 end)
local identified=R.transport(conflict,target2,{[a]=t,[bv]=t})
same(identified,R.bottom(target2),'exact quotient failed to expose contradiction')

-- Transport is functorial for staged partial exact images in the relational model.
local s1={'a','b','c'}
 local mid={'u','v'}
 local fin={'q'}
local k=R.relation(s1,function(v) return v.a==v.b or v.c==1 end)
local f={a='u',b=nil,c='v'}
local g={u='q',v='q'}
local staged=R.transport(R.transport(k,mid,f),fin,g)
local direct=R.transport(k,fin,R.compose_image(f,g))
same(staged,direct,'Construction-style transport was not functorial')

print('construction transport: '..n..' assertions passed')
