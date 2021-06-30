/proc/try_warp_servant(mob/living/servant, turf/target_location, bring_dragging = FALSE)
	if(!is_servant_of_ratvar(servant))
		return FALSE
	var/mob/living/M = servant
	var/mob/living/P = M.pulling
	var/turf/T = get_turf(M)
	if(is_centcom_level(T.z))
		return FALSE
	playsound(servant, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(target_location, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(5, TRUE, servant)
	do_sparks(5, TRUE, target_location)
	do_teleport(M, target_location, channel = TELEPORT_CHANNEL_FREE, no_effects = TRUE, teleport_mode = TELEPORT_MODE_CLOCKWORK)
	new /obj/effect/temp_visual/ratvar/warp(target_location)
	to_chat(servant, "<span class='inathneq'>You warp to [get_area(target_location)].</span>")
	if(istype(P) && bring_dragging)
		do_teleport(P, target_location, channel = TELEPORT_CHANNEL_FREE, no_effects = TRUE, teleport_mode = TELEPORT_MODE_CLOCKWORK)
		P.Paralyze(30)
		to_chat(P, "<span class='warning'>You feel sick and confused...</span>")
