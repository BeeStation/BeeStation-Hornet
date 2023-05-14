/*
	----- WARNING -----
		This subsystem needs to be initialised quite quickly because not a few systems need initialised access list
		So, this is why INIT_ORDER is quite prioritised
*/
SUBSYSTEM_DEF(department)
	name = "Departments"
	init_order = INIT_ORDER_DEPARTMENT
	flags = SS_NO_FIRE

	var/list/department_list = list()

/datum/controller/subsystem/department/Initialize(timeofday)
	for(var/datum/department_group/each_dept as() in subtypesof(/datum/department_group))
		each_dept = new each_dept
		department_list[each_dept.dept_id] = each_dept

	return ..()

/datum/controller/subsystem/department/proc/get_department_by_bitflag(bitflag)
	return

/datum/controller/subsystem/department/proc/get_department_by_id(id)
	return department_list[id]

/datum/controller/subsystem/department/proc/get_joblist_by_dept_id(id)
	var/datum/department_group = department_list[id]
	return department_group.jobs

/datum/department_group
	// basic variables
	var/dept_name = "No department"
	var/dept_id = NONE
	var/dept_bitflag = null
	var/dept_colour = null
	var/dept_radio_channel = null

	var/datacore_display = "No department"
	var/datacore_display_order = 0
	var/pref_display_order = 0

	// job related variables
	/// who's responsible of a department? (this is made as a list just in case)
	var/list/leaders
	/// job list of people working in a department
	var/list/jobs


	// access related variables
	/// name of the access group
	var/access_group_name = "Undefined"
	/// access list that is assigned to a department
	var/list/access
	/// a specific access that can control `list/access`
	var/dominant_access
	/// dominant access can't adjust these accesses (i.e. CMO can't give 'CMO office access' to their medical doctors card)
	var/list/protected_access

/// this is important because we want to put VIP into civilian pref category
/datum/department_group/proc/get_pref_category()
	return dept_name

/datum/department_group/vip/get_pref_category()
	return DEPT_NAME_SERVICE

// command
/datum/department_group/command
	dept_name = DEPT_NAME_COMMAND
	dept_id = DEPT_NAME_COMMAND
	dept_bitflag = DEPT_BITFLAG_COMMAND
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_COMMAND

	datacore_display = DEPT_NAME_COMMAND
	datacore_display_order = DEPT_DATACORE_ORDER_COMMAND
	pref_display_order = 1

	leaders = list(JOB_NAME_CAPTAIN)
	jobs = list(JOB_NAME_CAPTAIN,
				JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_CHIEFENGINEER,
				JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_HEADOFSECURITY)


	access_group_name = "Command"
	access = list(ACCESS_HEADS,
					ACCESS_RC_ANNOUNCE,
					ACCESS_KEYCARD_AUTH,
					ACCESS_CHANGE_IDS,
					ACCESS_AI_UPLOAD,
					ACCESS_TELEPORTER,
					ACCESS_EVA,
					ACCESS_GATEWAY,
					ACCESS_ALL_PERSONAL_LOCKERS,
					ACCESS_HOP,
					ACCESS_CAPTAIN,
					ACCESS_VAULT)
	dominant_access = null
	protected_access = list()

// service
/datum/department_group/service
	dept_name = DEPT_NAME_SERVICE
	dept_id = DEPT_NAME_SERVICE
	dept_bitflag = DEPT_BITFLAG_SERVICE
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_SERVICE

	datacore_display = DEPT_NAME_SERVICE
	datacore_display_order = 60
	pref_display_order = 6

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_BARTENDER,
				JOB_NAME_BOTANIST,
				JOB_NAME_COOK,
				JOB_NAME_JANITOR,
				JOB_NAME_LAWYER,
				JOB_NAME_CURATOR,
				JOB_NAME_CHAPLAIN,
				JOB_NAME_MIME,
				JOB_NAME_CLOWN,
				JOB_NAME_ASSISTANT)


	access_group_name = "Command"
	access = list(ACCESS_KITCHEN,
					ACCESS_BAR,
					ACCESS_HYDROPONICS,
					ACCESS_JANITOR,
					ACCESS_CHAPEL_OFFICE,
					ACCESS_CREMATORIUM,
					ACCESS_LIBRARY,
					ACCESS_THEATRE,
					ACCESS_LAWYER)
	dominant_access = null
	protected_access = list()

// civilian
// nothing belongs this department because how roundjoin & job pref window works, but Civ dept should exist anyway due to datacore
/datum/department_group/civilian
	dept_name = DEPT_NAME_CIVILIAN
	dept_id = DEPT_NAME_CIVILIAN
	dept_bitflag = DEPT_BITFLAG_CIVILIAN
	// dept_colour (auto)
	// dept_radio_channel (auto)

	datacore_display = DEPT_NAME_CIVILIAN
	datacore_display_order = 70

// this will automatically follow service department data
/datum/department_group/civilian/New()
	var/datum/department_group/service_dept = SSdepartment.get_department_by_id(DEPT_NAME_SERVICE)
	dept_colour = service_dept.dept_colour
	dept_radio_channel = service_dept.dept_radio_channel
	// other variables will not be used

// supply
list(ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_CARGO, ACCESS_QM, ACCESS_VAULT)


// science
list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_EXPLORATION, ACCESS_MECH_SCIENCE, ACCESS_MINISAT, ACCESS_RD, ACCESS_NETWORK, ACCESS_RD_SERVER)

// engineering
list(ACCESS_CONSTRUCTION, ACCESS_AUX_BASE, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_MECH_ENGINE, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_CE)

// medical
/datum/department_group/medical
	dept_name = DEPT_NAME_MEDICAL
	dept_id = DEPT_NAME_MEDICAL
	dept_bitflag = DEPT_BITFLAG_MEDICAL
	dept_colour = "#00c0e2"
	dept_radio_channel = FREQ_MEDICAL

	datacore_display = DEPT_NAME_MEDICAL
	pref_display_order = 4
	display_order = 4

	leaders = list(JOB_NAME_CHIEFMEDICALOFFICER)
	jobs = list(JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_MEDICALDOCTOR,
				JOB_NAME_CHEMIST,
				JOB_NAME_GENETICIST,
				JOB_NAME_VIROLOGIST,
				JOB_NAME_PARAMEDIC,
				JOB_NAME_PSYCHIATRIST)


	access_group_name = "Medbay"
	access = list(ACCESS_MEDICAL,
					ACCESS_GENETICS,
					ACCESS_CLONING,
					ACCESS_MORGUE,
					ACCESS_CHEMISTRY,
					ACCESS_VIROLOGY,
					ACCESS_SURGERY,
					ACCESS_MECH_MEDICAL)
	dominant_access = ACCESS_CMO
	protected_access = list(ACCESS_CMO)

// security
list(ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_WEAPONS, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_MECH_SECURITY, ACCESS_HOS)

// silicon (only for pref)
/datum/department_group/silicon
	dept_name = DEPT_NAME_SIL
	dept_id = DEPT_NAME_SIL
	dept_bitflag = DEPT_BITFLAG_SIL
	// dept_colour
	// dept_radio_channel

	datacore_display = "Silicon" //
	display_order = 95 // after command

	leaders = list()
	jobs = list()

	// access_group_name = ""
	// access = list()
	// dominant_access = null
	// protected_access = list()

// vip (only for pref & datacore)
/datum/department_group/vip
	dept_name = DEPT_NAME_VIP
	dept_id = DEPT_NAME_VIP
	dept_bitflag = DEPT_BITFLAG_VIP
	// dept_colour
	// dept_radio_channel

	datacore_display = "Very Important People"
	display_order = 11 // after command

	leaders = list()
	jobs = list()

	// access_group_name = ""
	// access = list()
	// dominant_access = null
	// protected_access = list()

// centcom (only for access sorting)
/datum/department_group/centcom
	dept_name = DEPT_NAME_CENTCOM
	dept_id = DEPT_NAME_CENTCOM
	dept_bitflag = DEPT_BITFLAG_CENTCOM
	dept_colour = "#00eba4"
	dept_radio_channel = FREQ_CENTCOM

	datacore_display = DEPT_NAME_CENTCOM
	display_order = 1000

	leaders = list()
	jobs = list()

	access_group_name = "CentCom"
	access = list(ACCESS_CENT_GENERAL, //get_all_centcom_access()
					ACCESS_CENT_THUNDER,
					ACCESS_CENT_SPECOPS,
					ACCESS_CENT_MEDICAL,
					ACCESS_CENT_LIVING,
					ACCESS_CENT_STORAGE,
					ACCESS_CENT_TELEPORTER,
					ACCESS_CENT_CAPTAIN,
					ACCESS_CENT_BAR)
	// dominant_access = null
	protected_access = list() // need to be empty for access system


// other (only for access sorting)
/datum/department_group/other
	dept_name = DEPT_NAME_OTHER
	dept_id = DEPT_NAME_OTHER
	dept_bitflag = DEPT_BITFLAG_OTHER
	dept_colour = "#00eba4"
	dept_radio_channel = FREQ_CENTCOM

	datacore_display = DEPT_NAME_OTHER
	display_order = 1000

	leaders = list()
	jobs = list()

	access_group_name = "Other (Non-CC)"
	access = list(ACCESS_SYNDICATE,
					ACCESS_SYNDICATE_LEADER,
					ACCESS_PIRATES,
					ACCESS_HUNTERS,
					ACCESS_AWAY_GENERAL,
					ACCESS_AWAY_MAINT,
					ACCESS_AWAY_MED,
					ACCESS_AWAY_SEC,
					ACCESS_AWAY_ENGINE,
					ACCESS_AWAY_GENERIC1,
					ACCESS_AWAY_GENERIC2,
					ACCESS_AWAY_GENERIC3,
					ACCESS_AWAY_GENERIC4,
					ACCESS_BLOODCULT,
					ACCESS_CLOCKCULT)
	// dominant_access = null
	protected_access = list() // need to be empty for access system
