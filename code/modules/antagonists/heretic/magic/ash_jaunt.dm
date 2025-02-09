/datum/action/spell/ashen_passage
	name = "Ashen Passage"
	desc = "A spell which turns the user into ash, granting them invulnerability and the ability to pass through any door unimpeded."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

/datum/action/spell/ashen_passage/on_cast(mob/living/user, atom/target)
	. = ..()
	user.apply_status_effect(/datum/status_effect/ashen_passage)

/// Used by heretic mobs that can ash jaunt
/datum/action/spell/jaunt/ethereal_jaunt/ash
	name = "Ashen Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	exit_jaunt_sound = null
	jaunt_duration = 1.1 SECONDS
	jaunt_in_time = 1.3 SECONDS
	jaunt_out_time = 0.6 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out

/datum/action/spell/jaunt/ethereal_jaunt/ash/do_steam_effects()
	return

/datum/action/spell/jaunt/ethereal_jaunt/ash/long
	name = "Ashen Walk"
	desc = "A long range spell that allows you pass unimpeded through multiple walls."
	jaunt_duration = 5 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS
