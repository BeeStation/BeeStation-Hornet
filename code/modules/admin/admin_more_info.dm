/datum/admins/proc/admin_more_info(mob/subject)
	if(!ismob(subject))
		to_chat(usr, "This can only be used on instances of type /mob.")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/position = get_turf(subject)

	//Location
	if(isturf(position))
		if(isarea(position.loc))
			location_description = "[subject.loc == position ? "at coordinates" : "in [position.loc] at coordinates"] [position.x], [position.y], [position.z] in area <b>[position.loc]</b>"
		else
			location_description = "[subject.loc == position ? "at coordinates" : "in [subject.loc] at coordinates"] [position.x], [position.y], [position.z]"

	//Job + antagonist
	if(subject.mind)
		special_role_description = "Role: <b>[subject.mind.assigned_role.title]</b>; Antagonist: <font color='red'><b>"

		if(subject.mind.antag_datums)
			var/iterable = 0
			for(var/datum/antagonist/role in subject.mind.antag_datums)
				special_role_description += "[role.name]"
				if(++iterable != length(subject.mind.antag_datums))
					special_role_description += ", "
			special_role_description += "</b></font>"
		else
			special_role_description += "None</b></font>"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>"

	//Health
	if(isliving(subject))
		var/mob/living/lifer = subject
		var/status
		switch (subject.stat)
			if(CONSCIOUS)
				status = "Alive"
			if(SOFT_CRIT)
				status = "<font color='orange'><b>Dying</b></font>"
			if(UNCONSCIOUS)
				status = "<font color='orange'><b>Unconscious</b></font>"
			if(HARD_CRIT)
				status = "<font color='orange'><b>Unconscious and Dying</b></font>"
			if(DEAD)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status: [status]"
		health_description += "<br>Brute: [lifer.getBruteLoss()] - Burn: [lifer.getFireLoss()] - Toxin: [lifer.getToxLoss()] - Suffocation: [lifer.getOxyLoss()]"
		health_description += "<br>Clone: [lifer.getCloneLoss()] - Brain: [lifer.getOrganLoss(ORGAN_SLOT_BRAIN)] - Stamina: [lifer.stamina.current]"
	else
		health_description = "This mob type has no health to speak of."

	//Gender
	switch(subject.gender)
		if(MALE,FEMALE,PLURAL)
			gender_description = "[subject.gender]"
		else
			gender_description = "<font color='red'><b>[subject.gender]</b></font>"

	//Full Output
	var/exportable_text = "[span_bold("Info about [subject.name]:")]<br>"
	exportable_text += "Key - [span_bold(subject.key)]<br>"
	exportable_text += "Mob Type - [subject.type]<br>"
	exportable_text += "Gender - [gender_description]<br>"
	exportable_text += "[health_description]<br>"
	exportable_text += "Name: [span_bold(subject.name)] - Real Name: [subject.real_name] - Mind Name: [subject.mind?"[subject.mind.name]":""]<br>"
	exportable_text += "Location is [location_description]<br>"
	exportable_text += "[special_role_description]<br>"
	exportable_text += ADMIN_FULLMONTY_NONAME(subject)

	to_chat(src.owner, examine_block(exportable_text))
