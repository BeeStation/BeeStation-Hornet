/datum/antagonist/teratoma
	name = "Teratoma"
	roundend_category = "other"
	antagpanel_category = "Changeling"
	job_rank = ROLE_TERATOMA

/datum/antagonist/teratoma/on_gain()
	owner.special_role = "Teratoma"
	..()

/datum/antagonist/teratoma/greet()
	to_chat(owner, "<b>You are a living tumor. By all accounts, you should not exist.</b>")
	to_chat(owner, "<b>Spread the misery and chaos upon the station.</b>")
	//owner.announce_objectives()

/datum/antagonist/teratoma/on_removal()
	owner.special_role = null
	. = ..()

/datum/antagonist/teratoma/proc/add_objective(datum/objective/O)
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/teratoma/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/teratoma/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")

/datum/antagonist/teratoma/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/teratoma/admin_remove(mob/admin)
	var/mob/living/carbon/monkey/tumor/M = owner.current
	if(istype(M))
		switch(alert(admin, "Humanize?", "Humanize", "Yes", "No"))
			if("Yes")
				if(admin == M)
					admin = M.humanize(TR_KEEPITEMS  |  TR_KEEPIMPLANTS  |  TR_KEEPORGANS  |  TR_KEEPDAMAGE  |  TR_KEEPVIRUS  |  TR_DEFAULTMSG)
				else
					M.humanize(TR_KEEPITEMS  |  TR_KEEPIMPLANTS  |  TR_KEEPORGANS  |  TR_KEEPDAMAGE  |  TR_KEEPVIRUS  |  TR_DEFAULTMSG)
			if("No")
				//nothing
			else
				return
	. = ..()

/datum/antagonist/teratoma/admin_add(datum/mind/new_owner, mob/admin)
	var/mob/living/carbon/human/H = new_owner.current
	if(istype(H))
		switch(alert(admin, "Teratomize?", "Teratomize", "Yes", "No"))
			if("Yes")
				if(admin == H)
					admin = H.teratomize()
				else
					H.teratomize()
			if("No")
				//nothing
			else
				return
	new_owner.add_antag_datum(src)
	log_admin("[key_name(admin)] made [key_name(new_owner)] a living teratoma!")
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] a living teratoma!")
