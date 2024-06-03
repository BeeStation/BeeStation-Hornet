#define INSUFFICIENT(path) (location.air.get_moles(path) < 0.5)
#define SPREAD_FIRE_POWER 5 SECONDS
#define DEFAULT_FIRE_POWER 3 SECONDS

/**
 * Simple atmospheric fire that requires oxygen, but doesn't consume it.
 * Will die out after a set amount of time.
 * Intended for non-atmospheric fires which shouldn't be tied to atmospherics.
 */
/obj/effect/simple_fire
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "2"
	layer = GASFIRE_LAYER
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	// increase power for more bloom
	light_power = 4
	light_color = LIGHT_COLOR_FIRE
	// Fire loses 1 power per second as it dies down
	var/fire_power = DEFAULT_FIRE_POWER
	var/last_fire = 0

/obj/effect/simple_fire/Initialize(mapload, power)
	if (!isnull(power))
		fire_power = power
	// Try a proper ignition
	var/turf/location = loc
	if (istype(location))
		location.hotspot_expose(FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
	// Can't set on fire if something is already there
	if (locate(/obj/effect/hotspot) in loc)
		return INITIALIZE_HINT_QDEL
	// Merge with other fires
	for (var/obj/effect/simple_fire/other_fire in loc)
		if (other_fire == src)
			continue
		other_fire.fire_power = fire_power + other_fire.fire_power
		return INITIALIZE_HINT_QDEL
	. = ..()
	setDir(pick(GLOB.cardinals))
	// Process to die out
	START_PROCESSING(SSeffects, src)
	// When someone enters, they burn
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/simple_fire/process(delta_time)
	var/turf/open/location = loc
	if(!istype(location))
		qdel(src)
		return
	// Fire dires out
	if(fire_power <= 0)
		qdel(src)
		return
	// These can exist without any actual gas, although will ignite gas
	if(!location.air || location.air.get_oxidation_power() < 0.5)
		qdel(src)
		return
	fire_power -= delta_time * 1 SECONDS
	switch (fire_power)
		if (3 SECONDS to INFINITY)
			icon_state = "3"
		if (1 SECONDS to 3 SECONDS)
			icon_state = "2"
		else
			icon_state = "1"
	// Fire at a rate of 1 per-second
	if (last_fire + 1 SECONDS > world.time)
		return
	last_fire = world.time
	// Spread the fire, so that it burns out quicker but makes a bigger effect
	if (fire_power > SPREAD_FIRE_POWER)
		var/turf/adjacent = get_step(src, pick(GLOB.cardinals))
		if (isopenturf(adjacent))
			new /obj/effect/simple_fire(adjacent, fire_power * 0.5)
		fire_power *= 0.5
	location.hotspot_expose(FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
	location.burn_tile()
	// Burn things in this place
	for(var/A in location)
		var/atom/AT = A
		// Stop if another fire starts here
		if (istype(AT, /obj/effect/hotspot))
			qdel(src)
			return
		if(!QDELETED(AT) && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(FIRE_MINIMUM_TEMPERATURE_TO_EXIST, 125)

/obj/effect/simple_fire/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		var/mob/living/immolated = arrived
		immolated.fire_act(FIRE_MINIMUM_TEMPERATURE_TO_EXIST, 125)

/obj/effect/simple_fire/singularity_pull(S, current_size)
	return

#undef INSUFFICIENT
