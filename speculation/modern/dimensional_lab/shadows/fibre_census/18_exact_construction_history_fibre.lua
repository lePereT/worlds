package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local function catalan(k) local c=1; for i=0,k-1 do c=c*2*(2*i+1)//(i+2) end; return c end
local function trees(a,b)
  if a==b then return {{leaf=a}} end
  local out={}; for k=a,b-1 do for _,l in ipairs(trees(a,k)) do for _,r in ipairs(trees(k+1,b)) do out[#out+1]={l=l,r=r} end end end; return out
end
local function leaves(N)
  local xs={}
  for i=1,N do local b=W.builder(); local m=b:membrane(nil,'L'..i); local p=b:point(m,'P'..i); local q=b:point(m,'P'..(i+1)); local ii=b:strand(m,{p},'in'); local oo=b:strand(m,{q},'out'); local f=b:face(m,{ii},{oo},'F'..i); xs[i]={g=b:finish(),i=ii,o=oo,f=f,map={[f]=f}} end
  return xs
end
local function build_variants(t,L)
  if t.leaf then local x=L[t.leaf]; return {{g=x.g,i=x.i,o=x.o,map=x.map}} end
  local A,B=build_variants(t.l,L),build_variants(t.r,L); local out={}
  for _,a in ipairs(A) do for _,b in ipairs(B) do for frame=0,1 do
    local parts=frame==0 and {a.g,b.g} or {b.g,a.g}; local g,img=W.join(parts,{{from=a.o,to=b.i}}); local map={}
    for orig,cur in pairs(a.map) do map[orig]=img[cur] end; for orig,cur in pairs(b.map) do map[orig]=img[cur] end
    out[#out+1]={g=g,i=img[a.i],o=img[b.o],map=map}
  end end end
  return out
end

print('hold one exact causal chain shadow fixed; enumerate parenthesisation x frame/template construction histories')
for N=3,7 do
  local L=leaves(N); local T=trees(1,N); eq(#T,catalan(N-1),'Catalan parenthesisations')
  local carrier_id,nextid={},0; local function id(x) local z=carrier_id[x]; if not z then nextid=nextid+1; z=nextid; carrier_id[x]=z end; return z end
  local exact,struct={},{}; local histories=0; local retained={}; local distinct={}; for i=1,N do retained[i]=0; distinct[i]={} end
  for _,t in ipairs(T) do
    local vs=build_variants(t,L); eq(#vs,1<<(N-1),'each internal join independently chooses frame/template retention')
    for _,v in ipairs(vs) do
      histories=histories+1; eq(#v.g:faces(),N); eq(#v.g:ingress(),1); eq(#v.g:egress(),1)
      local tuple={}; for i=1,N do local cur=v.map[L[i].f]; tuple[i]=id(cur); distinct[i][cur]=true; if cur==L[i].f then retained[i]=retained[i]+1 end end
      exact[table.concat(tuple,',')]=true; struct[#v.g:faces()..'/'..#v.g:strands()..'/'..#v.g:points()..'/'..#v.g:ingress()..'/'..#v.g:egress()]=true
    end
  end
  local ec,sc=0,0; for _ in pairs(exact) do ec=ec+1 end; for _ in pairs(struct) do sc=sc+1 end
  local expected=catalan(N-1)*(1<<(N-1)); eq(histories,expected); eq(ec,histories,'every tested construction path has a distinct exact Face tuple'); eq(sc,1,'all share one coarse causal-chain shadow')
  ok(retained[1]==retained[N],'full frame-choice census restores endpoint symmetry'); for i=1,N do local dc=0; for _ in pairs(distinct[i]) do dc=dc+1 end; ok(dc>=1); end
  print('  n='..N,'parenthesisations='..#T,'construction histories='..histories,'exact tuples='..ec)
end
print('PASS exact construction-history fibre',n,'assertions')
