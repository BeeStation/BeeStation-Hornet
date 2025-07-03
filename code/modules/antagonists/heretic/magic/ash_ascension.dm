/// Creates a constant Ring of Fire around the caster for a set duration of time, which follows them.
/datum/action/spell/fire_sworn
	name = "Oath of Flame"
	desc = "For a minute, you will passively create a ring of fire around you."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 70 SECONDS

	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius of the fire ring
	var/fire_radius = 1
	/// How long it the ring lasts
	var/duration = 1 MINUTES

/datum/action/spell/fire_sworn/Remove(mob/living/remove_from)
	remove_from.remove_status_effect(/datum/status_effect/fire_ring)
	return ..()

/datum/action/spell/fire_sworn/is_valid_spell(mob/user, atom/target)
	return isliving(user)

/datum/action/spell/fire_sworn/on_cast(mob/living/user, atom/target)
	. = ..()
	user.apply_status_effect(/datum/status_effect/fire_ring, duration, fire_radius)

/// Simple status effect for adding a ring of fire around a mob.
/datum/status_effect/fire_ring
	id = "fire_ring"
	tick_interval = 0.1 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The radius of the ring around us.
	var/ring_radius = 1

/datum/status_effect/fire_ring/on_creation(mob/living/new_owner, duration = 1 MINUTES, radius = 1)
	src.duration = duration
	src.ring_radius = radius
	return ..()

/datum/status_effect/fire_ring/tick(delta_time, times_fired)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return

	if(!isturf(owner.loc))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, owner))
		new /obj/effect/hotspot(nearby_turf)
		nearby_turf.hotspot_expose(750, 25 * delta_time, 1)
		for(var/mob/living/fried_living in nearby_turf.contents - owner)
			fried_living.apply_damage(2.5 * delta_time, BURN)

/// Creates one, large, expanding ring of fire around the caster, which does not follow them.
/datum/action/spell/fire_cascade
	name = "Lesser Fire Cascade"
	desc = "Heats the air around you."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius the flames will go around the caster.
	var/flame_radius = 4

/datum/action/spell/fire_cascade/on_cast(mob/user, atom/target)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fire_cascade), get_turf(user), flame_radius)

/// Spreads a huge wave of fire in a radius around us, staggered between levels
/datum/action/spell/fire_cascade/proc/fire_cascade(atom/centre, flame_radius = 1)
	for(var/i in 0 to flame_radius)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			new /obj/effect/hotspot(nearby_turf)
			nearby_turf.hotspot_expose(750, 50, 1)
			for(var/mob/living/fried_living in nearby_turf.contents - centre)
				fried_living.apply_damage(5, BURN)

		stoplag(0.3 SECONDS)

/datum/action/spell/fire_cascade/big
	name = "Greater Fire Cascade"
	flame_radius = 6

// Currently unused - releases streams of fire around the caster.
/datum/action/spell/pointed/ash_beams
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases five streams of eldritch fire towards the target."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "flames"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 300

	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The length of the flame line spit out.
	var/flame_line_length = 15

/datum/action/spell/pointed/ash_beams/is_valid_spell(mob/user, atom/target)
	return TRUE

/datum/action/spell/pointed/ash_beams/on_cast(mob/user, atom/target)
	. = ..()
	var/static/list/offsets = list(-25, -10, 0, 10, 25)
	for(var/offset in offsets)
		INVOKE_ASYNC(src, PROC_REF(fire_line), owner, line_target(offset, flame_line_length, target, owner))

/datum/action/spell/pointed/ash_beams/proc/line_target(offset, range, atom/at, atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/datum/action/spell/pointed/ash_beams/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		for(var/mob/living/L in T.contents)
			if(L.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))
				L.visible_message(span_danger("The spell bounces off of [L]!"),span_danger("The spell bounces off of you!"))
				continue
			if((L in hit_list) || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s eldritch flames!"))
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/vehicle/sealed/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(0.15 SECONDS)
