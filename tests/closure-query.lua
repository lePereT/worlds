package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local n=0
local function ok(x,m) n=n+1; assert(x,m) end
local function eq(a,b,m) n=n+1; assert(a==b,'assert '..n..' '..(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function decided(q,fuel) while true do local k,x=q:step(fuel or math.huge); if k~='more' then return k,x end end end
local function collect(q,fuel)
  local out={}; while true do local k,x=decided(q,fuel); if k=='yes' then out[#out+1]=x elseif k=='done' then return out elseif k=='no' then return out,x else error('unexpected '..tostring(k)) end end
end

local function pair_part(name,role_a,role_b)
  local b=W.builder(); local m=b:membrane(nil,name); local a=role_a and b:point(m,role_a) or nil; local c=role_b and b:point(m,role_b) or nil
  local i=b:strand(m,a and {a} or {},name..'.in'); local o=b:strand(m,c and {c} or {},name..'.out'); b:face(m,{i},{o},name..'.work')
  return b:finish(),{m=m,i=i,o=o,a=a,c=c}
end

-- Direct two-part closure is not staged through a product Geometry.
do
  local a,A=pair_part('A'); local b,B=pair_part('B')
  local q=Query.close({a,b},{sources={A.o},targets={B.i}}); eq(q:form(),'close'); eq(#q:parts(),2)
  local k,e=decided(Query.solve(q),math.huge); eq(k,'yes'); eq(#e,1); eq(e[1].from,A.o); eq(e[1].to,B.i)
  local g=W.join({a,b},e); ok(W.is_geometry(g)); eq(decided(Query.solve(q),math.huge),'yes')
end

-- Bidirectional closure across the same two parts is one finite Question.
do
  local a,A=pair_part('A2'); local b,B=pair_part('B2')
  local q=Query.close({a,b},{sources={A.o,B.o},targets={A.i,B.i},required_targets={A.i,B.i},admissible={{from=A.o,to=B.i},{from=B.o,to=A.i}}})
  local solve=Query.solve(q); local k,e=decided(solve,math.huge); eq(k,'yes'); eq(#e,2); ok(W.is_geometry(W.join({a,b},e))); eq(decided(solve,math.huge),'done')
end

-- Three-part cyclic closure is judged directly, not via an ambient product.
do
  local a,A=pair_part('A3'); local b,B=pair_part('B3'); local c,C=pair_part('C3')
  local q=Query.close({a,b,c},{sources={A.o,B.o,C.o},targets={A.i,B.i,C.i},admissible={{from=A.o,to=B.i},{from=B.o,to=C.i},{from=C.o,to=A.i}}})
  local k,e=decided(Query.solve(q),math.huge); eq(k,'yes'); eq(#e,3); local g=W.join({a,b,c},e); ok(W.is_geometry(g)); eq(#g:faces(),1,'cycle should SCC-normalise to one joint')
end

-- Same-Geometry internal closure is the one-part special case.
do
  local b=W.builder(); local m=b:membrane(nil,'internal'); local i=b:strand(m,{},'i'); local mid=b:strand(m,{},'mid'); local o=b:strand(m,{},'o'); b:face(m,{i},{mid},'left'); b:face(m,{mid},{o},'right'); local g=b:finish()
  -- mid is internal already, so make an actually open pair in one Geometry.
  local c=W.builder(); local cm=c:membrane(nil,'same'); local a=c:strand(cm,{},'a'); local z=c:strand(cm,{},'z'); local same=c:finish()
  local q=Query.close({same},{sources={a},targets={z},required_targets={z},admissible={{from=a,to=z}}})
  local k,e=decided(Query.solve(q),math.huge); eq(k,'yes'); ok(W.is_geometry(W.join({same},e)))
end

-- Optional targets are genuine finite closure alternatives.
do
  local b=W.builder(); local m=b:membrane(nil,'offers'); local s1=b:strand(m,{},'s1'); local s2=b:strand(m,{},'s2'); local offers=b:finish()
  local t=W.builder(); local tm=t:membrane(nil,'needs'); local d1=t:strand(tm,{},'d1'); local d2=t:strand(tm,{},'d2'); local needs=t:finish()
  local q=Query.close({offers,needs},{sources={s1,s2},targets={d1,d2},required_targets={}})
  local hits=collect(Query.solve(q),math.huge); local sizes={}; for _,e in ipairs(hits) do sizes[#sizes+1]=#e; ok(W.is_geometry(W.join({offers,needs},e))) end
  table.sort(sizes); eq(table.concat(sizes,','),'0,1,1,1,1,2,2','all injective optional closures should be enumerated')
end


-- Required source coverage is independent of required targets. This is what
-- generic cut closure needs for left/right/exact coverage without a side predicate.
do
  local b=W.builder(); local m=b:membrane(nil,'domain'); local s1=b:strand(m,{},'s1'); local s2=b:strand(m,{},'s2'); local a=b:finish()
  local c=W.builder(); local cm=c:membrane(nil,'range'); local d1=c:strand(cm,{},'d1'); local d2=c:strand(cm,{},'d2'); local z=c:finish()
  local q=Query.close({a,z},{sources={s1,s2},targets={d1,d2},required_sources={s2},required_targets={d1}})
  local hits=collect(Query.solve(q),math.huge); ok(#hits>0)
  for _,es in ipairs(hits) do
    local used,closed={},{}; for _,e in ipairs(es) do used[e.from]=true; closed[e.to]=true end
    ok(used[s2],'required source must occur in domain(E)'); ok(closed[d1],'required target must occur in codomain(E)')
  end
  local impossible=Query.close({a,z},{sources={s1},targets={d1},required_sources={s1},required_targets={},admissible={}})
  local k,no=decided(Query.solve(impossible),math.huge); eq(k,'no'); ok(Query.is_refutation(no))
end

-- Seeds are exact, mandatory and globally scarce.
do
  local b=W.builder(); local m=b:membrane(nil,'seed-source'); local s1=b:strand(m,{},'s1'); local s2=b:strand(m,{},'s2'); local a=b:finish()
  local c=W.builder(); local cm=c:membrane(nil,'seed-target'); local d1=c:strand(cm,{},'d1'); local d2=c:strand(cm,{},'d2'); local z=c:finish()
  local q=Query.close({a,z},{sources={s1,s2},targets={d1,d2},seeds={{from=s2,to=d1}}})
  local k,e=decided(Query.solve(q),math.huge); eq(k,'yes'); local by={}; for _,x in ipairs(e) do by[x.to]=x.from end; eq(by[d1],s2); eq(by[d2],s1)
  ok(not pcall(function() Query.close({a,z},{seeds={{from=s1,to=d1},{from=s1,to=d2}}}) end),'seed source scarcity is structural')
end

-- Close is weaker than directional Match by design: it asks whether exact open
-- occurrences may form lawful Geometry, not whether one part is a rooted target
-- development pattern.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'world'); local s=wb:strand(wm,{},'s'); local world=wb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil,'fragment'); local d=pb:strand(pm,{},'d'); local spontaneous=pb:strand(pm,{},'spontaneous'); pb:face(pm,{}, {spontaneous},'unrooted'); local fragment=pb:finish()
  local ck,ce=decided(Query.solve(Query.close({world,fragment},{sources={s},targets={d},seeds={{from=s,to=d}}})),math.huge); eq(ck,'yes'); ok(W.is_geometry(W.join({world,fragment},ce)))
  ok(not pcall(function() Query.solve(Query.match(world,fragment,{seeds={{from=s,to=d}}})) end),'Match retains the stronger target-development premise')
end

-- Locality-lifetime regression: direct Close must reject the exact unthreaded
-- quotient and accept the threaded one.  Every yes is immediately joinable.
do
  local function depth(m) local n=0 while m do n=n+1; m=W.parent(m) end return n end
  local function provider(levels)
    local b=W.builder(); local m=nil; for i=1,levels do m=b:membrane(m,'provider.'..i) end
    local input=b:strand(m,{},'provider.in'); local output=b:strand(m,{},'provider.out'); b:face(m,{input},{output},'provider.work'); return b:finish(),input,output
  end
  local function excursion(threaded)
    local b=W.builder(); local root=b:membrane(nil,'root'); local outer=b:membrane(root,'outer'); local inner=b:membrane(root,'inner'); local target=b:membrane(outer,'target')
    local start=b:strand(outer,{},'start'); local work=b:strand(inner,{},'work'); local cap=threaded and b:strand(outer,{},'outer.cap') or nil
    local outs={work}; if cap then outs[#outs+1]=cap end; b:face(root,{start},outs,'depart')
    local returned=b:strand(target,{},'returned'); local locality=b:strand(target,{},'locality'); local carry=b:strand(target,{},'carry'); b:face(target,{returned},{carry,locality},'open')
    local accept=b:strand(target,{},'accept'); local ins={work,locality}; if cap then ins[#ins+1]=cap end; b:face(root,ins,{accept},'return')
    return b:finish(),{target=target,accept=accept,returned=returned}
  end
  local function ask(threaded)
    local context,x=excursion(threaded); local pg,pin,pout=provider(depth(x.target))
    local q=Query.close({context,pg},{sources={x.accept,pout},targets={pin,x.returned},required_targets={pin,x.returned},admissible={{from=x.accept,to=pin},{from=pout,to=x.returned}}})
    return context,pg,q
  end
  local a,b,q=ask(false); local k,no=decided(Query.solve(q),math.huge); eq(k,'no'); ok(Query.is_refutation(no)); eq(no:reason().kind,'unlawful-realisation')
  local c,d,q2=ask(true); local k2,e=decided(Query.solve(q2),math.huge); eq(k2,'yes'); ok(W.is_geometry(W.join({c,d},e)))
end

-- Finite fuel is epistemic. It may stop before a lawful closure is found, but
-- never converts unfinished search into no.
do
  local b=W.builder(); local m=b:membrane(nil,'fuel-s'); local s1=b:strand(m,{},'s1'); local s2=b:strand(m,{},'s2'); local a=b:finish()
  local c=W.builder(); local cm=c:membrane(nil,'fuel-t'); local d1=c:strand(cm,{},'d1'); local d2=c:strand(cm,{},'d2'); local z=c:finish()
  local solve=Query.solve(Query.close({a,z},{sources={s1,s2},targets={d1,d2}})); local k=solve:step(0); eq(k,'more'); local k2,e=decided(solve,math.huge); eq(k2,'yes'); ok(W.is_geometry(W.join({a,z},e)))
end

-- Public constructors are precise: vague new() is deliberately absent.
ok(Query.new==nil,'Question.new must not hide the judgement form')

print('PASS closure query',n,'assertions')
