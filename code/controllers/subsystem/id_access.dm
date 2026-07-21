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
	/// Dictionary of accesses based on station region. Keys are region strings. Values are lists of accesses.
	var/list/accesses_by_region = list()
	/// Dictionary of CentCom/ERT job accesses. Keys are job names. Values are lists of accesses.
	var/list/accesses_by_centcom_job = list()
	/// Specially formatted list for sending access levels to tgui interfaces.
	var/list/all_region_access_tgui = list()
	/// Dictionary of access names. Keys are access levels. Values are their associated names.
	var/list/desc_by_access = list()
	/// Helper list containing all station regions.
	var/list/station_regions = list()

	/// The roundstart generated code for the spare ID safe. This is given to the Captain on shift start. If there's no Captain, it's given to the HoP. If there's no HoP
	var/spare_id_safe_code = ""

/datum/controller/subsystem/id_access/Initialize(timeofday)
	setup_access_flags()
	setup_region_lists()
	setup_centcom_access()
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

/// Populates the region lists with data about which accesses correspond to which regions.
/datum/controller/subsystem/id_access/proc/setup_region_lists()
	accesses_by_region[REGION_ALL_STATION] = REGION_ACCESS_ALL_STATION
	accesses_by_region[REGION_ALL_GLOBAL] = REGION_ACCESS_ALL_GLOBAL
	accesses_by_region[REGION_GENERAL] = REGION_ACCESS_GENERAL
	accesses_by_region[REGION_SECURITY] = REGION_ACCESS_SECURITY
	accesses_by_region[REGION_MEDBAY] = REGION_ACCESS_MEDBAY
	accesses_by_region[REGION_RESEARCH] = REGION_ACCESS_RESEARCH
	accesses_by_region[REGION_ENGINEERING] = REGION_ACCESS_ENGINEERING
	accesses_by_region[REGION_SUPPLY] = REGION_ACCESS_SUPPLY
	accesses_by_region[REGION_COMMAND] = REGION_ACCESS_COMMAND
	accesses_by_region[REGION_CENTCOM] = REGION_ACCESS_CENTCOM

	station_regions = REGION_AREA_STATION

/// Populates the CentCom/ERT job access table. Ugly as sin, but better than it was before
/datum/controller/subsystem/id_access/proc/setup_centcom_access()
	accesses_by_centcom_job[JOB_CENTCOM_VIP] = list(ACCESS_CENT_GENERAL)
	accesses_by_centcom_job[JOB_CENTCOM_CUSTODIAN] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	accesses_by_centcom_job[JOB_CENTCOM_THUNDERDOME_OVERSEER] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
	accesses_by_centcom_job[JOB_CENTCOM_OFFICIAL] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
	accesses_by_centcom_job["CentCom Intern"] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
	accesses_by_centcom_job["CentCom Head Intern"] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
	accesses_by_centcom_job[JOB_CENTCOM_MEDICAL_DOCTOR] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
	accesses_by_centcom_job[JOB_ERT_DEATHSQUAD] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	accesses_by_centcom_job[JOB_CENTCOM_RESEARCH_OFFICER] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
	accesses_by_centcom_job["Special Ops Officer"] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	accesses_by_centcom_job[JOB_CENTCOM_ADMIRAL] = CENTCOM_ACCESS
	accesses_by_centcom_job[JOB_CENTCOM_COMMANDER] = CENTCOM_ACCESS
	accesses_by_centcom_job[JOB_ERT_COMMANDER] = CENTCOM_ACCESS
	accesses_by_centcom_job[JOB_ERT_OFFICER] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
	accesses_by_centcom_job[JOB_ERT_ENGINEER] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	accesses_by_centcom_job[JOB_ERT_MEDICAL_DOCTOR] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)
	accesses_by_centcom_job[JOB_CENTCOM_BARTENDER] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
	accesses_by_centcom_job["Comedy Response Officer"] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
	accesses_by_centcom_job["HONK Squad Trooper"] = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)

/// Creates various data structures that primarily get fed to tgui interfaces, although these lists are used in other places.
/datum/controller/subsystem/id_access/proc/setup_tgui_lists()
	for(var/region in accesses_by_region)
		var/list/region_access = accesses_by_region[region]

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
 * Builds and returns a list of accesses from a list of regions.
 *
 * Arguments:
 * * regions - A list of region defines.
 */
/datum/controller/subsystem/id_access/proc/get_region_access_list(list/regions)
	if(!length(regions))
		return

	var/list/built_region_list = list()

	for(var/region in regions)
		built_region_list |= accesses_by_region[region]

	return built_region_list

/**
 * Returns the CentCom access levels allotted to a given CentCom/ERT job.
 *
 * Arguments:
 * * job - The job name to get CentCom access for.
 */
/datum/controller/subsystem/id_access/proc/get_centcom_access_list(job)
	var/list/centcom_access = accesses_by_centcom_job[job]
	return centcom_access?.Copy()

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
