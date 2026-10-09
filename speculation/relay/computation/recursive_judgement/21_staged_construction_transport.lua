package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
 local Construction=require('worlds.construction')
 local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local n=0
 local function same(a,b,m) n=n+1
 assert(K.equal(a,b),m or 'relations differ') end
local function stage(name) local b=W.builder()
 local m=b:membrane(nil,name)
 local p=b:point(m)
 local i=b:strand(m,{p})
 local o=b:strand(m,{p})
 b:face(m,{i},{o})
 return b:finish(),{i=i,o=o} end
local function bare(name) local b=W.builder()
 local m=b:membrane(nil,name)
 local s=b:strand(m,{})
 return b:finish(),s end
local X,x=stage('X')
 local Y,y=stage('Y')
 local U,u0=bare('U')
 local V,v0=bare('V')
 local p=Construction.join({X,Y,U,V},{})
 local g=p:result()
local xo,yi,yo,xi,u,v=p:image(x.o),p:image(y.i),p:image(y.o),p:image(x.i),p:image(u0),p:image(v0)
local source={xo,yi,u,v}
 local ctx={}
 for _,z in ipairs(source) do ctx[#ctx+1]={point=z,sort='bool',values={false,true}} end
local phi=K.relation(ctx,function(e) return e[xo]==e[u] and e[yi]==e[v] end)
local function info(c,coords)
  local corr=c:correspondence()
 local sources={[1]={}}
 local target={}
  for _,z in ipairs(coords) do sources[1][z]=corr:source_class(z) end
  for _,z in ipairs(c:result():strands()) do target[corr:target_class(z)]=z end
  local tctx,seen={},{}
  for _,z in ipairs(coords) do local im=c:image(z)
 if im and not seen[im] then seen[im]=true
 tctx[#tctx+1]={point=im,sort='bool',values={false,true}} end end
  return {sources=sources,target=target},tctx
end
local c1=Construction.join({g},{{from=xo,to=yi}})
 local i1,ctx1=info(c1,source)
 local k1=K.transport_parts({phi},i1,ctx1)
local coords1={}
 for _,c in ipairs(k1.ctx) do coords1[#coords1+1]=c.point end
local c2=Construction.join({c1:result()},{{from=c1:image(yo),to=c1:image(xi)}})
 local i2,ctx2=info(c2,coords1)
 local k2=K.transport_parts({k1},i2,ctx2)
local direct=Construction.join({g},{{from=xo,to=yi},{from=yo,to=xi}})
 local id,ctxd=info(direct,source)
 local kd=K.transport_parts({phi},id,ctxd)
local final2={c2:image(c1:image(u)),c2:image(c1:image(v))}
 local finald={direct:image(u),direct:image(v)}
local cctx={{point='u',sort='bool',values={false,true}},{point='v',sort='bool',values={false,true}}}
local p2=K.select(k2,final2,{{point=final2[1],sort='bool',values={false,true}},{point=final2[2],sort='bool',values={false,true}}})
local pd=K.select(kd,finald,{{point=finald[1],sort='bool',values={false,true}},{point=finald[2],sort='bool',values={false,true}}})
local a2=K.rename(p2,{[final2[1]]='u',[final2[2]]='v'},cctx)
local ad=K.rename(pd,{[finald[1]]='u',[finald[2]]='v'},cctx)
same(a2,ad,'staged Construction knowledge transport disagrees with one-shot transport')
print('PASS rj 21: native correspondence makes restrictive knowledge transport compositional ('..n..')')
