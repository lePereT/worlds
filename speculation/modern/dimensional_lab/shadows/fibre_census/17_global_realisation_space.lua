package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local F=require('speculation.modern.dimensional_lab.shadows.fibre_census.common')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local lawful,dev,state={},{},{}
for code=0,4095 do local good,g=pcall(F.cube_support_assignment,code); if good then lawful[code]=true; state[code]=F.base4_digits(code,6); if g:is_developable() then dev[code]=true end end end
local function graph_stats(set)
  local V=0; for _ in pairs(set) do V=V+1 end; local E=0; local adj={}
  for code in pairs(set) do adj[code]={}; local d=state[code]; local pow=1
    for i=1,6 do local old=d[i]; for nv=0,3 do if nv~=old then local nb=code+(nv-old)*pow; if set[nb] then adj[code][nb]=true; if code<nb then E=E+1 end end end end; pow=pow*4 end
  end
  local comps=0; local seen={}; for root in pairs(set) do if not seen[root] then comps=comps+1; seen[root]=true; local q={root}; local qi=1; while qi<=#q do local x=q[qi]; qi=qi+1; for y in pairs(adj[x]) do if not seen[y] then seen[y]=true; q[#q+1]=y end end end end end
  return V,E,comps,E-V+comps,adj
end

print('1. local face-state edits turn the lawful fibre into one enormous connected realisation graph')
local lv,le,lc,lb,ladj=graph_stats(lawful); eq(lv,2304); eq(le,16940); eq(lc,1); eq(lb,14637)
local dv,de,dc,db,dadj=graph_stats(dev); eq(dv,120); eq(de,386); eq(dc,1); eq(db,267)

print('2. the executable locus is a small connected island inside a much larger latent lawful space')
local dist,q={},{}; for code in pairs(dev) do dist[code]=0; q[#q+1]=code end; local qi=1
while qi<=#q do local x=q[qi]; qi=qi+1; for y in pairs(ladj[x]) do if dist[y]==nil then dist[y]=dist[x]+1; q[#q+1]=y end end end
local hist,max={},0; for code in pairs(lawful) do local d=assert(dist[code]); hist[d]=(hist[d] or 0)+1; if d>max then max=d end end
eq(max,5); local expected={120,360,858,756,204,6}; for d=0,5 do eq(hist[d],expected[d+1],'distance shell '..d) end

print('3. independent local edits generate a high-dimensional cubical subcomplex of the realisation fibre')
local value_pairs={{0,1},{0,2},{0,3},{1,2},{1,3},{2,3}}; local powers={1,4,16,64,256,1024}
local function combinations(nn,k,start,prefix,out)
  if k==0 then local z={}; for i,v in ipairs(prefix) do z[i]=v end; out[#out+1]=z; return end
  for i=start,nn-k+1 do prefix[#prefix+1]=i; combinations(nn,k-1,i+1,prefix,out); prefix[#prefix]=nil end
end
local function count_cells(set,k)
  if k==0 then local z=0; for _ in pairs(set) do z=z+1 end; return z end
  local acts={}; combinations(6,k,1,{},acts); local total=0
  for _,act in ipairs(acts) do
    local active={}; for _,i in ipairs(act) do active[i]=true end; local fixed={}; for i=1,6 do if not active[i] then fixed[#fixed+1]=i end end
    local np,nf=6^k,4^(6-k)
    for pc=0,np-1 do local x=pc; local prs={}; for j=1,k do prs[j]=value_pairs[(x%6)+1]; x=math.floor(x/6) end
      for fc=0,nf-1 do local y=fc; local base=0; for _,i in ipairs(fixed) do local v=y%4; y=math.floor(y/4); base=base+v*powers[i] end
        local all=true
        for corner=0,(1<<k)-1 do local code=base; for j,i in ipairs(act) do local pr=prs[j]; local v=((corner & (1<<(j-1)))~=0) and pr[2] or pr[1]; code=code+v*powers[i] end; if not set[code] then all=false; break end end
        if all then total=total+1 end
      end
    end
  end
  return total
end
local lf={2304,16940,49636,74677,61616,26697,4770}; local df={120,386,358,106,8,0,0}
local lchi,dchi=0,0
for k=0,6 do local a,b=count_cells(lawful,k),count_cells(dev,k); eq(a,lf[k+1],'lawful f_'..k); eq(b,df[k+1],'developable f_'..k); lchi=lchi+((k%2==0) and a or -a); dchi=dchi+((k%2==0) and b or -b) end
eq(lchi,12,'lawful cubical Euler characteristic'); eq(dchi,-6,'developable cubical Euler characteristic')
eq(lf[7],4770,'lawful fibre contains full six-coordinate cubes'); eq(df[5],8); eq(df[6],0,'developable locus has dimension four in this probe')
print('PASS global realisation-space census',n,'assertions','lawful-beta1(graph)',lb,'developable-beta1(graph)',db,'chi',lchi,dchi)
