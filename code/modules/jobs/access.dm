
//
/**
 * Returns TRUE if this mob has sufficient access to use this object
 *
 * * accessor - mob trying to access this object, !!CAN BE NULL!! because of telekiesis because we're in hell
 */
/obj/proc/allowed(mob/accessor)
	if(!accessor) // early return for null check. This exists because attack_tk() sends null accessor
		return src.check_access(null)
	if(SEND_SIGNAL(src, COMSIG_OBJ_ALLOWED, accessor) & COMPONENT_OBJ_ALLOW)
		return TRUE
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return TRUE
	if(length(accessor.buckled_mobs) && handle_buckled_access(accessor))
		return TRUE
	if(issilicon(accessor))
		var/mob/living/silicon/S = accessor
		return check_access(S.internal_id_card)	//AI can do whatever it wants
	if(IsAdminGhost(accessor))
		//Access can't stop the abuse
		return TRUE
		//If the mob has the simple_access component with the requried access, we let them in.
	else if(SEND_SIGNAL(accessor, COMSIG_MOB_TRIED_ACCESS, src) & ACCESS_ALLOWED)
		return TRUE
	//If the mob is holding a valid ID, we let them in. get_active_held_item() is on the mob level, so no need to copypasta everywhere.
	else if(check_access(accessor.get_active_held_item()))
		return TRUE
	//if they are wearing a card that has access, that works
	else if(istype(accessor) && SEND_SIGNAL(accessor, ACCESS_ALLOWED, src))
		return TRUE
	else if(ishuman(accessor))
		var/mob/living/carbon/human/human_accessor = accessor
		if(check_access(human_accessor.wear_id))
			return TRUE
	//if they have a hacky abstract animal ID with the required access, let them in i guess...
	else if(isanimal(accessor))
		var/mob/living/simple_animal/animal = accessor
		if(check_access(animal.get_active_held_item()) || check_access(animal.access_card))
			return TRUE
	else if(isbrain(accessor))
		var/obj/item/mmi/brain_mmi = get(accessor.loc, /obj/item/mmi)
		if(brain_mmi && ismecha(brain_mmi.loc))
			var/obj/vehicle/sealed/mecha/big_stompy_robot = brain_mmi.loc
			return check_access_list(big_stompy_robot.accesses)
	return FALSE

/obj/proc/handle_buckled_access(mob/accessor)
	. = FALSE
	// check if someone riding on / buckled to them has access
	for(var/mob/living/buckled in accessor.buckled_mobs)
		if(accessor == buckled || buckled == src) // just in case to prevent a possible infinite loop scenario (but it won't happen)
			continue
		if(allowed(buckled))
			return TRUE

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/item/proc/RemoveID()
	return null

/obj/item/proc/InsertID()
	return FALSE

/obj/proc/text2access(access_text)
	. = list()
	if(!access_text)
		return
	var/list/split = splittext(access_text,";")
	for(var/x in split)
		var/n = text2num(x)
		if(n)
			. += n

//Call this before using req_access or req_one_access directly
/obj/proc/gen_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!req_access)
		req_access = list()
		for(var/a in text2access(req_access_txt))
			req_access |= a
	if(!req_one_access)
		req_one_access = list()
		for(var/b in text2access(req_one_access_txt))
			req_one_access |= b

// Check if an item has access to this object
/obj/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : null)


/obj/proc/check_access_list(list/accesses_to_check)
	gen_access()

	if(!islist(req_access)) //something's very wrong
		return TRUE

	if(!req_access.len && !length(req_one_access))
		return TRUE

	if(!length(accesses_to_check) || !islist(accesses_to_check))
		return FALSE

	for(var/each_code in req_access)
		if(!(each_code in accesses_to_check)) //doesn't have this access
			return FALSE

	if(length(req_one_access))
		for(var/each_code in req_one_access)
			if(each_code in accesses_to_check) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/*
 * Checks if this packet can access this device
 *
 * Normally just checks the access list however you can override it for
 * hacking proposes or if wires are cut
 *
 * Arguments:
 * * passkey - passkey from the datum/netdata packet
 */
/obj/proc/check_access_ntnet(list/passkey)
	return check_access_list(passkey)

/// Returns the CentCom access levels allotted to a given CentCom/ERT job. Not part of the region system as these are job-specific subsets.
/proc/get_centcom_access(job)
	switch(job)
		if(JOB_CENTCOM_VIP)
			return list(ACCESS_CENT_GENERAL)
		if(JOB_CENTCOM_CUSTODIAN)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if(JOB_CENTCOM_THUNDERDOME_OVERSEER)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
		if(JOB_CENTCOM_OFFICIAL)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("CentCom Intern")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("CentCom Head Intern")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if(JOB_CENTCOM_MEDICAL_DOCTOR)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
		if(JOB_ERT_DEATHSQUAD)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if(JOB_CENTCOM_RESEARCH_OFFICER)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
		if("Special Ops Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if(JOB_CENTCOM_ADMIRAL)
			return CENTCOM_ACCESS
		if(JOB_CENTCOM_COMMANDER)
			return CENTCOM_ACCESS
		if(JOB_ERT_COMMANDER)
			return get_ert_access("commander")
		if(JOB_ERT_OFFICER )
			return get_ert_access("sec")
		if(JOB_ERT_ENGINEER)
			return get_ert_access("eng")
		if(JOB_ERT_MEDICAL_DOCTOR)
			return get_ert_access("med")
		if(JOB_CENTCOM_BARTENDER)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
		if("Comedy Response Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("HONK Squad Trooper")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)

/// Returns the CentCom access levels allotted to a given ERT class. Not part of the region system as these are class-specific subsets.
/proc/get_ert_access(class)
	switch(class)
		if("commander")
			return CENTCOM_ACCESS
		if("sec")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
		if("eng")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("med")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)

/// Returns the SecHUD job icon state for whatever this object's ID card is, if it has one.
/obj/item/proc/get_sechud_job_icon_state()
	var/obj/item/card/id/id_card = GetID()

	return id_card?.get_sechud_icon_state() || "hudno_id"
