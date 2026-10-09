local W=require('worlds')
local Construction=require('worlds.construction')
local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function same(a,b,msg) ok(K.equal(a,b),msg) end

local function stage(label)
  local b=W.development_builder()
  local m=b:membrane(nil,label); local p=b:point(m,label..'.p')
  local i=b:strand(m,{p},label..'.in'); local o=b:strand(m,{p},label..'.out')
  local f=b:face(m,{i},{o},label..'.face')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end

-- Actual Worlds feedback Construction whose cyclic Strands are annihilated.
local X,x=stage('X'); local Y,y=stage('Y'); local Z,z=stage('Z')
local product=Construction.join({X,Y,Z},{})
local xi,yi,zi={},{},{}
for k,v in pairs(x) do xi[k]=product:image(v) end
for k,v in pairs(y) do yi[k]=product:image(v) end
for k,v in pairs(z) do zi[k]=product:image(v) end
local c=Construction.join({product:result()},{{from=xi.o,to=yi.i},{from=yi.o,to=xi.i}})
local hidden=xi.o
ok(c:image(hidden)==nil,'control Construction did not annihilate chosen carrier')
ok(c:image(xi.p)~=nil and c:image(zi.p)~=nil,'control survivors disappeared')

-- Correlation through an annihilated exact occurrence survives because the host
-- acts through Construction correspondence, not final carrier image.
local source={xi.p,hidden,zi.p}
local phi=R.relation(source,function(v) return v[xi.p]==v[hidden] and v[hidden]==v[zi.p] end)
local proper=K.transport({phi},c)
local target=K.context(proper)
local expected=R.relation(target,function(v) return v[target[1]]==v[target[2]] end)
same(proper,expected,'native correspondence transport lost hidden correlation')

-- Many-to-one exact identification can expose contradiction.
local b=W.development_builder()
local m=b:membrane(nil,'Q')
local p1=b:point(m,'Q.p1'); local p2=b:point(m,'Q.p2')
local s1=b:strand(m,{p1},'Q.out'); local s2=b:strand(m,{p2},'Q.in')
local qg=b:finish()
local qc=Construction.join({qg},{{from=s1,to=s2}})
local conflict=R.relation({p1,p2},function(v) return v[p1]~=v[p2] end)
local identified=K.transport({conflict},qc)
ok(K.is_bottom(identified),'exact quotient failed to expose contradiction')

-- Native correspondence action is functorial under composition.
local A,a=stage('A'); local B,bp=stage('B'); local D,d=stage('D')
local c1=Construction.join({A,B},{{from=a.o,to=bp.i}})
local c2=Construction.join({c1:result(),D},{{from=c1:image(bp.o),to=d.i}})
local ka=R.relation({a.p},function(v) return v[a.p]==1 end)
local kb=K.top({bp.p}); local kd=K.top({d.p})
local mid=K.transport({ka,kb},c1)
local staged=K.transport({mid,kd},c2)
local direct=K.transport({ka,kb,kd},c1:correspondence():compose(c2:correspondence()))
same(staged,direct,'native correspondence action was not functorial')

print('construction transport: '..n..' assertions passed')
