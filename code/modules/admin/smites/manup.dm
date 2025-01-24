/datum/smite/manup
	name = "Man Up!"

/datum/smite/manup/effect(client/user, mob/living/target)
	. = ..()
	target.visible_message("<span class='warning'>[target] faints!</span>", "<span class='narsie'>Man up!</span>")
	target.playsound_local(get_turf(target), 'sound/magic/manup1.ogg', 200, 0)
	target.Paralyze(50, ignore_canstun = TRUE)
	target.Jitter(100)
	target.confused += 50
