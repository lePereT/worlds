package.path='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;'..package.path
local W=require('worlds')
local C=require('speculation.showcases.transactions.transactional_development_calculus.calculus')
local T=C.Theory()
local P=C.Package()
local G=C.Geometry()
local M={W=W,C=C,T=T,P=P,G=G}
function M.counter()
  local n=0
  local function ok(x,msg) n=n+1
 assert(x,msg or 'assertion failed') end
  local function eq(a,b,msg) n=n+1
 assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b)) end
  return ok,eq,function() return n end
end
function M.roundtrip(p) return P.decode(p:bytes()) end
function M.out_value(p,alt,pos)
  local a=p:alternative(alt or 1)
 local name=a.values.outputs[pos or 1]
  return name and T.value(a.theory,name) or nil
end
function M.in_value(p,alt,pos)
  local a=p:alternative(alt or 1)
 local name=a.values.inputs[pos or 1]
  return name and T.value(a.theory,name) or nil
end
function M.branch(values,opts)
  opts=opts or {}
 local items={}
  for _,row in ipairs(values) do
    local geom,ports=G.operation(opts.auth and 1 or 0,opts.auth and 1 or 0)
    items[#items+1]={geometry=geom,
      theory={variables={'x','y'},equalities={T.eq(T.var('x'),row[1]),T.eq(T.var('y'),row[2])}},
      authority={inputs=ports.inputs,outputs=ports.outputs},values={inputs={'x'},outputs={'y'}}}
  end
  return P.new({items=items,edges=opts.edges or {}})
end
function M.identity_operation()
  local geom,ports=G.operation(1,1)
  return C.atom({geometry=geom,theory={variables={'x','y'},equalities={T.eq(T.var('x'),T.var('y'))}},
    authority={inputs=ports.inputs,outputs=ports.outputs},values={inputs={'x'},outputs={'y'}}})
end
function M.live(n)
  local b=W.builder()
 local m=b:membrane(nil)
 local role=b:point(m)
  local xs={}
 for i=1,n do xs[i]=b:strand(m,{role}) end
  return b:finish(),xs
end
function M.reach(f,a,b)
  local n=#f.items
 local r={}
 for i=1,n do r[i]={} end
  for _,e in ipairs(f.edges) do r[e[1]][e[2]]=true end
  for k=1,n do for i=1,n do if r[i][k] then for j=1,n do if r[k][j] then r[i][j]=true end end end end end
  return r[a][b] or false
end
function M.fanout(n)
  local g={membranes={{parent=0}},points={{membrane=1}},strands={},faces={}}
  local function strand() g.strands[#g.strands+1]={membrane=1,points={1}}
 return #g.strands end
  local input,output=strand(),strand()
  if n==0 then g.faces[1]={membrane=1,inputs={input},outputs={output}}
  else
    local mids={}
 for i=1,n do mids[i]=strand() end
    g.faces[#g.faces+1]={membrane=1,inputs={input},outputs=mids}
    local dones={}
 for i=1,n do dones[i]=strand()
 g.faces[#g.faces+1]={membrane=1,inputs={mids[i]},outputs={dones[i]}} end
    g.faces[#g.faces+1]={membrane=1,inputs=dones,outputs={output}}
  end
  return g,input,output
end
return M
