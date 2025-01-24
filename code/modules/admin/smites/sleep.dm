/datum/smite/sleep
	name = "Put to sleep"

/datum/smite/sleep/effect(client/user, mob/living/target)
	. = ..()
	target.visible_message("<span class='danger'>[target] faints in fear!</span>", "<span class='userdanger'>You inexplicably faint!</span>")
	target.Sleeping(300, TRUE, TRUE)
