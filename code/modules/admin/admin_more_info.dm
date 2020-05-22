/datum/admins/proc/admin_more_info(mob/M)
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob.")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/T = get_turf(M)

	//Location
	if(isturf(T))
		if(isarea(T.loc))
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
		else
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

	//Job + antagonist
	if(M.mind)
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>"

	//Health
	if(isliving(M))
		var/mob/living/L = M
		var/status
		switch (M.stat)
			if(CONSCIOUS)
				status = "Alive"
			if(SOFT_CRIT)
				status = "<font color='orange'><b>Dying</b></font>"
			if(UNCONSCIOUS)
				status = "<font color='orange'><b>[L.InCritical() ? "Unconscious and Dying" : "Unconscious"]</b></font>"
			if(DEAD)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status = [status]"
		health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getOrganLoss(ORGAN_SLOT_BRAIN)] - Stamina: [L.getStaminaLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gender
	switch(M.gender)
		if(MALE,FEMALE)
			gender_description = "[M.gender]"
		else
			gender_description = "<font color='red'><b>[M.gender]</b></font>"

	to_chat(src.owner, "<b>Info about [M.name]:</b> ")
	to_chat(src.owner, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
	to_chat(src.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
	to_chat(src.owner, "Location = [location_description];")
	to_chat(src.owner, "[special_role_description]")
	to_chat(src.owner, ADMIN_FULLMONTY_NONAME(M))
