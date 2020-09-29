/**
  * # area
  *
  * A grouping of tiles into a logical space, mostly used by map editors
  */
/area
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	//Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/map_name // Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.

	var/valid_territory = TRUE // If it's a valid territory for gangs to claim
	var/blob_allowed = TRUE // Does it count for blobs score? By default, all areas count.
	var/clockwork_warp_allowed = TRUE // Can servants warp into this area from Reebe?
	var/clockwork_warp_fail = "The structure there is too dense for warping to pierce. (This is normal in high-security areas.)"

	var/fire = null
	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/lightswitch = TRUE
	var/vacuum = null

	var/requires_power = TRUE
	var/always_unpowered = FALSE	// This gets overridden to 1 for space in area/Initialize().

	var/outdoors = FALSE //For space, the asteroid, lavaland, etc. Used with blueprints to determine if we are adding a new area (vs editing a station room)

	var/areasize = 0 //Size of the area in open turfs, only calculated for indoors areas.

	var/mood_bonus = 0 //Mood for being here
	var/mood_message = "<span class='nicegreen'>This area is pretty nice!\n</span>" //Mood message for being here, only shows up if mood_bonus != 0

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE

	var/has_gravity = 0
	///Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
	var/noteleport = FALSE
	///Hides area from player Teleport function.
	var/hidden = FALSE
	///Is the area teleport-safe: no space / radiation / aggresive mobs / other dangers
	var/safe = FALSE
	/// If false, loading multiple maps with this area type will create multiple instances.
	var/unique = TRUE

	var/no_air = null

	var/parallax_movedir = 0

	var/list/ambientsounds = GENERIC
	flags_1 = CAN_BE_DIRTY_1

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/firedoors_last_closed_on = 0
	/// Can the Xenobio management console transverse this area by default?
	var/xenobiology_compatible = FALSE
	/// typecache to limit the areas that atoms in this area can smooth with, used for shuttles IIRC
	var/list/canSmoothWithAreas

	var/list/power_usage

	var/lighting_colour_tube = "#FFF6ED"
	var/lighting_colour_bulb = "#FFE6CC"
	var/lighting_colour_night = "#FFDBB5"
	var/lighting_brightness_tube = 10
	var/lighting_brightness_bulb = 6
	var/lighting_brightness_night = 6

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
		if(istype(AR, /area/shuttle) || AR.noteleport)
			continue
		if(GLOB.teleportlocs[AR.name])
			continue
		if (!AR.contents.len)
			continue
		var/turf/picked = AR.contents[1]
		if (picked && is_station_level(picked.z))
			GLOB.teleportlocs[AR.name] = AR

	sortTim(GLOB.teleportlocs, /proc/cmp_text_asc)

/**
  * Called when an area loads
  *
  *  Adds the item to the GLOB.areas_by_type list based on area type
  */
/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if (unique)
		GLOB.areas_by_type[type] = src
	power_usage = new /list(AREA_USAGE_LEN) // Some atoms would like to use power in Initialize()
	return ..()

/**
  * Initalize this area
  *
  * intializes the dynamic area lighting and also registers the area with the z level via
  * reg_in_areas_in_z
  *
  * returns INITIALIZE_HINT_LATELOAD
  */
/area/Initialize()
	icon_state = ""
	layer = AREA_LAYER
	map_name = name // Save the initial (the name set in the map) name of the area.
	canSmoothWithAreas = typecacheof(canSmoothWithAreas)

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

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

	reg_in_areas_in_z()

	return INITIALIZE_HINT_LATELOAD

/**
  * Sets machine power levels in the area
  */
/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon

/**
  * Register this area as belonging to a z level
  *
  * Ensures the item is added to the SSmapping.areas_in_z list for this z
  *
  * It also goes through every item in this areas contents and sets the area level z to it
  * breaking the exat first time it does this, this seems crazy but what would I know, maybe
  * areas don't have a valid z themself or something
  */
/area/proc/reg_in_areas_in_z()
	if(contents.len)
		var/list/areas_in_z = SSmapping.areas_in_z
		var/z
		update_areasize()
		for(var/i in 1 to contents.len)
			var/atom/thing = contents[i]
			if(!thing)
				continue
			z = thing.z
			break
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
	STOP_PROCESSING(SSobj, src)
	return ..()

/**
  * Generate a power alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/poweralert(state, obj/source)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				if (state == 1)
					aiPlayer.cancelAlarm("Power", src, source)
				else
					aiPlayer.triggerAlarm("Power", src, cameras, source)

			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				if(state == 1)
					a.cancelAlarm("Power", src, source)
				else
					a.triggerAlarm("Power", src, cameras, source)

			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				if(state == 1)
					D.cancelAlarm("Power", src, source)
				else
					D.triggerAlarm("Power", src, cameras, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				if(state == 1)
					p.cancelAlarm("Power", src, source)
				else
					p.triggerAlarm("Power", src, cameras, source)

/**
  * Generate an atmospheric alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/atmosalert(danger_level, obj/source)
	if(danger_level != atmosalm)
		if (danger_level==2)

			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, source)
			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				a.triggerAlarm("Atmosphere", src, cameras, source)
			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				D.triggerAlarm("Atmosphere", src, cameras, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.triggerAlarm("Atmosphere", src, cameras, source)

		else if (src.atmosalm == 2)
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				aiPlayer.cancelAlarm("Atmosphere", src, source)
			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				a.cancelAlarm("Atmosphere", src, source)
			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				D.cancelAlarm("Atmosphere", src, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.cancelAlarm("Atmosphere", src, source)

		src.atmosalm = danger_level
		return 1
	return 0

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
			if(cont && D.is_operational())
				if(D.operating)
					D.nextstate = opening ? FIREDOOR_OPEN : FIREDOOR_CLOSED
				else if(!(D.density ^ opening))
					INVOKE_ASYNC(D, (opening ? /obj/machinery/door/firedoor.proc/open : /obj/machinery/door/firedoor.proc/close))

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

	if (!fire)
		set_fire_alarm_effect()
		ModifyFiredoors(FALSE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()

	for (var/item in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/a = item
		a.triggerAlarm("Fire", src, cameras, source)
	for (var/item in GLOB.silicon_mobs)
		var/mob/living/silicon/aiPlayer = item
		aiPlayer.triggerAlarm("Fire", src, cameras, source)
	for (var/item in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = item
		D.triggerAlarm("Fire", src, cameras, source)
	for(var/item in GLOB.alarmdisplay)
		var/datum/computer_file/program/alarm_monitor/p = item
		p.triggerAlarm("Fire", src, cameras, source)

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
	if (fire)
		unset_fire_alarm_effects()
		ModifyFiredoors(TRUE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_icon()

	for (var/item in GLOB.silicon_mobs)
		var/mob/living/silicon/aiPlayer = item
		aiPlayer.cancelAlarm("Fire", src, source)
	for (var/item in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/a = item
		a.cancelAlarm("Fire", src, source)
	for (var/item in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = item
		D.cancelAlarm("Fire", src, source)
	for(var/item in GLOB.alarmdisplay)
		var/datum/computer_file/program/alarm_monitor/p = item
		p.cancelAlarm("Fire", src, source)

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
	//Lockdown airlocks
	for(var/obj/machinery/door/DOOR in src)
		close_and_lock_door(DOOR)

	for (var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/SILICON = i
		if(SILICON.triggerAlarm("Burglar", src, cameras, trigger))
			//Cancel silicon alert after 1 minute
			addtimer(CALLBACK(SILICON, /mob/living/silicon.proc/cancelAlarm,"Burglar",src,trigger), 600)

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
		L.update()

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
		L.update()

/area/proc/set_vacuum_alarm_effect() //Just like fire alarm but blue
	vacuum = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/light/L in src)
		L.update()

/area/proc/unset_vacuum_alarm_effect()
	vacuum = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/light/L in src)
		L.update()

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

/**
  * Update the icon of the area (overridden to always be null for space
  */
/area/space/update_icon_state()
	icon_state = null


/**
  * Returns int 1 or 0 if the area has power for the given channel
  *
  * evalutes a mixture of variables mappers can set, requires_power, always_unpowered and then
  * per channel power_equip, power_light, power_environ
  */
/area/proc/powered(chan)		// return true if the area has power to given channel

	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(AREA_USAGE_EQUIP)
			return power_equip
		if(AREA_USAGE_LIGHT)
			return power_light
		if(AREA_USAGE_ENVIRON)
			return power_environ

	return 0

/**
  * Space is not powered ever, so this returns 0
  */
/area/space/powered(chan) //Nope.avi
	return 0

/**
  * Called when the area power status changes
  *
  * Updates the area icon, calls power change on all machinees in the area, and sends the `COMSIG_AREA_POWER_CHANGE` signal.
  */
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()				// reverify power status (to update icons etc.)
	SEND_SIGNAL(src, COMSIG_AREA_POWER_CHANGE)
	update_icon()


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
  * Sends signals COMSIG_AREA_ENTERED and COMSIG_ENTER_AREA (to the atom)
  *
  * If the area has ambience, then it plays some ambience music to the ambience channel
  */
/area/Entered(atom/movable/M)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return

	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = CHANNEL_BUZZ))

	if(!(L.client && (L.client.prefs.toggles & SOUND_AMBIENCE)))
		return //General ambience check is below the ship ambience so one can play without the other

	if(prob(35))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/**
  * Called when an atom exits an area
  *
  * Sends signals COMSIG_AREA_EXITED and COMSIG_EXIT_AREA (to the atom)
  */
/area/Exited(atom/movable/M)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, M)
	SEND_SIGNAL(M, COMSIG_EXIT_AREA, src) //The atom that exits the area

/**
  * Reset the played var to false on the client
  */
/client/proc/ResetAmbiencePlayed()
	played = FALSE

/**
  * Returns true if this atom has gravity for the passed in turf
  *
  * Sends signals COMSIG_ATOM_HAS_GRAVITY and COMSIG_TURF_HAS_GRAVITY, both can force gravity with
  * the forced gravity var
  *
  * Gravity situations:
  * * No gravity if you're not in a turf
  * * No gravity if this atom is in is a space turf
  * * Gravity if the area it's in always has gravity
  * * Gravity if there's a gravity generator on the z level
  * * Gravity if the Z level has an SSMappingTrait for ZTRAIT_GRAVITY
  * * otherwise no gravity
  */
/atom/proc/has_gravity(turf/T)
	if(!T || !isturf(T))
		T = get_turf(src)

	if(!T)
		return 0

	var/list/forced_gravity = list()
	SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, T, forced_gravity)
	if(!forced_gravity.len)
		SEND_SIGNAL(T, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	if(forced_gravity.len)
		var/max_grav
		for(var/i in forced_gravity)
			max_grav = max(max_grav, i)
		return max_grav

	if(isspaceturf(T)) // Turf never has gravity
		return 0

	var/area/A = get_area(T)
	if(A.has_gravity) // Areas which always has gravity
		return A.has_gravity
	else
		// There's a gravity generator on our z level
		if(GLOB.gravity_generators["[T.z]"])
			var/max_grav = 0
			for(var/obj/machinery/gravity_generator/main/G in GLOB.gravity_generators["[T.z]"])
				max_grav = max(G.setting,max_grav)
			return max_grav
	return SSmapping.level_trait(T.z, ZTRAIT_GRAVITY)
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
	valid_territory = FALSE
	blob_allowed = FALSE
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
/area/proc/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	return flags
