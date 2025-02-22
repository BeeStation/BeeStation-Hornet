/datum/action/spell/pointed/void_phase
	name = "Void Phase"
	desc = "Let's you blink to your pointed destination, causes 3x3 aoe damage bubble \
		around your pointed destination and your current location. \
		It has a minimum range of 3 tiles and a maximum range of 9 tiles."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "RE'L'TY PH'S'E."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1

/datum/action/spell/pointed/void_phase/pre_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(owner && get_dist(get_turf(owner), get_turf(cast_on)) < min_cast_range)
		cast_on.balloon_alert(owner, "too close!")
		return . | SPELL_CANCEL_CAST

/datum/action/spell/pointed/void_phase/on_cast(mob/user, atom/target)
	. = ..()
	var/turf/source_turf = get_turf(user)
	var/turf/targeted_turf = get_turf(target)

	new /obj/effect/temp_visual/voidin(source_turf)
	new /obj/effect/temp_visual/voidout(targeted_turf)

	// We handle sounds here so we can disable vary
	playsound(source_turf, 'sound/magic/voidblink.ogg', 60, FALSE)
	playsound(targeted_turf, 'sound/magic/voidblink.ogg', 60, FALSE)

	for(var/mob/living/living_mob in range(damage_radius, source_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == user || living_mob.can_block_magic(MAGIC_RESISTANCE))
			continue
		living_mob.apply_damage(40, BRUTE)

	for(var/mob/living/living_mob in range(damage_radius, targeted_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == user || living_mob.can_block_magic(MAGIC_RESISTANCE))
			continue
		living_mob.apply_damage(40, BRUTE)

	do_teleport(
		user,
		targeted_turf,
		precision = 1,
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC_SELF,
	)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32
/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32
