-- Worlds public surface, v0.3.0.
--
-- The semantic carrier remains World / Point / Strand / Face.  Complete
-- attachment, exact residual frontiers and pointed cuts are one derived
-- relation exposed as Att; no residual/concurrency/compiler bookkeeping is
-- carrier ontology.
return {
  VERSION='0.3.0',
  Model=require('worlds.harden'),
  Att=require('worlds.att'),
  Certified=require('worlds.certified'),
  Separate=require('worlds.separate'),
  Completion=require('worlds.completion'),
}
