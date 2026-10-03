package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local Construction=require('worlds.construction')
local Oracle=require('speculation.modern.restrictive_theory_followup.correspondence')
local R=require('speculation.modern.restrictive_theory_followup.relation_doctrine')
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
local function all_source(parts)
  local out={}
  for _,g in ipairs(parts) do
    for _,k in ipairs{'membranes','points','strands','faces'} do
      for _,x in ipairs(g[k](g)) do out[#out+1]=x end
    end
  end
  return out
end
local function same_partition(native,oracle,msg)
  local xs=all_source(native:source_parts())
  for i=1,#xs do for j=1,#xs do
    ok(native:source_equivalent(xs[i],xs[j])==oracle:source_equivalent(xs[i],xs[j]),msg)
  end end
end
local function transport(rel,corr,target_ctx)
  local out={}
  local function rows(k)
    local xs={}
    for x=0,2^k-1 do
      local bits={}
      for i=k,1,-1 do bits[i]=(x%2==1) and '1' or '0'
      x=math.floor(x/2) end
      xs[#xs+1]=table.concat(bits)
    end
    return xs
  end
  local function bit(row,i) return row:sub(i,i) end
  local si,ti={},{ }
  for i,x in ipairs(rel.ctx) do si[x]=i
  assert(corr:source_class(x),'relation carrier outside native correspondence source') end
  for i,x in ipairs(target_ctx) do ti[x]=i
  assert(corr:target_class(x),'target carrier outside native correspondence result') end
  for _,rt in ipairs(rows(#target_ctx)) do
    local allowed=false
    for rs in pairs(rel.rows) do
      local vals={}
      local consistent=true
      for _,x in ipairs(rel.ctx) do
        local cl=corr:source_class(x)
        local v=bit(rs,si[x])
        if vals[cl] and vals[cl]~=v then consistent=false
        break end
        vals[cl]=v
      end
      if consistent then
        for _,y in ipairs(target_ctx) do
          local cl=corr:target_class(y)
          local v=bit(rt,ti[y])
          if vals[cl] and vals[cl]~=v then consistent=false
          break end
          vals[cl]=v
        end
      end
      if consistent then allowed=true
      break end
    end
    if allowed then out[rt]=true end
  end
  return {ctx=target_ctx,rows=out}
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

print('1. native Construction correspondence retains a later-annihilated quotient class')
local c1=Construction.join({G0},{{from=xo,to=yi}})
local n1=c1:correspondence()
local o1=Oracle.from_construction(c1)
local m=assert(c1:image(xo))
ok(m==c1:image(yi),'first cut did not identify seam')
local c2=Construction.join({c1:result()},{{from=c1:image(yo),to=c1:image(xi)}})
local n2=c2:correspondence()
local o2=Oracle.from_construction(c2)
local staged=n1:compose(n2)
local ostaged=Oracle.compose(o1,o2)
ok(c2:image(m)==nil,'second cut did not annihilate the intermediate seam')
ok(staged:source_equivalent(xo,yi),'native composed correspondence forgot source equality')
same_partition(staged,ostaged,'native source quotient differs from reconstruction oracle')

print('2. one-shot and staged native correspondence agree')
local direct=Construction.join({G0},{{from=xo,to=yi},{from=yo,to=xi}})
local nd=direct:correspondence()
ok(staged:same_source_partition(nd),'native staged and one-shot source partitions differ')

print('3. native correspondence gives compositional positive-knowledge transport')
local phi=R.relation({xo,yi,u,v},function(e) return e[xo]==e[u] and e[yi]==e[v] end)
local mctx={m,c1:image(u),c1:image(v)}
local k1=transport(phi,n1,mctx)
local sctx={c2:image(c1:image(u)),c2:image(c1:image(v))}
local k2=transport(k1,n2,sctx)
local kd=transport(phi,staged,sctx)
same(k2,kd,'native staged knowledge transport is not compositional')
local expected=R.relation(sctx,function(e) return e[sctx[1]]==e[sctx[2]] end)
same(kd,expected,'native vanished quotient lost surviving public correlation')

print('4. source-relative mate agrees with the reconstruction oracle')
local dctx={direct:image(u),direct:image(v)}
local kdirect=transport(phi,nd,dctx)
local sigma={}
for _,z in ipairs(dctx) do
  local native=assert(nd:mate(staged,z),'native mate missing')
  local oracle=Oracle.between(Oracle.from_construction(direct),ostaged)[z]
  ok(native==oracle,'native mate disagrees with reconstruction oracle')
  sigma[z]=native
end
same(R.reindex(kdirect,sctx,sigma),kd,'native endpoint mate disagrees with Theory transport')

print('PASS native Construction correspondence repairs Theory transport',n,'assertions')
