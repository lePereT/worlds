package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local C=require('speculation.showcases.theory.lifecycle_and_correspondence.correspondence')
local R=require('speculation.showcases.theory.lifecycle_and_correspondence.relation_doctrine')
local n=0
local function ok(x,m) n=n+1
assert(x,m or 'assertion failed') end
local function same(a,b,m) n=n+1
assert(R.equal(a,b),m or 'relations differ') end

local function stage(name)
  local b=W.builder()
  local m=b:membrane(nil,name)
  local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i')
  local o=b:strand(m,{p},name..'.o')
  local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end
local function bare(name)
  local b=W.builder()
  local m=b:membrane(nil,name)
  local s=b:strand(m,{},name..'.s')
  return b:finish(),s
end

local X,x=stage('X')
local Y,y=stage('Y')
local U,u0=bare('U')
local V,v0=bare('V')
local product=Construction.join({X,Y,U,V},{})
local G0=product:result()
local xo,yi=product:image(x.o),product:image(y.i)
local yo,xi=product:image(y.o),product:image(x.i)
local u,v=product:image(u0),product:image(v0)

print('1. stage one identifies a source class which stage two later annihilates')
local c1=Construction.join({G0},{{from=xo,to=yi}})
local r1=C.from_construction(c1)
local m=assert(c1:image(xo))
ok(m==c1:image(yi),'first cut did not identify seam')
local c2=Construction.join({c1:result()},{{from=c1:image(yo),to=c1:image(xi)}})
local r2=C.from_construction(c2)
local staged=C.compose(r1,r2)
ok(c2:image(m)==nil,'second cut did not annihilate the intermediate seam')
ok(staged:source_equivalent(xo,yi),'composed correspondence forgot vanished source equality')

print('2. one-shot Construction yields the same source quotient correspondence')
local direct=Construction.join({G0},{{from=xo,to=yi},{from=yo,to=xi}})
local rd=C.from_construction(direct)
ok(direct:image(xo)==nil and direct:image(yi)==nil,'one-shot control did not annihilate seam')
ok(C.same_source_partition(staged,rd),'staged and one-shot source quotient partitions differ')

print('3. correspondence transport preserves knowledge carried through the vanished quotient')
local phi=R.relation({xo,yi,u,v},function(e) return e[xo]==e[u] and e[yi]==e[v] end)
local mctx={m,c1:image(u),c1:image(v)}
local k1=C.transport(phi,r1,mctx,R)
local sctx={c2:image(c1:image(u)),c2:image(c1:image(v))}
local k2=C.transport(k1,r2,sctx,R)
local kd=C.transport(phi,staged,sctx,R)
same(k2,kd,'staged correspondence transport is not compositional')
local expected=R.relation(sctx,function(e) return e[sctx[1]]==e[sctx[2]] end)
same(kd,expected,'vanished quotient failed to leave surviving public correlation')

print('4. final partial image alone loses the same correlation')
local image={}
for _,z in ipairs{xo,yi,u,v} do image[z]=c2:image(c1:image(z)) end
local naive=R.transport(phi,sctx,image)
ok(not R.equal(naive,expected),'partial final image unexpectedly retained quotient history')
same(naive,R.top(sctx),'partial final image should forget the survivor correlation')

print('5. direct and staged exact-distinct codomains agree after source-relative reindexing')
local dctx={direct:image(u),direct:image(v)}
local kdirect=C.transport(phi,rd,dctx,R)
local map=C.between(rd,staged)
local sigma={[dctx[1]]=map[dctx[1]],[dctx[2]]=map[dctx[2]]}
local reindexed=R.reindex(kdirect,sctx,sigma)
same(reindexed,kd,'source-relative endpoint map disagrees with Theory transport')

print('PASS one Construction correspondence repairs Theory transport composition',n,'assertions')
