local M={}
M.EPS=1e-9
function M.ok(x,msg) M._n=(M._n or 0)+1; assert(x,msg or 'assertion failed') end
function M.eq(a,b,msg) M._n=(M._n or 0)+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
function M.approx(a,b,eps,msg) M._n=(M._n or 0)+1; if type(eps)=='string' and msg==nil then msg=eps; eps=nil end; eps=eps or M.EPS; assert(math.abs(a-b)<=eps,(msg or 'not approx')..': '..tostring(a)..' ~= '..tostring(b)) end
function M.count() return M._n or 0 end
function M.reset() M._n=0 end
function M.deepcopy(A) local R={}; for i=1,#A do R[i]={}; for j=1,#A[i] do R[i][j]=A[i][j] end end; return R end
function M.eye(n) local R={}; for i=1,n do R[i]={}; for j=1,n do R[i][j]=(i==j) and 1 or 0 end end; return R end
function M.zeros(r,c) local R={}; for i=1,r do R[i]={}; for j=1,c do R[i][j]=0 end end; return R end
function M.transpose(A) local R={}; for j=1,#A[1] do R[j]={}; for i=1,#A do R[j][i]=A[i][j] end end; return R end
function M.mm(A,B)
  local R=M.zeros(#A,#B[1])
  for i=1,#A do for j=1,#B[1] do local s=0; for k=1,#B do s=s+A[i][k]*B[k][j] end; R[i][j]=s end end
  return R
end
function M.mv(A,v) local r={}; for i=1,#A do local s=0; for j=1,#v do s=s+A[i][j]*v[j] end; r[i]=s end; return r end
function M.add(A,B) local R=M.zeros(#A,#A[1]); for i=1,#A do for j=1,#A[i] do R[i][j]=A[i][j]+B[i][j] end end; return R end
function M.scale(A,s) local R=M.zeros(#A,#A[1]); for i=1,#A do for j=1,#A[i] do R[i][j]=s*A[i][j] end end; return R end
function M.kron(A,B)
  local R={}
  for ia=1,#A do for ib=1,#B do local row={}; for ja=1,#A[1] do for jb=1,#B[1] do row[#row+1]=A[ia][ja]*B[ib][jb] end end; R[#R+1]=row end end
  return R
end
function M.meq(A,B,eps)
  eps=eps or M.EPS
  if #A~=#B or #A[1]~=#B[1] then return false end
  for i=1,#A do for j=1,#A[i] do if math.abs(A[i][j]-B[i][j])>eps then return false end end end
  return true
end
function M.veq(a,b,eps) eps=eps or M.EPS; if #a~=#b then return false end; for i=1,#a do if math.abs(a[i]-b[i])>eps then return false end end; return true end
function M.outer(v) local R=M.zeros(#v,#v); for i=1,#v do for j=1,#v do R[i][j]=v[i]*v[j] end end; return R end
function M.trace(A) local s=0; for i=1,#A do s=s+A[i][i] end; return s end
function M.dephase2(rho) return {{rho[1][1],0},{0,rho[2][2]}} end
function M.partial_trace_env2(rho)
  -- basis |q,e>: 00,01,10,11; trace e, keep q
  return {
    {rho[1][1]+rho[2][2], rho[1][3]+rho[2][4]},
    {rho[3][1]+rho[4][2], rho[3][3]+rho[4][4]}
  }
end
function M.apply_unitary(U,rho) return M.mm(M.mm(U,rho),M.transpose(U)) end
function M.apply_kraus(Ks,rho)
  local R=M.zeros(#rho,#rho)
  for _,K in ipairs(Ks) do R=M.add(R,M.mm(M.mm(K,rho),M.transpose(K))) end
  return R
end
function M.diagprob(rho) local p={}; for i=1,#rho do p[i]=rho[i][i] end; return p end
function M.entropy_probs(p)
  local s=0
  for _,x in ipairs(p) do if x>0 then s=s-x*(math.log(x)/math.log(2)) end end
  return s
end
function M.matvec_prob(P,p) return M.mv(P,p) end
function M.commute(A,B,eps) return M.meq(M.mm(A,B),M.mm(B,A),eps) end
function M.is_identity_up_to_sign(A,eps)
  eps=eps or M.EPS; local n=#A; local I=M.eye(n)
  if M.meq(A,I,eps) then return 1 end
  if M.meq(A,M.scale(I,-1),eps) then return -1 end
  return nil
end
function M.bits(index,n)
  local t={}; local x=index
  for k=n,1,-1 do t[k]=x%2; x=math.floor(x/2) end
  return t
end
function M.index_from_bits(bits)
  local x=0; for i=1,#bits do x=2*x+bits[i] end; return x+1
end
function M.reduced_density_real_pure(vec,n,keep)
  local keep_set={}; for _,k in ipairs(keep) do keep_set[k]=true end
  local trace={}; for k=1,n do if not keep_set[k] then trace[#trace+1]=k end end
  local dk=2^#keep; local dt=2^#trace; local R=M.zeros(dk,dk)
  for a=0,dk-1 do
    local ab=M.bits(a,#keep)
    for b=0,dk-1 do
      local bb=M.bits(b,#keep); local s=0
      for t=0,dt-1 do
        local tb=M.bits(t,#trace); local fulla={}; local fullb={}; local ki=1; local ti=1
        for pos=1,n do
          if keep_set[pos] then fulla[pos]=ab[ki]; fullb[pos]=bb[ki]; ki=ki+1
          else fulla[pos]=tb[ti]; fullb[pos]=tb[ti]; ti=ti+1 end
        end
        local ia=M.index_from_bits(fulla); local ib=M.index_from_bits(fullb)
        s=s+vec[ia]*vec[ib]
      end
      R[a+1][b+1]=s
    end
  end
  return R
end
function M.row_key(W,s)
  local pts=W.points(s); local t={tostring(W.membrane(s))}; for _,p in ipairs(pts) do t[#t+1]=tostring(p) end; return table.concat(t,'|')
end
return M
