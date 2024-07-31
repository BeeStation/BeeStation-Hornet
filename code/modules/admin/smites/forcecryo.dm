/// Cryo's the target, opening up their job slot in the lobby
/datum/smite/force_cryo_pod
	name = "Force Cryo (using centcom pod)"

/datum/smite/force_cryo_pod/effect(client/user, mob/living/target)
	. = ..()
	force_cryo(target)

/datum/smite/force_cryo_instant
	name = "Force Cryo (instant)"

/datum/smite/force_cryo_instant/effect(client/user, mob/living/target)
	. = ..()
	instant_force_cryo(target)
