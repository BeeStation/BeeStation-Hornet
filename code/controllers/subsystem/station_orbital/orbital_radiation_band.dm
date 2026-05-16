// Rad protection levels
#define PROTECTION_HIGH 3
#define PROTECTION_MEDIUM 2
#define PROTECTION_LOW 1

SUBSYSTEM_DEF(orbital_radiation_band)
	name = "Orbital Radiation Band"
	// Starts disabled, orbital_altitude turns us on/off via can_fire
	can_fire = FALSE
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
	)
	// Only allowed to use small portions of tick
	priority = FIRE_PRIORITY_STATION_ALTITUDE
	runlevels = RUNLEVEL_GAME
	/// Station levels
	var/list/station_levels

/datum/controller/subsystem/orbital_radiation_band/Initialize()
	// What are the station z-levels?
	station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/orbital_radiation_band/fire(resumed)
	// Calculate intensity based on altitude
	var/current_altitude = SSorbital_altitude.orbital_altitude

	// if above 120km, intensity is 1, if above 130km, intensity is 2
	var/intensity = 0
	if(current_altitude > ORBITAL_ALTITUDE_UPPER_CRITICAL)
		intensity = 2
	else if(current_altitude > ORBITAL_ALTITUDE_UPPER)
		intensity = 1

	// Are we above the critical altitude threshold?
	var/is_critical = current_altitude > ORBITAL_ALTITUDE_UPPER_CRITICAL

	// Process all living mobs on station z-levels
	for(var/mob/living/living_mob in GLOB.mob_living_list)
		var/turf/mob_turf = get_turf(living_mob)
		if(!mob_turf)
			continue

		// Skip if not on a station z-level
		if(!(mob_turf.z in station_levels))
			continue

		// Skip if they have radiation immunity
		if(HAS_TRAIT(living_mob, TRAIT_RADIMMUNE))
			continue

		var/area/mob_area = get_area(living_mob)
		if(!mob_area)
			continue // How?

		// Determine protection level (HIGH, MEDIUM, or LOW)
		var/protection_level

		// Check for HIGH protection (rad-shielded areas)
		if(istype(mob_area, /area/station/maintenance) || \
			istype(mob_area, /area/station/ai_monitored/turret_protected/ai_upload) || \
			istype(mob_area, /area/station/ai_monitored/turret_protected/ai_upload_foyer) || \
			istype(mob_area, /area/station/ai_monitored/turret_protected/ai) || \
			istype(mob_area, /area/station/commons/storage/emergency) || \
			istype(mob_area, /area/shuttle) || \
			istype(mob_area, /area/station/security/prison))
			protection_level = PROTECTION_HIGH
		// Check for LOW protection (in space)
		else if(istype(mob_turf, /turf/open/space))
			protection_level = PROTECTION_LOW
		// Otherwise MEDIUM protection
		else
			protection_level = PROTECTION_MEDIUM

		// HIGH protection: always immune
		if(protection_level >= PROTECTION_HIGH)
			continue

		// Below critical altitude: only LOW protection gets radiation
		if(!is_critical && protection_level >= PROTECTION_MEDIUM)
			continue

		// Calculate per-mob dose
		var/dose = intensity

		// Above critical altitude: MEDIUM protection gets half dose
		if(is_critical && protection_level == PROTECTION_MEDIUM)
			dose *= 0.5

		// Apply the radiation
		if(dose > 0)
			SSradiation.irradiate(living_mob, dose)

/// Called by the altitude subsystem when radiation processing should stop.
/datum/controller/subsystem/orbital_radiation_band/proc/deactivate()
	can_fire = FALSE

#undef PROTECTION_HIGH
#undef PROTECTION_MEDIUM
#undef PROTECTION_LOW
