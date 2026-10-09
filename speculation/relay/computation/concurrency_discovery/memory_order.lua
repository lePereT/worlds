-- Minimal memory-order pressure.  Per-location state authority orders operations on one cell;
-- distinct cells remain unordered.  Release/acquire adds one explicit cross-location sync Strand.
local C=require('speculation.relay.computation.development_calculus.calculus')
local T=C.Equality()
local G=C.Geometry()
local M={}
local function state(cell) return {protocol='relay.atomic.state',cell=T.var('cell')} end
local function sync() return {protocol='relay.atomic.order',order='release-acquire'} end
function M.seed(cell)
  local g,p=G.operation(0,1)
  return C.atom({geometry=g,theory={variables={'cell'},equalities={T.eq(T.var('cell'),cell)}},
    support={strands={[p.outputs[1]]=state(cell)}},authority={inputs={},outputs=p.outputs},values={inputs={},outputs={}}})
end
local function op(cell,kind)
  local nin,nout=1,1
  if kind=='release' then nout=2 elseif kind=='acquire' then nin=2 end
  local g,p=G.operation(nin,nout)
  local support={strands={}}
  support.strands[p.inputs[1]]=state(cell); support.strands[p.outputs[1]]=state(cell)
  if kind=='release' then support.strands[p.outputs[2]]=sync()
  elseif kind=='acquire' then support.strands[p.inputs[2]]=sync() end
  return C.atom({geometry=g,theory={variables={'cell'},equalities={T.eq(T.var('cell'),cell)}},support=support,
    authority={inputs=p.inputs,outputs=p.outputs},values={inputs={},outputs={}}})
end
function M.relaxed(cell) return op(cell,'relaxed') end
function M.release(cell) return op(cell,'release') end
function M.acquire(cell) return op(cell,'acquire') end
local function output_position(package,protocol,cell)
  local a=package:alternative(1)
  for i,si in ipairs(a.authority.outputs) do
    local r=a.support and a.support.strands and a.support.strands[si]
    if r and r.protocol==protocol then
      if not cell then return i end
      local v=T.is_var(r.cell) and T.value(a.theory,r.cell.var) or r.cell
      if v==cell then return i end
    end
  end
  return nil
end
function M.step(seed,operation)
  local pos=assert(output_position(seed,'relay.atomic.state'),'state authority missing')
  return C.and_then(seed,operation,{value_pairs={},captures={{from=pos,to=1}}})
end
function M.output_position(...) return output_position(...) end
return M
