
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
 * Singleton datum holding the static metadata for a single access level.
 *
 * One instance exists per access, stored in GLOB.access_datums keyed by the access as text
 * (accesses are frequently stored as text elsewhere). Built once at global init, so lookups are
 * order-independent of subsystem startup.
 */
/datum/access
	/// The numeric access level this datum represents.
	var/id
	/// Human-readable description of the area/permission this access unlocks. May be null for internal accesses.
	var/desc
	/// The access flag tier (ACCESS_FLAG_*) this access belongs to. NONE if it isn't part of a tier.
	var/flag = NONE

/datum/access/New(id)
	. = ..()
	src.id = id

/// Assoc list of every /datum/access singleton, keyed by the access as text ("[access]").
GLOBAL_LIST_INIT(access_datums, generate_access_datums())
/// Assoc list of access flag tier -> the list of accesses in that tier. Keyed by the flag as text ("[flag]").
GLOBAL_LIST_INIT(accesses_by_flag, list(
	"[ACCESS_FLAG_COMMON]" = COMMON_ACCESS,
	"[ACCESS_FLAG_COMMAND]" = COMMAND_ACCESS,
	"[ACCESS_FLAG_PRV_COMMAND]" = PRIVATE_COMMAND_ACCESS,
	"[ACCESS_FLAG_CAPTAIN]" = CAPTAIN_ACCESS,
	"[ACCESS_FLAG_CENTCOM]" = CENTCOM_ACCESS,
	"[ACCESS_FLAG_SYNDICATE]" = SYNDICATE_ACCESS,
	"[ACCESS_FLAG_AWAY]" = AWAY_ACCESS,
	"[ACCESS_FLAG_SPECIAL]" = CULT_ACCESS,
))

/// Builds the GLOB.access_datums singletons, folding together each access's flag tier and description.
/proc/generate_access_datums()
	var/list/datums = list()

	// Flag tiers. Kept self-contained rather than reading GLOB.accesses_by_flag to avoid depending on global init order.
	var/list/flag_tiers = list(
		"[ACCESS_FLAG_COMMON]" = COMMON_ACCESS,
		"[ACCESS_FLAG_COMMAND]" = COMMAND_ACCESS,
		"[ACCESS_FLAG_PRV_COMMAND]" = PRIVATE_COMMAND_ACCESS,
		"[ACCESS_FLAG_CAPTAIN]" = CAPTAIN_ACCESS,
		"[ACCESS_FLAG_CENTCOM]" = CENTCOM_ACCESS,
		"[ACCESS_FLAG_SYNDICATE]" = SYNDICATE_ACCESS,
		"[ACCESS_FLAG_AWAY]" = AWAY_ACCESS,
		"[ACCESS_FLAG_SPECIAL]" = CULT_ACCESS,
	)
	for(var/flag_key in flag_tiers)
		var/flag = text2num(flag_key)
		for(var/access in flag_tiers[flag_key])
			var/datum/access/access_datum = datums["[access]"]
			if(!access_datum)
				access_datum = new(access)
				datums["[access]"] = access_datum
			access_datum.flag = flag

	// Descriptions. Any access with a description but no flag tier still gets a datum.
	var/list/descriptions = list(
		"[ACCESS_CARGO]" = "Cargo Bay",
		"[ACCESS_SERVICE]" = "Service",
		"[ACCESS_SECURITY]" = "Security",
		"[ACCESS_BRIG]" = "Holding Cells",
		"[ACCESS_COURT]" = "Courtroom",
		"[ACCESS_FORENSICS_LOCKERS]" = "Forensics",
		"[ACCESS_MEDICAL]" = "Medical",
		"[ACCESS_GENETICS]" = "Genetics Lab",
		"[ACCESS_CLONING]" = "Cloning Room",
		"[ACCESS_MORGUE]" = "Morgue",
		"[ACCESS_TOX]" = "R&D Lab",
		"[ACCESS_TOX_STORAGE]" = "Toxins Lab",
		"[ACCESS_EXPLORATION]" = "Exploration Dock",
		"[ACCESS_RD_SERVER]" = "Research Server Room",
		"[ACCESS_CHEMISTRY]" = "Chemistry Lab",
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
		"[ACCESS_SURGERY]" = "Surgery",
		"[ACCESS_THEATRE]" = "Theatre",
		"[ACCESS_RESEARCH]" = "Science",
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
		"[ACCESS_BRIGPHYS]" = "Brig Physician",
		"[ACCESS_MINERAL_STOREROOM]" = "Mineral Storage",
		"[ACCESS_MINISAT]" = "AI Satellite",
		"[ACCESS_WEAPONS]" = "Weapon Permit",
		"[ACCESS_NETWORK]" = "Network Access",
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
		"[ACCESS_PRISONER]" = "Prisoner",
		"[ACCESS_SYNDICATE]" = "Syndicate",
		"[ACCESS_SYNDICATE_LEADER]" = "Syndicate Leader",
		"[ACCESS_AWAY_GENERIC1]" = "Away generic 1",
		"[ACCESS_BLOODCULT]" = "Bloodcult",
		"[ACCESS_CLOCKCULT]" = "Clockcult",
	)
	for(var/access_key in descriptions)
		var/datum/access/access_datum = datums[access_key]
		if(!access_datum)
			access_datum = new(text2num(access_key))
			datums[access_key] = access_datum
		access_datum.desc = descriptions[access_key]

	return datums

/**
 * Returns the access flag tier (ACCESS_FLAG_*) associated with any given access level, or NONE if it has none.
 *
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/proc/get_access_flag(access)
	var/datum/access/access_datum = GLOB.access_datums["[access]"]
	return access_datum?.flag

/**
 * Returns the human-readable description associated with any given access level, or null if it has none.
 *
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/proc/get_access_desc(access)
	var/datum/access/access_datum = GLOB.access_datums["[access]"]
	return access_datum?.desc

/**
 * Returns a list of descriptions for a list of accesses, falling back to the raw access for any without one.
 * Arguments:
 * * accesses - A list of access levels.
 */
/proc/get_access_descs(list/accesses)
	var/list/descriptions = list()
	for(var/access in accesses)
		descriptions += get_access_desc(access) || "[access]"
	return descriptions

/**
 * Returns the list of all accesses associated with any given access flag tier.
 *
 * Arguments:
 * * flag - The flag to get access for as either a pure number or string representation of the flag.
 */
/proc/get_flag_access_list(flag)
	return GLOB.accesses_by_flag["[flag]"]
