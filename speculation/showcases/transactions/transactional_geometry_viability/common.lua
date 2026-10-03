package.path='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;'..package.path
local W=require('worlds')
local K=require('speculation.showcases.transactions.transactional_recursive_judgement.knowledge')
local Context=require('speculation.showcases.transactions.transactional_recursive_judgement.context')
local RP=require('speculation.showcases.transactions.transactional_recursive_judgement.package')
local Search=require('speculation.showcases.transactions.transactional_recursive_judgement.search')
local A=require('speculation.showcases.transactions.transactional_geometry_viability.authority')
local Case=require('speculation.showcases.transactions.transactional_geometry_viability.case')
local Analysis=require('speculation.showcases.transactions.transactional_geometry_viability.analysis')
local Judgement=require('speculation.showcases.transactions.transactional_geometry_viability.judgement')
local M={W=W,K=K,Context=Context,RP=RP,Search=Search,A=A,Case=Case,Analysis=Analysis,Judgement=Judgement}

function M.counter()
  local n=0
  local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
  local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b)) end
  return ok,eq,function() return n end
end

local function top() return K.spec(K.top({})) end
local function strand(g,membrane,points)
  g.strands[#g.strands+1]={membrane=membrane,points=points or {}}
 return #g.strands
end

function M.authority_identity_context(point_count,guard)
  point_count=point_count or 1
  local g={membranes={{parent=0}},points={},strands={},faces={}}
 local ps={}
  for i=1,point_count do g.points[i]={membrane=1}
 ps[i]=i end
  local s=strand(g,1,ps)
 local theory=K.top({})
 local values={inputs={},outputs={}}
  if guard~=nil then
    g.points[#g.points+1]={membrane=1}
 local p=#g.points
    local ctx={{point=p,sort='bool',values={false,true}}}
 theory=K.point_value(ctx,p,guard)
 values.inputs={p}
  end
  return Context.closed({geometry=g,theory=K.spec(theory),authority={inputs={s},outputs={s}},values=values})
end

function M.authority_step_context(point_count,guard)
  point_count=point_count or 1
  local g={membranes={{parent=0}},points={},strands={},faces={}}
 local a,b={},{ }
  for i=1,point_count do g.points[#g.points+1]={membrane=1}
 a[i]=#g.points end
  for i=1,point_count do g.points[#g.points+1]={membrane=1}
 b[i]=#g.points end
  local si=strand(g,1,a)
 local so=strand(g,1,b)
 g.faces[1]={membrane=1,inputs={si},outputs={so}}
  local theory=K.top({})
 local values={inputs={},outputs={}}
  if guard~=nil then
    g.points[#g.points+1]={membrane=1}
 local p=#g.points
    local ctx={{point=p,sort='bool',values={false,true}}}
 theory=K.point_value(ctx,p,guard)
 values.inputs={p}
  end
  return Context.closed({geometry=g,theory=K.spec(theory),authority={inputs={si},outputs={so}},values=values})
end

function M.authority_disconnected_context(point_count)
  -- Same complete one-input/one-output boundary as a causal step, but the input
  -- is consumed independently while the output is freshly created.
  point_count=point_count or 1
  local g={membranes={{parent=0}},points={},strands={},faces={}}
 local a,b={},{ }
  for i=1,point_count do g.points[#g.points+1]={membrane=1}
 a[i]=#g.points end
  for i=1,point_count do g.points[#g.points+1]={membrane=1}
 b[i]=#g.points end
  local si=strand(g,1,a)
 local so=strand(g,1,b)
  g.faces[1]={membrane=1,inputs={si},outputs={}}
  g.faces[2]={membrane=1,inputs={},outputs={so}}
  return Context.closed({geometry=g,theory=top(),authority={inputs={si},outputs={so}},values={inputs={},outputs={}}})
end

function M.unary_context(target,opts)
  opts=opts or {}
 local pc=opts.points or 1
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local function one()
    local ps={}
 for i=1,pc do g.points[#g.points+1]={membrane=1}
 ps[i]=#g.points end
    return strand(g,1,ps)
  end
  local outer_in=one()
 local hole_in=one()
 local hole_out=one()
 local outer_out=hole_out
  if opts.prefix~=false then g.faces[#g.faces+1]={membrane=1,inputs={outer_in},outputs={hole_in}} end
  if opts.suffix then outer_out=one()
 g.faces[#g.faces+1]={membrane=1,inputs={hole_out},outputs={outer_out}} end
  return Context.normal({template={geometry=g,theory=top(),authority={inputs={outer_in,hole_out},outputs={hole_in,outer_out}},values={inputs={},outputs={}}},
    outer={authority={inputs={1},outputs={2}},values={inputs={},outputs={}}},holes={{target=target,authority={to_target={1},from_target={2}},values={to_target={},from_target={}}}}})
end

function M.guarded_identity_context(point_count,guard)
  point_count=point_count or 1
  local g={membranes={{parent=0}},points={},strands={},faces={}}
 local ps={}
  for i=1,point_count do g.points[#g.points+1]={membrane=1}
 ps[i]=#g.points end
  local s=strand(g,1,ps)
 g.points[#g.points+1]={membrane=1}
 local vp=#g.points
  local ctx={{point=vp,sort='bool',values={false,true}}}
 local theory=K.point_value(ctx,vp,guard)
  return Context.closed({geometry=g,theory=K.spec(theory),authority={inputs={s},outputs={s}},values={inputs={vp},outputs={}}})
end



function M.bool_authority_context(point_count,guard)
  point_count=point_count or 1
  local g={membranes={{parent=0}},points={},strands={},faces={}}
 local ps={}
  for i=1,point_count do g.points[#g.points+1]={membrane=1}
 ps[i]=#g.points end
  local s=strand(g,1,ps)
 g.points[#g.points+1]={membrane=1}
 local vp=#g.points
  local ctx={{point=vp,sort='bool',values={false,true}}}
 local theory=K.top(ctx)
  if guard~=nil then theory=K.point_value(ctx,vp,guard) end
  return Context.closed({geometry=g,theory=K.spec(theory),authority={inputs={s},outputs={s}},values={inputs={vp},outputs={}}})
end

function M.two_port_context(count1,count2)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
 local ports={}
  for _,n in ipairs({count1,count2}) do local ps={}
 for i=1,n do g.points[#g.points+1]={membrane=1}
 ps[i]=#g.points end
 ports[#ports+1]=strand(g,1,ps) end
  return Context.closed({geometry=g,theory=top(),authority={inputs={ports[1],ports[2]},outputs={ports[1],ports[2]}},values={inputs={},outputs={}}})
end

function M.diamond_context()
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,6 do g.points[i]={membrane=1} end
  for i=1,6 do g.strands[i]={membrane=1,points={i}} end
  g.faces[1]={membrane=1,inputs={1},outputs={2,3}}
  g.faces[2]={membrane=1,inputs={2},outputs={4}}
  g.faces[3]={membrane=1,inputs={3},outputs={5}}
  g.faces[4]={membrane=1,inputs={4,5},outputs={6}}
  return Context.closed({geometry=g,theory=top(),authority={inputs={1},outputs={6}},values={inputs={},outputs={}}})
end

function M.two_authority_identity_context(shared_point,shared_membrane)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local m1=1
 local m2
  if shared_membrane then m2=1 else g.membranes[2]={parent=0}
 m2=2 end
  g.points[1]={membrane=m1}
 local p2
  if shared_point then p2=1 else g.points[2]={membrane=m2}
 p2=2 end
  local s1=strand(g,m1,{1})
 local s2=strand(g,m2,{p2})
  return Context.closed({geometry=g,theory=top(),authority={inputs={s1,s2},outputs={s1,s2}},values={inputs={},outputs={}}})
end

function M.rec_package(definitions)
  return RP.new({definitions=definitions})
end

function M.one_root(identity,alternatives,prefers)
  return M.rec_package({{identity=identity,alternatives=alternatives,prefers=prefers or {}}})
end

function M.state_one(point_count)
  point_count=point_count or 1
 local b=W.builder()
 local m=b:membrane(nil)
 local ps={}
  for i=1,point_count do ps[i]=b:point(m) end
  local s=b:strand(m,ps)
 return b:finish(),{s}
end

function M.state_two(shared_point,shared_membrane)
  local b=W.builder()
 local m1=b:membrane(nil)
 local m2=shared_membrane and m1 or b:membrane(nil)
  local p1=b:point(m1)
 local p2=shared_point and p1 or b:point(m2)
  local s1=b:strand(m1,{p1})
 local s2=b:strand(m2,{p2})
 return b:finish(),{s1,s2}
end

function M.state_bool(value)
  local ctx={{point='i1',sort='bool',values={false,true}}}
 if value==nil then return K.top(ctx) end
  return K.point_value(ctx,'i1',value)
end
function M.empty_knowledge() return K.top({}) end

return M
