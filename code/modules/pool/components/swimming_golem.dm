/datum/component/swimming/golem/enter_pool()
	var/mob/living/M = parent
	M.Paralyze(60)
	M.visible_message(span_warning("[M] crashed violently into the ground!"),
		span_warning("You sink like a rock!"))
	playsound(get_turf(M), 'sound/effects/picaxe1.ogg')

/datum/component/swimming/golem/is_drowning()
	return FALSE
