package.path='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;'..package.path
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local Family=require('speculation.relay.computation.development_calculus.family')
local K=require('speculation.relay.computation.recursive_judgement.knowledge')
local Template=require('speculation.relay.computation.recursive_judgement.template')
local Context=require('speculation.relay.computation.recursive_judgement.context')
local RP=require('speculation.relay.computation.recursive_judgement.package')
local Search=require('speculation.relay.computation.recursive_judgement.search')
local Analysis=require('speculation.relay.computation.recursive_judgement.analysis')
local Judgement=require('speculation.relay.computation.recursive_judgement.judgement')
local M={Canonical=Canonical,Family=Family,K=K,Template=Template,Context=Context,RP=RP,Search=Search,Analysis=Analysis,Judgement=Judgement}

function M.counter()
  local n=0
  local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
  local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b)) end
  return ok,eq,function() return n end
end

local BOOL={false,true}
function M.bool_context(points)
  local out={}
 for i,p in ipairs(points) do out[i]={point=p,sort='bool',values=BOOL} end
 return out
end
function M.bool_relation(points,predicate) return K.relation(M.bool_context(points),predicate) end

local function value_geometry(n)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,n do g.points[i]={membrane=1} end
  return g
end

function M.closed_bool(value)
  local ctx=M.bool_context({1})
 local theory=K.point_value(ctx,1,value)
  return Context.closed({geometry=value_geometry(1),theory=K.spec(theory),authority={inputs={},outputs={}},values={inputs={},outputs={1}}})
end

function M.bool_identity_context(guard)
  local ctx=M.bool_context({1,2})
 local theory=K.points_equal(ctx,1,2)
  if guard~=nil then theory=K.meet(theory,K.point_value(ctx,1,guard)) end
  return Context.closed({geometry=value_geometry(2),theory=K.spec(theory),authority={inputs={},outputs={}},values={inputs={1},outputs={2}}})
end

function M.unary_bool_context(target,guard,flip)
  -- Points: outer input, recursive return, recursive call, outer output.
  local ctx=M.bool_context({1,2,3,4})
  local theory=K.relation(ctx,function(v)
    local call=v[1]
 if flip then call=not v[1] end
    return v[3]==call and v[4]==v[2] and (guard==nil or v[1]==guard)
  end)
  return Context.normal({template={geometry=value_geometry(4),theory=K.spec(theory),authority={inputs={},outputs={}},values={inputs={1,2},outputs={3,4}}},
    outer={authority={inputs={},outputs={}},values={inputs={1},outputs={2}}},
    holes={{target=target,authority={to_target={},from_target={}},values={to_target={1},from_target={2}}}}})
end

function M.base_bool_context(guard,value_transform)
  local ctx=M.bool_context({1,2})
 local theory=K.relation(ctx,function(v)
    local out=value_transform and value_transform(v[1]) or v[1]
    return v[2]==out and (guard==nil or v[1]==guard)
  end)
  return Context.closed({geometry=value_geometry(2),theory=K.spec(theory),authority={inputs={},outputs={}},values={inputs={1},outputs={2}}})
end


function M.authority_identity_context()
  local g={membranes={{parent=0}},points={{membrane=1}},strands={{membrane=1,points={1}}},faces={}}
  return Context.closed({geometry=g,theory=K.spec(K.top({})),authority={inputs={1},outputs={1}},values={inputs={},outputs={}}})
end

function M.rec_package(identity,alternatives,prefers)
  return RP.new({definitions={{identity=identity,alternatives=alternatives,prefers=prefers or {}}}})
end

function M.state_bool(value)
  local ctx={{point='i1',sort='bool',values=BOOL}}
  if value==nil then return K.top(ctx) end
  return K.point_value(ctx,'i1',value)
end

function M.row_count(k) local n=0
 for _ in pairs(K.normal(k).rows) do n=n+1 end
 return n end
function M.roundtrip(p) return RP.decode(p:bytes()) end

return M
