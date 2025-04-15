//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

// Outside here to satisfy ticked file enforcement while still providing defines
#include "__DEFINES\test_defines.dm"

// BEGIN_INCLUDE

#include "achievement_validation.dm"
#include "anchored_mobs.dm"
#include "antag_datums.dm"
#include "antimagic_test.dm"
#include "area_contents.dm"
#include "armor_verification.dm"
#include "armour_checks.dm"
#include "armour_readouts.dm"
#include "asset_smart_cache.dm"
#include "async.dm"
#include "autowiki.dm"
#include "bloody_footprints.dm"
#include "breath.dm"
#include "check_adjustable_clothing.dm"
#include "closets.dm"
#include "combat.dm"
#include "component_tests.dm"
#include "connect_loc.dm"
#include "crafting_tests.dm"
/*
#include "create_and_destroy.dm"
*/
#include "dcs_get_id_from_elements.dm"
#include "dynamic_ruleset_sanity.dm"
#include "emoting.dm"
#include "enumerables.dm"

#ifdef REFERENCE_TRACKING_DEBUG //Don't try and parse this file if ref tracking isn't turned on. IE: don't parse ref tracking please mr linter
#include "find_reference_sanity.dm"
#endif

#include "food_edibility_check.dm"
#include "gamemode_sanity.dm"
#include "gas_transfer.dm"
#include "greyscale_config.dm"
#include "handcuff_tests.dm"
#include "heretic_knowledge.dm"
#include "heretic_rituals.dm"
#include "hydroponics_extractor_storage.dm"
#include "icon_smoothing_unit_test.dm"
#include "janky_actions.dm"
#include "keybinding_init.dm"
#include "language_transfer.dm"
#include "merge_type.dm"
#include "metabolizing.dm"
#include "mindbound_actions.dm"
#include "missing_icons.dm"
#include "ntnetwork_tests.dm"
#include "orphaned_genturf.dm"
#include "outfit_sanity.dm"
#include "preference_species.dm"
#include "preferences.dm"
#include "projectiles.dm"
#include "quirks.dm"
#include "random_ruin_mapsize.dm"
#include "rcd.dm"
#include "reagent_container_defaults.dm"
#include "reagent_grinder.dm"
#include "reagent_id_duplicates.dm"
#include "reagent_id_typos.dm"
#include "reagent_recipe_collisions.dm"
#include "security_levels.dm"
#include "serving_tray.dm"
#include "shuttle_width_height_correctness.dm"
#include "siunit.dm"
#include "spawn_humans.dm"
#include "species_whitelists.dm"
#include "spell_invocations.dm"
#include "spell_mindswap.dm"
#include "spell_names.dm"
#include "spell_shapeshift.dm"
#include "stat_mc.dm"
#include "subsystem_init.dm"
#include "subsystem_metric_sanity.dm"
#include "surgery_linking.dm"
#include "techweb_sanity.dm"
#include "teleporters.dm"
#include "tgui_create_message.dm"
#include "timer_sanity.dm"
#include "trait_tests.dm"
#include "unit_test.dm"
#include "walls_have_sheets.dm"
#include "wizard_loadout.dm"
#include "worn_icons.dm"

/*
#include "__DEFINES\test_defines.dm"
*/

#include "mapping\check_active_turfs.dm"
#include "mapping\check_area_apc.dm"
#include "mapping\check_camera_attachment.dm"
#include "mapping\check_disposals.dm"
#include "mapping\check_light_attachment.dm"
#include "mapping\check_multiple_objects.dm"
#include "mapping\map_test.dm"

// END_INCLUDE

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
#undef TEST_ASSERT_TRUE
#undef TEST_ASSERT_FALSE
//#undef TEST_FOCUS - This define is used by vscode unit test extension to pick specific unit tests to run and appended later so needs to be used out of scope here
#endif
