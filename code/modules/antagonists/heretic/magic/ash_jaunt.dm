/obj/effect/proc_holder/spell/targeted/ashen_passage
	name = "Ashen Passage"
	desc = "A spell which turns the user into ash, granting them invulnerability and the ability to pass through any door unimpeded."
	action_icon = 'icons/hud/actions/actions_heretic.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	requires_heretic_focus = TRUE
	clothes_req = FALSE
	charge_max = 90 SECONDS
	range = -1
	include_user = TRUE
	nonabstract_req = TRUE

/obj/effect/proc_holder/spell/targeted/ashen_passage/cast(list/targets, mob/user)
	for(var/mob/living/target in targets)
		target.apply_status_effect(/datum/status_effect/ashen_passage)

/// Used by heretic mobs that can ash jaunt
/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	name = "Ashen Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	action_icon = 'icons/hud/actions/actions_heretic.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	requires_heretic_focus = TRUE
	charge_max = 150
	range = -1
	jaunt_in_time = 13
	jaunt_duration = 10
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long
	jaunt_duration = 50

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/play_sound()
	return


