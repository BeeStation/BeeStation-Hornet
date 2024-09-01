//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// For advanced cases, fail unconditionally but don't return (so a test can return multiple results)
#define TEST_FAIL(reason) (Fail(reason || "No reason", __FILE__, __LINE__))

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is not null
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is null
#define TEST_ASSERT_NULL(a, reason) if (!isnull(a)) { return Fail("Expected null value but received [a]: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// *Only* run the test provided within the parentheses
/// This is useful for debugging when you want to reduce noise, but should never be pushed
/// Intended to be used in the manner of `TEST_FOCUS(/datum/unit_test/math)`
#define TEST_FOCUS(test_path) ##test_path { focus = TRUE; }

/// Logs a noticable message on GitHub, but will not mark as an error.
/// Use this when something shouldn't happen and is of note, but shouldn't block CI.
/// Does not mark the test as failed.
#define TEST_NOTICE(source, message) source.log_for_test((##message), "notice", __FILE__, __LINE__)

/// Constants indicating unit test completion status
#define UNIT_TEST_PASSED 0
#define UNIT_TEST_FAILED 1
#define UNIT_TEST_SKIPPED 2

#define TEST_PRE 0
#define TEST_DEFAULT 1
/// After most test steps, used for tests that run long so shorter issues can be noticed faster
#define TEST_LONGER 10
/// This must be the one of last tests to run due to the inherent nature of the test iterating every single tangible atom in the game and qdeleting all of them (while taking long sleeps to make sure the garbage collector fires properly) taking a large amount of time.
#define TEST_CREATE_AND_DESTROY 9001
/**
 * For tests that rely on create and destroy having iterated through every (tangible) atom so they don't have to do something similar.
 * Keep in mind tho that create and destroy will absolutely break the test platform, anything that relies on its shape cannot come after it.
 */
#define TEST_AFTER_CREATE_AND_DESTROY INFINITY

/// Change color to red on ANSI terminal output, if enabled with -DANSICOLORS.
#ifdef ANSICOLORS
#define TEST_OUTPUT_RED(text) "\x1B\x5B1;31m[text]\x1B\x5B0m"
#else
#define TEST_OUTPUT_RED(text) (text)
#endif
/// Change color to green on ANSI terminal output, if enabled with -DANSICOLORS.
#ifdef ANSICOLORS
#define TEST_OUTPUT_GREEN(text) "\x1B\x5B1;32m[text]\x1B\x5B0m"
#else
#define TEST_OUTPUT_GREEN(text) (text)
#endif
/// Change color to yellow on ANSI terminal output, if enabled with -DANSICOLORS.
#ifdef ANSICOLORS
#define TEST_OUTPUT_YELLOW(text) "\x1B\x5B1;33m[text]\x1B\x5B0m"
#else
#define TEST_OUTPUT_YELLOW(text) (text)
#endif
/// A trait source when adding traits through unit tests
#define TRAIT_SOURCE_UNIT_TESTS "unit_tests"

#include "../achievement_validation.dm"
#include "../anchored_mobs.dm"
#include "../antag_datums.dm"
#include "../area_contents.dm"
#include "../armour_checks.dm"
#include "../asset_smart_cache.dm"
#include "../async.dm"
#include "../bloody_footprints.dm"
#include "../check_adjustable_clothing.dm"
#include "../closets.dm"
#include "../component_tests.dm"
#include "../connect_loc.dm"
#include "../crafting_tests.dm"
//#include "../create_and_destroy.dm"
#include "../dcs_get_id_from_elements.dm"
#include "../dynamic_ruleset_sanity.dm"
#include "../enumerables.dm"
#include "../gamemode_sanity.dm"
#include "../keybinding_init.dm"
#include "../rcd.dm"
#include "../reagent_id_typos.dm"
#include "../reagent_recipe_collisions.dm"
#include "../siunit.dm"
#include "../shuttle_width_height_correctness.dm"
#include "../spawn_humans.dm"
#include "../species_whitelists.dm"
#include "../food_edibility_check.dm"
#include "../greyscale_config.dm"
#include "../heretic_knowledge.dm"
#include "../heretic_rituals.dm"
#include "../icon_smoothing_unit_test.dm"
#include "../merge_type.dm"
#include "../metabolizing.dm"
#include "../missing_icons.dm"
#include "../ntnetwork_tests.dm"
#include "../preference_species.dm"
#include "../projectiles.dm"
#include "../stat_mc.dm"
#include "../subsystem_init.dm"
#include "../subsystem_metric_sanity.dm"
#include "../surgery_linking.dm"
#include "../techweb_sanity.dm"
#include "../teleporters.dm"
#include "../tgui_create_message.dm"
#include "../timer_sanity.dm"
#include "../unit_test.dm"
#include "../random_ruin_mapsize.dm"
#include "../walls_have_sheets.dm"
#include "../worn_icons.dm"

#ifdef REFERENCE_TRACKING_DEBUG //Don't try and parse this file if ref tracking isn't turned on. IE: don't parse ref tracking please mr linter
#include "../find_reference_sanity.dm"
#endif

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
//#undef TEST_FOCUS - This define is used by vscode unit test extension to pick specific unit tests to run and appended later so needs to be used out of scope here
#endif
