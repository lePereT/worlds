package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local tests={
  {'X01','carrier-relative Theory','01_carrier_relative'},
  {'X02','governance split/merge','02_governance_split_merge'},
  {'X03','factored independent edits','03_factored_independent_edits'},
  {'X04','support remains Geometry','04_support_is_geometry'},
  {'X05','recursion remains Geometry','05_recursive_geometry'},
  {'X06','full validation before hiding','06_full_validation_before_hiding'},
  {'X07','fixed-size renewal','07_fixed_size_renewal'},
  {'X08','derived transition observation','08_observation_not_effect_state'},
  {'X09','overlap conflict','09_overlap_conflict'},
  {'X10','fresh Theory existentials','10_fresh_theory_existentials'},
  {'X11','exact rebase through SCC','11_exact_rebase_through_scc'},
  {'X12','no Theory self-justification','12_no_self_justification'},
  {'X13','exact staleness dominates','13_exact_staleness'},
  {'X14','ordered same-root tuple','14_ordered_same_root_tuple'},
  {'X15','ambiguity is not policy','15_ambiguity_is_not_policy'},
  {'X16','independent edit permutations','16_independent_edit_permutations'},
  {'X17','routine continue/complete','17_routine_continue_complete'},
  {'X18','residual open composition','18_residual_open_composition'},
  {'X19','no invented split pairing','19_no_invented_split_pairing'},
  {'X20','root drop no promotion','20_root_drop_no_promotion'},
  {'X21','Theory staleness','21_theory_staleness_without_authority_staleness'},
  {'X22','quotient-created Theory conflict','22_quotient_created_theory_conflict'},
  {'X23','fresh locality stays Worlds','23_fresh_locality_stays_worlds'},
  {'X24','epistemic generation noncausal','24_epistemic_generation_noncausal'},
  {'X25','external resource causal repair','25_external_resource_causal_repair'},
  {'X26','generated support oracle','26_generated_support_oracle'},
  {'X27','three-way Point scope','27_three_way_point_scope'},
  {'X28','overlapping alternatives external','28_overlapping_alternatives_stay_external'},
  {'X29','generated exact Theory rebase','29_generated_exact_rebase'},
  {'X30','generated validate-before-hide','30_generated_validation_before_hide'},
  {'X31','relation locality independence','31_theory_relation_locality_independence'},
  {'X32','weak-memory boundary principle','32_weak_memory_boundary_principle'},
  {'X33','long renewal stress','33_long_renewal_stress'},
  {'X34','same-root recurrent environments','34_same_root_recurrent_environments'},
  {'X35','linear governed one-shot','35_linear_governed_one_shot'},
  {'X36','cross-component recursive Theory','36_cross_component_recursive_theory'},
  {'X37','four-corridor Theory permutations','37_four_corridor_theory_permutations'},
  {'X38','Theory cannot rescue support','38_theory_cannot_rescue_support_mismatch'},
  {'X39','dead reference no resurrection','39_dead_reference_no_resurrection'},
  {'X40','alpha existential invariance','40_alpha_existential_invariance'},
  {'X41','generated correlation atlas','41_generated_correlation_atlas'},
  {'X42','same-root multi-record schedules','42_same_root_multi_record_schedules'},
  {'X43','fresh instantiation atlas','43_fresh_instantiation_atlas'},
  {'X44','Construction image incidence','44_construction_image_incidence'},
  {'X45','feedback support quotient','45_feedback_support_quotient'},
  {'X46','scarcity conflict not choice','46_scarcity_conflict_not_choice'},
  {'X47','transactional internal communication','47_transactional_internal_communication'},
  {'X48','staged recursive Theory history','48_staged_recursive_theory_history'},
}local passed,failed=0,{}
for _,t in ipairs(tests) do
  local load_ok,f=pcall(require,'speculation.extended_theory_lab.pressures.'..t[3])
  local ok,detail=false,f
  if load_ok then ok,detail=pcall(f) end
  if not ok then
    failed[#failed+1]={id=t[1],title=t[2],detail=detail}
    io.stderr:write(string.format('FAIL %s %-34s %s\n',t[1],t[2],detail))
  else
    passed=passed+1
    print(string.format('PASS %s %-34s %s',t[1],t[2],detail))
  end
end
print(string.format('extended theory hostile lab: %d/%d passed, %d failed',passed,#tests,#failed))
if #failed>0 then os.exit(1) end
