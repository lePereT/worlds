package.path='./src/?.lua;'..package.path
local Choice=require('choice_normalise')
math.randomseed(1701)
local N=2000
for case=1,N do
  local nr=math.random(1,3); local na=math.random(2,5)
  local spec={resources={},arms={}}
  for r=1,nr do spec.resources[r]={name='r'..r,epsilon=(math.random(0,1)==1),delta=(math.random(0,1)==1)} end
  for a=1,na do
    local arm={name='a'..a,uses={}}
    for r=1,nr do arm.uses['r'..r]=math.random(0,3) end
    spec.arms[a]=arm
  end
  local ref=Choice.reference_valid(spec)
  local built,why=Choice.build(spec)
  if ref then
    assert(built,why); local ok,cwhy=Choice.certify(built); assert(ok,'case '..case..': '..tostring(cwhy))
    local pick=spec.arms[math.random(1,#spec.arms)].name
    local run,rwhy=Choice.run_arm(spec,pick); assert(run,'case '..case..': '..tostring(rwhy))
    for _,r in ipairs(spec.resources) do assert(run.uses[r.name]==1,'case '..case..' resource '..r.name..' use '..tostring(run.uses[r.name])) end
  else
    assert(not built,'case '..case..' reference rejected but normaliser built')
  end
end
print(string.format('%d/%d choice-normalisation stress cases passed',N,N))
