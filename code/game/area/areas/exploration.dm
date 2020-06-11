/area/exploration_away
	name = "\improper Uncharted Area"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	hidden = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	blob_allowed = FALSE
	valid_territory = FALSE
	ambientsounds = SPACE

/area/exploration_away/outside
	name = "\improper Uncharted Space"
	has_gravity = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	outdoors = TRUE

/area/exploration_away/no_gravity
	has_gravity = FALSE

/area/exploration_away/always_powered
	requires_power = FALSE
	power_light = TRUE
	power_equip = TRUE
	power_environ = TRUE
