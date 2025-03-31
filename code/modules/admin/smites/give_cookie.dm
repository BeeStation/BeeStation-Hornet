/// Tries to put a cookie in the target's hands
/datum/smite/give_cookie
	name = "Give Cookie"

/datum/smite/give_cookie/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/carb_targ = target
	carb_targ.give_cookie(usr)
