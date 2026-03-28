
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

/proc/get_all_accesses()
	var/static/list/access_list
	if(!access_list)
		access_list = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT,
							ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_MORGUE, ACCESS_RD,
							ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS,
							ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD,
							ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS,
							ACCESS_TECH_STORAGE, ACCESS_CHAPEL_OFFICE, ACCESS_ATMOSPHERICS, ACCESS_KITCHEN,
							ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_ROBOTICS, ACCESS_CARGO, ACCESS_CONSTRUCTION, ACCESS_AUX_BASE,
							ACCESS_HYDROPONICS, ACCESS_SERVICE, ACCESS_LIBRARY, ACCESS_LAWYER, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_QM, ACCESS_EXPLORATION, ACCESS_SURGERY,
							ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_MAILSORTING, ACCESS_WEAPONS,
							ACCESS_MECH_MINING, ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY, ACCESS_MECH_MEDICAL,
							ACCESS_VAULT, ACCESS_MINING_STATION, ACCESS_XENOBIOLOGY, ACCESS_CE, ACCESS_HOP, ACCESS_HOS, ACCESS_RC_ANNOUNCE,
							ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_MINISAT, ACCESS_NETWORK, ACCESS_CLONING, ACCESS_RD_SERVER)
	return access_list.Copy()

/proc/get_all_centcom_access()
	return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_TELEPORTER, ACCESS_CENT_CAPTAIN, ACCESS_CENT_BAR)

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

/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/proc/get_all_away_access()
	return list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_MED, ACCESS_AWAY_SEC, ACCESS_AWAY_ENGINE, ACCESS_AWAY_GENERIC1, ACCESS_AWAY_GENERIC2, ACCESS_AWAY_GENERIC3, ACCESS_AWAY_GENERIC4)

/proc/get_every_access()
	return get_all_accesses() + get_all_centcom_access() + get_all_syndicate_access() + get_all_away_access() + ACCESS_BLOODCULT + ACCESS_CLOCKCULT

/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //station general
			return list(ACCESS_KITCHEN,ACCESS_BAR, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_THEATRE, ACCESS_LAWYER)
		if(2) //security
			return list(ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_WEAPONS, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_MECH_SECURITY, ACCESS_HOS)
		if(3) //medbay
			return list(ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_MECH_MEDICAL, ACCESS_CMO)
		if(4) //research
			return list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_EXPLORATION, ACCESS_MECH_SCIENCE, ACCESS_MINISAT, ACCESS_RD, ACCESS_NETWORK, ACCESS_RD_SERVER)
		if(5) //engineering and maintenance
			return list(ACCESS_CONSTRUCTION, ACCESS_AUX_BASE, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_MECH_ENGINE, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_CE)
		if(6) //supply
			return list(ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_CARGO, ACCESS_QM, ACCESS_VAULT)
		if(7) //command
			return list(ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_GATEWAY, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_HOP, ACCESS_CAPTAIN, ACCESS_VAULT)

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

/proc/get_all_jobs()
	return list(JOB_NAME_CAPTAIN,
				// Service
				JOB_NAME_ASSISTANT, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_BARTENDER, JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_JANITOR, JOB_NAME_CURATOR,
				JOB_NAME_CHAPLAIN, JOB_NAME_LAWYER, JOB_NAME_CLOWN, JOB_NAME_MIME, JOB_NAME_BARBER, JOB_NAME_STAGEMAGICIAN,
				// Cargo
				JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN,JOB_NAME_SHAFTMINER,
				// R&D
				JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW,
				// Engineering
				JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN,
				// Medical
				JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST, JOB_NAME_PARAMEDIC, JOB_NAME_PSYCHIATRIST,
				// Security
				JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_SECURITYOFFICER, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_DEPUTY)
				// Each job is supposed to be in their department due to the HoP console.

/proc/get_all_job_icons() //We need their HUD icons, but we don't want to give these jobs to people from the job list of HoP console.
	return get_all_jobs() + list("Prisoner", "King", JOB_NAME_VIP, "Acting Captain")

/proc/get_all_centcom_jobs()
	return list(JOB_CENTCOM_VIP,JOB_CENTCOM_CUSTODIAN, JOB_CENTCOM_THUNDERDOME_OVERSEER,JOB_CENTCOM_OFFICIAL,JOB_CENTCOM_MEDICAL_DOCTOR,JOB_ERT_DEATHSQUAD,JOB_CENTCOM_RESEARCH_OFFICER,"Special Ops Officer",JOB_CENTCOM_ADMIRAL,JOB_CENTCOM_COMMANDER,JOB_ERT_COMMANDER,JOB_ERT_OFFICER ,JOB_ERT_ENGINEER, JOB_ERT_MEDICAL_DOCTOR,JOB_CENTCOM_BARTENDER,"Comedy Response Officer", "HONK Squad Trooper")

/obj/item/proc/get_item_job_icon() //Used in secHUD icon generation (the new one)
	var/obj/item/card/id/I = GetID()
	if(!I)
		return
	var/I_hud = I.hud_state
	if(I_hud)
		return I_hud
	return "unknown"
