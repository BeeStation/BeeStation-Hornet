/datum/smite/manup
	name = "Man Up!"

/datum/smite/manup/effect(client/user, mob/living/target)
	. = ..()
	target.visible_message(span_warning("[target] faints!"), span_narsie("Man up!"))
	target.playsound_local(get_turf(target), 'sound/magic/manup1.ogg', 200, 0)
	target.Paralyze(50, ignore_canstun = TRUE)
	target.set_timed_status_effect(200 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	target.adjust_confusion(50 SECONDS)
