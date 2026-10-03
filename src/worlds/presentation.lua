-- Ordered non-authoritative presentation of exact open Strand occurrences.
--
-- A Presentation owns no Geometry and carries no programme authority.  Its rows,
-- row order, coordinate order and coordinate multiplicity are descriptive
-- structure relative to one exact ambient Geometry.

local W=require('worlds')
local Construction=require('worlds.construction')
local DENSE=require('worlds._array')

local Presentation={}
local STATE=setmetatable({}, {__mode='k'})
local function immutable() error('Worlds values are immutable',2) end
local MT={__newindex=immutable,__metatable='Worlds Presentation'}
MT.__index=MT

local function state(x) return type(x)=='table' and STATE[x] or nil end

local function is_open(g,s)
  return g:producer(s)==nil or g:consumer(s)==nil
end

local function normal_rows(g,rows)
  DENSE.length(rows,'Presentation rows')
  for _,row in ipairs(rows) do
    DENSE.length(row,'Presentation row')
    for _,s in ipairs(row) do
      assert(W.kind(s)=='strand' and g:owns_strand(s),
          'Presentation coordinate must be an exact Strand of the ambient Geometry')
      assert(is_open(g,s),'Presentation coordinate must be open in the ambient Geometry')
    end
  end
  return rows
end

local function value(st)
  local x=setmetatable({},MT)
  STATE[x]=st
  return x
end

function Presentation.new(geometry,rows)
  assert(W.is_geometry(geometry),'Presentation ambient must be Worlds Geometry')
  return value{ambient=geometry,rows=normal_rows(geometry,rows)}
end

function Presentation.is_presentation(x)
  return state(x)~=nil
end

function MT:ambient()
  return assert(state(self),'Worlds Presentation required').ambient
end

function MT:rows()
  return assert(state(self),'Worlds Presentation required').rows
end

function MT:row(i)
  local st=assert(state(self),'Worlds Presentation required')
  assert(type(i)=='number' and i>=1 and i%1==0 and i<=#st.rows,
      'Presentation row index out of range')
  return st.rows[i]
end

function MT:transport(construction)
  local st=assert(state(self),'Worlds Presentation required')
  assert(Construction.is_construction(construction),
      'Presentation transport requires Worlds Construction')

  local authorised=false
  for _,g in ipairs(construction:parts()) do
    if g==st.ambient then authorised=true
    break end
  end
  assert(authorised,'Presentation ambient must be an exact part of the Construction')

  local target=construction:result()
  local rows={}
  for i,row in ipairs(st.rows) do
    local out={}
    for _,s in ipairs(row) do
      local mapped=construction:image(s)
      if mapped and W.kind(mapped)=='strand' and target:owns_strand(mapped) and is_open(target,
          mapped) then
        out[#out+1]=mapped
      end
    end
    rows[i]=out
  end
  return value{ambient=target,rows=rows}
end

return Presentation
