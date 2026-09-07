local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Give=vb:point(vm,'Give'); local Take=vb:point(vm,'Take'); local Unit=vb:point(vm,'Unit'); local Counter=vb:point(vm,'Counter'); vb:finish()
local function source(n)
  local b=W.Geometry.builder(); local m=b:membrane(nil,'root'); local gp=b:strand(m,{Give},'give-permit'); local tp=b:strand(m,{Take},'take-permit'); b:strand(m,{Give,Unit,Counter},'resource-handle')
  local units={}; for i=1,n do units[i]=b:strand(m,{Unit,Counter},'unit') end
  return W.Operational.from_geometry(b:finish()),gp,tp,units
end
local function each_pattern()
  local p=W.Geometry.builder(); local m=p:membrane(nil,'p')
  local gi=p:strand(m,{Give}); local go=p:strand(m,{Give}); local made=p:strand(m,{Unit,Counter}); p:face(m,{gi},{go,made},'give')
  local ti=p:strand(m,{Take}); local to=p:strand(m,{Take}); local need=p:strand(m,{Unit,Counter}); p:face(m,{ti,need},{to},'take')
  return p:finish(),gi,ti
end
local function together_pattern()
  local p=W.Geometry.builder(); local m=p:membrane(nil,'p')
  local gi=p:strand(m,{Give}); local go=p:strand(m,{Give}); local ti=p:strand(m,{Take}); local to=p:strand(m,{Take}); local hand=p:strand(m,{Unit,Counter}); p:face(m,{gi},{go,hand},'give'); p:face(m,{ti,hand},{to},'take')
  return p:finish(),gi,ti
end
local e,egi,eti=each_pattern(); local t,tgi,tti=together_pattern()
local l0,g0,t0,u0=source(0)
T.eq(W.Operational.one(l0,e,{strands={[egi]=g0,[eti]=t0},offers=u0}),nil)
T.ok(W.Operational.one(l0,t,{strands={[tgi]=g0,[tti]=t0}}))
local l1,g1,t1,u1=source(1)
T.ok(W.Operational.one(l1,e,{strands={[egi]=g1,[eti]=t1},offers=u1}))
return T.count()
