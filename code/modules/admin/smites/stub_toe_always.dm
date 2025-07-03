/// Stub Toes always
/datum/smite/stub_toe_always
	name = "Stub Toes Always"

/datum/smite/stub_toe_always/effect(client/user, mob/living/target)
	. = ..()
	ADD_TRAIT(target, TRAIT_ALWAYS_STUBS, "adminabuse")
