
///returns TRUE if this mob has sufficient access to use this object.
///Note that this will return FALSE when passed null, unless the door doesn't require any access.
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return TRUE
	if(issilicon(M))
		var/mob/living/silicon/S = M
		return check_access(S.internal_id_card)	//AI can do whatever it wants
	if(IsAdminGhost(M))
		//Access can't stop the abuse
		return TRUE
	else if(istype(M) && SEND_SIGNAL(M, COMSIG_MOB_ALLOWED, src))
		return TRUE
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || src.check_access(H.wear_id))
			return TRUE
	else if(ismonkey(M) || isalienadult(M))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(check_access(george.get_active_held_item()))
			return TRUE
	else if(isanimal(M))
		var/mob/living/simple_animal/A = M
		if(check_access(A.get_active_held_item()) || check_access(A.access_card))
			return TRUE
	return FALSE

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

/proc/get_all_accesses()
	return SSdepartment.get_all_station_accesses()

/proc/get_all_centcom_access()
	return SSdepartment.get_department_access_by_dept_id(DEPT_NAME_CENTCOM)

/proc/get_every_access()
	return SSdepartment.get_all_ingame_accesses()

/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/proc/get_all_away_access()
	return list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_MED, ACCESS_AWAY_SEC, ACCESS_AWAY_ENGINE, ACCESS_AWAY_GENERIC1, ACCESS_AWAY_GENERIC2, ACCESS_AWAY_GENERIC3, ACCESS_AWAY_GENERIC4)


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
			return get_all_centcom_access()
		if(JOB_CENTCOM_COMMANDER)
			return get_all_centcom_access()
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

/proc/get_ert_access(class)
	switch(class)
		if("commander")
			return get_all_centcom_access()
		if("sec")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
		if("eng")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("med")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)



/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //station general
			return
		if(2) //security
			return
		if(3) //medbay
			return
		if(4) //research
			return
		if(5) //engineering and maintenance
			return
		if(6) //supply
			return
		if(7) //command
			return

/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "All"
		if(1) //station general
			return "General"
		if(2) //security
			return "Security"
		if(3) //medbay
			return "Medbay"
		if(4) //research
			return "Research"
		if(5) //engineering and maintenance
			return "Engineering"
		if(6) //supply
			return "Supply"
		if(7) //command
			return "Command"


GLOBAL_LIST_INIT(access_desc_list, list( \
	"[ACCESS_CARGO]" = "Cargo Bay",
	"[ACCESS_SECURITY]" = "Security",
	"[ACCESS_BRIG]" = "Holding Cells",
	"[ACCESS_COURT]" = "Courtroom",
	"[ACCESS_FORENSICS_LOCKERS]" = "Forensics",
	"[ACCESS_MEDICAL]" = "Medical",
	"[ACCESS_GENETICS]" = "Genetics Lab",
	"[ACCESS_MORGUE]" = "Morgue",
	"[ACCESS_TOX]" = "R&D Lab",
	"[ACCESS_TOX_STORAGE]" = "Toxins Lab",
	"[ACCESS_CHEMISTRY]" = "Chemistry Lab",
	"[ACCESS_BRIGPHYS]" = "Brig Physician",
	"[ACCESS_RD]" = "RD Office",
	"[ACCESS_BAR]" = "Bar",
	"[ACCESS_JANITOR]" = "Custodial Closet",
	"[ACCESS_ENGINE]" = "Engineering",
	"[ACCESS_ENGINE_EQUIP]" = "Power and Engineering Equipment",
	"[ACCESS_MAINT_TUNNELS]" = "Maintenance",
	"[ACCESS_EXTERNAL_AIRLOCKS]" = "External Airlocks",
	"[ACCESS_CHANGE_IDS]" = "ID Console",
	"[ACCESS_AI_UPLOAD]" = "AI Chambers",
	"[ACCESS_TELEPORTER]" = "Teleporter",
	"[ACCESS_EVA]" = "EVA",
	"[ACCESS_HEADS]" = "Bridge",
	"[ACCESS_CAPTAIN]" = "Captain",
	"[ACCESS_ALL_PERSONAL_LOCKERS]" = "Personal Lockers",
	"[ACCESS_CHAPEL_OFFICE]" = "Chapel Office",
	"[ACCESS_TECH_STORAGE]" = "Technical Storage",
	"[ACCESS_ATMOSPHERICS]" = "Atmospherics",
	"[ACCESS_CREMATORIUM]" = "Crematorium",
	"[ACCESS_ARMORY]" = "Armory",
	"[ACCESS_CONSTRUCTION]" = "Construction",
	"[ACCESS_KITCHEN]" = "Kitchen",
	"[ACCESS_HYDROPONICS]" = "Hydroponics",
	"[ACCESS_LIBRARY]" = "Library",
	"[ACCESS_LAWYER]" = "Law Office",
	"[ACCESS_ROBOTICS]" = "Robotics",
	"[ACCESS_VIROLOGY]" = "Virology",
	"[ACCESS_CMO]" = "CMO Office",
	"[ACCESS_QM]" = "Quartermaster",
	"[ACCESS_EXPLORATION]" = "Exploration Dock",
	"[ACCESS_SURGERY]" = "Surgery",
	"[ACCESS_THEATRE]" = "Theatre",
	"[ACCESS_RESEARCH]" = "Science",
	"[ACCESS_RD_SERVER]" = "Research Server Room",
	"[ACCESS_MINING]" = "Mining",
	"[ACCESS_MAILSORTING]" = "Cargo Office",
	"[ACCESS_VAULT]" = "Main Vault",
	"[ACCESS_MINING_STATION]" = "Mining EVA",
	"[ACCESS_XENOBIOLOGY]" = "Xenobiology Lab",
	"[ACCESS_HOP]" = "HoP Office",
	"[ACCESS_HOS]" = "HoS Office",
	"[ACCESS_CE]" = "CE Office",
	"[ACCESS_RC_ANNOUNCE]" = "RC Announcements",
	"[ACCESS_KEYCARD_AUTH]" = "Keycode Auth.",
	"[ACCESS_TCOMSAT]" = "Telecommunications",
	"[ACCESS_GATEWAY]" = "Gateway",
	"[ACCESS_SEC_DOORS]" = "Brig",
	"[ACCESS_SEC_RECORDS]" = "Security Records",
	"[ACCESS_MINERAL_STOREROOM]" = "Mineral Storage",
	"[ACCESS_MINISAT]" = "AI Satellite",
	"[ACCESS_WEAPONS]" = "Weapon Permit",
	"[ACCESS_NETWORK]" = "Network Access",
	"[ACCESS_CLONING]" = "Cloning Room",
	"[ACCESS_MECH_MINING]" = "Mining Mech Access",
	"[ACCESS_MECH_MEDICAL]" = "Medical Mech Access",
	"[ACCESS_MECH_SECURITY]" = "Security Mech Access",
	"[ACCESS_MECH_SCIENCE]" = "Science Mech Access",
	"[ACCESS_MECH_ENGINE]" = "Engineering Mech Access",
	"[ACCESS_AUX_BASE]" = "Auxiliary Base",
	"[ACCESS_CENT_GENERAL]" = "Code Grey",
	"[ACCESS_CENT_THUNDER]" = "Code Yellow",
	"[ACCESS_CENT_STORAGE]" = "Code Orange",
	"[ACCESS_CENT_LIVING]" = "Code Green",
	"[ACCESS_CENT_MEDICAL]" = "Code White",
	"[ACCESS_CENT_TELEPORTER]" = "Code Blue",
	"[ACCESS_CENT_SPECOPS]" = "Code Black",
	"[ACCESS_CENT_CAPTAIN]" = "Code Gold",
	"[ACCESS_CENT_BAR]" = "Code Scotch",
	"[ACCESS_SYNDICATE]" = "Syndicate",
	"[ACCESS_SYNDICATE_LEADER]" = "Syndicate Leader",
	"[ACCESS_AWAY_GENERIC1]" = "Away generic 1",
	"[ACCESS_BLOODCULT]" = "Bloodcult",
	"[ACCESS_CLOCKCULT]" = "Clockcult"))

/proc/get_access_desc(access_code)
	return GLOB.access_desc_list["[access_code]"] || "Unknown [access_code]"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_CENT_GENERAL)
			return "Code Grey"
		if(ACCESS_CENT_THUNDER)
			return "Code Yellow"
		if(ACCESS_CENT_STORAGE)
			return "Code Orange"
		if(ACCESS_CENT_LIVING)
			return "Code Green"
		if(ACCESS_CENT_MEDICAL)
			return "Code White"
		if(ACCESS_CENT_TELEPORTER)
			return "Code Blue"
		if(ACCESS_CENT_SPECOPS)
			return "Code Black"
		if(ACCESS_CENT_CAPTAIN)
			return "Code Gold"
		if(ACCESS_CENT_BAR)
			return "Code Scotch"

/proc/get_all_centcom_jobs()
	return list(JOB_CENTCOM_VIP,JOB_CENTCOM_CUSTODIAN, JOB_CENTCOM_THUNDERDOME_OVERSEER,JOB_CENTCOM_OFFICIAL,JOB_CENTCOM_MEDICAL_DOCTOR,JOB_ERT_DEATHSQUAD,JOB_CENTCOM_RESEARCH_OFFICER,"Special Ops Officer",JOB_CENTCOM_ADMIRAL,JOB_CENTCOM_COMMANDER,JOB_ERT_COMMANDER,JOB_ERT_OFFICER ,JOB_ERT_ENGINEER, JOB_ERT_MEDICAL_DOCTOR,JOB_CENTCOM_BARTENDER,"Comedy Response Officer", "HONK Squad Trooper")

/obj/item/proc/GetJobIcon() //Used in secHUD icon generation (the new one)
	var/obj/item/card/id/I = GetID()
	if(!I)
		return
	var/I_hud = I.hud_state
	if(I_hud)
		return I_hud
	return "unknown"
