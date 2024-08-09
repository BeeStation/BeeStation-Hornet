
SUBSYSTEM_DEF(department)
	name = "Departments"
	init_order = INIT_ORDER_DEPARTMENT
	flags = SS_NO_FIRE

	//
	var/list/department_id_list = list()
	var/list/department_type_list = list()
	var/list/department_by_key = list()
	var/list/sorted_department_for_manifest = list()
	var/list/sorted_department_for_pref = list()

	var/list/checker

	var/list/all_station_departments_list = list(
		DEPARTMENT_COMMAND,
		DEPARTMENT_CIVILIAN,
		DEPARTMENT_SERVICE,
		DEPARTMENT_CARGO,
		DEPARTMENT_SCIENCE,
		DEPARTMENT_ENGINEERING,
		DEPARTMENT_MEDICAL,
		DEPARTMENT_SECURITY,
		DEPARTMENT_VIP,
		DEPARTMENT_SILICON
	)

	// A list of each bitflag and the name of its associated department. For use in the preferences menu.
	var/list/department_bitflag_to_name = list()

	// A list of each department and its associated bitflag.
	var/list/departments = list()

	// department order and its dept color
	var/list/department_order = list()


/datum/controller/subsystem/department/Initialize(timeofday)
	for(var/datum/department_group/each_dept as() in subtypesof(/datum/department_group))
		each_dept = new each_dept()
		department_type_list += each_dept
		department_by_key[each_dept.dept_id] = each_dept
		department_id_list += each_dept.dept_id
		//To do: remind for #10933 Just in case: Blame EvilDragonFiend.
	// initialising static list inside of the procs
	get_departments_by_pref_order()
	get_departments_by_manifest_order()
	department_bitflag_to_name = list(
		"[DEPT_BITFLAG_CAPTAIN]" = "Captain",
		"[DEPT_BITFLAG_COM]" = "Command",
		"[DEPT_BITFLAG_CIV]" = "Civilian",
		"[DEPT_BITFLAG_SRV]" = "Service",
		"[DEPT_BITFLAG_CAR]" = "Cargo",
		"[DEPT_BITFLAG_SCI]" = "Science",
		"[DEPT_BITFLAG_ENG]" = "Engineering",
		"[DEPT_BITFLAG_MED]" = "Medical",
		"[DEPT_BITFLAG_SEC]" = "Security",
		"[DEPT_BITFLAG_VIP]" = "Very Important People",
		"[DEPT_BITFLAG_SILICON]" = "Silicon"
	)
	departments = list(
		"Command" = DEPT_BITFLAG_COM,
		"Very Important People" = DEPT_BITFLAG_VIP,
		"Security" = DEPT_BITFLAG_SEC,
		"Engineering" = DEPT_BITFLAG_ENG,
		"Medical" = DEPT_BITFLAG_MED,
		"Science" = DEPT_BITFLAG_SCI,
		"Supply" = DEPT_BITFLAG_CAR,
		"Cargo" = DEPT_BITFLAG_CAR,
		"Service" = DEPT_BITFLAG_SRV,
		"Civilian" = DEPT_BITFLAG_CIV,
		"Silicon" = DEPT_BITFLAG_SILICON
	)
	department_order = list(
		DEPARTMENT_COMMAND = "#ddddff",
		DEPARTMENT_VIP = "#999791",
		DEPARTMENT_SECURITY = "#ffdddd",
		DEPARTMENT_ENGINEERING = "#ffeeaa",
		DEPARTMENT_MEDICAL= "#c1e1ec",
		DEPARTMENT_SCIENCE = "#ffddff",
		DEPARTMENT_CARGO = "#d7b088",
		DEPARTMENT_SERVICE = "#bbe291",
		DEPARTMENT_CIVILIAN = "#bbe291",
		DEPARTMENT_SILICON = "#ccffcc"
	)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/department/proc/get_department_by_bitflag(bitflag)
	for(var/datum/department_group/each_dept in department_type_list)
		if(each_dept.dept_bitflag & bitflag)
			return each_dept
	CRASH("[bitflag] isn't an existing department bitflag.")

/datum/controller/subsystem/department/proc/get_department_by_dept_id(id)
	. = department_by_key[id]
	if(!.)
		CRASH("[id] isn't an existing department id.")
	return department_by_key[id]

/// WARNING: include_dispatch parameter is important. Avoid using it to security positions.
/datum/controller/subsystem/department/proc/get_jobs_by_dept_id(id_or_list)
	if(!id_or_list)
		stack_trace("proc has no id value")
		return list()

	if(!islist(id_or_list))
		id_or_list = list(id_or_list)
	else if(islist(id_or_list?[1]))
		CRASH("You did something wrong. Check if you did like 'list(list())'")

	var/list/jobs_to_return = list()
	for(var/each in id_or_list)
		var/datum/department_group/dept = department_by_key[each]
		if(!dept)
			message_admins("is not exist: [each]")
			continue
		if(!length(dept.jobs))
			continue
		jobs_to_return |= dept.jobs

	return jobs_to_return

/// returns the department list as manifest order
/datum/controller/subsystem/department/proc/get_departments_by_manifest_order()
	if(!length(sorted_department_for_manifest))
		var/list/copied_dept = department_type_list.Copy()
		var/sanity_check = 1000 // this won't happen but just in case
		while(length(copied_dept) && sanity_check--)
			var/datum/department_group/current
			for(var/datum/department_group/each_dept in copied_dept)
				if(!each_dept.manifest_category_order || !each_dept.manifest_category_name)
					copied_dept -= each_dept
					continue
				if(!current)
					current = each_dept
					continue
				if(each_dept.manifest_category_order < current.manifest_category_order)
					current = each_dept
					continue
			sorted_department_for_manifest += current
			copied_dept -= current
		if(!sanity_check)
			stack_trace("the proc reached 0 sanity check - something's causing the infinite loop.")
	return sorted_department_for_manifest

/// returns the department list as preference order (used in latejoin)
/datum/controller/subsystem/department/proc/get_departments_by_pref_order()
	if(!length(sorted_department_for_pref))
		var/list/copied_dept = department_type_list.Copy()
		var/sanity_check = 1000
		while(length(copied_dept) && sanity_check--)
			var/datum/department_group/current
			for(var/datum/department_group/each_dept in copied_dept)
				if(!each_dept.pref_category_order || !each_dept.pref_category_name)
					copied_dept -= each_dept
					continue
				if(!current)
					current = each_dept
					continue
				if(each_dept.pref_category_order < current.pref_category_order)
					current = each_dept
					continue
			sorted_department_for_pref += current
			copied_dept -= current
		if(!sanity_check)
			stack_trace("the proc reached 0 sanity check - something's causing the infinite loop.")
	return sorted_department_for_pref

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

	// job preference & roundjoin window
	var/pref_category_name = "No department"
	var/pref_category_order = 0

	// job related variables
	/// who's responsible of a department? (this is made as a list just in case)
	var/list/leaders = list()
	/// job list of people working in a department
	var/list/jobs = list()

	/// If you check crew manifest, department name will be displayed as this
	var/manifest_category_name = "No department"
	/// Crew manifest sort by low number (Command first)
	var/manifest_category_order = 0

// ---------------------------------------------------------------------
//                                COMMAND
// ---------------------------------------------------------------------
/datum/department_group/command
	dept_name = DEPARTMENT_COMMAND
	dept_id = DEPARTMENT_COMMAND
	dept_bitflag = DEPT_BITFLAG_COM
	dept_colour = "#ddddff"
	dept_radio_channel = FREQ_COMMAND
	is_station = TRUE

	pref_category_name = DEPARTMENT_COMMAND
	pref_category_order = DEPT_PREF_ORDER_COMMAND

	leaders = list(JOB_NAME_CAPTAIN)
	jobs = list(JOB_NAME_CAPTAIN,
				JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_CHIEFENGINEER,
				JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_HEADOFSECURITY)

	manifest_category_name = DEPARTMENT_COMMAND
	manifest_category_order = DEPT_MANIFEST_ORDER_COMMAND

// ---------------------------------------------------------------------
//                                SERVICE
// ---------------------------------------------------------------------
/datum/department_group/service
	dept_name = DEPARTMENT_SERVICE
	dept_id = DEPARTMENT_SERVICE
	dept_bitflag = DEPT_BITFLAG_SRV
	dept_colour = "#bbe291"
	dept_radio_channel = FREQ_SERVICE
	is_station = TRUE

	pref_category_name = DEPARTMENT_SERVICE
	pref_category_order = DEPT_PREF_ORDER_SERVICE

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_BARTENDER,
				JOB_NAME_BOTANIST,
				JOB_NAME_COOK,
				JOB_NAME_JANITOR,
				JOB_NAME_MIME,
				JOB_NAME_CLOWN)

	manifest_category_name = DEPARTMENT_SERVICE
	manifest_category_order = DEPT_MANIFEST_ORDER_SERVICE

// ---------------------------------------------------------------------
//                                CIVILIAN
// ---------------------------------------------------------------------
/datum/department_group/civilian
	dept_name = DEPARTMENT_CIVILIAN
	dept_id = DEPARTMENT_CIVILIAN
	dept_bitflag = DEPT_BITFLAG_CIV
	is_station = TRUE

	pref_category_name = DEPARTMENT_CIVILIAN
	pref_category_order = DEPT_PREF_ORDER_CIVILIAN

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_ASSISTANT,
				JOB_NAME_GIMMICK,
				JOB_NAME_BARBER,
				JOB_NAME_STAGEMAGICIAN,
				JOB_NAME_PSYCHIATRIST,
				JOB_NAME_VIP,
				JOB_NAME_CHAPLAIN,
				JOB_NAME_CURATOR,
				JOB_NAME_LAWYER)

	manifest_category_name = DEPARTMENT_CIVILIAN
	manifest_category_order = DEPT_MANIFEST_ORDER_CIVILIAN

// ---------------------------------------------------------------------
//                               SUPPLY (CARGO)
// ---------------------------------------------------------------------
/datum/department_group/cargo
	dept_name = DEPARTMENT_CARGO
	dept_id = DEPARTMENT_CARGO
	dept_bitflag = DEPT_BITFLAG_CAR
	dept_colour = "#d7b088"
	dept_radio_channel = FREQ_SUPPLY
	is_station = TRUE

	pref_category_name = DEPARTMENT_CARGO
	pref_category_order = DEPT_PREF_ORDER_CARGO

	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	jobs = list(JOB_NAME_HEADOFPERSONNEL,
				JOB_NAME_QUARTERMASTER,
				JOB_NAME_CARGOTECHNICIAN,
				JOB_NAME_SHAFTMINER)

	manifest_category_name = DEPARTMENT_CARGO
	manifest_category_order = DEPT_MANIFEST_ORDER_CARGO

// ---------------------------------------------------------------------
//                              SCIENCE
// ---------------------------------------------------------------------
/datum/department_group/science
	dept_name = DEPARTMENT_SCIENCE
	dept_id = DEPARTMENT_SCIENCE
	dept_bitflag = DEPT_BITFLAG_SCI
	dept_colour = "#ffddff"
	dept_radio_channel = FREQ_SCIENCE
	is_station = TRUE

	pref_category_name = DEPARTMENT_SCIENCE
	pref_category_order = DEPT_PREF_ORDER_SCIENCE

	leaders = list(JOB_NAME_RESEARCHDIRECTOR)
	jobs = list(JOB_NAME_RESEARCHDIRECTOR,
				JOB_NAME_SCIENTIST,
				JOB_NAME_EXPLORATIONCREW,
				JOB_NAME_ROBOTICIST)

	manifest_category_name = DEPARTMENT_SCIENCE
	manifest_category_order = DEPT_MANIFEST_ORDER_SCIENCE

// ---------------------------------------------------------------------
//                            ENGINEERING
// ---------------------------------------------------------------------
/datum/department_group/engineering
	dept_name = DEPARTMENT_ENGINEERING
	dept_id = DEPARTMENT_ENGINEERING
	dept_bitflag = DEPT_BITFLAG_ENG
	dept_colour = "#ffeeaa"
	dept_radio_channel = FREQ_ENGINEERING
	is_station = TRUE

	pref_category_name = DEPARTMENT_ENGINEERING
	pref_category_order = DEPT_PREF_ORDER_ENGINEERING

	leaders = list(JOB_NAME_CHIEFENGINEER)
	jobs = list(JOB_NAME_CHIEFENGINEER,
				JOB_NAME_STATIONENGINEER,
				JOB_NAME_ATMOSPHERICTECHNICIAN)



	manifest_category_name = DEPARTMENT_ENGINEERING
	manifest_category_order = DEPT_MANIFEST_ORDER_ENGINEERING

// ---------------------------------------------------------------------
//                               MEDICAL
// ---------------------------------------------------------------------
/datum/department_group/medical
	dept_name = DEPARTMENT_MEDICAL
	dept_id = DEPARTMENT_MEDICAL
	dept_bitflag = DEPT_BITFLAG_MED
	dept_colour = "#c1e1ec"
	dept_radio_channel = FREQ_MEDICAL
	is_station = TRUE

	pref_category_name = DEPARTMENT_MEDICAL
	pref_category_order = DEPT_PREF_ORDER_MEDICAL

	leaders = list(JOB_NAME_CHIEFMEDICALOFFICER)
	jobs = list(JOB_NAME_CHIEFMEDICALOFFICER,
				JOB_NAME_MEDICALDOCTOR,
				JOB_NAME_PARAMEDIC,
				JOB_NAME_BRIGPHYSICIAN,
				JOB_NAME_CHEMIST,
				JOB_NAME_GENETICIST,
				JOB_NAME_VIROLOGIST,
				JOB_NAME_PSYCHIATRIST)


	manifest_category_name = DEPARTMENT_MEDICAL
	manifest_category_order = DEPT_MANIFEST_ORDER_MEDICAL

// ---------------------------------------------------------------------
//                               SECURITY
// ---------------------------------------------------------------------
/datum/department_group/security
	dept_name = DEPARTMENT_SECURITY
	dept_id = DEPARTMENT_SECURITY
	dept_bitflag = DEPT_BITFLAG_SEC
	dept_colour = "#ffdddd"
	dept_radio_channel = FREQ_SECURITY
	is_station = TRUE

	pref_category_name = DEPARTMENT_SECURITY
	pref_category_order = DEPT_PREF_ORDER_SECURITY

	leaders = list(JOB_NAME_HEADOFSECURITY)
	jobs = list(JOB_NAME_HEADOFSECURITY,
				JOB_NAME_WARDEN,
				JOB_NAME_DETECTIVE,
				JOB_NAME_SECURITYOFFICER,
				JOB_NAME_DEPUTY)

	manifest_category_name = DEPARTMENT_SECURITY
	manifest_category_order = DEPT_MANIFEST_ORDER_SECURITY

// ---------------------------------------------------------------------
//                               VIP
//                     Used for: crew manifest
// ---------------------------------------------------------------------
// in fact, nobody belongs here even VIPs don't because how system works. This is dummy department actually.
/datum/department_group/vip
	dept_name = DEPARTMENT_VIP
	dept_id = DEPARTMENT_VIP
	dept_bitflag = DEPT_BITFLAG_VIP

	manifest_category_name = "Very Important People"
	manifest_category_order = DEPT_MANIFEST_ORDER_VIP

// ---------------------------------------------------------------------
//                              SILICON
//               Used for: job pref & roundjoin window
//                 (currently not for crew manifest)
// ---------------------------------------------------------------------
/datum/department_group/silicon
	dept_name = DEPARTMENT_SILICON
	dept_id = DEPARTMENT_SILICON
	dept_bitflag = DEPT_BITFLAG_SILICON
	dept_colour = "#ccffcc"
	// is_station = TRUE // It's station department, but silicon list... maybe not a good idea using this

	pref_category_name = DEPARTMENT_SILICON
	pref_category_order = DEPT_PREF_ORDER_SILICON

	leaders = list()
	jobs = list(JOB_NAME_AI,
				JOB_NAME_CYBORG)

	// currently not used
	manifest_category_name = DEPARTMENT_SILICON
	manifest_category_order = DEPT_MANIFEST_ORDER_SILICON

// ---------------------------------------------------------------------
//                           CentCom
//     Used for: access sorting (mainly), cerw manifest (admin gimmick)
// ---------------------------------------------------------------------
/datum/department_group/centcom
	dept_name = DEPARTMENT_CENTCOM
	dept_id = DEPARTMENT_CENTCOM
	dept_bitflag = DEPT_BITFLAG_CENTCOM
	dept_colour = "#00eba4"
	dept_radio_channel = FREQ_CENTCOM

	manifest_category_name = DEPARTMENT_CENTCOM
	manifest_category_order = DEPT_MANIFEST_ORDER_CENTCOM

// ---------------------------------------------------------------------
//                   Others (syndicate, cult, away, etc)
//     Used for: access sorting (mainly), cerw manifest (admin gimmick)
// ---------------------------------------------------------------------
/datum/department_group/other
	dept_name = DEPARTMENT_OTHER
	dept_id = DEPARTMENT_OTHER
	dept_bitflag = DEPT_BITFLAG_OTHER
	dept_colour = "#00eba4"
	dept_radio_channel = FREQ_CENTCOM

	manifest_category_name = DEPARTMENT_OTHER
	manifest_category_order = 1000
