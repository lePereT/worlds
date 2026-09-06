-- choice_normalise.lua
--
-- Executable normalisation experiment from a path-sensitive alternative
-- specification into competing detached World stages followed by one generic
-- open-identity join stage.
--
-- This is deliberately not a new kernel feature.  It is a constructor and a
-- reference criterion used to test whether the World topology can represent
-- the old min/max scarcity story.

local Model=require('model')
local Audit=require('audit')
local N={}

local function minmax(spec,r)
  local mn, mx=nil,nil
  for _,a in ipairs(spec.arms) do
    local k=(a.uses and a.uses[r]) or 0
    if mn==nil or k<mn then mn=k end
    if mx==nil or k>mx then mx=k end
  end
  return mn or 0,mx or 0
end

function N.reference_valid(spec)
  for _,r in ipairs(spec.resources or {}) do
    local mn,mx=minmax(spec,r.name)
    if mn<1 and not r.epsilon then return false,'resource '..r.name..' has a zero-use path without EPSILON' end
    if mx>1 and not r.delta then return false,'resource '..r.name..' has a multi-use path without DELTA' end
  end
  return true
end

local function build(spec)
  local ok,why=N.reference_valid(spec)
  if not ok then return nil,why end
  local m=Model.new('O'); local O=m.actuality
  local Choice=m:point('Choice',O,'Choice'); local Join=m:point('Join',O,'Join')
  local tags,resources={},{}
  for _,a in ipairs(spec.arms) do tags[a.name]=m:point('tag:'..a.name,O,'Tag') end
  for _,r in ipairs(spec.resources or {}) do resources[r.name]={spec=r,point=m:point('res:'..r.name,O,'Res:'..r.name)} end

  local arms={}
  for _,a in ipairs(spec.arms) do
    local Dg=m:world('Dgate:'..a.name); local G=m:world('G:'..a.name)
    local gate=m:strand('gate:'..a.name,Dg,{Choice,tags[a.name]},'ChoiceA')
    local body_inputs={gate}; local demands={}; local structural={}
    for _,r in ipairs(spec.resources or {}) do
      local D=m:world('D:'..a.name..':'..r.name)
      local d=m:strand('demand:'..a.name..':'..r.name,D,{resources[r.name].point},'R:'..r.name)
      demands[r.name]=d
      local k=(a.uses and a.uses[r.name]) or 0
      if k==0 then
        structural[#structural+1]=m:discard('discard:'..a.name..':'..r.name,G,d,'structural')
      elseif k==1 then
        body_inputs[#body_inputs+1]=d
      else
        local copies={}
        for i=1,k do copies[i]=m:strand('copy:'..a.name..':'..r.name..':'..i,G,{resources[r.name].point},'R:'..r.name) end
        structural[#structural+1]=m:copy('copy:'..a.name..':'..r.name,G,d,copies,'structural')
        for _,s in ipairs(copies) do body_inputs[#body_inputs+1]=s end
      end
    end
    local qi=m:point('branch-id:'..a.name,G,'BranchIdentity')
    local out=m:strand('branch-out:'..a.name,G,{Join,qi},'JoinA')
    local body=m:face('body:'..a.name,G,body_inputs,{out},'Branch:'..a.name)
    arms[a.name]={gate=gate,G=G,qi=qi,out=out,body=body,demands=demands,structural=structural}
  end

  -- One generic join stage works for every branch.  The branch-specific Point
  -- remains open and binds to whichever actual branch occurrence exists.
  local Dj=m:world('JoinDemand'); local Gj=m:world('JoinGenerated')
  local q=m:point('branch?',Dj,'BranchIdentity')
  local jg=m:strand('join?',Dj,{Join,q},'JoinA')
  local done=m:strand('done',Gj,{q},'Done')
  local jf=m:face('join',Gj,{jg},{done},'Join')

  return {model=m,Choice=Choice,Join=Join,tags=tags,resources=resources,arms=arms,join={q=q,gate=jg,done=done,face=jf},spec=spec}
end
N.build=build

function N.certify(x)
  for _,a in pairs(x.arms) do
    local ok,why=Audit.check_stage(x.model,a.gate); if not ok then return false,why end
  end
  local ok,why=Audit.check_stage(x.model,x.join.gate); if not ok then return false,why end
  return true
end

function N.run_arm(spec,arm_name)
  local x,why=build(spec); if not x then return nil,why end
  local ok,cwhy=N.certify(x); if not ok then return nil,cwhy end
  local m=x.model; local arm=x.arms[arm_name]; if not arm then return nil,'unknown arm '..tostring(arm_name) end
  local W=m:world('Invocation:'..arm_name,m.actuality)
  local actual={}
  for _,r in ipairs(spec.resources or {}) do
    actual[r.name]=m:strand('actual:'..r.name,W,{x.resources[r.name].point},'R:'..r.name)
  end
  local choose=m:strand('choose:'..arm_name,W,{x.Choice,x.tags[arm_name]},'ChoiceA')
  local bi=m:develop(choose)
  local branch_out=bi.map[arm.out]
  local ji=m:develop(branch_out)
  local aok,awhy=Audit.check(m); if not aok then return nil,awhy end
  local uses={}; for n,s in pairs(actual) do uses[n]=m:_realised_uses(s) end
  return {x=x,branch=bi,join=ji,actual=actual,uses=uses}
end

return N
