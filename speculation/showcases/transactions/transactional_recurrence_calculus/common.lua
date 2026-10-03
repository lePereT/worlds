package.path='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;'..package.path
local Canonical=require('speculation.showcases.transactions.transactional_development_calculus.canonical')
local C=require('speculation.showcases.transactions.transactional_development_calculus.calculus')
local FP=require('speculation.showcases.transactions.transactional_development_calculus.package')
local Family=require('speculation.showcases.transactions.transactional_development_calculus.family')
local Template=require('speculation.showcases.transactions.transactional_development_calculus.template')
local T=require('speculation.showcases.transactions.transactional_development_calculus.theory')
local Context=require('speculation.showcases.transactions.transactional_recurrence_calculus.context')
local RP=require('speculation.showcases.transactions.transactional_recurrence_calculus.package')
local Unfold=require('speculation.showcases.transactions.transactional_recurrence_calculus.unfold')
local M={Canonical=Canonical,C=C,FP=FP,Family=Family,Template=Template,T=T,
  Context=Context,RP=RP,Unfold=Unfold}

function M.counter()
  local n=0
  local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
  local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b)) end
  return ok,eq,function() return n end
end

local function unary_geometry(prefix,suffix)
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local function strand()
    g.points[#g.points+1]={membrane=1}
    g.strands[#g.strands+1]={membrane=1,points={#g.points}}
    return #g.strands
  end
  local outer_in=strand()
  local hole_in=strand()
  local hole_out=strand()
  local outer_out=hole_out
  if prefix then g.faces[#g.faces+1]={membrane=1,inputs={outer_in},outputs={hole_in}} end
  if suffix then
    outer_out=strand()
    g.faces[#g.faces+1]={membrane=1,inputs={hole_out},outputs={outer_out}}
  end
  return g,outer_in,hole_in,hole_out,outer_out
end

function M.authority_identity_context()
  local g={membranes={{parent=0}},points={{membrane=1}},
    strands={{membrane=1,points={1}}},faces={}}
  return Context.closed({geometry=g,theory={variables={},equalities={}},
    authority={inputs={1},outputs={1}},values={inputs={},outputs={}}})
end


function M.authority_value_identity_context()
  local g={membranes={{parent=0}},points={{membrane=1}},
    strands={{membrane=1,points={1}}},faces={}}
  return Context.closed({geometry=g,theory={variables={'x','y'},equalities={{a=T.var('x'),b=T.var('y')}}},
    authority={inputs={1},outputs={1}},values={inputs={'x'},outputs={'y'}}})
end

function M.unary_context(target,opts)
  opts=opts or {}
  local g,outer_in,hole_in,hole_out,outer_out=unary_geometry(opts.prefix~=false,opts.suffix)
  local vars,eqs,vin,vout={},{},{},{}
  local outer={authority={inputs={1},outputs={2}},values={inputs={},outputs={}}}
  local hole={target=target,authority={to_target={1},from_target={2}},
    values={to_target={},from_target={}}}
  local authority={inputs={outer_in,hole_out},outputs={hole_in,outer_out}}
  if opts.values then
    vars={'x','return','call','y'}
    -- wrapper inputs: outer x, recursive return; outputs: recursive call, outer y
    vin={'x','return'}
 vout={'call','y'}
    eqs={{a=T.var('x'),b=T.var('call')},{a=T.var('return'),b=T.var('y')}}
    outer.values={inputs={1},outputs={2}}
    hole.values={to_target={1},from_target={2}}
  end
  return Context.normal({template={geometry=g,theory={variables=vars,equalities=eqs},
    authority=authority,values={inputs=vin,outputs=vout}},outer=outer,holes={hole}})
end

function M.closed_value(value)
  return Context.closed({geometry={membranes={},points={},strands={},faces={}},
    theory={variables={'y'},equalities={{a=T.var('y'),b=value}}},
    authority={inputs={},outputs={}},values={inputs={},outputs={'y'}}})
end

function M.identity_value_context()
  return Context.closed({geometry={membranes={},points={},strands={},faces={}},
    theory={variables={'x','y'},equalities={{a=T.var('x'),b=T.var('y')} }},
    authority={inputs={},outputs={}},values={inputs={'x'},outputs={'y'}}})
end


function M.closed_chain_context(n)
  assert(type(n)=='number' and n%1==0 and n>=0,'closed chain length required')
  if n==0 then return Context.closed({geometry={membranes={},points={},strands={},faces={}},
    theory={variables={},equalities={}},authority={inputs={},outputs={}},values={inputs={},outputs={}}}) end
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  local strands={}
  for i=1,n-1 do
    g.points[i]={membrane=1}
 g.strands[i]={membrane=1,points={i}}
 strands[i]=i
  end
  for i=1,n do
    g.faces[i]={membrane=1,inputs=i==1 and {} or {strands[i-1]},
      outputs=i==n and {} or {strands[i]}}
  end
  return Context.closed({geometry=g,theory={variables={},equalities={}},
    authority={inputs={},outputs={}},values={inputs={},outputs={}}})
end

function M.zero_hole_context(targets)
  local holes={}
  for i,t in ipairs(targets) do holes[i]={target=t,authority={to_target={},from_target={}},
    values={to_target={},from_target={}}} end
  return Context.normal({template={geometry={membranes={},points={},strands={},faces={}},
    theory={variables={},equalities={}},authority={inputs={},outputs={}},values={inputs={},outputs={}}},
    outer={authority={inputs={},outputs={}},values={inputs={},outputs={}}},holes=holes})
end

function M.rec_package(identity,alternatives,prefers)
  return RP.new({definitions={{identity=identity,alternatives=alternatives,prefers=prefers or {}}}})
end

function M.item_bytes(finite_package)
  local out={}
  for _,x in ipairs(finite_package:family().items) do out[#out+1]=Canonical.encode(x) end
  table.sort(out)
  return out
end

function M.item_set(finite_package)
  local out={}
  for _,x in ipairs(M.item_bytes(finite_package)) do out[x]=true end
  return out
end

function M.contains_items(a,b)
  local bs=M.item_set(b)
  for _,x in ipairs(M.item_bytes(a)) do if not bs[x] then return false end end
  return true
end


function M.reach(f,a,b)
  local n=#f.items
 local r={}
 for i=1,n do r[i]={} end
  for _,e in ipairs(f.edges) do r[e[1]][e[2]]=true end
  for k=1,n do for i=1,n do if r[i][k] then for j=1,n do if r[k][j] then r[i][j]=true end end end end end
  return r[a][b] or false
end

function M.roundtrip(p) return RP.decode(p:bytes()) end

return M
