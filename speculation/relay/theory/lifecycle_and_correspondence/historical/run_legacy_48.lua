package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
package.loaded['speculation.extended_theory_lab.theory']=
  require('speculation.relay.theory.lifecycle_and_correspondence.historical.legacy_no_retract_adapter')
package.loaded['speculation.extended_theory_lab.development']=nil
local tests={
  '01_carrier_relative',
  '02_governance_split_merge',
  '03_factored_independent_edits',
  '04_support_is_geometry',
  '05_recursive_geometry',
  '06_full_validation_before_hiding',
  '07_fixed_size_renewal',
  '08_observation_not_effect_state',
  '09_overlap_conflict',
  '10_fresh_theory_existentials',
  '11_exact_rebase_through_scc',
  '12_no_self_justification',
  '13_exact_staleness',
  '14_ordered_same_root_tuple',
  '15_ambiguity_is_not_policy',
  '16_independent_edit_permutations',
  '17_routine_continue_complete',
  '18_residual_open_composition',
  '19_no_invented_split_pairing',
  '20_root_drop_no_promotion',
  '21_theory_staleness_without_authority_staleness',
  '22_quotient_created_theory_conflict',
  '23_fresh_locality_stays_worlds',
  '24_epistemic_generation_noncausal',
  '25_external_resource_causal_repair',
  '26_generated_support_oracle',
  '27_three_way_point_scope',
  '28_overlapping_alternatives_stay_external',
  '29_generated_exact_rebase',
  '30_generated_validation_before_hide',
  '31_theory_relation_locality_independence',
  '32_weak_memory_boundary_principle',
  '33_long_renewal_stress',
  '34_same_root_recurrent_environments',
  '35_linear_governed_one_shot',
  '36_cross_component_recursive_theory',
  '37_four_corridor_theory_permutations',
  '38_theory_cannot_rescue_support_mismatch',
  '39_dead_reference_no_resurrection',
  '40_alpha_existential_invariance',
  '41_generated_correlation_atlas',
  '42_same_root_multi_record_schedules',
  '43_fresh_instantiation_atlas',
  '44_construction_image_incidence',
  '45_feedback_support_quotient',
  '46_scarcity_conflict_not_choice',
  '47_transactional_internal_communication',
  '48_staged_recursive_theory_history',
}
local n=0
for _,name in ipairs(tests) do
  local f=require('speculation.extended_theory_lab.pressures.'..name)
  local ok,detail=pcall(f)
  assert(ok,name..': '..tostring(detail))
  n=n+1
end
print('legacy retract erasure: '..n..'/48 pressures passed with historical strict positive semantics')
