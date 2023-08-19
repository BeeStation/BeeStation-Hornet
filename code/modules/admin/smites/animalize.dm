/// Makes the target an animal
/datum/smite/animalize
	name = "Make into Simplemob"

/datum/smite/animalize/effect(client/user, mob/living/target)
	. = ..()
	target.Animalize()
