/obj/eldritch/narsie/toddsie
	name = "Todd'Sie's Avatar"
	icon = 'icons/obj/toddsie.dmi'
	icon_state = "TODDTHEGOD"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees. You realize for some reason you want to buy Skyrim."
	pixel_x = -236
	pixel_y = -256
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	plane = MASSIVE_OBJ_PLANE
	zmm_flags = ZMM_WIDE_LOAD
	light_color = COLOR_RED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/eldritch/narsie/toddsie/greeting_message()
	send_to_playing_players(span_narsie("TODD'SIE HAS RISEN. BUY. SKYRIM."))
	sound_to_playing_players('sound/creatures/narsie_rises.ogg')
	var/area/A = get_area(src)
	if(A)
		var/mutable_appearance/alert_overlay = mutable_appearance('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts(
			"Todd'Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.",
			source = src,
			alert_overlay = alert_overlay,
		)
	narsie_spawn_animation()

/obj/eldritch/narsie/toddsie/acquire(atom/food)
	var/datum/component/singularity/singularity_component = singularity.resolve()
	if(food == singularity_component?.target)
		return
	to_chat(singularity_component?.target, span_cultsmall("TODD'SIE HAS LOST INTEREST IN YOU."))
	singularity_component?.target = food
	if(ishuman(singularity_component?.target))
		to_chat(singularity_component?.target, span_cult("TODD'SIE HUNGERS FOR YOUR SOUL."))
	else
		to_chat(singularity_component?.target, span_cult("TODD'SIE HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL."))
