package.path='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;'..package.path
local C=require('speculation.relay.computation.formed_computation.calculus')
local Context=C.Context()
local Package=C.Package()
local T=C.Equality()
local G=C.Geometry()
local Family=C.Family()
local Canonical=require('speculation.relay.computation.development_calculus.canonical')
local M={C=C,Context=Context,Package=Package,T=T,G=G,Family=Family,Canonical=Canonical}

function M.counter()
  local n=0
  local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
  local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b)) end
  return ok,eq,function() return n end
end

function M.value_context(value,opts)
  opts=opts or {}
  local ai,ao=opts.authority_inputs or 0,opts.authority_outputs or 0
  local geometry,ports=G.operation(ai,ao)
  local vars,eqs={},{}
  local vin,vout={},{}
  if opts.input then vars[#vars+1]='x'
 vin={'x'} end
  if value~=nil then vars[#vars+1]='y'
 vout={'y'}
 eqs[#eqs+1]=T.eq(T.var('y'),value) end
  return Context.closed({geometry=geometry,theory={variables=vars,equalities=eqs},
    authority={inputs=ports.inputs,outputs=ports.outputs},values={inputs=vin,outputs=vout}})
end

function M.identity_value_context()
  return Context.closed({geometry={membranes={},points={},strands={},faces={}},
    theory={variables={'x','y'},equalities={T.eq(T.var('x'),T.var('y'))}},
    authority={inputs={},outputs={}},values={inputs={'x'},outputs={'y'}}})
end

function M.package(identity,alternatives,prefers)
  return Package.new({definitions={{identity=identity,alternatives=alternatives,prefers=prefers or {}}}})
end

function M.link(xs) return Package.link(xs) end
function M.roundtrip(p) return Package.decode(p:bytes()) end

function M.output_value(p,alt,pos)
  local a=p:alternative(alt or 1)
  local name=a.values.outputs[pos or 1]
  return name and T.value(a.theory,name) or nil
end

function M.faces(p,alt)
  return #(p:alternative(alt or 1).geometry.faces or {})
end

function M.form_family(roots,captures)
  local items={}
  for i,r in ipairs(roots) do
    local c=C.form_context(r,captures or 0)
    items[i]=assert(Context.plug(c,{}))
  end
  return Family.new(items,{})
end

return M
