
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

/// Returns the SecHUD job icon state for whatever this object's ID card is, if it has one.
/obj/item/proc/get_sechud_job_icon_state()
	var/obj/item/card/id/id_card = GetID()

	return id_card?.get_sechud_icon_state() || "hudno_id"

/**
 * Non-processing subsystem that holds various procs and data structures to manage ID cards, trims and access.
 */
SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	ss_flags = SS_NO_FIRE

	/// Dictionary of access flags. Keys are accesses. Values are their associated bitflags.
	var/list/flags_by_access = list()
	/// Dictionary of access lists. Keys are access flag names. Values are lists of all accesses as part of that access.
	var/list/accesses_by_flag = list()
	/// Dictionary of access flag string representations. Keys are bitflags. Values are their associated names.
	var/list/access_flag_string_by_flag = list()
	/// Specially formatted list for sending access levels to tgui interfaces.
	var/list/all_region_access_tgui = list()
	/// Dictionary of access names. Keys are access levels. Values are their associated names.
	var/list/desc_by_access = list()

	/// The roundstart generated code for the spare ID safe. This is given to the Captain on shift start. If there's no Captain, it's given to the HoP. If there's no HoP
	var/spare_id_safe_code = ""

/datum/controller/subsystem/id_access/Initialize(timeofday)
	setup_access_flags()
	setup_access_descriptions()
	setup_tgui_lists()

	spare_id_safe_code = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"

	return ..()

/// Build access flag lists.
/datum/controller/subsystem/id_access/proc/setup_access_flags()
	accesses_by_flag["[ACCESS_FLAG_COMMON]"] = COMMON_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_COMMON]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_COMMON)

	accesses_by_flag["[ACCESS_FLAG_COMMAND]"] = COMMAND_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_COMMAND]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_COMMAND)

	accesses_by_flag["[ACCESS_FLAG_PRV_COMMAND]"] = PRIVATE_COMMAND_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_PRV_COMMAND]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_PRV_COMMAND)

	accesses_by_flag["[ACCESS_FLAG_CAPTAIN]"] = CAPTAIN_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_CAPTAIN]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_CAPTAIN)

	accesses_by_flag["[ACCESS_FLAG_CENTCOM]"] = CENTCOM_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_CENTCOM]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_CENTCOM)

	accesses_by_flag["[ACCESS_FLAG_SYNDICATE]"] = SYNDICATE_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_SYNDICATE]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_SYNDICATE)

	accesses_by_flag["[ACCESS_FLAG_AWAY]"] = AWAY_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_AWAY]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_AWAY)

	accesses_by_flag["[ACCESS_FLAG_SPECIAL]"] = CULT_ACCESS
	for(var/access in accesses_by_flag["[ACCESS_FLAG_SPECIAL]"])
		flags_by_access |= list("[access]" = ACCESS_FLAG_SPECIAL)

	access_flag_string_by_flag["[ACCESS_FLAG_COMMON]"] = ACCESS_FLAG_COMMON_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_COMMAND]"] = ACCESS_FLAG_COMMAND_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_PRV_COMMAND]"] = ACCESS_FLAG_PRV_COMMAND_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_CAPTAIN]"] = ACCESS_FLAG_CAPTAIN_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_CENTCOM]"] = ACCESS_FLAG_CENTCOM_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_SYNDICATE]"] = ACCESS_FLAG_SYNDICATE_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_AWAY]"] = ACCESS_FLAG_AWAY_NAME
	access_flag_string_by_flag["[ACCESS_FLAG_SPECIAL]"] = ACCESS_FLAG_SPECIAL_NAME

/// Creates various data structures that primarily get fed to tgui interfaces, although these lists are used in other places.
/datum/controller/subsystem/id_access/proc/setup_tgui_lists()
	for(var/region in SSdepartment.accesses_by_region)
		var/list/region_access = SSdepartment.accesses_by_region[region]

		var/parsed_accesses = list()

		for(var/access in region_access)
			var/access_desc = get_access_desc(access)
			if(!access_desc)
				continue

			parsed_accesses += list(list(
				"desc" = replacetext(access_desc, "&nbsp", " "),
				"ref" = access,
			))

		all_region_access_tgui[region] = list(list(
			"name" = region,
			"accesses" = parsed_accesses,
		))

/// Setup dictionary that converts access levels to text descriptions.
/datum/controller/subsystem/id_access/proc/setup_access_descriptions()
	desc_by_access["[ACCESS_CARGO]"] = "Cargo Bay"
	desc_by_access["[ACCESS_SERVICE]"] = "Service"
	desc_by_access["[ACCESS_SECURITY]"] = "Security"
	desc_by_access["[ACCESS_BRIG]"] = "Holding Cells"
	desc_by_access["[ACCESS_COURT]"] = "Courtroom"
	desc_by_access["[ACCESS_FORENSICS_LOCKERS]"] = "Forensics"
	desc_by_access["[ACCESS_MEDICAL]"] = "Medical"
	desc_by_access["[ACCESS_GENETICS]"] = "Genetics Lab"
	desc_by_access["[ACCESS_CLONING]"] = "Cloning Room"
	desc_by_access["[ACCESS_MORGUE]"] = "Morgue"
	desc_by_access["[ACCESS_TOX]"] = "R&D Lab"
	desc_by_access["[ACCESS_TOX_STORAGE]"] = "Toxins Lab"
	desc_by_access["[ACCESS_EXPLORATION]"] = "Exploration Dock"
	desc_by_access["[ACCESS_RD_SERVER]"] = "Research Server Room"
	desc_by_access["[ACCESS_CHEMISTRY]"] = "Chemistry Lab"
	desc_by_access["[ACCESS_RD]"] = "RD Office"
	desc_by_access["[ACCESS_BAR]"] = "Bar"
	desc_by_access["[ACCESS_JANITOR]"] = "Custodial Closet"
	desc_by_access["[ACCESS_ENGINE]"] = "Engineering"
	desc_by_access["[ACCESS_ENGINE_EQUIP]"] = "Power and Engineering Equipment"
	desc_by_access["[ACCESS_MAINT_TUNNELS]"] = "Maintenance"
	desc_by_access["[ACCESS_EXTERNAL_AIRLOCKS]"] = "External Airlocks"
	desc_by_access["[ACCESS_CHANGE_IDS]"] = "ID Console"
	desc_by_access["[ACCESS_AI_UPLOAD]"] = "AI Chambers"
	desc_by_access["[ACCESS_TELEPORTER]"] = "Teleporter"
	desc_by_access["[ACCESS_EVA]"] = "EVA"
	desc_by_access["[ACCESS_HEADS]"] = "Bridge"
	desc_by_access["[ACCESS_CAPTAIN]"] = "Captain"
	desc_by_access["[ACCESS_ALL_PERSONAL_LOCKERS]"] = "Personal Lockers"
	desc_by_access["[ACCESS_CHAPEL_OFFICE]"] = "Chapel Office"
	desc_by_access["[ACCESS_TECH_STORAGE]"] = "Technical Storage"
	desc_by_access["[ACCESS_ATMOSPHERICS]"] = "Atmospherics"
	desc_by_access["[ACCESS_CREMATORIUM]"] = "Crematorium"
	desc_by_access["[ACCESS_ARMORY]"] = "Armory"
	desc_by_access["[ACCESS_CONSTRUCTION]"] = "Construction"
	desc_by_access["[ACCESS_KITCHEN]"] = "Kitchen"
	desc_by_access["[ACCESS_HYDROPONICS]"] = "Hydroponics"
	desc_by_access["[ACCESS_LIBRARY]"] = "Library"
	desc_by_access["[ACCESS_LAWYER]"] = "Law Office"
	desc_by_access["[ACCESS_ROBOTICS]"] = "Robotics"
	desc_by_access["[ACCESS_VIROLOGY]"] = "Virology"
	desc_by_access["[ACCESS_CMO]"] = "CMO Office"
	desc_by_access["[ACCESS_QM]"] = "Quartermaster"
	desc_by_access["[ACCESS_SURGERY]"] = "Surgery"
	desc_by_access["[ACCESS_THEATRE]"] = "Theatre"
	desc_by_access["[ACCESS_RESEARCH]"] = "Science"
	desc_by_access["[ACCESS_MINING]"] = "Mining"
	desc_by_access["[ACCESS_MAILSORTING]"] = "Cargo Office"
	desc_by_access["[ACCESS_VAULT]"] = "Main Vault"
	desc_by_access["[ACCESS_MINING_STATION]"] = "Mining EVA"
	desc_by_access["[ACCESS_XENOBIOLOGY]"] = "Xenobiology Lab"
	desc_by_access["[ACCESS_HOP]"] = "HoP Office"
	desc_by_access["[ACCESS_HOS]"] = "HoS Office"
	desc_by_access["[ACCESS_CE]"] = "CE Office"
	desc_by_access["[ACCESS_RC_ANNOUNCE]"] = "RC Announcements"
	desc_by_access["[ACCESS_KEYCARD_AUTH]"] = "Keycode Auth."
	desc_by_access["[ACCESS_TCOMSAT]"] = "Telecommunications"
	desc_by_access["[ACCESS_GATEWAY]"] = "Gateway"
	desc_by_access["[ACCESS_SEC_DOORS]"] = "Brig"
	desc_by_access["[ACCESS_SEC_RECORDS]"] = "Security Records"
	desc_by_access["[ACCESS_BRIGPHYS]"] = "Brig Physician"
	desc_by_access["[ACCESS_MINERAL_STOREROOM]"] = "Mineral Storage"
	desc_by_access["[ACCESS_MINISAT]"] = "AI Satellite"
	desc_by_access["[ACCESS_WEAPONS]"] = "Weapon Permit"
	desc_by_access["[ACCESS_NETWORK]"] = "Network Access"
	desc_by_access["[ACCESS_MECH_MINING]"] = "Mining Mech Access"
	desc_by_access["[ACCESS_MECH_MEDICAL]"] = "Medical Mech Access"
	desc_by_access["[ACCESS_MECH_SECURITY]"] = "Security Mech Access"
	desc_by_access["[ACCESS_MECH_SCIENCE]"] = "Science Mech Access"
	desc_by_access["[ACCESS_MECH_ENGINE]"] = "Engineering Mech Access"
	desc_by_access["[ACCESS_AUX_BASE]"] = "Auxiliary Base"
	desc_by_access["[ACCESS_CENT_GENERAL]"] = "Code Grey"
	desc_by_access["[ACCESS_CENT_THUNDER]"] = "Code Yellow"
	desc_by_access["[ACCESS_CENT_STORAGE]"] = "Code Orange"
	desc_by_access["[ACCESS_CENT_LIVING]"] = "Code Green"
	desc_by_access["[ACCESS_CENT_MEDICAL]"] = "Code White"
	desc_by_access["[ACCESS_CENT_TELEPORTER]"] = "Code Blue"
	desc_by_access["[ACCESS_CENT_SPECOPS]"] = "Code Black"
	desc_by_access["[ACCESS_CENT_CAPTAIN]"] = "Code Gold"
	desc_by_access["[ACCESS_CENT_BAR]"] = "Code Scotch"
	desc_by_access["[ACCESS_PRISONER]"] = "Prisoner"
	desc_by_access["[ACCESS_SYNDICATE]"] = "Syndicate"
	desc_by_access["[ACCESS_SYNDICATE_LEADER]"] = "Syndicate Leader"
	desc_by_access["[ACCESS_AWAY_GENERIC1]"] = "Away generic 1"
	desc_by_access["[ACCESS_BLOODCULT]"] = "Bloodcult"
	desc_by_access["[ACCESS_CLOCKCULT]"] = "Clockcult"

/**
 * Returns the access bitflags associated with any given access level.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/datum/controller/subsystem/id_access/proc/get_access_flag(access)
	var/flag = flags_by_access["[access]"]
	return flag

/**
 * Returns the access description associated with any given access level.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/datum/controller/subsystem/id_access/proc/get_access_desc(access)
	return desc_by_access["[access]"]

/**
 * Returns a list of descriptions for a list of accesses, falling back to the raw access for any without one.
 * Arguments:
 * * accesses - A list of access levels.
 */
/datum/controller/subsystem/id_access/proc/get_access_descs(list/accesses)
	var/list/descriptions = list()
	for(var/access in accesses)
		descriptions += get_access_desc(access) || "[access]"
	return descriptions

/**
 * Returns the list of all accesses associated with any given access flag.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * flag - The flag to get access for as either a pure number of string representation of the flag.
 */
/datum/controller/subsystem/id_access/proc/get_flag_access_list(flag)
	return accesses_by_flag["[flag]"]

/**
 * Tallies up all accesses the card has that have flags greater than or equal to the access_flag supplied.
 *
 * Returns the number of accesses that have flags matching access_flag or a higher tier access.
 * Arguments:
 * * id_card - The ID card to tally up access for.
 * * access_flag - The minimum access flag required for an access to be tallied up.
 */
/datum/controller/subsystem/id_access/proc/tally_access(obj/item/card/id/id_card, access_flag = NONE)
	var/tally = 0

	var/list/id_card_access = id_card.access
	for(var/access in id_card_access)
		if(flags_by_access["[access]"] >= access_flag)
			tally++

	return tally
