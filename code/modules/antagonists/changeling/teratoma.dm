/datum/antagonist/teratoma
	name = "Teratoma"
	roundend_category = "other"
	antagpanel_category = "Changeling"
	banning_key = ROLE_TERATOMA
	required_living_playtime = 0

/datum/antagonist/teratoma/on_gain()
	. = ..()
	owner.special_role = "Teratoma"
	add_objective(new /datum/objective/chaos())

/datum/antagonist/teratoma/greet()
	var/static/list/msg = list(
		span_boldwarning("You are a living tumor. By all accounts, you should not exist."),
		span_warning("Spread misery and chaos upon the station.</b>"),
	)
	to_chat(owner.current, examine_block(msg.Join("\n")))

/datum/antagonist/teratoma/on_removal()
	owner.special_role = null
	return ..()

/datum/antagonist/teratoma/admin_remove(mob/admin)
	var/mob/living/carbon/monkey/tumor/M = owner.current
	if(alert(admin, "Humanize?", "Humanize", "Yes", "No") == "Yes")
		M.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_DEFAULTMSG)
	return ..()

/datum/antagonist/teratoma/admin_add(datum/mind/new_owner, mob/admin)
	var/mob/living/carbon/human/H = new_owner.current
	if(alert(admin, "Teratomize?", "Teratomize", "Yes", "No") == "Yes")
		H.teratomize()
	new_owner.add_antag_datum(src)
	log_admin("[key_name(admin)] made [key_name(new_owner)] a living teratoma!")
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] a living teratoma!")

//Mainttoma

/datum/antagonist/teratoma/hugbox
	name = "Maintenance Teratoma"

/datum/antagonist/teratoma/hugbox/greet()
	var/static/list/msg = list(
		span_boldwarning("You are a living tumor. By all accounts, you should not exist."),
		span_warning("Spread misery and chaos upon the station.</b>"),
		span_warning("Avoid killing unprovoked, kill only in self defense!")
	)
	to_chat(owner.current, examine_block(msg.Join("\n")))
