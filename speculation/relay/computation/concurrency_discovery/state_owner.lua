-- Grounded persistent-state protocol experiment.
-- State authority is captured causally before request matching; client requests remain ordinary open computations.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}

local function state_record(kind,cell,payload)
  local r={protocol='relay.state.owner',cell=T.var('cell'),state=kind}
  if payload then r.payload=T.var('payload') end
  return r
end

function M.seed_empty(cell)
  local g,p=G.operation(0,1)
  return C.atom({geometry=g,theory={variables={'cell','state','observed'},equalities={T.eq(T.var('cell'),cell),
      T.eq(T.var('state'),'empty'),T.eq(T.var('observed'),'relay.none')}},
    support={strands={[p.outputs[1]]=state_record('empty',cell,false)}},
    authority={inputs={},outputs=p.outputs},values={inputs={},outputs={'state','observed'}}})
end

function M.seed_full(cell,value)
  local g,p=G.operation(0,1)
  return C.atom({geometry=g,theory={variables={'cell','payload','state','observed'},equalities={
      T.eq(T.var('cell'),cell),T.eq(T.var('payload'),value),T.eq(T.var('state'),'full'),
      T.eq(T.var('observed'),T.var('payload'))}},
    support={strands={[p.outputs[1]]=state_record('full',cell,true)}},
    authority={inputs={},outputs=p.outputs},values={inputs={},outputs={'state','observed'}}})
end

local function seam(phase,op,cell,payload)
  local r={protocol='relay.state.'..phase,operation=op,cell=T.var('cell')}
  if payload then r.payload=T.var('payload') end
  return r
end

local function handler(from_state,to_state,op,opts)
  opts=opts or {}
  local g,p=G.operation(2,3) -- state + request -> next-state + reply + server continuation
  local vars={'cell','state','observed'}
  if opts.payload then vars[#vars+1]='payload' end
  local eqs={T.eq(T.var('state'),to_state)}
  if opts.to_payload then eqs[#eqs+1]=T.eq(T.var('observed'),T.var('payload'))
  else eqs[#eqs+1]=T.eq(T.var('observed'),'relay.none') end
  local support={strands={}}
  support.strands[p.inputs[1]]=state_record(from_state,nil,opts.from_payload)
  support.strands[p.inputs[2]]=seam('request',op,nil,opts.request_payload)
  support.strands[p.outputs[1]]=state_record(to_state,nil,opts.to_payload)
  support.strands[p.outputs[2]]=seam('reply',op,nil,opts.reply_payload)
  return C.atom({geometry=g,theory={variables=vars,equalities=eqs},support=support,
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={2},outputs={2}}},
    values={inputs={},outputs={'state','observed'}}})
end

function M.server()
  return C.choice(
    handler('empty','full','put',{payload=true,request_payload=true,to_payload=true}),
    C.choice(
      handler('full','empty','take',{payload=true,from_payload=true,reply_payload=true}),
      handler('full','full','read',{payload=true,from_payload=true,to_payload=true,reply_payload=true})
    )
  )
end

local function request(op,cell,value)
  local g,p=G.operation(1,2) -- reply -> offer + caller continuation
  local vars={'cell'}
  if op=='put' or op=='take' or op=='read' then vars[#vars+1]='payload' end
  local eqs={T.eq(T.var('cell'),cell)}
  if op=='put' then eqs[#eqs+1]=T.eq(T.var('payload'),value) end
  local support={strands={}}
  support.strands[p.inputs[1]]=seam('reply',op,cell,op~='put')
  support.strands[p.outputs[1]]=seam('request',op,cell,op=='put')
  local values={inputs={},outputs={}}
  if op=='take' or op=='read' then values.outputs={'payload'} end
  return C.atom({geometry=g,theory={variables=vars,equalities=eqs},support=support,
    authority={inputs=p.inputs,outputs=p.outputs,open={inputs={1},outputs={1}}},values=values})
end

function M.put(cell,value) return request('put',cell,value) end
function M.take(cell) return request('take',cell) end
function M.read(cell) return request('read',cell) end

local function state_output_position(package)
  local pos=nil
  for _,a in ipairs(package:family().items) do
    local found=nil
    for i,si in ipairs(a.authority.outputs) do
      local r=a.support and a.support.strands and a.support.strands[si]
      if r and r.protocol=='relay.state.owner' then assert(not found,'multiple owner-state outputs'); found=i end
    end
    assert(found,'state package has no owner-state output')
    if pos then assert(pos==found,'state output position differs across alternatives') else pos=found end
  end
  return pos
end

function M.ground(state)
  return C.and_then(state,M.server(),{value_pairs={},captures={{from=state_output_position(state),to=1}}})
end

function M.step(state,request_package)
  return C.together({M.ground(state),request_package})
end


function M.stable_reader()
  return C.atom({geometry=G.empty(),theory={variables={'state','observed','result'},equalities={
      T.eq(T.var('state'),'full'),T.eq(T.var('result'),T.var('observed'))}},
    authority={inputs={},outputs={}},values={inputs={'state','observed'},outputs={'result'}}})
end

function M.stable_view(state)
  return C.and_then(state,M.stable_reader(),{value_pairs={{from=1,to=1},{from=2,to=2}},captures={}})
end

return M
