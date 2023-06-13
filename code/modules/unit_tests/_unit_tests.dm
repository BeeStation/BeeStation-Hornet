//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// *Only* run the test provided within the parentheses
/// This is useful for debugging when you want to reduce noise, but should never be pushed
/// Intended to be used in the manner of `TEST_FOCUS(/datum/unit_test/math)`
#define TEST_FOCUS(test_path) ##test_path { focus = TRUE; }

/// Constants indicating unit test completion status
#define UNIT_TEST_PASSED 0
#define UNIT_TEST_FAILED 1
#define UNIT_TEST_SKIPPED 2

#define TEST_DEFAULT 1
#define TEST_DEL_WORLD INFINITY

/// A trait source when adding traits through unit tests
#define TRAIT_SOURCE_UNIT_TESTS "unit_tests"

#include "achievement_validation.dm"
#include "anchored_mobs.dm"
#include "check_adjustable_clothing.dm"
#include "component_tests.dm"
#include "connect_loc.dm"
#include "crafting_tests.dm"

// Del the World.
// This unit test creates and qdels almost every atom in the code, checking for errors with initialization and harddels on deletion.
// It is disabled by default for now due to the large amount of consistent errors it produces. Run the "dm: find hard deletes" task to enable it.
#ifdef REFERENCE_TRACKING_FAST
#include "create_and_destroy.dm"
#endif

#include "dynamic_ruleset_sanity.dm"
#include "enumerables.dm"
#include "keybinding_init.dm"
#include "rcd.dm"
#include "reagent_id_typos.dm"
#include "reagent_recipe_collisions.dm"
#include "siunit.dm"
#include "shuttle_width_height_correctness.dm"
#include "spawn_humans.dm"
#include "species_whitelists.dm"
#include "greyscale_config.dm"
#include "heretic_knowledge.dm"
#include "heretic_rituals.dm"
#include "metabolizing.dm"
#include "ntnetwork_tests.dm"
#include "projectiles.dm"
#include "subsystem_init.dm"
#include "subsystem_metric_sanity.dm"
#include "techweb_sanity.dm"
#include "tgui_create_message.dm"
#include "timer_sanity.dm"
#include "unit_test.dm"
#include "random_ruin_mapsize.dm"
#include "walls_have_sheets.dm"

#ifdef REFERENCE_TRACKING_DEBUG //Don't try and parse this file if ref tracking isn't turned on. IE: don't parse ref tracking please mr linter
#include "find_reference_sanity.dm"
#endif

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
//#undef TEST_FOCUS - This define is used by vscode unit test extension to pick specific unit tests to run and appended later so needs to be used out of scope here
#endif
