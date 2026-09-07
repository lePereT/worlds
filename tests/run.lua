package.path='../src/?.lua;../src/?/init.lua;./?.lua;'..package.path
local files={
  'geometry/core.lua',
  'geometry/imported_points_are_rigid.lua',
  'geometry/fresh_point_in_existing_locality.lua',
  'geometry/public_metatables_are_locked.lua',

  'cut/unknown_and_first_hit.lua',
  'cut/empty_cut.lua',
  'cut/work_budget_counts_incompatible.lua',
  'cut/stale_witness.lua',
  'cut/scarcity_and_point_laws.lua',
  'cut/unrelated_commit_preserves_witness.lua',
  'cut/common_solver.lua',
  'cut/searchable_detached_cut.lua',
  'cut/complete_cut_execution.lua',

  'algebra/sortless_each_together.lua',
  'algebra/detached_cut_and_then.lua',
  'algebra/partial_cut_leaves_external_requirements.lua',
  'algebra/cut_associativity.lua',
  'algebra/tensor_is_each.lua',
  'algebra/symmetric_close_acyclic.lua',
  'algebra/symmetric_close_cycle_joint.lua',
  'algebra/each_together_derived.lua',
  'algebra/joint_scc_preserves_external_boundary.lua',
  'algebra/multiple_joint_sccs.lua',
  'algebra/close_link_laws.lua',
  'algebra/cross_locality_joint_lca.lua',
  'algebra/cut_family_order_invariance.lua',
  'algebra/joint_scc_order_and_lca.lua',
  'algebra/joint_face_incidence_unordered.lua',

  'authority/exact_strand_induces_locality.lua',
  'authority/membrane_identity_is_not_authority.lua',
  'authority/point_identity_is_not_authority.lua',
  'authority/handle_reissue_and_retirement.lua',
  'authority/nested_opacity.lua',
  'authority/fresh_child_is_grounded.lua',
  'authority/dangling_input_is_not_authority.lua',
  'authority/frame_law.lua',
  'authority/structural_cut_vs_authority_admissibility.lua',
  'authority/no_spontaneous_execution.lua',

  'state/long_running_boundary.lua',
  'state/local_update.lua',
  'state/history_boundary_commuting_square.lua',
  'state/fresh_identity_history_boundary.lua',

  'concurrency/cube_compatibility.lua',

  'theory/values_identity.lua',
  'theory/generativity_names.lua',
  'theory/proofs_quantum.lua',
  'theory/quotient_congruence.lua',
}
local total=0
for _,f in ipairs(files) do
  package.loaded.support=nil
  local ok,n=pcall(dofile,f)
  if not ok then io.stderr:write('FAIL ',f,': ',tostring(n),'\n'); os.exit(1) end
  total=total+(n or 0); print('ok',f,n or 0)
end
print('PASS',#files,'law files',total,'assertions')
