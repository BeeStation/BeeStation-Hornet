/datum/smite/sleep
	name = "Put to sleep"

/datum/smite/sleep/effect(client/user, mob/living/target)
	. = ..()
	target.visible_message(span_danger("[target] faints in fear!"), span_userdanger("You inexplicably faint!"))
	target.Sleeping(300, TRUE, TRUE)
