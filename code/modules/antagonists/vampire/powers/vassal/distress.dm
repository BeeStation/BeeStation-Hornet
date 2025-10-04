/datum/action/vampire/distress
	name = "Distress"
	desc = "Injure yourself, allowing you to make a desperate call for help to your Master."
	button_icon_state = "power_distress"
	power_explanation = "Use this Power anywhere and your Master will instantly be alerted to your location."
	power_flags = NONE
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 10
	cooldown_time = 10 SECONDS

/datum/action/vampire/distress/activate_power()
	. = ..()
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(owner)

	owner.balloon_alert(owner, "you call out for your master!")
	to_chat(vassaldatum.master.owner, span_userdanger("[owner], your loyal Vassal, is desperately calling for aid at [get_area(owner)]!"))

	var/mob/living/living_owner = owner
	living_owner.adjustBruteLoss(10)
	deactivate_power()
