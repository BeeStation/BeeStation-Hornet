/// Give the target the stalker brain trauma
/datum/smite/stalker
	name = "Stalker Trauma"

/datum/smite/stalker/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/human/H = target
	H.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_LIMIT_LOBOTOMY)
