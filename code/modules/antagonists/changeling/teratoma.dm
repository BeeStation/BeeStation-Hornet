/datum/antagonist/teratoma
	name = "Teratoma"
	roundend_category = "other"
	antagpanel_category = "Changeling"
	banning_key = ROLE_TERATOMA
	required_living_playtime = 0

/datum/antagonist/teratoma/on_gain()
	owner.special_role = "Teratoma"
	var/datum/objective/chaos/C = new
	add_objective(C)
	..()

/datum/antagonist/teratoma/greet()
	to_chat(owner, "<b>You are a living tumor. By all accounts, you should not exist.</b>")
	to_chat(owner, "<b>Spread misery and chaos upon the station.</b>")

/datum/antagonist/teratoma/on_removal()
	owner.special_role = null
	. = ..()

/datum/antagonist/teratoma/proc/add_objective(datum/objective/O)
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/teratoma/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/teratoma/admin_remove(mob/admin)
	var/mob/living/carbon/human/species/monkey/tumor/M = owner.current
	if(alert(admin, "Humanize?", "Humanize", "Yes", "No") == "Yes")
		M.humanize()
	. = ..()

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
	roundend_category = "other"
	antagpanel_category = "Changeling"

/datum/antagonist/teratoma/hugbox/greet()
	..()
	to_chat(owner, span_userdanger("Avoid killing unprovoked, kill only in self defense!"))
