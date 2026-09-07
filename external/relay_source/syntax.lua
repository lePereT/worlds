-- Deliberately tiny Relay parser. It exists only to test whether pleasant
-- source Forms can share one lower open-process representation.

local S={}
local function trim(s) return (s:gsub('^%s+',''):gsub('%s+$','')) end
local function split_args(s)
  local out,depth,start={},0,1
  if trim(s)=='' then return out end
  for i=1,#s do local c=s:sub(i,i); if c=='(' then depth=depth+1 elseif c==')' then depth=depth-1 elseif c==',' and depth==0 then out[#out+1]=trim(s:sub(start,i-1)); start=i+1 end end
  out[#out+1]=trim(s:sub(start)); return out
end
local function expr(s)
  s=trim(s)
  if s:match('^-?%d+$') then return {kind='int',value=tonumber(s)} end
  local callee,args=s:match('^([%w_%.]+)%((.*)%)$')
  if callee then local xs={}; for _,a in ipairs(split_args(args)) do xs[#xs+1]=expr(a) end; return {kind='call',callee=callee,args=xs} end
  assert(s:match('^[%w_]+$'),'unsupported tiny expression: '..s)
  return {kind='name',name=s}
end
S.expr=expr

local function lines_of(text)
  local out={}; for line in (text..'\n'):gmatch('(.-)\n') do line=line:gsub('%s*#.*$',''); if trim(line)~='' then out[#out+1]=trim(line) end end; return out
end

local function block(lines,i,stop_at_end)
  local out={}
  while i<=#lines do
    local line=lines[i]
    if line=='end' then assert(stop_at_end,'unexpected end'); return out,i+1 end
    local name,rhs=line:match('^let%s+([%w_]+)%s*=%s*(.+)$')
    if name then out[#out+1]={kind='let',name=name,expr=expr(rhs)}; i=i+1
    else
      local q,val=line:match('^handle%s+([%w_%.]+)%s*=%s*(-?%d+)$')
      if q then local body,ni=block(lines,i+1,true); out[#out+1]={kind='handle',operation=q,value=tonumber(val),body=body}; i=ni
      else out[#out+1]={kind='expr',expr=expr(line)}; i=i+1 end
    end
  end
  assert(not stop_at_end,'missing end')
  return out,i
end

function S.parse(text)
  local lines=lines_of(text); local ast={interfaces={},effects={},resources={},functions={},main=nil}; local i=1
  while i<=#lines do
    local line=lines[i]
    local n=line:match('^interface%s+([%w_]+)$')
    if n then
      local d={name=n,ops={}}; i=i+1
      while lines[i]~='end' do local op=assert(lines[i]:match('^op%s+([%w_]+)$'),'bad interface line '..tostring(lines[i])); d.ops[#d.ops+1]=op; i=i+1 end
      ast.interfaces[#ast.interfaces+1]=d; i=i+1
    else
      n=line:match('^effect%s+([%w_]+)$')
      if n then
        local d={name=n,ops={}}; i=i+1
        while lines[i]~='end' do local op=assert(lines[i]:match('^op%s+([%w_]+)$'),'bad effect line '..tostring(lines[i])); d.ops[#d.ops+1]=op; i=i+1 end
        ast.effects[#ast.effects+1]=d; i=i+1
      else
        n=line:match('^resource%s+([%w_]+)$')
        if n then
          local d={name=n,providers={}}; i=i+1
          while lines[i]~='end' do
            local st=lines[i]:match('^state%s+([%w_%.:]+)$')
            if st then d.state=st
            else
              local q,from,to=lines[i]:match('^provides%s+([%w_%.]+)%s+(-?%d+)%s*%-%>%s*(-?%d+)$')
              if q then d.providers[#d.providers+1]={operation=q,from=tonumber(from),to=tonumber(to)}
              else
                local q2,v=lines[i]:match('^provides%s+([%w_%.]+)%s*=%s*(-?%d+)$')
                if q2 then d.providers[#d.providers+1]={operation=q2,value=tonumber(v)}
                else local a,b=lines[i]:match('^provides%s+([%w_%.]+)%s+via%s+([%w_%.]+)$'); assert(a,'bad resource line '..lines[i]); d.providers[#d.providers+1]={operation=a,via=b} end
              end
            end
            i=i+1
          end
          assert(d.state,'resource requires state'); ast.resources[#ast.resources+1]=d; i=i+1
        else
          local fn,generic,arg,rhs=line:match('^fn%s+([%w_]+)%[([^%]]+)%]%(([%w_]+)%)%s*=%s*(.+)$')
          if not fn then fn,arg,rhs=line:match('^fn%s+([%w_]+)%(([%w_]+)%)%s*=%s*(.+)$'); generic=nil end
          if fn then ast.functions[#ast.functions+1]={name=fn,generic=generic,arg=arg,body=expr(rhs)}; i=i+1
          elseif line=='main' then local body,ni=block(lines,i+1,true); ast.main=body; i=ni
          else error('unsupported top-level tiny Relay form: '..line) end
        end
      end
    end
  end
  assert(ast.main,'missing main'); return ast
end
return S
