/// Stub Toes once
/datum/smite/stub_toe
	name = "Stub Toes"

/datum/smite/stub_toe/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/human/H = target
	to_chat(H, span_warning("You stub your toe on an invisible table!"))
	H.stub_toe(5)


