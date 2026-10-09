package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
 local Construction=require('worlds.construction')
 local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local n=0
 local function ok(x,m) n=n+1
 assert(x,m or 'assertion failed') end
local function stage(name)
 local b=W.builder()
 local m=b:membrane(nil,name)
 local p=b:point(m,name..'.p')
 local i=b:strand(m,{p},name..'.i')
 local o=b:strand(m,{p},name..'.o')
 b:face(m,{i},{o},name..'.f')
 return b:finish(),{p=p,i=i,o=o}
end
local function bare(name) local b=W.builder()
 local m=b:membrane(nil,name)
 local p=b:point(m,name..'.p')
 local s=b:strand(m,{p},name..'.s')
 return b:finish(),{p=p,s=s} end
local X,x=stage('X')
 local Y,y=stage('Y')
 local U,u0=bare('U')
 local V,v0=bare('V')
local product=Construction.join({X,Y,U,V},{})
 local G0=product:result()
 local xo,yi=product:image(x.o),product:image(y.i)
 local yo,xi=product:image(y.o),product:image(x.i)
 local u,v=product:image(u0.s),product:image(v0.s)
local c=Construction.join({G0},{{from=xo,to=yi},{from=yo,to=xi}})
 local corr=c:correspondence()
local source_points={xo,yi,u,v}
 local ctx={}
for _,p in ipairs(source_points) do ctx[#ctx+1]={point=p,sort='bool',values={false,true}} end
local phi=K.relation(ctx,function(e) return e[source_points[1]]==e[u] and e[source_points[2]]==e[v] end)
local sources={[1]={}}
 local class_target={}
 for _,p in ipairs(source_points) do sources[1][p]=corr:source_class(p) end
for _,z in ipairs(c:result():strands()) do class_target[corr:target_class(z)]=z end
local target_ctx={{point=c:image(u),sort='bool',values={false,true}},{point=c:image(v),sort='bool',values={false,true}}}
local out=K.transport_parts({phi},{sources=sources,target=class_target},target_ctx)
local expected=K.relation(target_ctx,function(e) return e[target_ctx[1].point]==e[target_ctx[2].point] end)
ok(K.equal(out,expected),'annihilated Construction quotient failed to leave public correlation')
print('PASS rj 05: restrictive Theory transport uses native Construction quotient before hiding ('..n..')')
