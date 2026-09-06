-- Worlds public surface, v0.2.0.
--
-- The carrier remains World/Point/Strand/Face.  Actualisation is no longer a
-- trigger-centred Model operation: Worlds.Attachment derives complete boundary
-- attachment, retained queries witness/refute it, and graft makes one witnessed
-- attachment freshly actual.
return {
  VERSION='0.2.0',
  Model=require('worlds.harden'),
  Attachment=require('worlds.attachment'),
  Certified=require('worlds.certified'),
  Separate=require('worlds.separate'),
  Frontier=require('worlds.frontier'),
  Completion=require('worlds.completion'),
}
