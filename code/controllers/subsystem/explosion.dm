#define EXPLOSION_THROW_SPEED 4
GLOBAL_LIST_EMPTY(explosions)

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = INIT_ORDER_EXPLOSIONS
	priority = FIRE_PRIORITY_EXPLOSIONS
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0
	var/cost_flameturf = 0

	var/cost_throwturf = 0

	var/cost_low_mov_atom = 0
	var/cost_med_mov_atom = 0
	var/cost_high_mov_atom = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()
	var/list/flameturf = list()

	var/list/throwturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	var/list/explosions = list()

	var/currentpart = SSAIR_REBUILD_PIPENETS


/datum/controller/subsystem/explosions/stat_entry(msg)
	msg += "C:{"
	msg += "LT:[round(cost_lowturf,1)]|"
	msg += "MT:[round(cost_medturf,1)]|"
	msg += "HT:[round(cost_highturf,1)]|"
	msg += "FT:[round(cost_flameturf,1)]||"

	msg += "LO:[round(cost_low_mov_atom,1)]|"
	msg += "MO:[round(cost_med_mov_atom,1)]|"
	msg += "HO:[round(cost_high_mov_atom,1)]|"

	msg += "TO:[round(cost_throwturf,1)]"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[lowturf.len]|"
	msg += "MT:[medturf.len]|"
	msg += "HT:[highturf.len]|"
	msg += "FT:[flameturf.len]||"

	msg += "LO:[low_mov_atom.len]|"
	msg += "MO:[med_mov_atom.len]|"
	msg += "HO:[high_mov_atom.len]|"

	msg += "TO:[throwturf.len]"

	msg += "} "
	return ..()


#define SSEX_TURF "turf"
#define SSEX_OBJ "obj"

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || flameturf.len || throwturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/datum/controller/subsystem/explosions/proc/wipe_turf(turf/T)
	lowturf -= T
	medturf -= T
	highturf -= T
	flameturf -= T
	throwturf -= T

/client/proc/check_bomb_impacts()
	set name = "Check Bomb Impact"
	set category = "Debug"

	var/newmode = alert("Use reactionary explosions?","Check Bomb Impact", "Yes", "No")
	var/turf/epicenter = get_turf(mob)
	if(!epicenter)
		return

	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/list/choices = list("Small Bomb","Medium Bomb","Big Bomb","Custom Bomb")
	var/choice = input("Bomb Size?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			dev = 1
			heavy = 2
			light = 3
		if("Medium Bomb")
			dev = 2
			heavy = 3
			light = 4
		if("Big Bomb")
			dev = 3
			heavy = 5
			light = 7
		if("Custom Bomb")
			dev = input("Devastation range (Tiles):") as num
			heavy = input("Heavy impact range (Tiles):") as num
			light = input("Light impact range (Tiles):") as num

	var/max_range = max(dev, heavy, light)
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/list/wipe_colours = list()
	for(var/turf/T as() in spiral_range_turfs(max_range, epicenter))
		wipe_colours += T
		var/dist = cheap_hypotenuse(T.x, T.y, x0, y0)

		if(newmode == "Yes")
			var/turf/TT = T
			while(TT != epicenter)
				TT = get_step_towards(TT,epicenter)
				if(TT.density)
					dist += TT.explosion_block

				for(var/obj/O in T)
					var/the_block = O.explosion_block
					dist += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

		if(dist < dev)
			T.color = "red"
			T.maptext = MAPTEXT("Dev")
		else if (dist < heavy)
			T.color = "yellow"
			T.maptext = MAPTEXT("Heavy")
		else if (dist < light)
			T.color = "blue"
			T.maptext = MAPTEXT("Light")
		else
			continue

	addtimer(CALLBACK(GLOBAL_PROC, .proc/wipe_color_and_text, wipe_colours), 100)

/proc/wipe_color_and_text(list/atom/wiping)
	for(var/i in wiping)
		var/atom/A = i
		A.color = null
		A.maptext = ""

/**
 * Using default dyn_ex scale:
 *
 * 100 explosion power is a (5, 10, 20) explosion.
 * 75 explosion power is a (4, 8, 17) explosion.
 * 50 explosion power is a (3, 7, 14) explosion.
 * 25 explosion power is a (2, 5, 10) explosion.
 * 10 explosion power is a (1, 3, 6) explosion.
 * 5 explosion power is a (0, 1, 3) explosion.
 * 1 explosion power is a (0, 0, 1) explosion.
 *
 * Arguments:
 * * epicenter: Turf the explosion is centered at.
 * * power - Dyn explosion power. See reference above.
 * * flame_range: Flame range. Equal to the equivalent of the light impact range multiplied by this value.
 * * flash_range: The range at which the explosion flashes people. Equal to the equivalent of the light impact range multiplied by this value.
 * * adminlog: Whether to log the explosion/report it to the administration.
 * * ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * * flame_range: The range at which the explosion should produce hotspots.
 * * silent: Whether to generate/execute sound effects.
 * * smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * * explosion_cause: [Optional] The atom that caused the explosion, when different to the origin. Used for logging.
 */
/proc/dyn_explosion(turf/epicenter, power, flame_range = 0, flash_range = null, adminlog = TRUE, ignorecap = TRUE, silent = FALSE, smoke = TRUE, list/explosion_multiplier = list(1, 1, 1, 1))
	if(!power)
		return
	var/range = 0
	range = round((2 * power)**GLOB.DYN_EX_SCALE)
	explosion(epicenter, devastation_range = round(range * 0.25 * explosion_multiplier[1]), heavy_impact_range = round(range * 0.5 * explosion_multiplier[2]), light_impact_range = round(range * explosion_multiplier[3]), flame_range = flame_range*range, flash_range = flash_range*range * explosion_multiplier[4], adminlog = adminlog, ignorecap = ignorecap, silent = silent, smoke = smoke)



/**
 * Makes a given atom explode.
 *
 * Arguments:
 * - [origin][/atom]: The atom that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 */
/proc/explosion(atom/origin, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 0, flash_range = 0, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = FALSE, magic = FALSE, holy = FALSE, cap_modifier = 1)
	. = SSexplosions.explode(arglist(args))


/**
 * Makes a given atom explode. Now on the explosions subsystem!
 *
 * Arguments:
 * - [origin][/atom]: The atom that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 */

/datum/controller/subsystem/explosions/proc/explode(atom/origin, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 0, flash_range = 0, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = FALSE, magic = FALSE, holy = FALSE, cap_modifier, explode_z = TRUE)
	var/list/arguments = list(
		EXARG_KEY_ORIGIN = origin,
		EXARG_KEY_DEV_RANGE = devastation_range,
		EXARG_KEY_HEAVY_RANGE = heavy_impact_range,
		EXARG_KEY_LIGHT_RANGE = light_impact_range,
		EXARG_KEY_FLAME_RANGE = flame_range,
		EXARG_KEY_FLASH_RANGE = flash_range,
		EXARG_KEY_ADMIN_LOG = adminlog,
		EXARG_KEY_IGNORE_CAP = ignorecap,
		EXARG_KEY_SILENT = silent,
		EXARG_KEY_SMOKE = smoke,
		EXARG_KEY_MAGIC = magic,
		EXARG_KEY_HOLY = holy,
		EXARG_KEY_CAP_MODIFIER = cap_modifier,
		EXARG_KEY_EXPLODE_Z = explode_z,
	)
	var/atom/location = isturf(origin) ? origin : origin.loc
	if(SEND_SIGNAL(origin, COMSIG_ATOM_EXPLODE, arguments) & COMSIG_CANCEL_EXPLOSION)
		return // Signals are incompatible with `arglist(...)` so we can't actually use that for these. Additionally,

	while(location)
		var/next_loc = location.loc
		if(SEND_SIGNAL(location, COMSIG_ATOM_INTERNAL_EXPLOSION, arguments) & COMSIG_CANCEL_EXPLOSION)
			return
		if(isturf(location))
			break
		location = next_loc

	if(!location)
		return

	var/area/epicenter_area = get_area(location)
	if(SEND_SIGNAL(epicenter_area, COMSIG_AREA_INTERNAL_EXPLOSION, arguments) & COMSIG_CANCEL_EXPLOSION)
		return

	arguments -= EXARG_KEY_ORIGIN

	propagate_blastwave(arglist(list(location) + arguments))


/**
 * Handles the effects of an explosion originating from a given point.
 *
 * Primarily handles popagating the balstwave of the explosion to the relevant turfs.
 * Also handles the fireball from the explosion.
 * Also handles the smoke cloud from the explosion.
 * Also handles sfx and screenshake.
 *
 * Arguments:
 * - [epicenter][/atom]: The location of the explosion rounded to the nearest turf.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to TRUE for some mysterious reason.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - magic: If the explosion is magical or not
 * - holy: If the explosion is holy or not
 * - cap_modifier: modifies the maximum explosion cap
 * - explode_z: The explosion considers z levels
 */
/datum/controller/subsystem/explosions/proc/propagate_blastwave(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range, adminlog, ignorecap, silent, smoke, magic, holy, cap_modifier, explode_z = TRUE)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	if(isnull(flame_range))
		flame_range = light_impact_range
	if(isnull(flash_range))
		flash_range = devastation_range

	// Archive the uncapped explosion for the doppler array.
	var/orig_dev_range = devastation_range
	var/orig_heavy_range = heavy_impact_range
	var/orig_light_range = light_impact_range

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flame_range, flash_range)

	//Zlevel specific bomb cap multiplier.
	var/cap_multiplier = SSmapping.level_trait(epicenter.z, ZTRAIT_BOMBCAP_MULTIPLIER)
	if(isnull(cap_multiplier))
		cap_multiplier = 1
	cap_multiplier *= cap_modifier

	if(!ignorecap)
		devastation_range = min(GLOB.MAX_EX_DEVESTATION_RANGE * cap_multiplier, devastation_range)
		heavy_impact_range = min(GLOB.MAX_EX_HEAVY_RANGE * cap_multiplier, heavy_impact_range)
		light_impact_range = min(GLOB.MAX_EX_LIGHT_RANGE * cap_multiplier, light_impact_range)
		flash_range = min(GLOB.MAX_EX_FLASH_RANGE * cap_multiplier, flash_range)
		flame_range = min(GLOB.MAX_EX_FLAME_RANGE * cap_multiplier, flame_range)

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)
	var/started_at = REALTIMEOFDAY
	if(adminlog)
		message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [ADMIN_VERBOSEJMP(epicenter)]")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [loc_name(epicenter)]")
		if(is_station_level(epicenter.z))
			deadchat_broadcast("<span class='ghostalert'>Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [get_area(epicenter)]!</span>", turf_target = epicenter)

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.get_virtual_z_level()
	var/area/areatype = get_area(epicenter)
	SSblackbox.record_feedback("associative", "explosion", 1, list("dev" = devastation_range, "heavy" = heavy_impact_range, "light" = light_impact_range, "flame" = flame_range, "flash" = flash_range, "orig_dev" = orig_dev_range, "orig_heavy" = orig_heavy_range, "orig_light" = orig_light_range, "x" = x0, "y" = y0, "z" = z0, "area" = areatype.type, "time" = time_stamp("YYYY-MM-DD hh:mm:ss", 1)))

	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	// 3/7/14 will calculate to 80 + 35

	var/far_dist = 0
	far_dist += heavy_impact_range * 15
	far_dist += devastation_range * 20

	if(!silent)
		shake_the_room(epicenter, orig_max_distance, far_dist, devastation_range, heavy_impact_range)

	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/E
		if(smoke)
			E = new /datum/effect_system/explosion/smoke
		else
			E = new
		E.set_up(epicenter)
		E.start()

	//flash mobs
	if(flash_range)
		for(var/mob/living/L in viewers(flash_range, epicenter))
			if(L.anti_magic_check(magic, holy))
				continue
			L.flash_act()

	var/list/affected_turfs = GatherSpiralTurfs(max_range, epicenter)

	var/reactionary = CONFIG_GET(flag/reactionary_explosions)
	var/list/cached_exp_block

	if(reactionary)
		cached_exp_block = CaculateExplosionBlock(affected_turfs)

	//lists are guaranteed to contain at least 1 turf at this point

	for(var/TI in affected_turfs)
		var/turf/T = TI
		var/init_dist = cheap_hypotenuse(T.x, T.y, x0, y0)
		var/dist = init_dist

		//Phew, that was a close one.
		if(holy && (locate(/obj/effect/blessing) in T))
			continue

		if(reactionary)
			var/turf/Trajectory = T
			while(Trajectory != epicenter)
				Trajectory = get_step_towards(Trajectory, epicenter)
				dist += cached_exp_block[Trajectory]

		var/flame_dist = dist < flame_range

		if(T.get_virtual_z_level() != z0)
			dist = EXPLODE_NONE
		else if(dist < devastation_range)
			dist = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			dist = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			dist = EXPLODE_LIGHT
		else
			dist = EXPLODE_NONE

		if(T == epicenter) // Ensures explosives detonating from bags trigger other explosives in that bag
			var/list/items = list()
			for(var/I in T)
				var/atom/A = I
				//Ignore magic protected things.
				if(ismob(A))
					var/mob/M = A
					if(M.anti_magic_check(magic, holy, TRUE, TRUE))
						continue
				if (length(A.contents) && !(A.flags_1 & PREVENT_CONTENTS_EXPLOSION_1)) //The atom/contents_explosion() proc returns null if the contents ex_acting has been handled by the atom, and TRUE if it hasn't.
					items += A.GetAllContents(ignore_flag_1 = PREVENT_CONTENTS_EXPLOSION_1)
			for(var/thing in items)
				var/atom/movable/movable_thing = thing
				if(QDELETED(movable_thing))
					continue
				switch(dist)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += movable_thing
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += movable_thing
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += movable_thing

		//Protect turfs if there is holyness on them
		if(magic || holy)
			var/divine_protection = FALSE
			for(var/mob/living/L in T.contents)
				if(L.anti_magic_check(magic, holy, TRUE))
					divine_protection = TRUE
					break
			if(divine_protection)
				continue

		switch(dist)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T

		if(flame_dist && prob(40) && !isspaceturf(T) && !T.density)
			flameturf += T

		//--- THROW ITEMS AROUND ---
		var/throw_dir
		if(T == epicenter)
			throw_dir = pick(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		else
			throw_dir = get_dir(epicenter,T)
		var/throw_range = max_range * 1.5
		var/list/throwingturf = T.explosion_throw_details
		if (throwingturf)
			if (throwingturf[1] < throw_range)
				throwingturf[1] = throw_range
				throwingturf[2] = throw_dir
				throwingturf[3] = max_range
		else
			T.explosion_throw_details = list(throw_range, throw_dir, max_range)
			throwturf += T

	//Calculate above and below Zs
	//Multi-z explosions only work on station levels.
	if(explode_z)
		var/max_z_range = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range) / (MULTI_Z_DISTANCE + 1)
		var/list/z_list = get_zs_in_range(epicenter.z, max_z_range)
		//Dont blow up our level again
		z_list -= epicenter.z
		for(var/affecting_z in z_list)
			var/z_reduction = abs(epicenter.z - affecting_z) * (MULTI_Z_DISTANCE + 1)
			var/turf/T = locate(epicenter.x, epicenter.y, affecting_z)
			if(!T)
				continue
			SSexplosions.explode(T,
				max(devastation_range - z_reduction, 0),
				max(heavy_impact_range - z_reduction, 0),
				max(light_impact_range - z_reduction, 0),
				max(flame_range - z_reduction, 0),
				max(flash_range - z_reduction, 0),
				adminlog,
				ignorecap,
				silent = TRUE,
				smoke = FALSE,
				explode_z = FALSE)

	var/took = (REALTIMEOFDAY - started_at) / 10

	//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes to explosion code using this please so we can compare
	if(GLOB.Debug2)
		log_world("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_EXPLOSION, epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)

// Explosion SFX defines...
/// The probability that a quaking explosion will make the station creak per unit. Maths!
#define QUAKE_CREAK_PROB 30
/// The probability that an echoing explosion will make the station creak per unit.
#define ECHO_CREAK_PROB 5
/// Time taken for the hull to begin to creak after an explosion, if applicable.
#define CREAK_DELAY (5 SECONDS)
/// Lower limit for far explosion SFX volume.
#define FAR_LOWER 40
/// Upper limit for far explosion SFX volume.
#define FAR_UPPER 60
/// The probability that a distant explosion SFX will be a far explosion sound rather than an echo. (0-100)
#define FAR_SOUND_PROB 75
/// The upper limit on screenshake amplitude for nearby explosions.
#define NEAR_SHAKE_CAP 10
/// The upper limit on screenshake amplifude for distant explosions.
#define FAR_SHAKE_CAP 2.5
/// The duration of the screenshake for nearby explosions.
#define NEAR_SHAKE_DURATION (2.5 SECONDS)
/// The duration of the screenshake for distant explosions.
#define FAR_SHAKE_DURATION (1 SECONDS)
/// The lower limit for the randomly selected hull creaking frequency.
#define FREQ_LOWER 25
/// The upper limit for the randomly selected hull creaking frequency.
#define FREQ_UPPER 40

/**
 * Handles the sfx and screenshake caused by an explosion.
 *
 * Arguments:
 * - [epicenter][/turf]: The location of the explosion.
 * - near_distance: How close to the explosion you need to be to get the full effect of the explosion.
 * - far_distance: How close to the explosion you need to be to hear more than echos.
 * - quake_factor: Main scaling factor for screenshake.
 * - echo_factor: Whether to make the explosion echo off of very distant parts of the station.
 * - creaking: Whether to make the station creak. Autoset if null.
 * - [near_sound][/sound]: The sound that plays if you are close to the explosion.
 * - [far_sound][/sound]: The sound that plays if you are far from the explosion.
 * - [echo_sound][/sound]: The sound that plays as echos for the explosion.
 * - [creaking_sound][/sound]: The sound that plays when the station creaks during the explosion.
 * - [hull_creaking_sound][/sound]: The sound that plays when the station creaks after the explosion.
 */
/datum/controller/subsystem/explosions/proc/shake_the_room(turf/epicenter, near_distance, far_distance, quake_factor, echo_factor, creaking, sound/near_sound = sound(get_sfx("explosion")), sound/far_sound = sound('sound/effects/explosionfar.ogg'), sound/echo_sound = sound('sound/effects/explosion_distant.ogg'), sound/creaking_sound = sound(get_sfx("explosion_creaking")), hull_creaking_sound = sound(get_sfx("hull_creaking")))
	var/frequency = get_rand_frequency()
	var/blast_z = epicenter.z
	if(isnull(creaking)) // Autoset creaking.
		var/on_station = SSmapping.level_trait(epicenter.z, ZTRAIT_STATION)
		if(on_station && prob((quake_factor * QUAKE_CREAK_PROB) + (echo_factor * ECHO_CREAK_PROB))) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
			creaking = TRUE // prob over 100 always returns true
		else
			creaking = FALSE

	for(var/mob/listener as anything in GLOB.player_list)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || listener_turf.z != blast_z)
			continue

		var/distance = get_dist(epicenter, listener_turf)
		if(epicenter == listener_turf)
			distance = 0
		var/base_shake_amount = sqrt(near_distance / (distance + 1))

		if(distance <= round(near_distance + world.view - 2, 1)) // If you are close enough to see the effects of the explosion first-hand (ignoring walls)
			listener.playsound_local(epicenter, null, 100, TRUE, frequency, S = near_sound)
			if(base_shake_amount > 0)
				shake_camera(listener, NEAR_SHAKE_DURATION, clamp(base_shake_amount, 0, NEAR_SHAKE_CAP))

		else if(distance < far_distance) // You can hear a far explosion if you are outside the blast radius. Small explosions shouldn't be heard throughout the station.
			var/far_volume = clamp(far_distance / 2, FAR_LOWER, FAR_UPPER)
			if(creaking)
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, S = creaking_sound, distance_multiplier = 0)
			else if(prob(FAR_SOUND_PROB)) // Sound variety during meteor storm/tesloose/other bad event
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, S = far_sound, distance_multiplier = 0)
			else
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, S = echo_sound, distance_multiplier = 0)

			if(base_shake_amount || quake_factor)
				base_shake_amount = max(base_shake_amount, quake_factor * 3, 0) // Devastating explosions rock the station and ground
				shake_camera(listener, FAR_SHAKE_DURATION, min(base_shake_amount, FAR_SHAKE_CAP))

		else if(!isspaceturf(listener_turf) && echo_factor) // Big enough explosions echo through the hull.
			var/echo_volume
			if(quake_factor)
				echo_volume = 60
				shake_camera(listener, FAR_SHAKE_DURATION, clamp(quake_factor / 4, 0, FAR_SHAKE_CAP))
			else
				echo_volume = 40
			listener.playsound_local(epicenter, null, echo_volume, TRUE, frequency, S = echo_sound, distance_multiplier = 0)

		if(creaking) // 5 seconds after the bang, the station begins to creak
			addtimer(CALLBACK(listener, /mob/proc/playsound_local, epicenter, null, rand(FREQ_LOWER, FREQ_UPPER), TRUE, frequency, null, null, FALSE, hull_creaking_sound, 0), CREAK_DELAY)

#undef CREAK_DELAY
#undef QUAKE_CREAK_PROB
#undef ECHO_CREAK_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef FAR_SOUND_PROB
#undef NEAR_SHAKE_CAP
#undef FAR_SHAKE_CAP
#undef NEAR_SHAKE_DURATION
#undef FAR_SHAKE_DURATION
#undef FREQ_UPPER
#undef FREQ_LOWER

/datum/controller/subsystem/explosions/proc/GatherSpiralTurfs(range, turf/epicenter)
	var/list/outlist = list()
	var/center = epicenter
	var/dist = range
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1
	L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
	. = L

/datum/controller/subsystem/explosions/proc/CaculateExplosionBlock(list/affected_turfs)
	. = list()
	var/I
	for(I in 1 to affected_turfs.len) // we cache the explosion block rating of every turf in the explosion area
		var/turf/T = affected_turfs[I]
		var/current_exp_block = T.density ? T.explosion_block : 0

		for(var/obj/O in T)
			var/the_block = O.explosion_block
			current_exp_block += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

		.[T] = current_exp_block

/datum/controller/subsystem/explosions/fire(resumed = 0)
	if (!is_exploding())
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE_REAL
		var/list/low_turf = lowturf
		lowturf = list()
		for(var/thing in low_turf)
			var/turf/turf_thing = thing
			turf_thing.explosion_level = max(turf_thing.explosion_level, EXPLODE_LIGHT)
			turf_thing.ex_act(EXPLODE_LIGHT)
			lowturf -= turf_thing
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medturf
		medturf = list()
		for(var/thing in med_turf)
			var/turf/turf_thing = thing
			turf_thing.explosion_level = max(turf_thing.explosion_level, EXPLODE_HEAVY)
			turf_thing.ex_act(EXPLODE_HEAVY)
			medturf -= turf_thing
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highturf
		highturf = list()
		for(var/thing in high_turf)
			var/turf/turf_thing = thing
			turf_thing.explosion_level = max(turf_thing.explosion_level, EXPLODE_DEVASTATE)
			turf_thing.ex_act(EXPLODE_DEVASTATE)
			highturf -= turf_thing
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/flame_turf = flameturf
		flameturf = list()
		for(var/thing in flame_turf)
			if(thing)
				var/turf/T = thing
				new /obj/effect/hotspot(T) //Mostly for ambience!
		cost_flameturf = MC_AVERAGE(cost_flameturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		if (low_turf.len || med_turf.len || high_turf.len)
			Master.laggy_byond_map_update_incoming()

	if(currentpart == SSEXPLOSIONS_MOVABLES)
		currentpart = SSEXPLOSIONS_THROWS

		timer = TICK_USAGE_REAL
		var/list/local_high_mov_atom = high_mov_atom
		high_mov_atom = list()
		for(var/thing in local_high_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_DEVASTATE)
			high_mov_atom -= movable_thing
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/thing in local_med_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_HEAVY)
			med_mov_atom -= movable_thing
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/thing in local_low_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_LIGHT)
			low_mov_atom -= movable_thing
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


	if (currentpart == SSEXPLOSIONS_THROWS)
		currentpart = SSEXPLOSIONS_TURFS
		timer = TICK_USAGE_REAL
		var/list/throw_turf = throwturf
		throwturf = list()
		for (var/thing in throw_turf)
			if (!thing)
				continue
			var/turf/T = thing
			var/list/L = T.explosion_throw_details
			T.explosion_throw_details = null
			if (length(L) != 3)
				continue
			var/throw_range = L[1]
			var/throw_dir = L[2]
			var/max_range = L[3]
			for(var/atom/movable/A in T)
				if(!A.anchored && A.move_resist != INFINITY)
					var/atom_throw_range = rand(throw_range, max_range)
					var/turf/throw_at = get_ranged_target_turf(A, throw_dir, atom_throw_range)
					A.throw_at(throw_at, atom_throw_range, EXPLOSION_THROW_SPEED, quickstart = FALSE)
		cost_throwturf = MC_AVERAGE(cost_throwturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	currentpart = SSEXPLOSIONS_TURFS

#undef SSAIR_REBUILD_PIPENETS
