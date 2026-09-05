/// A preferences datum for unit tests.
/// Bypasses some "ermmm your client is null so we are killing you" conditionals that make unit tests not work
/datum/preferences/mock

/datum/preferences/mock/New()
	player_data = new(src)
	character_data = new(src, default_slot)
	character_data.provide_defaults(src, should_use_informed = FALSE)
