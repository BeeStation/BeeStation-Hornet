// Even higher orbit, causing extreme radiation outside, and more frequent radstorms.
#define ORBITAL_ALTITUDE_HIGH_CRITICAL 130000
// High orbit, radiation starts here
#define ORBITAL_ALTITUDE_HIGH 120000
// The altitude at which the station orbits the planet at roundstart. This is where we want it to be normally. In meters.
#define ORBITAL_ALTITUDE_DEFAULT 110000
// The altitude at which the station is considered to be in low orbit, causing light structural damage.
#define ORBITAL_ALTITUDE_LOW 95000
// Critical orbit altitude, causing heavy structural damage. If you spend 10 minutes here without raising your orbit, goodbye station.
#define ORBITAL_ALTITUDE_LOW_CRITICAL 90000

/**
 * Orbital Altitude Subsystem
 * Handles the orbital altitude of the station, causing various effects based on altitude.
 * critical_failure() is called when the station experiences a game over condition due to low orbit.
 * This can be the case for a station that remains below 70km for 10 minutes, or a station that falls below 60km.
 */
SUBSYSTEM_DEF(orbital_altitude)
	name = "Orbital Altitude"
	can_fire = TRUE
	wait = 1 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING

	var/orbital_altitude = 91000

	var/velocity_index = 0 // Used for the consoles to tell the crew if we are gaining or losing altitude.

	// All below are meters per second, based on fire running every second. This might not be the case, please advise.
	var/thrust // Positive values raise orbit, negative values lower it.
	var/decay_rate // Scales with altitude.

	// Resistance, scales with altitude, reduces the effect of all vertical movement, decay and thrust alike. Caps at 0.5 at 70km, 1.0 at 90km.
	var/resistance = 1.0

	var/critical_orbit_start_time = 0 // World time when critical orbit started
	var/in_critical_orbit = FALSE // TRUE if we're currently in critical orbit
	var/final_countdown_active = FALSE // TRUE if we're in the final 60 second countdown
	var/last_warning_time = 0 // Last time we issued a warning
	var/previous_alert_level = SEC_LEVEL_GREEN // Security level before we went to delta
	var/countdown_stage = 0 // Track which stage of the countdown we're in (0=none, 1=60s, 2=30s, 3=10s, 4=destruction)

	// Pre-calculated station bounds per z-level. This used to take like 50ms teehee
	var/list/station_bounds_cache // Associative list of z_level -> bounds, calculated once at initialization
	var/bounds_calculated = FALSE // Track if we've calculated bounds yet

	COOLDOWN_DECLARE(orbital_report_cooldown)
	COOLDOWN_DECLARE(orbital_report_critical)
	COOLDOWN_DECLARE(heavy_atmospheric_drag_cooldown)

/datum/controller/subsystem/orbital_altitude/fire(resumed = FALSE)
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return // If we do this in initialize it yells at us about calling fire on a ss that doesn't fire, which this does.

	// Calculate bounds on first fire after map load
	if(!bounds_calculated)
		calculate_all_station_bounds()
		bounds_calculated = TRUE

	// Apply orbital altitude changes.
	orbital_altitude_change()

	// Check for critical orbit conditions
	check_critical_orbit()

	// Every cooldown period, send out orbital report, unless in critical orbit
	if(COOLDOWN_FINISHED(src, orbital_report_cooldown) && !in_critical_orbit)
		send_orbital_report()

	// Handle critical orbit stuff
	if(in_critical_orbit)
		// Spawn atmospheric drag meteors
		spawn_atmospheric_drag()
		// More frequent reports
		if(COOLDOWN_FINISHED(src, orbital_report_critical))
			send_orbital_report()

/datum/controller/subsystem/orbital_altitude/proc/orbital_altitude_change()
	var/orbital_altitude_change = 0

	// Determine decay rate and resistance based on current orbital altitude. Plug this mess into desmos if you want to see how it works.
	decay_rate = min( max( (-orbital_altitude * 0.0008) + 96, 0), 30)
	resistance = min( max( (orbital_altitude * 0.0001) - 8.5, 0.5), 1)

	// Thrust is set by the consoles separately, so we just use the current value.
	// We now have everything we need to update the orbital altitude.
	orbital_altitude_change -= decay_rate
	orbital_altitude_change += thrust
	orbital_altitude_change += rand(-5,5) / 10 // Small random fluctuation to make things less static.

	var/atmospheric_turbulence_chance = min( max( (-orbital_altitude * 0.01) +1000, 5), 100)
	if(prob(atmospheric_turbulence_chance)) // increasing chance with depth to have a bigger orbital fluctuation.
		var/fluctuation = rand(-(atmospheric_turbulence_chance / 20), atmospheric_turbulence_chance / 20)
		orbital_altitude_change += fluctuation

	// Update velocity index for consoles. We do this here to avoid including any kind of resistance effects.
	var/temp_index
	temp_index = orbital_altitude_change / 3 // Scale to a 10 point scale.
	velocity_index = temp_index //+ ( rand(-10,10) / 10 ) // Add a bit of randomness to make it less static.
	velocity_index = clamp(velocity_index, -10, 10)

	// Apply resistances to the change in orbital altitude.
	orbital_altitude_change *= resistance
	if(orbital_altitude <= 85000) // We are actually falling all the way. Make sure we go slower so we can't ever go below 70km for immersion
		orbital_altitude_change /= 2

	// We cap the maximum change to 30 m/s up or down to prevent extreme jumps.
	orbital_altitude_change = clamp(orbital_altitude_change, -30, 30)

	// Update orbital altitude
	orbital_altitude += orbital_altitude_change

	// Clamp orbital altitude to reasonable values.
	orbital_altitude = clamp(orbital_altitude, 80000, 140000)

/datum/controller/subsystem/orbital_altitude/proc/send_orbital_report()
	COOLDOWN_START(src, orbital_report_cooldown, 10 MINUTES)
	COOLDOWN_START(src, orbital_report_critical, 1 MINUTES)

	var/resistance_normalized = clamp((1 - resistance) * 100 + rand(-10,10), 0, 100)// Scale resistance to look a bit nicer for reports

	if(in_critical_orbit)
		var/time_in_critical = (world.time - critical_orbit_start_time) / 10 // Convert to seconds
		var/time_remaining = max(0, 600 - time_in_critical) // 600 seconds = 10 minutes
		var/minutes_remaining = round(time_remaining / 60, 0.1)

		GLOB.news_network.submit_article("<h1>EMERGENCY STATUS REPORT</h1>\
												<b>STATION [uppertext(station_name())] - CRITICAL ALERT</b><br><br>\
												Current orbital altitude: <b>[round(orbital_altitude/1000, 0.1)]km</b><br>\
												Orbital Velocity Index: [round(velocity_index, 0.1)]<br>\
												Detected Orbital Decay: <b>[round(decay_rate, 0.1)]m/s</b><br>\
												Atmospheric resistance: <b>[round(resistance_normalized, 0.1)]%</b><br>\
												<b>Estimated time to structural failure: [minutes_remaining] minutes</b><br><br>\
												<b>STATUS: [pick("STRUCTURAL STRESS DETECTED","HULL BREACHES DETECTED","CATASTROPHIC FAILURE IMMINENT","EMERGENCY THRUST REQUIRED")]</b><br>\
												<b>IMMEDIATE CORRECTIVE ACTION REQUIRED</b><br><br>\
												- Automated Station Systems - PRIORITY ALERT",
												"Automated Station System",
												"Station Orbital Report")
	else
		GLOB.news_network.submit_article("<h1>Automated Orbital Parameter Status Report</h1>\
												Station [station_name()] telemetry update:<br><br>\
												Current orbital altitude: [round(orbital_altitude/1000, 0.1)]km<br>\
												Orbital Velocity Index: [round(velocity_index, 0.1)]<br>\
												Detected Orbital Decay: [round(decay_rate, 0.1)]m/s<br>\
												Normalized atmospheric resistance: [round(resistance_normalized, 0.1)]%<br>\
												Semi-Major Axis: [rand(6500, 6900)]km<br>\
												Status: [pick("No drift detected.","Minimal drift detected.","Drift detected, within acceptable parameters.")]<br><br>\
												<b>All systems nominal.</b><br><br>\
												- Automated Station Systems - ",
												"Automated Station System",
												"Station Orbital Report")

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////          Critical orbit handling            /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Check if we're in critical orbit and handle the failure condition
 */
/datum/controller/subsystem/orbital_altitude/proc/check_critical_orbit()
	if(orbital_altitude < ORBITAL_ALTITUDE_LOW_CRITICAL)
		if(!in_critical_orbit)
			// Just entered critical orbit
			in_critical_orbit = TRUE
			critical_orbit_start_time = world.time
			last_warning_time = world.time

			// Sound priority alert and set delta alert
			priority_announce("WARNING: Station orbital altitude has fallen below critical threshold. Structural damage detected.\nRestore orbital parameters immediately.",
				"CRITICAL ORBITAL FAILURE",
				sound = 'sound/misc/notice1.ogg',
				has_important_message = TRUE)

		// Calculate time in critical orbit
		var/time_in_critical = (world.time - critical_orbit_start_time) / 10 // Convert to seconds
		var/time_remaining = 600 - time_in_critical // 600 seconds = 10 minutes

		// Regular warnings every 2 minutes (120 seconds)
		if(!final_countdown_active && (world.time - last_warning_time) >= 120 SECONDS)
			last_warning_time = world.time
			var/minutes_remaining = round(time_remaining / 60)

			priority_announce("WARNING: Station altitude remains critical at [round(orbital_altitude/1000, 0.1)]km. \
				Estimated time until full structural failure: [minutes_remaining] minute[minutes_remaining == 1 ? "" : "s"]. \
				Immediate corrective action required.", \
				"ORBITAL PARAMETERS CRITICAL",
				sound = 'sound/misc/notice1.ogg',
				has_important_message = TRUE)

			if(time_remaining <= 240 && SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_DELTA)
				// Save the current alert level before going to delta
				previous_alert_level = SSsecurity_level.get_current_level_as_number()
				SSsecurity_level.set_level(SEC_LEVEL_DELTA)

		// Handle countdown stages based on time remaining
		if(!final_countdown_active && time_remaining <= 60)
			final_countdown_active = TRUE
			countdown_stage = 1
			announce_countdown_stage()
		else if(final_countdown_active)
			// Progress through countdown stages
			if(countdown_stage == 1 && time_remaining <= 30)
				countdown_stage = 2
				announce_countdown_stage()
			else if(countdown_stage == 2 && time_remaining <= 10)
				countdown_stage = 3
				announce_countdown_stage()
			else if(countdown_stage == 3 && time_remaining <= 0)
				countdown_stage = 4
				initiate_destruction()
	else
		// Exited critical orbit
		if(in_critical_orbit)
			in_critical_orbit = FALSE
			critical_orbit_start_time = 0
			final_countdown_active = FALSE
			countdown_stage = 0

			priority_announce("Station altitude has been restored above critical threshold. \
				Emergency status cancelled.", \
				"ORBITAL STABILITY RESTORED",
				sound = 'sound/misc/notice2.ogg',
				has_important_message = TRUE)

			send_orbital_report()

			// Restore previous security level if it was delta
			if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_DELTA)
				SSsecurity_level.set_level(previous_alert_level)

/**
 * Announce the current countdown stage
 */
/datum/controller/subsystem/orbital_altitude/proc/announce_countdown_stage()
	switch(countdown_stage)
		if(1)
			priority_announce("DANGER: Catastrophic structural failure imminent. Station breakup in 60 seconds. \
				All personnel is to evacuate immediately.", \
				"DESTRUCTION IMMINENT",
				sound = 'sound/misc/notice3.ogg',
				has_important_message = TRUE)
		if(2)
			priority_announce("DANGER: Station breakup in 30 seconds.", \
				"DESTRUCTION IMMINENT",
				sound = 'sound/misc/notice3.ogg',
				has_important_message = TRUE)
		if(3)
			priority_announce("DANGER: Station breakup in 10 seconds.", \
				"DESTRUCTION IMMINENT",
				sound = 'sound/misc/notice3.ogg',
				has_important_message = TRUE)

/**
 * Initiate the station destruction sequence
 */
/datum/controller/subsystem/orbital_altitude/proc/initiate_destruction()
	// Play cinematic and then complete destruction
	Cinematic(CINEMATIC_SELFDESTRUCT, world, CALLBACK(src, PROC_REF(complete_destruction)))

/**
 * Complete the station destruction (called after cinematic)
 */
/datum/controller/subsystem/orbital_altitude/proc/complete_destruction()
	// Kill everyone on the station z-level
	for(var/mob/living/L in GLOB.mob_living_list)
		var/turf/T = get_turf(L)
		if(T && is_station_level(T.z))
			L.investigate_log("has died from orbital decay.", INVESTIGATE_DEATHS)
			L.gib()

	// End the round
	SSticker.force_ending = FORCE_END_ROUND

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////          Atmospheric drag handling            ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Spawn atmospheric drag meteors to simulate structural damage during low orbit
 */
/datum/controller/subsystem/orbital_altitude/proc/spawn_atmospheric_drag()
	// Get all station z-levels
	var/list/station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_z_levels))
		return

	// Pick a random station z-level
	var/target_z = pick(station_z_levels)

	// Get the pre-calculated bounds of the station area on this z-level
	var/list/bounds = station_bounds_cache["[target_z]"]
	if(!bounds)
		return

	// Pick a random edge to spawn from (north, south, east, west)
	var/edge = rand(1, 4)
	var/turf/start_turf
	var/turf/target_turf

	switch(edge)
		if(1) // North edge, coming from above
			start_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["max_y"] + 10, target_z)
			target_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["min_y"], target_z)
		if(2) // South edge, coming from below
			start_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["min_y"] - 10, target_z)
			target_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["max_y"], target_z)
		if(3) // East edge, coming from right
			start_turf = locate(bounds["max_x"] + 10, rand(bounds["min_y"], bounds["max_y"]), target_z)
			target_turf = locate(bounds["min_x"], rand(bounds["min_y"], bounds["max_y"]), target_z)
		if(4) // West edge, coming from left
			start_turf = locate(bounds["min_x"] - 10, rand(bounds["min_y"], bounds["max_y"]), target_z)
			target_turf = locate(bounds["max_x"], rand(bounds["min_y"], bounds["max_y"]), target_z)

	if(!start_turf || !target_turf)
		return

	if(COOLDOWN_FINISHED(src, heavy_atmospheric_drag_cooldown))
		COOLDOWN_START(src, heavy_atmospheric_drag_cooldown, 30 SECONDS)
		new /obj/effect/meteor/atmospheric_drag/heavy(start_turf, target_turf)
	else
		new /obj/effect/meteor/atmospheric_drag(start_turf, target_turf)

/**
 * Calculate station bounds for all station z-levels at initialization
 * Called once during subsystem initialization
 */
/datum/controller/subsystem/orbital_altitude/proc/calculate_all_station_bounds()
	station_bounds_cache = list()

	var/list/station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_z_levels))
		return

	for(var/z_level in station_z_levels)
		var/min_x = world.maxx
		var/max_x = 1
		var/min_y = world.maxy
		var/max_y = 1
		var/found_station = FALSE

		// Find the bounds by checking all station areas
		for(var/area/A in GLOB.areas)
			if(A.type == /area/space || istype(A, /area/space))
				continue

			// Check if this area has any turfs on our target z-level
			var/list/area_turfs = A.get_contained_turfs()
			if(!length(area_turfs))
				continue

			for(var/turf/T in area_turfs)
				if(T.z != z_level)
					continue
				if(!is_station_level(T.z))
					continue

				found_station = TRUE
				min_x = min(min_x, T.x)
				max_x = max(max_x, T.x)
				min_y = min(min_y, T.y)
				max_y = max(max_y, T.y)

		// Store the bounds if we found valid ones
		if(found_station && max_x >= min_x && max_y >= min_y)
			// Store with string key for consistency
			var/key = "[z_level]"
			station_bounds_cache[key] = list("min_x" = min_x, "max_x" = max_x, "min_y" = min_y, "max_y" = max_y)

/**
 * Atmospheric drag dummy meteor
 * These are invisible, intangible projectiles that only damage turfs
 * Used to simulate structural damage from atmospheric drag during low orbit
 */
/obj/effect/meteor/atmospheric_drag
	name = "atmospheric drag"
	desc = "You shouldn't be seeing this."
	icon_state = "dust"
	alpha = 0
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = null
	meteordrop = list() // No drops
	dropamt = 0
	threat = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSDOORS // Pass through everything except turfs
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT // Cannot be clicked
	movement_type = FLYING // Can move over dense objects
	var/erosionpower = 20

/obj/effect/meteor/atmospheric_drag/Initialize(mapload, target)
	. = ..()
	GLOB.meteor_list -= src
	SSaugury.unregister_doom(src)

/obj/effect/meteor/atmospheric_drag/chase_target(atom/chasing, delay, home)
	. = ..()

/obj/effect/meteor/atmospheric_drag/Bump(atom/A)
	// Never interact with mobs - pass right through them
	if(isliving(A) || ismob(A))
		return

	// Pass through everything except turfs and dense structures
	if(isturf(A))
		return ..()

	// Damage walls, windows, and other dense structures as we pass through
	if(A.density)
		if(istype(A, /obj/structure) || istype(A, /obj/machinery))
			var/obj/O = A
			O.take_damage(erosionpower, BRUTE, "melee", 0)
		else if(istype(A, /turf/closed))
			return ..()

	// Keep moving, don't stop
	return

/obj/effect/meteor/atmospheric_drag/ram_turf(turf/T)
	// Skip any mob warnings/messages
	// Check if there are any mobs on this turf - don't damage if so
	for(var/mob/M in T)
		return // Don't damage turfs with mobs on them

	// Skip space turfs - only damage station turfs
	if(isspaceturf(T))
		return

	// Only damage the turf itself - use light damage for normal ones
	SSexplosions.lowturf += T

	get_hit()

/obj/effect/meteor/atmospheric_drag/get_hit()
	hits--
	if(hits <= 0)
		playsound(src.loc, pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg'), 80, TRUE, 300, falloff_distance = 300) // We want everyone to hear but still want to use all the other fancy stuff this does.
		qdel(src)

/obj/effect/meteor/atmospheric_drag/examine(mob/user)
	return // Cannot be examined

/obj/effect/meteor/atmospheric_drag/attackby(obj/item/I, mob/user, params)
	return // Cannot be interacted with

/obj/effect/meteor/atmospheric_drag/CanPass(atom/movable/mover, border_dir)
	// Always let mobs pass through
	if(isliving(mover) || ismob(mover))
		return TRUE
	return ..()

/obj/effect/meteor/atmospheric_drag/CanPassThrough(atom/blocker, turf/target, blocker_dir)
	// Always pass through mobs
	if(isliving(blocker) || ismob(blocker))
		return TRUE
	return ..()

/obj/effect/meteor/atmospheric_drag/heavy
	name = "heavy atmospheric drag"
	hitpwr = EXPLODE_HEAVY
	hits = 50
	erosionpower = 100

/obj/effect/meteor/atmospheric_drag/heavy/ram_turf(turf/T)
	// Skip any mob warnings/messages
	// Check if there are any mobs on this turf - don't damage if so
	for(var/mob/M in T)
		return // Don't damage turfs with mobs on them

	// Skip space turfs - only damage station turfs
	if(isspaceturf(T))
		return

	// Heavy meteors use high damage
	SSexplosions.highturf += T

	get_hit()

#undef ORBITAL_ALTITUDE_HIGH_CRITICAL
#undef ORBITAL_ALTITUDE_HIGH
#undef ORBITAL_ALTITUDE_DEFAULT
#undef ORBITAL_ALTITUDE_LOW
#undef ORBITAL_ALTITUDE_LOW_CRITICAL
