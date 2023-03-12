/obj/eldritch/narsie/toddsie
	name = "Todd'Sie's Avatar"
	icon = 'icons/obj/toddsie.dmi'
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees. You realize for some reason you want to buy Skyrim."
	pixel_x = -236
	pixel_y = -256
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	plane = MASSIVE_OBJ_PLANE
	light_color = COLOR_RED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

/obj/eldritch/narsie/toddsie/greeting_message()
	send_to_playing_players("<span class='narsie'>TODD'SIE HAS RISEN. BUY. SKYRIM.</span>")
	sound_to_playing_players('sound/creatures/narsie_rises.ogg')
	var/area/A = get_area(src)
	if(A)
		var/mutable_appearance/alert_overlay = mutable_appearance('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts("Todd'Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.", source = src, alert_overlay = alert_overlay, action=NOTIFY_ATTACK)
	INVOKE_ASYNC(src, PROC_REF(narsie_spawn_animation))
/obj/eldritch/narsie/toddsie/acquire(atom/food)
	var/datum/component/singularity/singularity_component = singularity.resolve()
	if(food == singularity_component?.target)
		return
	to_chat(singularity_component?.target, "<span class='cultsmall'>TODD'SIE HAS LOST INTEREST IN YOU.</span>")
	singularity_component?.target = food
	if(ishuman(singularity_component?.target))
		to_chat(singularity_component?.target, "<span class ='cult'>TODD'SIE HUNGERS FOR YOUR SOUL.</span>")
	else
		to_chat(singularity_component?.target, "<span class ='cult'>TODD'SIE HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL.</span>")
