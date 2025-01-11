/datum/action/cooldown/vampire/distress
	name = "Distress"
	desc = "Injure yourself, allowing you to make a desperate call for help to your Master."
	button_icon_state = "power_distress"
	power_explanation = "Use this Power anywhere and your Master will instantly be alerted of your location."
	power_flags = NONE
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 10
	cooldown_time = 10 SECONDS

/datum/action/cooldown/vampire/distress/ActivatePower(trigger_flags)
	. = ..()
	var/turf/open/floor/target_area = get_area(owner)
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(owner)

	owner.balloon_alert(owner, "you call out for your master!")
	to_chat(vassaldatum.master.owner, "<span class='userdanger'>[owner], your loyal Vassal, is desperately calling for aid at [target_area]!</span>")

	var/mob/living/user = owner
	user.adjustBruteLoss(10)
