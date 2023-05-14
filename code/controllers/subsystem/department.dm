/*
	----- QUICK WARNING -----
		This subsystem also stores how to give access by region/job/id

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
	for(var/datum/department_group/each_dept in department_list)
		if(each_dept.dept_bitflag & bitflag)
			return each_dept

/datum/controller/subsystem/department/proc/get_department_by_id(id)
	return department_list[id]

/datum/controller/subsystem/department/proc/get_joblist_by_dept_id(id, include_dispatch=TRUE)
	var/datum/department_group = department_list[id]
	if(include_dispatch)
		return department_group.jobs + department_group.dispatched_jobs
	return department_group.jobs

// get access

/datum/department_group
	// basic variables
	var/dept_name = "No department"
	var/dept_id = NONE
	var/dept_bitflag = null
	var/dept_colour = null
	var/dept_radio_channel = null
	var/budget_id = null

	// datacore & crew manifest
	/// If you check crew manifest, department name will be displayed as this
	var/manifest_category_name = "No department"
	/// Crew manifest sort by low number (Command first)
	var/manifest_category_order = 0

	// job preference & roundjoin window
	/// sometimes a department should be merged into a department (i.e. VIP is Civilian in fact)
	var/pref_category_name = "No department"
	var/pref_category_order = 0

	// job related variables
	/// who's responsible of a department? (this is made as a list just in case)
	var/list/leaders = list()
	/// job list of people working in a department
	var/list/jobs = list()
	/// dispatched jobs from another department - they don't really belong here
	/// They'll be visible in a department they're dispatched to (i.e. Brig Phys, VIP)
	var/list/dispatched_jobs = list()

	// access related variables
	/// name of the access group
	var/access_group_name = "Undefined"
	/// a specific access that can control every access of this department
	var/dominant_access = null
	/// a specific access that can control `list/access`
	var/supervisor_access = null
	/// access list that is assigned to a department
	var/list/access = list()
	/// access list that is added by HoP work and only exists during a round
	var/list/custom_access = list()
	/// supervisor access can't adjust these accesses (i.e. CMO can't give 'CMO office access' to their medical doctors card)
	var/list/protected_access = list()

// ---------------------------------------------------------------------
//                                COMMAND
// ---------------------------------------------------------------------
/datum/department_group/command
	dept_name = DEPT_NAME_COMMAND
	dept_id = DEPT_NAME_COMMAND
	dept_bitflag = DEPT_BITFLAG_COMMAND
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_COMMAND
	budget_id = ACCOUNT_COM_ID

	manifest_category_name = DEPT_NAME_COMMAND
	manifest_category_order = DEPT_MANIFEST_ORDER_COMMAND
	pref_category_name = DEPT_NAME_COMMAND
	pref_category_order = DEPT_PREF_ORDER_COMMAND

	leaders = list(JOB_NAME_CAPTAIN)
	jobs = list(JOB_NAME_CAPTAIN,
				JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_CHIEFENGINEER,
				JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_HEADOFSECURITY)
	dispatched_jobs = list()


	access_group_name = DEPT_NAME_COMMAND
	dominant_access = ACCESS_CHANGE_IDS
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
	protected_access = list()

// ---------------------------------------------------------------------
//                                SERVICE
// ---------------------------------------------------------------------
/datum/department_group/service
	dept_name = DEPT_NAME_SERVICE
	dept_id = DEPT_NAME_SERVICE
	dept_bitflag = DEPT_BITFLAG_SERVICE
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_SERVICE
	budget_id = ACCOUNT_SRV_ID

	manifest_category_name = DEPT_NAME_SERVICE
	manifest_category_order = DEPT_MANIFEST_ORDER_SERVICE
	pref_category_name = DEPT_NAME_SERVICE
	pref_category_order = DEPT_PREF_ORDER_SERVICE

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
				JOB_NAME_STAGEMAGICIAN,
				JOB_NAME_BARBER,
				JOB_NAME_ASSISTANT)
	dispatched_jobs = list(JOB_NAME_VIP)

	access_group_name = "General"
	dominant_access = ACCESS_CHANGE_IDS
	supervisor_access = ACCESS_HOP
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

// ---------------------------------------------------------------------
//                                CIVILIAN
// ---------------------------------------------------------------------
// nothing belongs this department because how roundjoin & job pref window works, but Civ dept should exist anyway due to datacore
/datum/department_group/civilian
	dept_name = DEPT_NAME_CIVILIAN
	dept_id = DEPT_NAME_CIVILIAN
	dept_bitflag = DEPT_BITFLAG_CIVILIAN
	// dept_colour (auto)
	// dept_radio_channel (auto)
	budget_id = ACCOUNT_CIV_ID

	manifest_category_name = DEPT_NAME_CIVILIAN
	manifest_category_order = DEPT_PREF_ORDER_CIVILIAN
	// pref_category (unusued)
	// pref_category_order (unusued)

	// job part
	// 		unusued - Reason: civilian jobs are stored in service department.

	// access part
	// 		unusued - Reason: civilian accesses are service access in fact

// this will automatically follow service department data
/datum/department_group/civilian/New()
	var/datum/department_group/service_dept = SSdepartment.get_department_by_id(DEPT_NAME_SERVICE)
	dept_colour = service_dept.dept_colour
	dept_radio_channel = service_dept.dept_radio_channel
	// other variables will not be used

// ---------------------------------------------------------------------
//                               SUPPLY (CARGO)
// ---------------------------------------------------------------------
/datum/department_group/supply
	dept_name = DEPT_NAME_SUPPLY
	dept_id = DEPT_NAME_SUPPLY
	dept_bitflag = DEPT_BITFLAG_SUPPLY
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_SUPPLY
	budget_id = ACCOUNT_CAR_ID

	manifest_category_name = DEPT_NAME_SUPPLY
	manifest_category_order = DEPT_MANIFEST_ORDER_SUPPLY
	pref_category_name = DEPT_NAME_SUPPLY
	pref_category_order = DEPT_PREF_ORDER_SUPPLY

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_QUARTERMASTER,
				JOB_NAME_CARGOTECHNICIAN,
				JOB_NAME_SHAFTMINER)


	access_group_name = "Supply"
	dominant_access = ACCESS_CHANGE_IDS
	supervisor_access = ACCESS_HOP
	access = list(ACCESS_MAILSORTING,
					ACCESS_MINING,
					ACCESS_MINING_STATION,
					ACCESS_MECH_MINING,
					ACCESS_MINERAL_STOREROOM,
					ACCESS_CARGO,
					ACCESS_QM,
					ACCESS_VAULT)
	protected_access = list()

// ---------------------------------------------------------------------
//                              SCIENCE
// ---------------------------------------------------------------------
/datum/department_group/science
	dept_name = DEPT_NAME_SCIENCE
	dept_id = DEPT_NAME_SCIENCE
	dept_bitflag = DEPT_BITFLAG_SCIENCE
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_SCIENCE
	budget_id = ACCOUNT_SCI_ID

	manifest_category_name = DEPT_NAME_SCIENCE
	manifest_category_order = DEPT_MANIFEST_ORDER_SCIENCE
	pref_category_name = DEPT_NAME_SCIENCE
	pref_category_order = DEPT_PREF_ORDER_SCIENCE

	leaders = list(JOB_NAME_RESEARCHDIRECTOR)
	jobs = list(JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_SCIENTIST,
				JOB_NAME_EXPLORATIONCREW,
				JOB_NAME_ROBOTICIST)

	access_group_name = "Research"
	dominant_access = ACCESS_CHANGE_IDS
	supervisor_access = ACCESS_RD
	access = list(ACCESS_RESEARCH,
					ACCESS_TOX,
					ACCESS_TOX_STORAGE,
					ACCESS_ROBOTICS,
					ACCESS_XENOBIOLOGY,
					ACCESS_EXPLORATION,
					CCESS_MECH_SCIENCE,
					ACCESS_MINISAT,
					ACCESS_NETWORK,
					ACCESS_RD_SERVER,
					ACCESS_RD)
	protected_access = list()

// ---------------------------------------------------------------------
//                            ENGINEERING
// ---------------------------------------------------------------------
/datum/department_group/engineering
	dept_name = DEPT_NAME_ENGINEERING
	dept_id = DEPT_NAME_ENGINEERING
	dept_bitflag = DEPT_BITFLAG_ENGINEERING
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_ENGINEERING
	budget_id = ACCOUNT_ENG_ID

	manifest_category_name = DEPT_NAME_ENGINEERING
	manifest_category_order = DEPT_MANIFEST_ORDER_ENGINEERING
	pref_category_name = DEPT_NAME_ENGINEERING
	pref_category_order = DEPT_PREF_ORDER_ENGINEERING

	leaders = list(JOB_NAME_CHIEFENGINEER)
	jobs = list(JOB_NAME_CHIEFENGINEER,
				JOB_NAME_STATIONENGINEER,
				JOB_NAME_ATMOSPHERICTECHNICIAN)

	access_group_name = "Engineering"
	dominant_access = ACCESS_CHANGE_IDS
	supervisor_access = ACCESS_CE
	access = list(ACCESS_CONSTRUCTION,
					ACCESS_AUX_BASE,
					ACCESS_MAINT_TUNNELS,
					ACCESS_ENGINE,
					ACCESS_ENGINE_EQUIP,
					ACCESS_EXTERNAL_AIRLOCKS,
					ACCESS_TECH_STORAGE,
					ACCESS_ATMOSPHERICS,
					ACCESS_MECH_ENGINE,
					ACCESS_TCOMSAT,
					ACCESS_MINISAT,
					ACCESS_CE)
	protected_access = list()

// ---------------------------------------------------------------------
//                               MEDICAL
// ---------------------------------------------------------------------
/datum/department_group/medical
	dept_name = DEPT_NAME_MEDICAL
	dept_id = DEPT_NAME_MEDICAL
	dept_bitflag = DEPT_BITFLAG_MEDICAL
	dept_colour = "#00c0e2"
	dept_radio_channel = FREQ_MEDICAL
	budget_id = ACCOUNT_MED_ID

	manifest_category_name = DEPT_NAME_MEDICAL
	pref_category_order = 4
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
	dominant_access = ACCESS_CHANGE_IDS
	supervisor_access = ACCESS_CMO
	access = list(ACCESS_MEDICAL,
					ACCESS_GENETICS,
					ACCESS_CLONING,
					ACCESS_MORGUE,
					ACCESS_CHEMISTRY,
					ACCESS_VIROLOGY,
					ACCESS_SURGERY,
					ACCESS_MECH_MEDICAL,
					ACCESS_CMO)
	protected_access = list()

// ---------------------------------------------------------------------
//                               SECURITY
// ---------------------------------------------------------------------
/datum/department_group/security
	dept_name = DEPT_NAME_SECURITY
	dept_id = DEPT_NAME_SECURITY
	dept_bitflag = DEPT_BITFLAG_SECURITY
	dept_colour = "#ff0000"
	dept_radio_channel = FREQ_SECURITY
	budget_id = ACCOUNT_SEC_ID

	manifest_category_name = DEPT_NAME_SECURITY
	manifest_category_order = DEPT_MANIFEST_ORDER_SECURITY
	pref_category_name = DEPT_NAME_SECURITY
	pref_category_order = DEPT_PREF_ORDER_SECURITY

	leaders = list(JOB_NAME_HEADOFSECURITY)
	jobs = list(JOB_NAME_HEADOFSECURITY,
				JOB_NAME_WARDEN,
				JOB_NAME_DETECTIVE,
				JOB_NAME_SECURITYOFFICER,
				JOB_NAME_DEPUTY)
	dispatched_jobs = list(JOB_NAME_BRIGPHYSICIAN)

	access_group_name = "Security"
	dominant_access = ACCESS_CHANGE_IDS
	supervisor_access = ACCESS_HOS
	access = list(ACCESS_SEC_DOORS,
					ACCESS_SEC_RECORDS,
					ACCESS_WEAPONS,
					ACCESS_SECURITY,
					ACCESS_BRIG,
					ACCESS_BRIGPHYS,
					ACCESS_ARMORY,
					ACCESS_FORENSICS_LOCKERS,
					ACCESS_COURT,
					ACCESS_MECH_SECURITY,
					ACCESS_HOS)
	protected_access = list()

// ---------------------------------------------------------------------
//                              SILICON
//               Used for: job pref & roundjoin window
//                 (currently not for crew manifest)
// ---------------------------------------------------------------------
/datum/department_group/silicon
	dept_name = DEPT_NAME_SILICON
	dept_id = DEPT_NAME_SILICON
	dept_bitflag = DEPT_BITFLAG_SILICON
	// dept_colour
	// dept_radio_channel

	manifest_category_name = DEPT_NAME_SILICON
	manifest_category_order = DEPT_MANIFEST_ORDER_SILICON
	pref_category_name = DEPT_NAME_SILICON
	pref_category_order = DEPT_PREF_ORDER_SILICON

	leaders = list()
	jobs = list(JOB_NAME_AI,
				JOB_NAME_CYBORG)

	// access_group_name = ""
	// access = list()
	// dominant_access = null
	// protected_access = list()


// ---------------------------------------------------------------------
//                               VIP
//           Used for: job pref & roundjoin window, crew manifest
// ---------------------------------------------------------------------
/datum/department_group/vip
	dept_name = DEPT_NAME_VIP
	dept_id = DEPT_NAME_VIP
	dept_bitflag = DEPT_BITFLAG_VIP
	// dept_colour
	// dept_radio_channel
	budget_id = ACCOUNT_VIP_ID

	manifest_category_name = "Very Important People"
	display_order = DEPT_MANIFEST_ORDER_VIP

	leaders = list()
	jobs = list(JOB_NAME_VIP)

// ---------------------------------------------------------------------
//                           CentCom
//     Used for: access sorting (mainly), cerw manifest (admin gimmick)
// ---------------------------------------------------------------------
/datum/department_group/centcom
	dept_name = DEPT_NAME_CENTCOM
	dept_id = DEPT_NAME_CENTCOM
	dept_bitflag = DEPT_BITFLAG_CENTCOM
	dept_colour = "#00eba4"
	dept_radio_channel = FREQ_CENTCOM
	budget_id = ACCOUNT_COM_ID

	manifest_category_name = DEPT_NAME_CENTCOM
	manifest_category_order = DEPT_MANIFEST_ORDER_CENTCOM
	// pref_category (unused)
	// pref_category_order (unused)

	leaders = list()
	jobs = list()

	access_group_name = "CentCom"
	dominant_access = ACCESS_CENT_CAPTAIN
	access = list(ACCESS_CENT_GENERAL, //get_all_centcom_access()
					ACCESS_CENT_THUNDER,
					ACCESS_CENT_SPECOPS,
					ACCESS_CENT_MEDICAL,
					ACCESS_CENT_LIVING,
					ACCESS_CENT_STORAGE,
					ACCESS_CENT_TELEPORTER,
					ACCESS_CENT_CAPTAIN,
					ACCESS_CENT_BAR)

// ---------------------------------------------------------------------
//                   Others (syndicate, cult, away, etc)
//     Used for: access sorting (mainly), cerw manifest (admin gimmick)
// ---------------------------------------------------------------------
/datum/department_group/other
	dept_name = DEPT_NAME_OTHER
	dept_id = DEPT_NAME_OTHER
	dept_bitflag = DEPT_BITFLAG_OTHER
	dept_colour = "#00eba4"
	dept_radio_channel = FREQ_CENTCOM
	budget_id = ACCOUNT_COM_ID

	manifest_category_name = DEPT_NAME_OTHER
	manifest_category_order = 1000
	// pref_category (unused)
	// pref_category_order (unused)

	leaders = list()
	jobs = list()

	access_group_name = "Other (Non-CC)"
	dominant_access = ACCESS_CENT_CAPTAIN
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
