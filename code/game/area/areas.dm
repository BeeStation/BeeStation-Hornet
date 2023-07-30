/**
  * # area
  *
  * A grouping of tiles into a logical space, mostly used by map editors
  */
/area
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	//Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA

	var/clockwork_warp_allowed = TRUE // Can servants warp into this area from Reebe?
	var/clockwork_warp_fail = "The structure there is too dense for warping to pierce. (This is normal in high-security areas.)"

	///Do we have an active fire alarm?
	var/fire = null

	///Alarm type to count of sources. Not usable for ^ because we handle fires differently
	var/list/active_alarms = list()
	///We use this just for fire alarms, because they're area based right now so one alarm going poof shouldn't prevent you from clearing your alarms listing
	var/datum/alarm_handler/alarm_manager

	var/lightswitch = TRUE
	var/vacuum = null

	/// For space, the asteroid, lavaland, etc. Used with blueprints or with weather to determine if we are adding a new area (vs editing a station room)
	var/outdoors = FALSE

	var/areasize = 0 //Size of the area in open turfs, only calculated for indoors areas.

	var/mood_bonus = 0 //Mood for being here
	var/mood_message = "<span class='nicegreen'>This area is pretty nice!\n</span>" //Mood message for being here, only shows up if mood_bonus != 0
	/// if defined, restricts what jobs get this buff using JOB_NAME defines (-candycane/etherware)
	var/list/mood_job_allowed = null
	/// if true, mood_job_allowed will represent jobs exempt from getting the mood.
	var/mood_job_reverse = FALSE

	///Will objects this area be needing power?
	var/requires_power = TRUE
	/// This gets overridden to 1 for space in area/Initialize(mapload).
	var/always_unpowered = FALSE

	var/obj/machinery/power/apc/apc = null

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE

	var/has_gravity = FALSE
	///Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
	var/teleport_restriction = TELEPORT_ALLOW_ALL

	var/parallax_movedir = 0

	var/ambience_index = AMBIENCE_GENERIC
	///Regular
	var/list/ambientsounds
	///super lower chance (0.5%) ambient sounds
	var/list/rare_ambient_sounds
	///Used to decide what the minimum time between ambience is
	var/min_ambience_cooldown = 30 SECONDS
	///Used to decide what the maximum time between ambience is
	var/max_ambience_cooldown = 60 SECONDS

	///Ambient buzz of the station, plays repeatedly, also IC
	var/ambient_buzz = 'sound/ambience/shipambience.ogg'
	///The volume of the ambient buzz
	var/ambient_buzz_vol = 30

	var/ambient_music_index
	var/list/ambientmusic

	///Used to decide what kind of reverb the area makes sound have
	var/sound_environment = SOUND_ENVIRONMENT_NONE

	flags_1 = CAN_BE_DIRTY_1

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/firedoors_last_closed_on = 0
	/// typecache to limit the areas that atoms in this area can smooth with, used for shuttles IIRC
	var/list/canSmoothWithAreas

	var/list/power_usage

	var/lighting_colour_tube = "#FFF6ED"
	var/lighting_colour_bulb = "#FFE6CC"
	var/lighting_colour_night = "#FFDBB5"
	var/lighting_brightness_tube = 11
	var/lighting_brightness_bulb = 6
	var/lighting_brightness_night = 6

	///Typepath to limit the areas (subtypes included) that atoms in this area can smooth with. Used for shuttles.
	var/area/area_limited_icon_smoothing

	//Lighting overlay
	var/obj/effect/lighting_overlay
	var/lighting_overlay_colour = "#FFFFFF"
	var/lighting_overlay_opacity = 0
	var/lighting_overlay_matrix_cr = 0
	var/lighting_overlay_matrix_cg = 0
	var/lighting_overlay_matrix_cb = 0
	var/lighting_overlay_cached_darkening_matrix

	///This datum, if set, allows terrain generation behavior to be ran on Initialize()
	var/datum/map_generator/map_generator

	///Lazylist that contains additional turfs that map generation should be ran on. This is used for ruins which need a noop turf under non-noop areas so they don't leave genturfs behind.
	var/list/additional_genturfs

	/// Default network root for this area aka station, lavaland, etc
	var/network_root_id = null
	/// Area network id when you want to find all devices hooked up to this area
	var/network_area_id = null

	/// How hard it is to hack airlocks in this area
	var/airlock_hack_difficulty = AIRLOCK_SECURITY_NONE

	/// Whether the lights in this area aren't turned off when it's empty at roundstart
	var/lights_always_start_on = FALSE

/**
  * A list of teleport locations
  *
  * Adding a wizard area teleport list because motherfucking lag -- Urist
  * I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game
  */
GLOBAL_LIST_EMPTY(teleportlocs)

/**
  * Generate a list of turfs you can teleport to from the areas list
  *
  * Includes areas if they're not a shuttle or not not teleport or have no contents
  *
  * The chosen turf is the first item in the areas contents that is a station level
  *
  * The returned list of turfs is sorted by name
  */
/proc/process_teleport_locs()
	for(var/V in GLOB.sortedAreas)
		var/area/AR = V
		if(istype(AR, /area/shuttle) || AR.teleport_restriction)
			continue
		if(GLOB.teleportlocs[AR.name])
			continue
		if (!AR.contents.len)
			continue
		var/turf/picked = AR.contents[1]
		if (picked && is_station_level(picked.z))
			GLOB.teleportlocs[AR.name] = AR

	sortTim(GLOB.teleportlocs, GLOBAL_PROC_REF(cmp_text_asc))

/**
  * Called when an area loads
  *
  *  Adds the item to the GLOB.areas_by_type list based on area type
  */
/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if (area_flags & UNIQUE_AREA)
		GLOB.areas_by_type[type] = src
	power_usage = new /list(AREA_USAGE_LEN) // Some atoms would like to use power in Initialize()
	alarm_manager = new(src) // just in case
	return ..()

/**
  * Initalize this area
  *
  * intializes the dynamic area lighting and also registers the area with the z level via
  * reg_in_areas_in_z
  *
  * returns INITIALIZE_HINT_LATELOAD
  */
/area/Initialize(mapload)
	icon_state = ""
	canSmoothWithAreas = typecacheof(canSmoothWithAreas)

	if(!ambientsounds && ambience_index)
		ambientsounds = GLOB.ambience_assoc[ambience_index]

	if(!ambientmusic && ambient_music_index)
		ambientmusic = GLOB.ambient_music_assoc[ambient_music_index]

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else if(dynamic_lighting != DYNAMIC_LIGHTING_IFSTARLIGHT)
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	if(dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
		dynamic_lighting = CONFIG_GET(flag/starlight) ? DYNAMIC_LIGHTING_ENABLED : DYNAMIC_LIGHTING_DISABLED

	. = ..()

	if(!IS_DYNAMIC_LIGHTING(src))
		blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.
		add_overlay(GLOB.fullbright_overlay)
	else if(lighting_overlay_opacity && lighting_overlay_colour)
		generate_lighting_overlay()
	reg_in_areas_in_z()
	if(!mapload)
		if(!network_root_id)
			network_root_id = STATION_NETWORK_ROOT // default to station root because this might be created with a blueprint
		SSnetworks.assign_area_network_id(src)

	return INITIALIZE_HINT_LATELOAD

/**
  * Sets machine power levels in the area
  */
/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon

/**
 * Performs initial setup of the lighting overlays.
 */
/area/proc/generate_lighting_overlay()
	if(lighting_overlay)
		//Remove the old lighting overlay
		cut_overlay(lighting_overlay)
		//Delete the old lighting overlay object
		QDEL_NULL(lighting_overlay)
	//Create the lighting overlay object for this area
	update_lighting_overlay()
	//Areas with a lighting overlay should be fully visible, and the tiles adjacent to them should also
	//be luminous
	luminosity = 1
	//Add the lighting overlay
	add_overlay(lighting_overlay)

/area/proc/update_lighting_overlay()
	lighting_overlay = new /obj/effect/fullbright
	lighting_overlay.color = lighting_overlay_colour
	lighting_overlay.alpha = lighting_overlay_opacity
	if(length(lighting_overlay_colour) != 7)
		return
	var/r = hex2num(copytext(lighting_overlay_colour, 2, 4))/255
	var/g = hex2num(copytext(lighting_overlay_colour, 4, 6))/255
	var/b = hex2num(copytext(lighting_overlay_colour, 6, 8))/255
	lighting_overlay_matrix_cr = r * (lighting_overlay_opacity/255)
	lighting_overlay_matrix_cg = g * (lighting_overlay_opacity/255)
	lighting_overlay_matrix_cb = b * (lighting_overlay_opacity/255)
	lighting_overlay_cached_darkening_matrix = null // Clear cached list

/area/proc/RunGeneration()
	if(map_generator)
		map_generator = new map_generator()
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		if(additional_genturfs)
			turfs += additional_genturfs
			additional_genturfs = null
		map_generator.generate_terrain(turfs)

/area/proc/test_gen()
	if(map_generator)
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		if(additional_genturfs)
			turfs += additional_genturfs
			additional_genturfs = null
		map_generator.generate_terrain(turfs)


/**
  * Register this area as belonging to a z level
  *
  * Ensures the item is added to the SSmapping.areas_in_z list for this z
  */
/area/proc/reg_in_areas_in_z()
	if(!length(contents))
		return
	var/list/areas_in_z = SSmapping.areas_in_z
	update_areasize()
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src

/**
  * Destroy an area and clean it up
  *
  * Removes the area from GLOB.areas_by_type and also stops it processing on SSobj
  *
  * This is despite the fact that no code appears to put it on SSobj, but
  * who am I to argue with old coders
  */
/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	GLOB.sortedAreas -= src
	if(fire)
		STOP_PROCESSING(SSobj, src)
	QDEL_NULL(alarm_manager)
	return ..()

/**
  * Try to close all the firedoors in the area
  */
/area/proc/ModifyFiredoors(opening)
	if(firedoors)
		firedoors_last_closed_on = world.time
		for(var/FD in firedoors)
			var/obj/machinery/door/firedoor/D = FD
			var/cont = !D.welded
			if(cont && opening)	//don't open if adjacent area is on fire
				for(var/I in D.affecting_areas)
					var/area/A = I
					if(A.fire)
						cont = FALSE
						break
			if(cont && D.is_operational)
				if(D.operating)
					D.nextstate = opening ? FIREDOOR_OPEN : FIREDOOR_CLOSED
				else if(!(D.density ^ opening))
					INVOKE_ASYNC(D, (opening ? TYPE_PROC_REF(/obj/machinery/door/firedoor, open) : TYPE_PROC_REF(/obj/machinery/door/, close)))

/**
  * Generate an firealarm alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  *
  * Also starts the area processing on SSobj
  */
/area/proc/firealert(obj/source)
	if(always_unpowered == 1) //no fire alarms in space/asteroid
		return

	if(!fire)
		set_fire_alarm_effect()
		ModifyFiredoors(FALSE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_appearance()
	alarm_manager.send_alarm(ALARM_FIRE, source)
	START_PROCESSING(SSobj, src)



/**
  * Reset the firealarm alert for this area
  *
  * resets the alert sent to all ai players, alert consoles, drones and alarm monitor programs
  * in the world
  *
  * Also cycles the icons of all firealarms and deregisters the area from processing on SSOBJ
  */
/area/proc/firereset(obj/source)
	if(fire)
		unset_fire_alarm_effects()
		ModifyFiredoors(TRUE)
		STOP_PROCESSING(SSobj, src)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_appearance()
	alarm_manager.clear_alarm(ALARM_FIRE, source)
	STOP_PROCESSING(SSobj, src)


/**
  * If 100 ticks has elapsed, toggle all the firedoors closed again
  */
/area/process()
	if(firedoors_last_closed_on + 100 < world.time)	//every 10 seconds
		ModifyFiredoors(FALSE)

/**
  * Close and lock a door passed into this proc
  *
  * Does this need to exist on area? probably not
  */
/area/proc/close_and_lock_door(obj/machinery/door/DOOR)
	set waitfor = FALSE
	DOOR.close()
	if(DOOR.density)
		DOOR.lock()

/**
  * Raise a burglar alert for this area
  *
  * Close and locks all doors in the area and alerts silicon mobs of a break in
  *
  * Alarm auto resets after 600 ticks
  */
/area/proc/burglaralert(obj/trigger)
	if(always_unpowered) //no burglar alarms in space/asteroid
		return
	//Trigger alarm effect
	set_fire_alarm_effect()
	for(var/obj/machinery/door/door in src)
		close_and_lock_door(door)

/**
  * Trigger the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/set_fire_alarm_effect()
	fire = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/**
  * unset the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/unset_fire_alarm_effects()
	fire = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(fire)
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/area/proc/set_vacuum_alarm_effect() //Just like fire alarm but blue
	vacuum = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/area/proc/unset_vacuum_alarm_effect()
	vacuum = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/**
  * Update the icon state of the area
  *
  * Im not sure what the heck this does, somethign to do with weather being able to set icon
  * states on areas?? where the heck would that even display?
  */
/area/update_icon_state()
	var/weather_icon
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.stage != END_STAGE && (src in W.impacted_areas))
			W.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null
	return ..()
/**
 * Update the icon of the area (overridden to always be null for space
 */
/area/space/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	icon_state = null
	return ..()

/**
 * Returns int 1 or 0 if the area has power for the given channel
 *
 * evalutes a mixture of variables mappers can set, requires_power, always_unpowered and then
 * per channel power_equip, power_light, power_environ
 */
/area/proc/powered(chan) // return true if the area has power to given channel

	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	switch(chan)
		if(AREA_USAGE_EQUIP)
			return power_equip
		if(AREA_USAGE_LIGHT)
			return power_light
		if(AREA_USAGE_ENVIRON)
			return power_environ

	return FALSE

/**
 * Space is not powered ever, so this returns false
 */
/area/space/powered(chan) //Nope.avi
	return FALSE

/**
  * Called when the area power status changes
  *
  * Updates the area icon, calls power change on all machinees in the area, and sends the `COMSIG_AREA_POWER_CHANGE` signal.
  */
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()				// reverify power status (to update icons etc.)
	SEND_SIGNAL(src, COMSIG_AREA_POWER_CHANGE)
	update_appearance()


/**
  * Add a static amount of power load to an area
  *
  * Possible channels
  * *AREA_USAGE_STATIC_EQUIP
  * *AREA_USAGE_STATIC_LIGHT
  * *AREA_USAGE_STATIC_ENVIRON
  */
/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(AREA_USAGE_STATIC_START to AREA_USAGE_STATIC_END)
			power_usage[powerchannel] += value

/**
  * Clear all power usage in area
  *
  * Clears all power used for equipment, light and environment channels
  */
/area/proc/clear_usage()
	for(var/i in AREA_USAGE_DYNAMIC_START to AREA_USAGE_DYNAMIC_END)
		power_usage[i] = 0

/**
  * Add a power value amount to the stored used_x variables
  */
/area/proc/use_power(amount, chan)
	switch(chan)
		if(AREA_USAGE_DYNAMIC_START to AREA_USAGE_DYNAMIC_END)
			power_usage[chan] += amount

/**
  * Call back when an atom enters an area
  *
  * Sends signals COMSIG_AREA_ENTERED and COMSIG_MOVABLE_ENTERED_AREA (to the atom)
  *
  * If the area has ambience, then it plays some ambience music to the ambience channel
  */
/area/Entered(atom/movable/arrived, area/old_area)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, old_area)
	SEND_SIGNAL(arrived, COMSIG_MOVABLE_ENTERED_AREA, src) //The atom that enters the area

/**
  * Called when an atom exits an area
  *
  * Sends signals COMSIG_AREA_EXITED and COMSIG_MOVABLE_EXITTED_AREA (to the atom)
  */
/area/Exited(atom/movable/gone, direction)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, gone, direction)
	SEND_SIGNAL(gone, COMSIG_MOVABLE_EXITTED_AREA, src) //The atom that exits the area

/**
  * Setup an area (with the given name)
  *
  * Sets the area name, sets all status var's to false and adds the area to the sorted area list
  */
/area/proc/setup(a_name)
	name = a_name
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE
	always_unpowered = FALSE
	area_flags &= ~VALID_TERRITORY
	area_flags &= ~BLOBS_ALLOWED
	addSorted()
/**
  * Set the area size of the area
  *
  * This is the number of open turfs in the area contents, or FALSE if the outdoors var is set
  *
  */
/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	for(var/turf/open/T in contents)
		areasize++

/**
  * Causes a runtime error
  */
/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/**
  * Causes a runtime error
  */
/area/drop_location()
	CRASH("Bad op: area/drop_location() called")

/// A hook so areas can modify the incoming args (of what??)
/area/proc/PlaceOnTopReact(turf/T, list/new_baseturfs, turf/fake_turf_type, flags)
	return flags

/// Gets an areas virtual z value. For having multiple areas on the same z-level treated mechanically as different z-levels
/area/proc/get_virtual_z(turf/T)
	return T.z

/area/get_virtual_z_level()
	return get_virtual_z(get_turf(src))

/// if it returns true, the mood effect assigned to the area is defined. Defaults to checking mood_job_allowed
/area/proc/mood_check(mob/living/carbon/subject)
	if(!mood_bonus)
		return FALSE

	. = TRUE

	if(!length(mood_job_allowed))
		return .
	if(!(subject.mind?.assigned_role in mood_job_allowed))
		. = FALSE
	if(mood_job_reverse)
		return !.  // the most eye bleeding syntax ive written
