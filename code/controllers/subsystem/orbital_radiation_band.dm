// Orbital Radiation Band Subsystem
// Above ORBITAL_ALTITUDE_HIGH, this subsystem starts applying radiation-based effects to station z-levels
// Above ORBITAL_ALTITUDE_HIGH_CRITICAL, the effects are doubled.
// We start very lightly, just 0.1 radiation every tick for mobs on space tiles/not in a station area.
// As altitude increases, the intensity of radiation points increases.
// Mobs on space tiles receive doubled radiation.
// Once we reach past ORBITAL_ALTITUDE_HIGH_CRITICAL, we start applying minor damage even to mobs inside station areas, only skipping the ones in protected areas according to radstorms.
// Damage inside the station never goes past 1 damage per tick, even at max altitude.
// Outside it can't go past 2 damage per tick.

// Rad protection levels
#define PROTECTION_HIGH 3
#define PROTECTION_MEDIUM 2
#define PROTECTION_LOW 1

SUBSYSTEM_DEF(orbital_radiation_band)
	name = "Orbital Radiation Band"
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
	)
	// Only allowed to use small portions of tick
	priority = FIRE_PRIORITY_ORBITAL_STUFF
	runlevels = RUNLEVEL_GAME
	/// Station levels
	var/list/station_levels

	/// Is the subsystem currently active (altitude-based)?
	var/radiation_active = FALSE

/datum/controller/subsystem/orbital_radiation_band/Initialize()
	// Disable for planetary stations
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return SS_INIT_SUCCESS

	// What are the station z-levels?
	station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/orbital_radiation_band/fire(resumed)
	// Check if we should be active based on altitude
	var/current_altitude = SSorbital_altitude.orbital_altitude
	var/should_be_active = current_altitude > ORBITAL_ALTITUDE_HIGH

	// Handle activation/deactivation
	if (should_be_active && !radiation_active)
		radiation_active = TRUE

	else if (!should_be_active && radiation_active)
		radiation_active = FALSE
		return

	// If not active, don't process
	if (!radiation_active)
		return

	// Calculate altitude-based radiation intensity (0 to 1 scale)
	// Scales from 0 at ORBITAL_ALTITUDE_HIGH to 1 at ORBITAL_ALTITUDE_HIGH_BOUND
	var/intensity = clamp((current_altitude - ORBITAL_ALTITUDE_HIGH) / (ORBITAL_ALTITUDE_HIGH_BOUND - ORBITAL_ALTITUDE_HIGH), 0, 1)

	// Are we above the critical altitude threshold?
	var/is_critical = current_altitude > ORBITAL_ALTITUDE_HIGH_CRITICAL

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
			continue

		// Determine protection level (HIGH, MEDIUM, or LOW)
		var/protection_level

		// Check for HIGH protection (rad-shielded areas)
		if(istype(mob_area, /area/maintenance) || \
			istype(mob_area, /area/ai_monitored/turret_protected/ai_upload) || \
			istype(mob_area, /area/ai_monitored/turret_protected/ai_upload_foyer) || \
			istype(mob_area, /area/ai_monitored/turret_protected/ai) || \
			istype(mob_area, /area/storage/emergency) || \
			istype(mob_area, /area/shuttle) || \
			istype(mob_area, /area/security/prison))
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

		// Above critical altitude: MEDIUM protection gets half dose
		if(is_critical && protection_level == PROTECTION_MEDIUM)
			intensity *= 0.5

		// Apply the radiation
		if(intensity > 0)
			SSradiation.irradiate(living_mob, intensity)

#undef PROTECTION_HIGH
#undef PROTECTION_MEDIUM
#undef PROTECTION_LOW
