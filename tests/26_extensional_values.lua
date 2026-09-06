local S=require('tests.support'); local TS=require('tests.theory_support')
local G,A=S.G,S.A

local function values(shared)
  local b=G.builder(); local K=b:membrane(nil,'eval')
  local p=b:point(K,'Int'); local q=shared and p or b:point(K,'Int')
  b:strand(K,'Left',{p}); b:strand(K,'Right',{q})
  local g=b:finish(); local ann=TS.annotation(); ann:set(p,42); ann:set(q,42)
  return g,K,ann,p,q
end

-- One generic binary operation: distinct pattern Points are variables and may
-- bind either to one shared witness or to two independent witnesses.
local p=G.builder(); local D=p:membrane(nil,'eval')
local x=p:point(D,'Int'); local y=p:point(D,'Int')
local L=p:strand(D,'Left',{x}); local R=p:strand(D,'Right',{y})
local V=p:membrane(D,'value'); local z=p:point(V,'Int')
local O=p:strand(D,'Result',{z}); p:face(D,'add',{L,R},{O})
local add=p:finish()

local fresh,K,fa=values(false)
local canon,K2,ca=values(true)
local ef=A.one(fresh,{K},add); local ec=A.one(canon,{K2},add)
S.ok(ef); S.ok(ec)
S.eq(fa:get(ef:point(x))+fa:get(ef:point(y)),84)
S.eq(ca:get(ec:point(x))+ca:get(ec:point(y)),84)
local gf,imf=A.glue(ef); local gc,imc=A.glue(ec)
fa:set(imf.points[z],84); ca:set(imc.points[z],84)
S.eq(fa:get(imf.points[z]),ca:get(imc.points[z]))
S.no(S.Worlds.same(gf,gc),'fresh and canonical witnesses remain different exact geometry')

-- Literal Point identity is still observable if a process explicitly asks for it.
local i=G.builder(); local E=i:membrane(nil,'eval'); local same=i:point(E,'Int')
i:strand(E,'Left',{same}); i:strand(E,'Right',{same}); local identity=i:finish()
S.eq(#A.all(canon,{K2},identity),1)
S.eq(#A.all(fresh,{K},identity),0)

print('ok 26_extensional_values')
