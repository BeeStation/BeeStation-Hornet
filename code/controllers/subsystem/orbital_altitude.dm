// Orbital altitude thresholds in meters
#define ORBITAL_ALTITUDE_HIGH_BOUND 140000 // 140km - Cannot go higher than this
#define ORBITAL_ALTITUDE_HIGH_CRITICAL 130000 // 130km - Upper critical threshold
#define ORBITAL_ALTITUDE_HIGH 120000 // 120km - Upper normal threshold
#define ORBITAL_ALTITUDE_DEFAULT 110000 // 110km - Default stable altitude
#define ORBITAL_ALTITUDE_LOW 95000 // 95km - Lower warning threshold (visual effects start)
#define ORBITAL_ALTITUDE_LOW_CRITICAL 90000 // 90km - Lower critical threshold (structural damage begins)
#define ORBITAL_ALTITUDE_LOW_BOUND 80000 // 80km - Cannot go lower than this

SUBSYSTEM_DEF(orbital_altitude)
	name = "Orbital Altitude"
	can_fire = TRUE
	wait = 1 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING

	/// Current orbital altitude in meters
	var/orbital_altitude = ORBITAL_ALTITUDE_DEFAULT

	/// Velocity index for display purposes (-10 to +10)
	var/velocity_index = 0

	/// Current thrust applied to the station (from engines)
	var/thrust = 0
	/// Current orbital decay rate in m/s
	var/decay_rate = 0
	/// Atmospheric resistance coefficient (0.5 to 1.0)
	var/resistance = 1.0

	/// List of all orbital thrusters
	var/list/orbital_thrusters = list()

	/// World time when critical orbit was entered
	var/critical_orbit_start_time = 0
	/// Whether the station is in critical orbit (below 90km)
	var/in_critical_orbit = FALSE
	/// Whether the station is in low altitude warning zone (below 95km)
	var/in_low_altitude = FALSE
	/// Whether the station is in high altitude warning zone (above 120km)
	var/in_high_altitude = FALSE
	/// Whether the station is in critical high altitude zone (above 130km)
	var/in_high_altitude_critical = FALSE
	/// Whether the final 60-second countdown has started
	var/final_countdown_active = FALSE
	/// World time of the last warning announcement
	var/last_warning_time = 0
	/// Security level before switching to delta
	var/previous_alert_level = SEC_LEVEL_GREEN
	/// Current stage of the final countdown (0-4)
	var/countdown_stage = 0

	/// Cached station boundaries for each Z-level
	var/list/station_bounds_cache
	/// Whether station bounds have been calculated
	var/bounds_calculated = FALSE

	COOLDOWN_DECLARE(orbital_report_cooldown)
	COOLDOWN_DECLARE(orbital_report_critical)
	COOLDOWN_DECLARE(heavy_atmospheric_drag_cooldown)

/datum/controller/subsystem/orbital_altitude/fire(resumed = FALSE)
	// Disable for planetary stations (they don't orbit)
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return

	// Calculate station boundaries once at startup
	if(!bounds_calculated)
		calculate_all_station_bounds()
		bounds_calculated = TRUE

	// Update thrust from all orbital thrusters
	update_thrust_from_thrusters()

	// Update orbital altitude based on physics
	orbital_altitude_change()

	// Check for critical orbit conditions and warnings
	check_critical_orbit()

	// Send periodic status reports
	if(COOLDOWN_FINISHED(src, orbital_report_cooldown) && !in_critical_orbit)
		send_orbital_report()

	// Spawn atmospheric drag damage effects when critical
	if(in_critical_orbit)
		spawn_atmospheric_drag()
		if(COOLDOWN_FINISHED(src, orbital_report_critical))
			send_orbital_report()

/datum/controller/subsystem/orbital_altitude/proc/update_thrust_from_thrusters()
	// Calculate total thrust from all thrusters
	thrust = 0
	var/thruster_count = 0
	var/summed_thrust = 0

	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/T in orbital_thrusters)
		if(QDELETED(T))
			continue
		thruster_count++
		summed_thrust += T.thrust_level

	// We now know how many thrusters we have, and what their collective thrust is.

	// Average the thrust level
	summed_thrust /= thruster_count

	thrust = clamp(summed_thrust * 2, -40, 40) // Since thrusters can now range from -20 to +20, and we need -40 to +40 range

/datum/controller/subsystem/orbital_altitude/proc/orbital_altitude_change()
	var/orbital_altitude_change = 0

	// Calculate atmospheric decay rate (increases as altitude decreases)
	decay_rate = min(max((-orbital_altitude * 0.0006) + 78, 0), 30)

	// Calculate atmospheric resistance (decreases as altitude decreases)
	resistance = min(max((orbital_altitude * 0.0001) - 8.5, 0.5), 1)

	// Apply forces to altitude
	orbital_altitude_change -= decay_rate  // Natural orbital decay
	orbital_altitude_change += thrust      // Engine thrust (if any)
	orbital_altitude_change += rand(-5, 5) / 10  // Minor random fluctuation

	// Apply atmospheric turbulence (more likely at lower altitudes)
	var/atmospheric_turbulence_chance = min(max((-orbital_altitude * 0.01) + 1000, 5), 100)
	if(prob(atmospheric_turbulence_chance))
		var/fluctuation = rand(-(atmospheric_turbulence_chance / 20), atmospheric_turbulence_chance / 20)
		orbital_altitude_change += fluctuation

	// Calculate velocity index for display
	var/temp_index = orbital_altitude_change / 3
	velocity_index = clamp(temp_index, -10, 10)

	// Apply resistance to altitude change
	orbital_altitude_change *= resistance

	// Extreme atmospheric drag below 85km
	if(orbital_altitude <= 85000)
		orbital_altitude_change /= 2

	// Clamp altitude change rate
	orbital_altitude_change = clamp(orbital_altitude_change, -30, 30)

	// Apply the change
	orbital_altitude += orbital_altitude_change

	// Enforce hard altitude limits (80km minimum, 140km maximum)
	orbital_altitude = clamp(orbital_altitude, ORBITAL_ALTITUDE_LOW_BOUND, ORBITAL_ALTITUDE_HIGH_BOUND)

/datum/controller/subsystem/orbital_altitude/proc/send_orbital_report()
	COOLDOWN_START(src, orbital_report_cooldown, 10 MINUTES)
	COOLDOWN_START(src, orbital_report_critical, 1 MINUTES)

	// Normalize resistance for display (0-100%)
	var/resistance_normalized = clamp((1 - resistance) * 100 + rand(-10, 10), 0, 100)

	if(in_critical_orbit)
		// Critical orbit emergency report
		var/time_in_critical = (world.time - critical_orbit_start_time) / 10
		var/time_remaining = max(0, 600 - time_in_critical)
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
		// Normal status report
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

/datum/controller/subsystem/orbital_altitude/proc/check_critical_orbit()
	// High altitude critical warning (above 130km threshold)
	if(orbital_altitude > ORBITAL_ALTITUDE_HIGH_CRITICAL && !in_high_altitude_critical)
		in_high_altitude_critical = TRUE
		priority_announce("DANGER: Station orbital altitude has exceeded critical upper threshold. \
			Current altitude: [round(orbital_altitude/1000, 0.1)]km. \
			Station entering the Osei-Hollund radiation band. Critical radiative exposure likely. \
			Immediate corrective action required.", \
			"CRITICAL ALTITUDE WARNING",
			sound = 'sound/misc/notice1.ogg',
			has_important_message = TRUE)

	// High altitude warning (above 120km threshold)
	if(orbital_altitude > ORBITAL_ALTITUDE_HIGH && !in_high_altitude && !in_high_altitude_critical)
		in_high_altitude = TRUE
		priority_announce("Advisory: Station orbital altitude has exceeded normal operating parameters. \
			Current altitude: [round(orbital_altitude/1000, 0.1)]km. \
			Entering radiative zone at this altitude. Further monitoring is advised.", \
			"High Altitude Advisory",
			sound = 'sound/misc/notice2.ogg')

	// Low altitude warning (95km threshold)
	if(orbital_altitude < ORBITAL_ALTITUDE_LOW && !in_low_altitude)
		in_low_altitude = TRUE
		priority_announce("Advisory: Station orbital altitude has decreased below normal operating parameters. \
			Current altitude: [round(orbital_altitude/1000, 0.1)]km. \
			Further monitoring is advised.", \
			"Orbital Altitude Advisory",
			sound = 'sound/misc/notice2.ogg')

	// Critical orbit handling (below 90km)
	if(orbital_altitude < ORBITAL_ALTITUDE_LOW_CRITICAL)
		// Enter critical orbit state
		if(!in_critical_orbit)
			in_critical_orbit = TRUE
			critical_orbit_start_time = world.time
			last_warning_time = world.time

			priority_announce("WARNING: Station orbital altitude has fallen below critical threshold. Structural damage detected.\nRestore orbital parameters immediately.",
				"CRITICAL ORBITAL FAILURE",
				sound = 'sound/misc/notice1.ogg',
				has_important_message = TRUE)

		// Calculate time remaining until destruction
		var/time_in_critical = (world.time - critical_orbit_start_time) / 10
		var/time_remaining = 600 - time_in_critical

		// Send periodic warnings every 2 minutes
		if(!final_countdown_active && (world.time - last_warning_time) >= 120 SECONDS)
			last_warning_time = world.time
			var/minutes_remaining = round(time_remaining / 60)

			priority_announce("WARNING: Station altitude remains critical at [round(orbital_altitude/1000, 0.1)]km. \
				Estimated time until full structural failure: [minutes_remaining] minute[minutes_remaining == 1 ? "" : "s"]. \
				Immediate corrective action required.", \
				"ORBITAL PARAMETERS CRITICAL",
				sound = 'sound/misc/notice1.ogg',
				has_important_message = TRUE)

			// Escalate to delta alert at 4 minutes remaining
			if(time_remaining <= 240 && SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_DELTA)
				previous_alert_level = SSsecurity_level.get_current_level_as_number()
				SSsecurity_level.set_level(SEC_LEVEL_DELTA)

		// Final countdown stages
		if(!final_countdown_active && time_remaining <= 60)
			final_countdown_active = TRUE
			countdown_stage = 1
			announce_countdown_stage()
		else if(final_countdown_active)
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
		// Restored from critical orbit
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

			// Restore previous security level if we escalated to delta
			if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_DELTA)
				SSsecurity_level.set_level(previous_alert_level)

		// Clear low altitude flag when safely above 95km
		if(orbital_altitude >= ORBITAL_ALTITUDE_LOW && in_low_altitude)
			in_low_altitude = FALSE

	// Clear high altitude flags when returning to normal range
	if(orbital_altitude <= ORBITAL_ALTITUDE_HIGH)
		if(in_high_altitude_critical)
			in_high_altitude_critical = FALSE
			priority_announce("Station altitude has returned below critical upper threshold. \
				Radiative exposure normalized.", \
				"Altitude Stabilized",
				sound = 'sound/misc/notice2.ogg')

		if(in_high_altitude)
			in_high_altitude = FALSE
			priority_announce("Station altitude has returned to normal operating parameters.", \
				"Altitude Normalized",
				sound = 'sound/misc/notice2.ogg')

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

/datum/controller/subsystem/orbital_altitude/proc/initiate_destruction()
	Cinematic(CINEMATIC_SELFDESTRUCT, world, CALLBACK(src, PROC_REF(complete_destruction)))

/datum/controller/subsystem/orbital_altitude/proc/complete_destruction()
	// Kill all living mobs on station levels
	for(var/mob/living/L in GLOB.mob_living_list)
		var/turf/T = get_turf(L)
		if(T && is_station_level(T.z))
			L.investigate_log("has died from orbital decay.", INVESTIGATE_DEATHS)
			L.gib()

	// Force round end
	SSticker.force_ending = FORCE_END_ROUND

/datum/controller/subsystem/orbital_altitude/proc/spawn_atmospheric_drag()
	var/list/station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_z_levels))
		return

	var/target_z = pick(station_z_levels)
	var/list/bounds = station_bounds_cache["[target_z]"]
	if(!bounds)
		return

	// Pick a random edge to spawn from
	var/edge = rand(1, 4)
	var/turf/start_turf
	var/turf/target_turf

	switch(edge)
		if(1) // Top edge
			start_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["max_y"] + 10, target_z)
			target_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["min_y"], target_z)
		if(2) // Bottom edge
			start_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["min_y"] - 10, target_z)
			target_turf = locate(rand(bounds["min_x"], bounds["max_x"]), bounds["max_y"], target_z)
		if(3) // Right edge
			start_turf = locate(bounds["max_x"] + 10, rand(bounds["min_y"], bounds["max_y"]), target_z)
			target_turf = locate(bounds["min_x"], rand(bounds["min_y"], bounds["max_y"]), target_z)
		if(4) // Left edge
			start_turf = locate(bounds["min_x"] - 10, rand(bounds["min_y"], bounds["max_y"]), target_z)
			target_turf = locate(bounds["max_x"], rand(bounds["min_y"], bounds["max_y"]), target_z)

	if(!start_turf || !target_turf)
		return

	// Spawn heavy drag occasionally, light drag otherwise
	if(COOLDOWN_FINISHED(src, heavy_atmospheric_drag_cooldown))
		COOLDOWN_START(src, heavy_atmospheric_drag_cooldown, 60 SECONDS)
		new /obj/effect/meteor/atmospheric_drag/heavy(start_turf, target_turf)
	else
		new /obj/effect/meteor/atmospheric_drag(start_turf, target_turf)

/datum/controller/subsystem/orbital_altitude/proc/calculate_all_station_bounds()
	station_bounds_cache = list()

	var/list/station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_z_levels))
		return

	// Calculate bounding box and cache space turfs for each station Z-level
	for(var/z_level in station_z_levels)
		var/min_x = world.maxx
		var/max_x = 1
		var/min_y = world.maxy
		var/max_y = 1
		var/found_station = FALSE

		// Iterate through all non-space areas
		for(var/area/A in GLOB.areas)
			if(A.type == /area/space || istype(A, /area/space))
				continue

			var/list/area_turfs = A.get_contained_turfs()
			if(!length(area_turfs))
				continue

			// Find the bounding box of station turfs on this Z-level
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

		// Cache the bounds for this Z-level
		if(found_station && max_x >= min_x && max_y >= min_y)
			var	key = "[z_level]"
			station_bounds_cache[key] = list("min_x" = min_x, "max_x" = max_x, "min_y" = min_y, "max_y" = max_y)

// Invisible atmospheric drag effect that damages station structures
// Simulates heating and structural stress from atmospheric re-entry
/obj/effect/meteor/atmospheric_drag
	name = "atmospheric drag"
	desc = "You shouldn't be seeing this."
	icon_state = "dust"
	alpha = 0
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = null
	meteordrop = list()
	dropamt = 0
	threat = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSDOORS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	movement_type = FLYING

	/// Damage dealt to structures on impact
	var/erosionpower = 20

/obj/effect/meteor/atmospheric_drag/Initialize(mapload, target)
	. = ..()
	// Remove from global meteor list (this isn't a real meteor event)
	GLOB.meteor_list -= src
	SSaugury.unregister_doom(src)

/obj/effect/meteor/atmospheric_drag/chase_target(atom/chasing, delay, home)
	. = ..()

/obj/effect/meteor/atmospheric_drag/Bump(atom/A)
	// Pass through mobs harmlessly
	if(isliving(A) || ismob(A))
		return

	if(isturf(A))
		return ..()

	// Damage structures and machinery
	if(A.density)
		if(istype(A, /obj/structure) || istype(A, /obj/machinery))
			var/obj/O = A
			O.take_damage(erosionpower, BRUTE, "melee", 0)
		else if(istype(A, /turf/closed))
			return ..()

	return

/obj/effect/meteor/atmospheric_drag/ram_turf(turf/T)
	// Don't damage turfs with mobs on them
	for(var/mob/M in T)
		return

	if(isspaceturf(T))
		return

	// Queue minor explosion on this turf
	SSexplosions.lowturf += T

	get_hit()

/obj/effect/meteor/atmospheric_drag/get_hit()
	hits--
	if(hits <= 0)
		// Play creaking sound for atmosphere
		playsound(src.loc, pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg'), 80, TRUE, 300, falloff_distance = 300)
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

// Heavy variant for more intense damage
/obj/effect/meteor/atmospheric_drag/heavy
	name = "heavy atmospheric drag"
	hitpwr = EXPLODE_HEAVY
	hits = 50
	erosionpower = 100

/obj/effect/meteor/atmospheric_drag/heavy/ram_turf(turf/T)
	// Don't damage turfs with mobs on them
	for(var/mob/M in T)
		return

	if(isspaceturf(T))
		return

	// Queue major explosion on this turf
	SSexplosions.highturf += T

	get_hit()
