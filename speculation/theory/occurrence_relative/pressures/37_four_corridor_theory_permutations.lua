local Construction=require('worlds.construction')
local T=require('speculation.theory.occurrence_relative.theory')
local F=require('speculation.theory.occurrence_relative.multi_recursive_fixtures')
local function permutations(n)
  local out,used,row={},{},{};local function go(k) if k>n then local p={};for i=1,n do p[i]=row[i] end;out[#out+1]=p;return end;for x=1,n do if not used[x] then used[x]=true;row[k]=x;go(k+1);used[x]=nil end end end;go(1);return out
end
return function()
  local R=F.roles('ext-theory-p37');local S=F.component({{'h','a','x'},{'h','a','y'},{'h','b','z'},{'k','c','w'}},nil,R,'p37');local facts={};for _,f in ipairs(S.geometry:faces()) do if f~=nil then facts[#facts+1]=T.fact('event',f,'work') end end;local base=T.state(S.geometry,facts)
  local checks=0
  for _,perm in ipairs(permutations(4)) do local c=Construction.join({S.geometry},F.equations(S,F.feedbacks(perm)));local r=T.rebase(base,c);local images={};for _,f in ipairs(S.geometry:faces()) do local im=c:image(f);if im then images[im]=true end end;local n=0;for _ in pairs(images) do n=n+1 end;assert(r:count('event')==n,'Theory fact quotient disagreed with distinct Face images for permutation '..checks+1);checks=checks+1 end
  assert(checks==24)
  return 'all 24 four-corridor feedback permutations rebase exact Face-relative Theory to precisely the distinct post-SCC Face images'
end
