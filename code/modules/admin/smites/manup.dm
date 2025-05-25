/datum/smite/manup
	name = "Man Up!"

/datum/smite/manup/effect(client/user, mob/living/target)
	. = ..()
	target.visible_message(span_warning("[target] faints!"), span_narsie("Man up!"))
	target.playsound_local(get_turf(target), 'sound/magic/manup1.ogg', 200, 0)
	target.Paralyze(50, ignore_canstun = TRUE)
	target.Jitter(100)
	target.confused += 50
