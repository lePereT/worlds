package.path='./src/?.lua;./src/?/init.lua;./?.lua;./?/init.lua;'..package.path
local W=require('worlds')
local C=require('speculation.relay.computation.development_calculus.calculus')
local H=require('speculation.relay.computation.development_calculus.common')
local Channel=require('speculation.relay.computation.concurrency_discovery.channel')
local Formed=require('speculation.relay.computation.concurrency_discovery.formed')
local Discovery=require('speculation.relay.computation.concurrency_discovery.discovery')
local Continuation=require('speculation.relay.computation.concurrency_discovery.continuation')
local Triple=require('speculation.relay.computation.concurrency_discovery.triple_swap')
local Cell=require('speculation.relay.computation.concurrency_discovery.cell')
local IVar=require('speculation.relay.computation.concurrency_discovery.ivar')
local MVar=require('speculation.relay.computation.concurrency_discovery.mvar')
local Buffered=require('speculation.relay.computation.concurrency_discovery.buffered_channel')
local SelectableForm=require('speculation.relay.computation.concurrency_discovery.selectable_form')
local ExactEndpoint=require('speculation.relay.computation.concurrency_discovery.exact_endpoint')
local RecurrentOwner=require('speculation.relay.computation.concurrency_discovery.recurrent_owner')
local ParameterEndpoint=require('speculation.relay.computation.concurrency_discovery.parameter_endpoint')
local Semaphore=require('speculation.relay.computation.concurrency_discovery.semaphore')
local AtomicCell=require('speculation.relay.computation.concurrency_discovery.atomic_cell')
local Latch=require('speculation.relay.computation.concurrency_discovery.latch')
local Barrier=require('speculation.relay.computation.concurrency_discovery.barrier')
local Actor=require('speculation.relay.computation.concurrency_discovery.actor')
local MemoryOrder=require('speculation.relay.computation.concurrency_discovery.memory_order')
local T=C.Equality()
local G=C.Geometry()
local M={W=W,C=C,H=H,Channel=Channel,Formed=Formed,Discovery=Discovery,
  Continuation=Continuation,Triple=Triple,Cell=Cell,IVar=IVar,MVar=MVar,Buffered=Buffered,
  SelectableForm=SelectableForm,ExactEndpoint=ExactEndpoint,RecurrentOwner=RecurrentOwner,ParameterEndpoint=ParameterEndpoint,Semaphore=Semaphore,AtomicCell=AtomicCell,Latch=Latch,Barrier=Barrier,Actor=Actor,MemoryOrder=MemoryOrder,T=T,G=G}
function M.counter() return H.counter() end
function M.value(p,alt,pos) return H.out_value(p,alt,pos) end
function M.finish(...) return Continuation.finish(...) end
function M.accept(...) return Continuation.accept(...) end
function M.no_runtime_words(bytes)
  for _,word in ipairs({'scheduler','runnable','blocked','wait_queue','task_state','program_counter'}) do
    assert(not bytes:find(word,1,true),'semantic residue contains '..word)
  end
  return true
end
return M
