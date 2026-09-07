local unpack=table.unpack or unpack
local W=require('worlds'); local G=W.Geometry
local C={}; C.__index=C

local function cp(t) local r={}; for k,v in pairs(t or {}) do r[k]=v end; return r end
local function clone(s) return {geometry=s.geometry,env=cp(s.env),theory=cp(s.theory),resources=cp(s.resources),tasks=cp(s.tasks),handlers=cp(s.handlers),trace={unpack(s.trace or {})},unknown=s.unknown} end
local function remap_table(src,map)
  local r={}; for k,v in pairs(src or {}) do local nk=map[k] or k; if type(v)=='table' and v.__point then r[nk]={__point=true,p=map[v.p] or v.p} else r[nk]=v end end; return r
end
local function remap_state(s,g,img)
  local n=clone(s); n.geometry=g
  for k,p in pairs(n.env) do n.env[k]=img.points[p] or p end
  local nt={}; for p,v in pairs(n.theory) do nt[img.points[p] or p]=v end; n.theory=nt
  local nr={}; for p,v in pairs(n.resources) do nr[img.points[p] or p]=v end; n.resources=nr
  local tasks={}; for p,v in pairs(n.tasks) do tasks[img.points[p] or p]=img.points[v] or v end; n.tasks=tasks
  return n
end
local function add_geometry(s,x)
  local g,imgs=W.Algebra.tensor{s.geometry,x}; return remap_state(s,g,imgs[1]),imgs[2]
end
local function apply(s,proc,cut)
  local g,img=W.Algebra.apply(s.geometry,proc,cut); return remap_state(s,g,img.left),img.right,img.left
end

function C.new(ast)
  local self=setmetatable({ast=ast,atoms={},functions={},resource_types={},providers={},effect_ops={},trace={}},C)
  for _,d in ipairs(ast.interfaces) do for _,op in ipairs(d.ops) do self.providers[d.name..'.'..op]=self.providers[d.name..'.'..op] or {} end end
  for _,d in ipairs(ast.effects) do for _,op in ipairs(d.ops) do self.effect_ops[d.name..'.'..op]=true end end
  for _,d in ipairs(ast.resources) do self.resource_types[d.name]=d; for _,p in ipairs(d.providers) do self.providers[p.operation]=self.providers[p.operation] or {}; local row=cp(p); row.resource=d.name; row.state=d.state; self.providers[p.operation][#self.providers[p.operation]+1]=row end end
  for _,f in ipairs(ast.functions) do self.functions[f.name]=f end
  local b=G.builder(); b:membrane(nil,'initial'); self.initial={geometry=b:finish(),env={},theory={},resources={},tasks={},handlers={},trace={}}
  return self
end
function C:atom(name)
  local p=self.atoms[name]; if p then return p end
  local b=G.builder(); local m=b:membrane(nil,'atom'); p=b:point(m,name); b:finish(); self.atoms[name]=p; return p
end
function C:state_role(resdecl) return self:atom('state:'..resdecl.state) end
function C:task_role() return self:atom('task-live') end

function C:literal(s,n)
  local b=G.builder(); local m=b:membrane(nil,'literal'); local p=b:point(m,tostring(n)); local x=b:finish(); local ns,img=add_geometry(s,x); local q=img.points[p]; ns.theory[q]=n; return ns,q
end
function C:new_resource(s,name,init)
  local d=assert(self.resource_types[name],'unknown resource '..name); local b=G.builder(); local m=b:membrane(nil,name); local id=b:point(m,name); local val=b:point(m,'state'); b:strand(m,{self:state_role(d),id,val}); local ns,img=add_geometry(s,b:finish()); local rid,rval=img.points[id],img.points[val]; ns.resources[rid]=d; ns.theory[rval]=init; return ns,rid
end
local function terminal_state(s,role,rid)
  local out={}; for _,st in ipairs(s.geometry:egress()) do local pts=G.points(st); if pts[1]==role and (not rid or pts[2]==rid) then out[#out+1]=st end end; return out
end

function C:provider_process(row)
  local b=G.builder(); local m=b:membrane(nil,'provider'); local x=b:point(m,'resource'); local old=b:point(m,'old'); local new=b:point(m,'new'); local role=self:state_role(self.resource_types[row.resource]); local si=b:strand(m,{role,x,old}); local so=b:strand(m,{role,x,new}); b:face(m,{si},{so}); return b:finish(),{x=x,old=old,new=new,input=si,output=so,row=row}
end
function C:provider_plans(s,op,rid,seen)
  seen=seen or {}; local key=op..'@'..tostring(rid); if seen[key] then return nil,'Unknown' end
  local rows=self.providers[op] or {}; if #rows==0 then return {},'Retry' end
  local out={}; local nextseen=cp(seen); nextseen[key]=true
  for _,row in ipairs(rows) do
    local d=s.resources[rid]
    if d and d.name==row.resource then
      if row.via then
        local ps,status=self:provider_plans(s,row.via,rid,nextseen); if status=='Unknown' then return nil,'Unknown' end
        for _,p in ipairs(ps or {}) do local q=cp(p); q.via=(q.via or 0)+1; q.source_op=op; out[#out+1]=q end
      else
        local proc,meta=self:provider_process(row); out[#out+1]={proc=proc,meta=meta,rid=rid,from=row.from,to=row.to,value=row.value,op=op,via=0}
      end
    end
  end
  if #out==0 then return {},'Retry' end; return out,'Hit'
end
function C:apply_plan(s,plan)
  local cuts=W.Cut.all(plan.proc,{offers=s.geometry:egress()}); local outs={}
  for _,cut in ipairs(cuts) do
    if cut:point(plan.meta.x)==plan.rid then
      local old=cut:point(plan.meta.old); local ov=s.theory[old]; local accepted=(plan.from==nil or ov==plan.from)
      if accepted then
        local ns,img=apply(s,plan.proc,cut); local new=img.points[plan.meta.new]; ns.theory[new]=(plan.to~=nil and plan.to or plan.value); ns.trace[#ns.trace+1]={kind='provider',name=plan.op,via=plan.via}; outs[#outs+1]={state=ns,result=new}
      end
    end
  end
  return outs
end
function C:call_op(s,op,rid,seen)
  local plans,status=self:provider_plans(s,op,rid,seen); if status=='Unknown' then return {kind='Unknown'} end; if status=='Retry' then return {kind='Retry'} end
  local outs={}; for _,p in ipairs(plans) do for _,x in ipairs(self:apply_plan(s,p)) do outs[#outs+1]=x end end
  if #outs==0 then return {kind='Retry'} end; return {kind='Hit',outs=outs}
end

function C:call_plan_choices(s,e)
  local rid=assert(s.env[e.args[1].name],'operation argument must be named resource in tiny experiment'); return self:provider_plans(s,e.callee,rid)
end
function C:each_or_together(s,args,mode)
  local choices={}
  for i,e in ipairs(args) do if e.kind~='call' then return {kind='Retry'} end; local ps,status=self:call_plan_choices(s,e); if status=='Unknown' then return {kind='Unknown'} elseif status=='Retry' then return {kind='Retry'} end; choices[i]=ps end
  local combos={{}}
  for i=1,#choices do local nx={}; for _,prefix in ipairs(combos) do for _,p in ipairs(choices[i]) do local q={unpack(prefix)}; q[#q+1]=p; nx[#nx+1]=q end end; combos=nx end
  local results={}
  for _,plans in ipairs(combos) do
    local proc,imgs,ordered
    if mode=='each' then
      local parts={}; for i,p in ipairs(plans) do parts[i]=p.proc end; proc,imgs=W.Algebra.tensor(parts)
    else
      -- For each resource, find a Theory-compatible path beginning at current state.
      local parts={}; for i,p in ipairs(plans) do parts[i]=p.proc end
      local links={}; local groups={}; for i,p in ipairs(plans) do local k=p.rid; groups[k]=groups[k] or {}; groups[k][#groups[k]+1]=i end
      local valid=true
      for rid,idxs in pairs(groups) do
        if #idxs>1 then
          local stateStrands=terminal_state(s,self:state_role(s.resources[rid]),rid); local current=stateStrands[1] and s.theory[G.points(stateStrands[1])[3]]
          local function perm(a,k)
            if k>#a then
              if plans[a[1]].from~=current then return nil end
              for j=1,#a-1 do if plans[a[j]].to~=plans[a[j+1]].from then return nil end end
              return {unpack(a)}
            end
            for j=k,#a do a[k],a[j]=a[j],a[k]; local r=perm(a,k+1); if r then return r end; a[k],a[j]=a[j],a[k] end
          end
          local a={unpack(idxs)}; local seq=perm(a,1); if not seq then valid=false; break end
          for j=1,#seq-1 do links[#links+1]={plans[seq[j]].meta.output,plans[seq[j+1]].meta.input} end
        end
      end
      if valid then proc,imgs=W.Algebra.close(parts,links) end
    end
    if proc then
      local cuts=W.Cut.all(proc,{offers=s.geometry:egress()})
      for _,cut in ipairs(cuts) do
        local good=true
        for i,p in ipairs(plans) do local mx=imgs[i].points[p.meta.x]; local old=imgs[i].points[p.meta.old]; if cut:point(mx) and cut:point(mx)~=p.rid then good=false; break end; local oldsrc=cut:point(old); if oldsrc and p.from~=nil and s.theory[oldsrc]~=p.from then good=false; break end end
        if good then
          local ns,rimg=apply(s,proc,cut); local lane_results={}
          for i,p in ipairs(plans) do local cpnt=imgs[i].points[p.meta.new]; local new=rimg.points[cpnt]; ns.theory[new]=(p.to~=nil and p.to or p.value); lane_results[i]=new end
          ns.trace[#ns.trace+1]={kind=mode,name=mode}; results[#results+1]={state=ns,result=lane_results[#lane_results]}
        end
      end
    end
  end
  if #results==0 then return {kind='Retry'} end
  -- quotient exact provider schedule multiplicity by observable current resource states/result values.
  local uniq={}; local out={}
  for _,x in ipairs(results) do
    local sig={tostring(x.state.theory[x.result])}; local ids={}; for rid in pairs(x.state.resources) do ids[#ids+1]=rid end; table.sort(ids,function(a,b)return tostring(a)<tostring(b)end)
    for _,rid in ipairs(ids) do local st=terminal_state(x.state,self:state_role(x.state.resources[rid]),rid)[1]; sig[#sig+1]=tostring(st and x.state.theory[G.points(st)[3]]) end
    local k=table.concat(sig,'|'); if not uniq[k] then uniq[k]=true; out[#out+1]=x end
  end
  return {kind='Hit',outs=out}
end

function C:spawn(s,e)
  local r=self:eval_expr(s,e); if r.kind~='Hit' or #r.outs~=1 then return r end; local x=r.outs[1]; local b=G.builder(); local m=b:membrane(nil,'task'); local task=b:point(m,'task'); local live=b:strand(m,{self:task_role(),task,x.result}); local ns,img=add_geometry(x.state,b:finish()); local t=img.points[task]; ns.tasks[t]=img.points[x.result] or x.result; ns.trace[#ns.trace+1]={kind='spawn'}; return {kind='Hit',outs={{state=ns,result=t}}}
end
function C:join(s,e)
  local rr=self:eval_expr(s,e); if rr.kind~='Hit' then return rr end; local outs={}
  for _,x in ipairs(rr.outs) do local task=x.result; local result=x.state.tasks[task]; if not result then return {kind='Retry'} end
    local live
    for _,st in ipairs(x.state.geometry:egress()) do local pts=G.points(st); if pts[1]==self:task_role() and pts[2]==task then live=st; result=pts[3]; break end end
    if not live then return {kind='Retry'} end
    local p=G.builder(); local m=p:membrane(nil,'join'); local i=p:strand(m,{self:task_role(),task,result}); p:face(m,{i},{}); local proc=p:finish(); local cut=W.Cut.one(proc,{strands={[i]=live}}); assert(cut,'TaskLive must cut exactly'); local ns,_,leftimg=apply(x.state,proc,cut); local ntask=leftimg.points[task] or task; local nresult=leftimg.points[result] or result; ns.tasks[ntask]=nil; ns.trace[#ns.trace+1]={kind='join'}; outs[#outs+1]={state=ns,result=nresult}
  end
  return {kind='Hit',outs=outs}
end

function C:eval_expr(s,e)
  if e.kind=='int' then local ns,p=self:literal(s,e.value); return {kind='Hit',outs={{state=ns,result=p}}} end
  if e.kind=='name' then local p=s.env[e.name]; if not p and e.name=='_' then p=s.env._ end; assert(p,'unknown name '..e.name); return {kind='Hit',outs={{state=s,result=p}}} end
  local callee=e.callee
  if self.resource_types[callee] then local ar=self:eval_expr(s,e.args[1]); if ar.kind~='Hit' then return ar end; local outs={}; for _,x in ipairs(ar.outs) do local v=x.state.theory[x.result]; local ns,p=self:new_resource(x.state,callee,v); outs[#outs+1]={state=ns,result=p} end; return {kind='Hit',outs=outs} end
  if callee=='choice' then local all,unknown={},false; for _,a in ipairs(e.args) do local r=self:eval_expr(clone(s),a); if r.kind=='Hit' then for _,x in ipairs(r.outs) do all[#all+1]=x end elseif r.kind=='Unknown' then unknown=true end end; if #all>0 then return {kind='Hit',outs=all,had_unknown=unknown} elseif unknown then return {kind='Unknown'} else return {kind='Retry'} end end
  if callee=='or_else' then local a=self:eval_expr(clone(s),e.args[1]); if a.kind=='Hit' then return a elseif a.kind=='Unknown' then return a else local b=self:eval_expr(clone(s),e.args[2]); if b.kind=='Hit' then for _,x in ipairs(b.outs) do x.state.trace[#x.state.trace+1]={kind='or_else'} end end; return b end end
  if callee=='and_then' then local a=self:eval_expr(clone(s),e.args[1]); if a.kind~='Hit' then return a end; local all,unknown={},false; for _,x in ipairs(a.outs) do local ns=clone(x.state); ns.env._=x.result; local b=self:eval_expr(ns,e.args[2]); if b.kind=='Hit' then for _,y in ipairs(b.outs) do y.state.trace[#y.state.trace+1]={kind='and_then'}; all[#all+1]=y end elseif b.kind=='Unknown' then unknown=true end end; if #all>0 then return {kind='Hit',outs=all} elseif unknown then return {kind='Unknown'} else return {kind='Retry'} end end
  if callee=='each' or callee=='together' then return self:each_or_together(s,e.args,callee) end
  if callee=='spawn' then return self:spawn(s,e.args[1]) end
  if callee=='join' then return self:join(s,e.args[1]) end
  local f=self.functions[callee]
  if f then local ar=self:eval_expr(s,e.args[1]); if ar.kind~='Hit' then return ar end; local outs={}; for _,x in ipairs(ar.outs) do local ns=clone(x.state); local old=ns.env[f.arg]; ns.env[f.arg]=x.result; local rr=self:eval_expr(ns,f.body); ns.env[f.arg]=old; if rr.kind~='Hit' then return rr end; for _,y in ipairs(rr.outs) do outs[#outs+1]=y end end; return {kind='Hit',outs=outs} end
  if self.effect_ops[callee] then for i=#s.handlers,1,-1 do local h=s.handlers[i]; if h.operation==callee then local ns,p=self:literal(s,h.value); return {kind='Hit',outs={{state=ns,result=p}}} end end; return {kind='Retry'} end
  -- operation call
  local ar=self:eval_expr(s,e.args[1]); if ar.kind~='Hit' then return ar end; local outs,unknown={},false
  for _,x in ipairs(ar.outs) do local r=self:call_op(x.state,callee,x.result); if r.kind=='Hit' then for _,y in ipairs(r.outs) do outs[#outs+1]=y end elseif r.kind=='Unknown' then unknown=true end end
  if #outs>0 then return {kind='Hit',outs=outs} elseif unknown then return {kind='Unknown'} else return {kind='Retry'} end
end

function C:eval_block(states,body)
  local cur=states
  for _,stmt in ipairs(body) do local nexts={}
    for _,s in ipairs(cur) do
      if stmt.kind=='handle' then local ns=clone(s); ns.handlers[#ns.handlers+1]={operation=stmt.operation,value=stmt.value}; local rs=self:eval_block({ns},stmt.body); for _,x in ipairs(rs) do x.handlers[#x.handlers]=nil; nexts[#nexts+1]=x end
      else local r=self:eval_expr(s,stmt.expr); if r.kind=='Unknown' then local ns=clone(s); ns.unknown=true; nexts[#nexts+1]=ns elseif r.kind=='Hit' then for _,x in ipairs(r.outs) do if stmt.kind=='let' then x.state.env[stmt.name]=x.result end; nexts[#nexts+1]=x.state end end end
    end
    cur=nexts
  end
  return cur
end
function C:run() return self:eval_block({clone(self.initial)},self.ast.main) end
function C:can_retire(s)
  for _,st in ipairs(s.geometry:egress()) do if G.points(st)[1]==self:task_role() then return false,st end end; return true
end
return C
