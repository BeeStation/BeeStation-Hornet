
SUBSYSTEM_DEF(department)
	name = "Departments"
	init_stage = INITSTAGE_EARLY
	flags = SS_NO_FIRE

	/// full list of department datums.
	var/list/department_datums
	/// assoc list of department datums by its department name(dept_id). The list may not have full departments of ingame.
	var/list/department_assoc


	/// department datums in a 'crew manifest' priority order. Only used for crew manifest window.
	var/list/sorted_department_for_manifest
	/// department datums in a 'job pref' priority order in character selection.
	var/list/sorted_department_for_latejoin
	/// department datums in access manipulation - actually manual sort
	var/list/sorted_department_for_access = list(
		DEPT_NAME_SERVICE,
		DEPT_NAME_CIVILIAN,
		DEPT_NAME_CARGO,
		DEPT_NAME_MEDICAL,
		DEPT_NAME_SCIENCE,
		DEPT_NAME_ENGINEERING,
		DEPT_NAME_SECURITY,
		DEPT_NAME_COMMAND,
		DEPT_NAME_CENTCOM,
		DEPT_NAME_OTHER,
	)

/datum/controller/subsystem/department/Initialize(timeofday)
	department_datums = list()
	department_assoc = list()

	for(var/datum/department_group/each_dept as anything in subtypesof(/datum/department_group))
		each_dept = new each_dept()

		department_datums += each_dept
		if(each_dept.dept_id)
			department_assoc[each_dept.dept_id] = each_dept

	var/datum/department_group/dummy_datum
	dummy_datum = dummy_datum // be gone compile warning
	sorted_department_for_manifest = list()
	sorted_department_for_latejoin = list()
	init_and_sort_department(sorted_department_for_manifest, NAMEOF(dummy_datum, manifest_category_order))
	init_and_sort_department(sorted_department_for_latejoin, NAMEOF(dummy_datum, pref_category_order))

	var/list/temp = sorted_department_for_access
	sorted_department_for_access = list()
	for(var/each_dept in temp)
		sorted_department_for_access |= department_assoc[each_dept]

	// I don't like this here, but this globallist can't take proper values on its declaration.
	GLOB.exp_jobsmap = list(
		EXP_TYPE_CREW = 	get_all_jobs(),
		EXP_TYPE_COMMAND = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND),
		EXP_TYPE_ENGINEERING = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING),
		EXP_TYPE_MEDICAL = 	SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL),
		EXP_TYPE_SCIENCE = 	SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE),
		EXP_TYPE_SUPPLY = 	SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO),
		EXP_TYPE_SECURITY = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY),
		EXP_TYPE_SERVICE = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SERVICE),
		EXP_TYPE_SILICON = 	SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON)
	)

	return SS_INIT_SUCCESS

/// Puts department datums into a list in a desired sort priority. Only called once in subsystem Initialize.
/// * list_instance<list>: takes a list instance, to initialize and sort departments into this list
/// * priority_varname<string/NAMEOF>: a hacky one since sorting code does the same thing.
/datum/controller/subsystem/department/proc/init_and_sort_department(list/list_instance, priority_varname)
	if(isnull(list_instance))
		CRASH("'list_instance' does not exist: target_var [priority_varname]")
	if(!islist(list_instance))
		CRASH("'list_instance' is not a list: target_var [priority_varname]")
	if(!priority_varname || !length(priority_varname))
		CRASH("something's wrong to init department: target_var [priority_varname]")

	var/list/_department_datums_to_sort = department_datums.Copy()
	var/sanity_check = 1000
	while(length(_department_datums_to_sort) && sanity_check--)
		if(!sanity_check)
			CRASH("the proc reached 0 sanity check - something's causing the infinite loop.")

		var/datum/department_group/current
		for(var/datum/department_group/each_dept in _department_datums_to_sort)
			if(!each_dept.vars[priority_varname])
				_department_datums_to_sort -= each_dept
				continue
			if(!current)
				current = each_dept
				continue
			if(each_dept.vars[priority_varname] < current.vars[priority_varname])
				current = each_dept
				continue
		list_instance += current
		_department_datums_to_sort -= current

/// WARNING: This always returns as a list.
/// If your bitflag only gets a single department, it will return as a list.
/datum/controller/subsystem/department/proc/get_department_by_bitflag(bitflag)
	RETURN_TYPE(/list)
	var/return_result = list()
	. = return_result

	for(var/datum/department_group/each_dept in department_datums)
		if(each_dept.dept_bitflag & bitflag)
			. += each_dept

	return return_result

/datum/controller/subsystem/department/proc/get_department_by_dept_id(id)
	. = department_assoc[id]
	if(!.)
		CRASH("[id] isn't an existing department id.")
	return department_assoc[id]

/datum/controller/subsystem/department/proc/get_jobs_by_dept_id(id_or_list)
	if(!id_or_list)
		stack_trace("proc has no id value")
		return list()

	if(istext(id_or_list))
		var/datum/department_group/dept = department_assoc[id_or_list]
		return dept.jobs

	if(!islist(id_or_list))
		id_or_list = list(id_or_list)
	else if(islist(id_or_list?[1]))
		CRASH("You did something wrong. Check if you did like 'list(list())'")

	var/list/jobs_to_return = list()
	for(var/each in id_or_list)
		var/datum/department_group/dept = department_assoc[each]
		if(!dept)
			message_admins("is not exist: [each]")
			continue
		if(!length(dept.jobs))
			continue
		jobs_to_return |= dept.jobs

	return jobs_to_return

// --------------------------------------------
// department group datums for this subsystem
/datum/department_group
	// basic variables
	var/dept_name = "No department"
	var/dept_id = NONE
	var/dept_bitflag = null
	var/dept_colour = null
	var/dept_radio_channel = null
	var/is_station = FALSE

	// job related variables
	/// who's responsible of a department? (this is made as a list just in case)
	var/list/leaders = list()
	/// job list of people working in a department
	var/list/jobs = list()


	/// Group name of the access list
	var/access_group_name = "Unknown"
	/// list of access that belongs to this department
	var/list/access_list = list()
	/// if TRUE, restricts CentCom only
	var/access_filter

	/// Alternative department name in latejoin job selection window
	/// dept_name variable will be used if this variable has no value
	var/pref_category_name
	/// Latejoin department sort by low number (Command first)
	var/pref_category_order = 0

	/// Alternative department name in crew manifest.
	/// dept_name variable will be used if this variable has no value
	var/manifest_category_name
	/// Crew manifest sort by low number (Command first)
	var/manifest_category_order = 0

/datum/department_group/New()
	. = ..()
	if(dept_name)
		if(isnull(pref_category_name))
			pref_category_name = dept_name
		if(isnull(manifest_category_name))
			manifest_category_name = dept_name

// ---------------------------------------------------------------------
//                                COMMAND
// ---------------------------------------------------------------------
/datum/department_group/command
	dept_name = DEPT_NAME_COMMAND
	dept_id = DEPT_NAME_COMMAND
	dept_bitflag = DEPT_BITFLAG_COM
	dept_colour = "#ddddff"
	dept_radio_channel = FREQ_COMMAND
	is_station = TRUE

	leaders = list(JOB_NAME_CAPTAIN)
	jobs = list(JOB_NAME_CAPTAIN,
				JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_CHIEFENGINEER,
				JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_HEADOFSECURITY,
				)

	access_group_name = "Command"
	access_list = list(
		ACCESS_HEADS,
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
		ACCESS_VAULT,
	)

	pref_category_name = DEPT_NAME_COMMAND
	pref_category_order = DEPT_PREF_ORDER_COMMAND

	manifest_category_name = DEPT_NAME_COMMAND
	manifest_category_order = DEPT_MANIFEST_ORDER_COMMAND

// ---------------------------------------------------------------------
//                                SERVICE
// ---------------------------------------------------------------------
/datum/department_group/service
	dept_name = DEPT_NAME_SERVICE
	dept_id = DEPT_NAME_SERVICE
	dept_bitflag = DEPT_BITFLAG_SRV
	dept_colour = "#bbe291"
	dept_radio_channel = FREQ_SERVICE
	is_station = TRUE

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_BARTENDER,
				JOB_NAME_BOTANIST,
				JOB_NAME_COOK,
				JOB_NAME_JANITOR,
				JOB_NAME_MIME,
				JOB_NAME_CLOWN,
				JOB_NAME_STAGEMAGICIAN,
				)

	access_group_name = "General"
	// actually station general list
	access_list = list(
		ACCESS_KITCHEN,
		ACCESS_BAR,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CREMATORIUM,
		ACCESS_LIBRARY,
		ACCESS_THEATRE,
		ACCESS_LAWYER,
		ACCESS_SERVICE,
	)


	pref_category_name = DEPT_NAME_SERVICE
	pref_category_order = DEPT_PREF_ORDER_SERVICE

	manifest_category_name = DEPT_NAME_SERVICE
	manifest_category_order = DEPT_MANIFEST_ORDER_SERVICE

// ---------------------------------------------------------------------
//                                CIVILIAN
// ---------------------------------------------------------------------
/datum/department_group/civilian
	dept_name = DEPT_NAME_CIVILIAN
	dept_id = DEPT_NAME_CIVILIAN
	dept_bitflag = DEPT_BITFLAG_CIV
	dept_colour = "#bbe291"
	is_station = TRUE

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_ASSISTANT,
				JOB_NAME_GIMMICK,
				JOB_NAME_BARBER,
				JOB_NAME_VIP,
				JOB_NAME_CHAPLAIN,
				JOB_NAME_CURATOR,
				JOB_NAME_LAWYER,
				JOB_NAME_PRISONER,
				)

	access_group_name = "Residential" // in case when it's used
	// access_list = list() // check service

	pref_category_name = DEPT_NAME_CIVILIAN
	pref_category_order = DEPT_PREF_ORDER_CIVILIAN

	manifest_category_name = DEPT_NAME_CIVILIAN
	manifest_category_order = DEPT_MANIFEST_ORDER_CIVILIAN

// ---------------------------------------------------------------------
//                               SUPPLY (CARGO)
// ---------------------------------------------------------------------
/datum/department_group/cargo
	dept_name = DEPT_NAME_CARGO
	dept_id = DEPT_NAME_CARGO
	dept_bitflag = DEPT_BITFLAG_CAR
	dept_colour = "#d7b088"
	dept_radio_channel = FREQ_SUPPLY
	is_station = TRUE

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_QUARTERMASTER,
				JOB_NAME_CARGOTECHNICIAN,
				JOB_NAME_SHAFTMINER,
				)

	access_group_name = "Supply"
	access_list = list(
		ACCESS_MAILSORTING,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_CARGO,
		ACCESS_QM,
		ACCESS_VAULT,
	)


	pref_category_name = DEPT_NAME_CARGO
	pref_category_order = DEPT_PREF_ORDER_CARGO

	manifest_category_name = DEPT_NAME_CARGO
	manifest_category_order = DEPT_MANIFEST_ORDER_CARGO

// ---------------------------------------------------------------------
//                              SCIENCE
// ---------------------------------------------------------------------
/datum/department_group/science
	dept_name = DEPT_NAME_SCIENCE
	dept_id = DEPT_NAME_SCIENCE
	dept_bitflag = DEPT_BITFLAG_SCI
	dept_colour = "#ffddff"
	dept_radio_channel = FREQ_SCIENCE
	is_station = TRUE

	leaders = list(JOB_NAME_RESEARCHDIRECTOR)
	jobs = list(JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_SCIENTIST,
				JOB_NAME_EXPLORATIONCREW,
				JOB_NAME_ROBOTICIST,
				)

	access_group_name = "Research"
	access_list = list(
		ACCESS_RESEARCH,
		ACCESS_TOX,
		ACCESS_TOX_STORAGE,
		ACCESS_ROBOTICS,
		ACCESS_XENOBIOLOGY,
		ACCESS_EXPLORATION,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINISAT,
		ACCESS_RD,
		ACCESS_NETWORK,
		ACCESS_RD_SERVER,
	)

	pref_category_name = DEPT_NAME_SCIENCE
	pref_category_order = DEPT_PREF_ORDER_SCIENCE

	manifest_category_name = DEPT_NAME_SCIENCE
	manifest_category_order = DEPT_MANIFEST_ORDER_SCIENCE

// ---------------------------------------------------------------------
//                            ENGINEERING
// ---------------------------------------------------------------------
/datum/department_group/engineering
	dept_name = DEPT_NAME_ENGINEERING
	dept_id = DEPT_NAME_ENGINEERING
	dept_bitflag = DEPT_BITFLAG_ENG
	dept_colour = "#ffeeaa"
	dept_radio_channel = FREQ_ENGINEERING
	is_station = TRUE

	leaders = list(JOB_NAME_CHIEFENGINEER)
	jobs = list(JOB_NAME_CHIEFENGINEER,
				JOB_NAME_STATIONENGINEER,
				JOB_NAME_ATMOSPHERICTECHNICIAN,
				)

	access_group_name = "Engineering"
	access_list = list(
		ACCESS_CONSTRUCTION,
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
		ACCESS_CE,
	)

	pref_category_name = DEPT_NAME_ENGINEERING
	pref_category_order = DEPT_PREF_ORDER_ENGINEERING

	manifest_category_name = DEPT_NAME_ENGINEERING
	manifest_category_order = DEPT_MANIFEST_ORDER_ENGINEERING

// ---------------------------------------------------------------------
//                               MEDICAL
// ---------------------------------------------------------------------
/datum/department_group/medical
	dept_name = DEPT_NAME_MEDICAL
	dept_id = DEPT_NAME_MEDICAL
	dept_bitflag = DEPT_BITFLAG_MED
	dept_colour = "#c1e1ec"
	dept_radio_channel = FREQ_MEDICAL
	is_station = TRUE

	leaders = list(JOB_NAME_CHIEFMEDICALOFFICER)
	jobs = list(JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_MEDICALDOCTOR,
				JOB_NAME_PARAMEDIC,
				JOB_NAME_CHEMIST,
				JOB_NAME_GENETICIST,
				JOB_NAME_VIROLOGIST,
				JOB_NAME_PSYCHIATRIST,
				)

	access_group_name = "Medbay"
	access_list = list(
		ACCESS_MEDICAL,
		ACCESS_GENETICS,
		ACCESS_CLONING,
		ACCESS_MORGUE,
		ACCESS_CHEMISTRY,
		ACCESS_VIROLOGY,
		ACCESS_SURGERY,
		ACCESS_MECH_MEDICAL,
		ACCESS_CMO,
	)

	pref_category_name = DEPT_NAME_MEDICAL
	pref_category_order = DEPT_PREF_ORDER_MEDICAL

	manifest_category_name = DEPT_NAME_MEDICAL
	manifest_category_order = DEPT_MANIFEST_ORDER_MEDICAL

// ---------------------------------------------------------------------
//                               SECURITY
// ---------------------------------------------------------------------
/datum/department_group/security
	dept_name = DEPT_NAME_SECURITY
	dept_id = DEPT_NAME_SECURITY
	dept_bitflag = DEPT_BITFLAG_SEC
	dept_colour = "#ffdddd"
	dept_radio_channel = FREQ_SECURITY
	is_station = TRUE

	leaders = list(JOB_NAME_HEADOFSECURITY)
	jobs = list(JOB_NAME_HEADOFSECURITY,
				JOB_NAME_WARDEN,
				JOB_NAME_DETECTIVE,
				JOB_NAME_SECURITYOFFICER,
				JOB_NAME_BRIGPHYSICIAN,
				JOB_NAME_DEPUTY,
				)

	access_group_name = "Security"
	access_list = list(
		ACCESS_SEC_DOORS,
		ACCESS_SEC_RECORDS,
		ACCESS_WEAPONS,
		ACCESS_SECURITY,
		ACCESS_BRIG,
		ACCESS_BRIGPHYS,
		ACCESS_ARMORY,
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_HOS,
	)

	pref_category_name = DEPT_NAME_SECURITY
	pref_category_order = DEPT_PREF_ORDER_SECURITY

	manifest_category_name = DEPT_NAME_SECURITY
	manifest_category_order = DEPT_MANIFEST_ORDER_SECURITY

// ---------------------------------------------------------------------
//                               VIP
//                     Used for: crew manifest
// ---------------------------------------------------------------------
// in fact, nobody belongs here even VIPs don't because how system works. This is dummy department actually.
/datum/department_group/vip
	dept_name = DEPT_NAME_VIP
	dept_id = DEPT_NAME_VIP
	dept_bitflag = DEPT_BITFLAG_VIP

	manifest_category_name = "Very Important People"
	manifest_category_order = DEPT_MANIFEST_ORDER_VIP

// ---------------------------------------------------------------------
//                            Unassigned
//                     Used for: crew manifest
// ---------------------------------------------------------------------
// This is a dummy department for crew manifest of people who have no department assigned
/datum/department_group/unassigned
	dept_name = DEPT_NAME_UNASSIGNED
	dept_id = DEPT_NAME_UNASSIGNED

	manifest_category_name = DEPT_NAME_UNASSIGNED
	manifest_category_order = DEPT_MANIFEST_ORDER_UNASSIGNED

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

	leaders = list()
	jobs = list(JOB_NAME_AI,
				JOB_NAME_CYBORG)

	pref_category_name = DEPT_NAME_SILICON
	pref_category_order = DEPT_PREF_ORDER_SILICON

	// currently not used, but just in case
	manifest_category_name = DEPT_NAME_SILICON
	manifest_category_order = DEPT_MANIFEST_ORDER_SILICON

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
	access_list = list(
		ACCESS_CENT_GENERAL,
		ACCESS_CENT_THUNDER,
		ACCESS_CENT_SPECOPS,
		ACCESS_CENT_MEDICAL,
		ACCESS_CENT_LIVING,
		ACCESS_CENT_STORAGE,
		ACCESS_CENT_TELEPORTER,
		ACCESS_CENT_CAPTAIN,
		ACCESS_CENT_BAR,
		ACCESS_PRISONER,
	)
	access_filter = TRUE // CentCom Only

	// currently not used, but just in case
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

	access_group_name = "??? (Admin)"
	access_list = list(
		ACCESS_SYNDICATE,
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
		ACCESS_CLOCKCULT,
	)
	access_filter = TRUE // CentCom Only

	// currently not used, but just in case
	manifest_category_name = DEPT_NAME_OTHER
	manifest_category_order = 1000
