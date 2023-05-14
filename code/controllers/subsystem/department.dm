/*
	----- QUICK WARNING -----
		This subsystem also stores how to give access by region/job/id

*/
SUBSYSTEM_DEF(department)
	name = "Departments"
	init_order = INIT_ORDER_DEPARTMENT
	flags = SS_NO_FIRE

	var/list/department_list = list()
	var/list/department_by_key = list()
	var/list/department_names = list()

/datum/controller/subsystem/department/Initialize(timeofday)
	for(var/datum/department_group/each_dept as() in subtypesof(/datum/department_group))
		each_dept = new each_dept
		department_list += each_dept
		department_by_key[each_dept.dept_id] = each_dept
		department_names += each_dept.dept_id

	return ..()

/datum/controller/subsystem/department/proc/get_department_by_bitflag(bitflag)
	for(var/datum/department_group/each_dept in department_list)
		if(each_dept.dept_bitflag & bitflag)
			return each_dept

/datum/controller/subsystem/department/proc/get_department_by_id(id)
	return department_by_key[id]

/// WARNING: include_dispatch parameter is important. Avoid using it to security positions.
/datum/controller/subsystem/department/proc/get_joblist_by_dept_id(id)
	var/datum/department_group/dept = department_by_key[id]
	return dept.jobs

// get access proc

/datum/controller/subsystem/department/proc/get_all_jobs()



/datum/controller/subsystem/department/proc/get_departments_by_manifest_order()
	var/static/list/department_order = list()
	if(!length(department_order))
		var/list/copied_dept = department_list.Copy()
		while(length(copied_dept))
			var/datum/department_group/current
			for(var/datum/department_group/each_dept in copied_dept)
				if(!each_dept.manifest_category_order)
					copied_dept -= each_dept
					continue
				if(!current)
					current = each_dept
					continue
				if(each_dept.manifest_category_order < current.manifest_category_order)
					current = each_dept
					continue
			department_order += current
			copied_dept -= current
	return department_order

/datum/controller/subsystem/department/proc/get_departments_by_pref_order()
	var/static/list/department_order = list()
	if(!length(department_order))
		var/list/copied_dept = department_list.Copy()
		while(length(copied_dept))
			var/datum/department_group/current
			for(var/datum/department_group/each_dept in copied_dept)
				if(!each_dept.pref_category_order)
					copied_dept -= each_dept
					continue
				if(!current)
					current = each_dept
					continue
				if(each_dept.pref_category_order < current.pref_category_order)
					current = each_dept
					continue
			department_order += current
			copied_dept -= current
	return department_order

/datum/department_group
	// basic variables
	var/dept_name = "No department"
	var/dept_id = NONE
	var/dept_bitflag = null
	var/dept_colour = null
	var/dept_radio_channel = null
	var/is_station = FALSE

	// job preference & roundjoin window
	/// sometimes a department should be merged into a department (i.e. VIP is Civilian in fact)
	var/pref_category_name = "No department"
	var/pref_category_order = 0

	// job related variables
	/// who's responsible of a department? (this is made as a list just in case)
	var/list/leaders = list()
	/// job list of people working in a department
	var/list/jobs = list()

	// access related variables
	/// name of the access group. Being null means it has no access.
	var/access_group_name
	/// access that can control every access of this department
	var/list/access_dominant = list()
	/// an access that can control `list/access` (excluding protected access)
	var/list/access_supervisor = list()
	/// access list that is assigned to a department
	var/list/standard_access = list()
	/// access list that is added by HoP work and only exists during a round
	var/list/custom_access = list()
	/// supervisor access can't adjust these accesses (i.e. CMO can't give 'CMO office access' to their medical doctors card)
	var/list/protected_access = list()

	// datacore & crew manifest
	/// an access that can inject someone into a manifest
	var/list/access_manifest_changer = list()
	/// If you check crew manifest, department name will be displayed as this
	var/manifest_category_name = "No department"
	/// Crew manifest sort by low number (Command first)
	var/manifest_category_order = 0

	// budget related variables
	/// an access that can adjust payment
	var/list/access_accountancy = list()
	var/budget_id = null
	var/budget_bitflag = NONE

/datum/department_group/proc/check_authentication(check_type, list/access_to_check)
	if(!check_type)
		stack_trace("check_type is not specified")
		return FALSE

	var/list/auth_access
	switch(check_type)
		if(DEPT_AUTHCHECK_DOMINANT)
			auth_access = access_dominant
		if(DEPT_AUTHCHECK_SUPERVISOR)
			auth_access = access_supervisor
		if(DEPT_AUTHCHECK_ACCESS_MANAGER)
			auth_access = access_dominant
			auth_access |= access_supervisor
		if(DEPT_AUTHCHECK_MANIFEST)
			auth_access = access_manifest_changer
		if(DEPT_AUTHCHECK_BUDGET)
			auth_access = access_accountancy

	if(!auth_access)
		stack_trace("check_type is wrong: [check_type]")
		return FALSE
	if(!length(auth_access)) // no need to check
		return TRUE
	message_admins("Ctype: [check_type]")
	for(var/each_access in auth_access)
		if(each_access in access_to_check)
			message_admins("found: [each_access]")
			return TRUE
	message_admins("not found")
	return FALSE



// ---------------------------------------------------------------------
//                                COMMAND
// ---------------------------------------------------------------------
/datum/department_group/command
	dept_name = DEPT_NAME_COMMAND
	dept_id = DEPT_NAME_COMMAND
	dept_bitflag = DEPT_BITFLAG_COMMAND
	dept_colour = "#ddddff"
	dept_radio_channel = FREQ_COMMAND
	is_station = TRUE

	pref_category_name = DEPT_NAME_COMMAND
	pref_category_order = DEPT_PREF_ORDER_COMMAND

	leaders = list(JOB_NAME_CAPTAIN)
	jobs = list(JOB_NAME_CAPTAIN,
				JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_CHIEFENGINEER,
				JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_HEADOFSECURITY)

	access_group_name = DEPT_NAME_COMMAND
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(JOB_NAME_CAPTAIN)
	standard_access = list(ACCESS_HEADS,
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

	access_manifest_changer = list(ACCESS_CHANGE_IDS, JOB_NAME_CAPTAIN)
	manifest_category_name = DEPT_NAME_COMMAND
	manifest_category_order = DEPT_MANIFEST_ORDER_COMMAND

	access_accountancy = list(ACCESS_CENT_CAPTAIN) // only centcom can change command payment
	budget_id = ACCOUNT_COM_ID
	budget_bitflag = ACCOUNT_COM_BITFLAG

// ---------------------------------------------------------------------
//                                SERVICE
// ---------------------------------------------------------------------
/datum/department_group/service
	dept_name = DEPT_NAME_SERVICE
	dept_id = DEPT_NAME_SERVICE
	dept_bitflag = DEPT_BITFLAG_SERVICE
	dept_colour = "#bbe291"
	dept_radio_channel = FREQ_SERVICE
	is_station = TRUE

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
				JOB_NAME_ASSISTANT,
				JOB_NAME_VIP)

	access_group_name = "General"
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(ACCESS_HOP)
	standard_access = list(ACCESS_KITCHEN,
							ACCESS_BAR,
							ACCESS_HYDROPONICS,
							ACCESS_JANITOR,
							ACCESS_CHAPEL_OFFICE,
							ACCESS_CREMATORIUM,
							ACCESS_LIBRARY,
							ACCESS_THEATRE,
							ACCESS_LAWYER)
	protected_access = list()

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_HOP)
	manifest_category_name = DEPT_NAME_SERVICE
	manifest_category_order = DEPT_MANIFEST_ORDER_SERVICE

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_HOP)
	budget_id = ACCOUNT_SRV_ID
	budget_bitflag = ACCOUNT_SRV_BITFLAG

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
	is_station = TRUE

	// pref_category (unusued)
	// pref_category_order (unusued)

	// job part
	// 		unusued - Reason: civilian jobs are stored in service department.

	// access part
	// 		unusued - Reason: civilian accesses are service access in fact

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_HOP)
	manifest_category_name = DEPT_NAME_CIVILIAN
	manifest_category_order = DEPT_MANIFEST_ORDER_CIVILIAN

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_HOP)
	budget_id = ACCOUNT_CIV_ID
	budget_bitflag = ACCOUNT_CIV_BITFLAG

// this will automatically follow service department data
/datum/department_group/civilian/New()
	var/datum/department_group/service_dept = SSdepartment.get_department_by_id(DEPT_NAME_SERVICE)
	dept_colour = service_dept.dept_colour
	dept_radio_channel = service_dept.dept_radio_channel

// ---------------------------------------------------------------------
//                               SUPPLY (CARGO)
// ---------------------------------------------------------------------
/datum/department_group/supply
	dept_name = DEPT_NAME_SUPPLY
	dept_id = DEPT_NAME_SUPPLY
	dept_bitflag = DEPT_BITFLAG_SUPPLY
	dept_colour = "#d7b088"
	dept_radio_channel = FREQ_SUPPLY
	is_station = TRUE

	pref_category_name = DEPT_NAME_SUPPLY
	pref_category_order = DEPT_PREF_ORDER_SUPPLY

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_QUARTERMASTER,
				JOB_NAME_CARGOTECHNICIAN,
				JOB_NAME_SHAFTMINER)


	access_group_name = "Supply"
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(ACCESS_HOP)
	standard_access = list(ACCESS_MAILSORTING,
							ACCESS_MINING,
							ACCESS_MINING_STATION,
							ACCESS_MECH_MINING,
							ACCESS_MINERAL_STOREROOM,
							ACCESS_CARGO,
							ACCESS_QM,
							ACCESS_VAULT)
	protected_access = list()

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_HOP)
	manifest_category_name = DEPT_NAME_SUPPLY
	manifest_category_order = DEPT_MANIFEST_ORDER_SUPPLY

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_HOP)
	budget_id = ACCOUNT_CAR_ID
	budget_bitflag = ACCOUNT_CAR_BITFLAG

// ---------------------------------------------------------------------
//                              SCIENCE
// ---------------------------------------------------------------------
/datum/department_group/science
	dept_name = DEPT_NAME_SCIENCE
	dept_id = DEPT_NAME_SCIENCE
	dept_bitflag = DEPT_BITFLAG_SCIENCE
	dept_colour = "#ffddff"
	dept_radio_channel = FREQ_SCIENCE
	is_station = TRUE

	pref_category_name = DEPT_NAME_SCIENCE
	pref_category_order = DEPT_PREF_ORDER_SCIENCE

	leaders = list(JOB_NAME_RESEARCHDIRECTOR)
	jobs = list(JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_SCIENTIST,
				JOB_NAME_EXPLORATIONCREW,
				JOB_NAME_ROBOTICIST)

	access_group_name = "Research"
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(ACCESS_RD)
	standard_access = list(ACCESS_RESEARCH,
							ACCESS_TOX,
							ACCESS_TOX_STORAGE,
							ACCESS_ROBOTICS,
							ACCESS_XENOBIOLOGY,
							ACCESS_EXPLORATION,
							ACCESS_MECH_SCIENCE,
							ACCESS_MINISAT,
							ACCESS_NETWORK,
							ACCESS_RD_SERVER,
							ACCESS_RD)
	protected_access = list()

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_RD)
	manifest_category_name = DEPT_NAME_SCIENCE
	manifest_category_order = DEPT_MANIFEST_ORDER_SCIENCE

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_RD)
	budget_id = ACCOUNT_SCI_ID
	budget_bitflag = ACCOUNT_SCI_BITFLAG

// ---------------------------------------------------------------------
//                            ENGINEERING
// ---------------------------------------------------------------------
/datum/department_group/engineering
	dept_name = DEPT_NAME_ENGINEERING
	dept_id = DEPT_NAME_ENGINEERING
	dept_bitflag = DEPT_BITFLAG_ENGINEERING
	dept_colour = "#ffeeaa"
	dept_radio_channel = FREQ_ENGINEERING
	is_station = TRUE

	pref_category_name = DEPT_NAME_ENGINEERING
	pref_category_order = DEPT_PREF_ORDER_ENGINEERING

	leaders = list(JOB_NAME_CHIEFENGINEER)
	jobs = list(JOB_NAME_CHIEFENGINEER,
				JOB_NAME_STATIONENGINEER,
				JOB_NAME_ATMOSPHERICTECHNICIAN)

	access_group_name = "Engineering"
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(ACCESS_CE)
	standard_access = list(ACCESS_CONSTRUCTION,
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

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_CE)
	manifest_category_name = DEPT_NAME_ENGINEERING
	manifest_category_order = DEPT_MANIFEST_ORDER_ENGINEERING

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_CE)
	budget_id = ACCOUNT_ENG_ID
	budget_bitflag = ACCOUNT_ENG_BITFLAG

// ---------------------------------------------------------------------
//                               MEDICAL
// ---------------------------------------------------------------------
/datum/department_group/medical
	dept_name = DEPT_NAME_MEDICAL
	dept_id = DEPT_NAME_MEDICAL
	dept_bitflag = DEPT_BITFLAG_MEDICAL
	dept_colour = "#c1e1ec"
	dept_radio_channel = FREQ_MEDICAL
	is_station = TRUE

	pref_category_name = DEPT_NAME_MEDICAL
	pref_category_order = DEPT_PREF_ORDER_MEDICAL

	leaders = list(JOB_NAME_CHIEFMEDICALOFFICER)
	jobs = list(JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_MEDICALDOCTOR,
				JOB_NAME_CHEMIST,
				JOB_NAME_GENETICIST,
				JOB_NAME_VIROLOGIST,
				JOB_NAME_PARAMEDIC,
				JOB_NAME_PSYCHIATRIST)

	access_group_name = "Medbay"
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(ACCESS_CMO)
	standard_access = list(ACCESS_MEDICAL,
							ACCESS_GENETICS,
							ACCESS_CLONING,
							ACCESS_MORGUE,
							ACCESS_CHEMISTRY,
							ACCESS_VIROLOGY,
							ACCESS_SURGERY,
							ACCESS_MECH_MEDICAL,
							ACCESS_CMO)
	protected_access = list()

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_CMO)
	manifest_category_name = DEPT_NAME_MEDICAL
	manifest_category_order = DEPT_MANIFEST_ORDER_MEDICAL

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_CMO)
	budget_id = ACCOUNT_MED_ID
	budget_bitflag = ACCOUNT_MED_BITFLAG

// ---------------------------------------------------------------------
//                               SECURITY
// ---------------------------------------------------------------------
/datum/department_group/security
	dept_name = DEPT_NAME_SECURITY
	dept_id = DEPT_NAME_SECURITY
	dept_bitflag = DEPT_BITFLAG_SECURITY
	dept_colour = "#ffdddd"
	dept_radio_channel = FREQ_SECURITY
	is_station = TRUE

	pref_category_name = DEPT_NAME_SECURITY
	pref_category_order = DEPT_PREF_ORDER_SECURITY

	leaders = list(JOB_NAME_HEADOFSECURITY)
	jobs = list(JOB_NAME_HEADOFSECURITY,
				JOB_NAME_WARDEN,
				JOB_NAME_DETECTIVE,
				JOB_NAME_SECURITYOFFICER,
				JOB_NAME_DEPUTY)

	access_group_name = "Security"
	access_dominant = list(ACCESS_CHANGE_IDS)
	access_supervisor = list(ACCESS_HOS)
	standard_access = list(ACCESS_SEC_DOORS,
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

	access_manifest_changer = list(ACCESS_CHANGE_IDS, ACCESS_HOS)
	manifest_category_name = DEPT_NAME_SECURITY
	manifest_category_order = DEPT_MANIFEST_ORDER_SECURITY

	access_accountancy = list(ACCESS_CHANGE_IDS, ACCESS_HOS)
	budget_id = ACCOUNT_SEC_ID
	budget_bitflag = ACCOUNT_SEC_BITFLAG

// ---------------------------------------------------------------------
//                              SILICON
//               Used for: job pref & roundjoin window
//                 (currently not for crew manifest)
// ---------------------------------------------------------------------
/datum/department_group/silicon
	dept_name = DEPT_NAME_SILICON
	dept_id = DEPT_NAME_SILICON
	dept_bitflag = DEPT_BITFLAG_SILICON
	dept_colour = "#ccffcc"
	// is_station = TRUE // It's station department, but silicon list... maybe not a good idea using this

	pref_category_name = DEPT_NAME_SILICON
	pref_category_order = DEPT_PREF_ORDER_SILICON

	leaders = list()
	jobs = list(JOB_NAME_AI,
				JOB_NAME_CYBORG)

	// currently not used
	manifest_category_name = DEPT_NAME_SILICON
	manifest_category_order = DEPT_MANIFEST_ORDER_SILICON

// ---------------------------------------------------------------------
//                               VIP
//                     Used for: crew manifest
// ---------------------------------------------------------------------
// in fact, nobody belongs here even VIPs don't because how system works. This is dummy department actually.
/datum/department_group/vip
	dept_name = DEPT_NAME_VIP
	dept_id = DEPT_NAME_VIP
	dept_bitflag = DEPT_BITFLAG_VIP

	access_manifest_changer = list(ACCESS_CENT_CAPTAIN)
	manifest_category_name = "Very Important People"
	manifest_category_order = DEPT_MANIFEST_ORDER_VIP

	access_accountancy = list(ACCESS_CENT_CAPTAIN)
	budget_id = ACCOUNT_VIP_ID
	budget_bitflag = ACCOUNT_VIP_BITFLAG

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

	access_group_name = "CentCom"
	access_dominant = list(ACCESS_CENT_CAPTAIN)
	standard_access = list(ACCESS_CENT_GENERAL,
							ACCESS_CENT_THUNDER,
							ACCESS_CENT_SPECOPS,
							ACCESS_CENT_MEDICAL,
							ACCESS_CENT_LIVING,
							ACCESS_CENT_STORAGE,
							ACCESS_CENT_TELEPORTER,
							ACCESS_CENT_BAR,
							ACCESS_CENT_CAPTAIN)

	access_manifest_changer = list(ACCESS_CENT_CAPTAIN)
	manifest_category_name = DEPT_NAME_CENTCOM
	manifest_category_order = DEPT_MANIFEST_ORDER_CENTCOM

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

	access_group_name = "Other (Non-CC)"
	access_dominant = list(ACCESS_CENT_CAPTAIN)
	standard_access = list(ACCESS_SYNDICATE,
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

	access_manifest_changer = list(ACCESS_CENT_CAPTAIN)
	manifest_category_name = DEPT_NAME_OTHER
	manifest_category_order = 1000
