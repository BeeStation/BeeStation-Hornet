// Edgy.
/datum/smite/scarify
	name = "Scarify"

/datum/smite/scarify/effect(client/user, mob/living/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(usr,"<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return
	var/mob/living/carbon/C = target
	C.generate_fake_scars(rand(1, 4))
	to_chat(C, "<span class='warning'>You feel your body grow jaded and torn...</span>")
