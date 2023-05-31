/// Makes the target an animal
/datum/smite/animalize
	name = "Animalize"

/datum/smite/animalize/effect(client/user, mob/living/target)
	. = ..()
	target.Animalize()
