package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local K=require('speculation.relay.theory.knowledge')
local R=require('speculation.relay.theory.knowledge_contract.relation_domain')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function same(a,b,m) n=n+1; assert(K.equal(a,b),m or 'relations differ') end

local function stage(name)
  local b=W.development_builder()
  local m=b:membrane(nil,name); local p=b:point(m,name..'.p')
  local i=b:strand(m,{p},name..'.i'); local o=b:strand(m,{p},name..'.o')
  local f=b:face(m,{i},{o},name..'.f')
  return b:finish(),{m=m,p=p,i=i,o=o,f=f}
end
local function bare(name)
  local b=W.development_builder(); local m=b:membrane(nil,name)
  local s=b:strand(m,{},name..'.s'); return b:finish(),s
end

local X,x=stage('X'); local Y,y=stage('Y'); local U,u0=bare('U'); local V,v0=bare('V')
local product=Construction.join({X,Y,U,V},{})
local G0=product:result()
local xo,yi=product:image(x.o),product:image(y.i)
local yo,xi=product:image(y.o),product:image(x.i)
local u,v=product:image(u0),product:image(v0)

print('1. stage one identifies a source class which stage two later annihilates')
local c1=Construction.join({G0},{{from=xo,to=yi}})
local r1=c1:correspondence()
local m=assert(c1:image(xo))
ok(m==c1:image(yi),'first cut did not identify seam')
local c2=Construction.join({c1:result()},{{from=c1:image(yo),to=c1:image(xi)}})
local r2=c2:correspondence()
local staged=r1:compose(r2)
ok(c2:image(m)==nil,'second cut did not annihilate the intermediate seam')
ok(staged:source_equivalent(xo,yi),'composed native correspondence forgot vanished source equality')

print('2. one-shot Construction yields the same source quotient correspondence')
local direct=Construction.join({G0},{{from=xo,to=yi},{from=yo,to=xi}})
local rd=direct:correspondence()
ok(direct:image(xo)==nil and direct:image(yi)==nil,'one-shot control did not annihilate seam')
ok(staged:same_source_partition(rd),'staged and one-shot source quotient partitions differ')

print('3. thin Knowledge transport uses native Worlds correspondence')
local phi=R.relation({xo,yi,u,v},function(e) return e[xo]==e[u] and e[yi]==e[v] end)
local k1=K.transport({phi},c1)
local k2=K.transport({k1},c2)
local native_composed=c1:correspondence():compose(c2:correspondence())
local kd=K.transport({phi},native_composed)
same(k2,kd,'staged native correspondence transport is not compositional')
local sctx=K.context(kd)
local expected=R.relation(sctx,function(e) return e[sctx[1]]==e[sctx[2]] end)
same(kd,expected,'vanished quotient failed to leave surviving public correlation')

print('4. final partial image alone loses the same correlation')
local function partial_transport(k,target,image)
  local visible,sigma={},{}
  for _,z in ipairs(K.context(k)) do
    local y=image[z]
    if y~=nil then visible[#visible+1]=z; sigma[z]=y end
  end
  return K.reindex(K.exists(k,visible),target,sigma)
end
local image={}
for _,z in ipairs{xo,yi,u,v} do image[z]=c2:image(c1:image(z)) end
local naive=partial_transport(phi,sctx,image)
ok(not K.equal(naive,expected),'partial final image unexpectedly retained quotient history')
same(naive,K.top(sctx),'partial final image should forget the survivor correlation')

print('5. direct and staged exact-distinct codomains agree after source-relative reindexing')
local kdirect=K.transport({phi},direct)
local dctx=K.context(kdirect)
local sigma={}
for _,z in ipairs(dctx) do sigma[z]=assert(rd:mate(staged,z)) end
local reindexed=K.reindex(kdirect,sctx,sigma)
same(reindexed,kd,'source-relative endpoint map disagrees with Theory transport')

print('PASS one Construction correspondence repairs Knowledge transport composition',n,'assertions')
