GLOBAL_LIST_INIT(command_positions, list(
	JOB_KEY_CAPTAIN,
	JOB_KEY_HEADOFPERSONNEL,
	JOB_KEY_HEADOFSECURITY,
	JOB_KEY_CHIEFENGINEER,
	JOB_KEY_RESEARCHDIRECTOR,
	JOB_KEY_CHIEFMEDICALOFFICER))


GLOBAL_LIST_INIT(engineering_positions, list(
	JOB_KEY_CHIEFENGINEER,
	JOB_KEY_STATIONENGINEER,
	JOB_KEY_ATMOSPHERICTECHNICIAN))


GLOBAL_LIST_INIT(medical_positions, list(
	JOB_KEY_CHIEFMEDICALOFFICER,
	JOB_KEY_MEDICALDOCTOR,
	JOB_KEY_GENETICIST,
	JOB_KEY_VIROLOGIST,
	JOB_KEY_PARAMEDIC,
	JOB_KEY_CHEMIST,
	JOB_KEY_BRIGPHYSICIAN,
	JOB_KEY_PSYCHIATRIST))


GLOBAL_LIST_INIT(science_positions, list(
	JOB_KEY_RESEARCHDIRECTOR,
	JOB_KEY_SCIENTIST,
	JOB_KEY_EXPLORATIONCREW,
	JOB_KEY_ROBOTICIST))


GLOBAL_LIST_INIT(supply_positions, list(
	JOB_KEY_HEADOFPERSONNEL,
	JOB_KEY_QUARTERMASTER,
	JOB_KEY_CARGOTECHNICIAN,
	JOB_KEY_SHAFTMINER))


GLOBAL_LIST_INIT(civilian_positions, list(
	JOB_KEY_HEADOFPERSONNEL,
	JOB_KEY_BARTENDER,
	JOB_KEY_BOTANIST,
	JOB_KEY_COOK,
	JOB_KEY_JANITOR,
	JOB_KEY_LAWYER,
	JOB_KEY_CURATOR,
	JOB_KEY_CHAPLAIN,
	JOB_KEY_MIME,
	JOB_KEY_CLOWN,
	JOB_KEY_STAGEMAGICIAN,
	JOB_KEY_BARBER,
	JOB_KEY_VIP,
	JOB_KEY_ASSISTANT))

GLOBAL_LIST_INIT(security_positions, list(
	JOB_KEY_HEADOFSECURITY,
	JOB_KEY_WARDEN,
	JOB_KEY_DETECTIVE,
	JOB_KEY_SECURITYOFFICER,
	JOB_KEY_DEPUTY))


GLOBAL_LIST_INIT(nonhuman_positions, list(
	JOB_KEY_AI,
	JOB_KEY_CYBORG))



// Note: ghost/living time is hardcoded in `job_report.dm`
GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_CREW = list("titles" = command_positions | engineering_positions | medical_positions | science_positions | supply_positions | security_positions | civilian_positions | nonhuman_positions), // crew positions
	EXP_TYPE_COMMAND = list("titles" = command_positions),
	EXP_TYPE_ENGINEERING = list("titles" = engineering_positions),
	EXP_TYPE_MEDICAL = list("titles" = medical_positions),
	EXP_TYPE_SCIENCE = list("titles" = science_positions),
	EXP_TYPE_SUPPLY = list("titles" = supply_positions),
	EXP_TYPE_SECURITY = list("titles" = security_positions),
	EXP_TYPE_SILICON = list("titles" = nonhuman_positions), // except for pai
	EXP_TYPE_SERVICE = list("titles" = civilian_positions),
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_ANTAG = GLOB.roundstart_antag_prefs|GLOB.midround_antag_list|list(ROLE_KEY_VALENTINE_HATER), // some roles should be added manually
	EXP_TYPE_SPECIAL = GLOB.ghost_special_roles__spawnable|GLOB.ghost_special_roles__notifying|list(ROLE_KEY_MENTOR_RAT),
	EXP_TYPE_DEPRECATED = list(
		"Lavaland Syndicate", // renamed as ROLE_KEY_EXT_SYNDI_AGENT
		"Ash Walker",        // renamed as "Ashwalker Lizard"
		"Translocated Vet",  // renamed as "Translocated Veterinarian" (ROLE_KEY_LAVALAND_DOCTOR)
		"Space Syndicate",   // deprecated
		"Hotel Staff",       // no point to be a main role. it's still used, but it's bad.
		"Space Bar Patron",  // same above
		"Space Bartender",   // same above
		"Skeleton",          // merged into ROLE_KEY_UNDEAD
		"Zombie",            // merged into ROLE_KEY_UNDEAD
		"Servant Golem",     // merged into ROLE_KEY_GOLEM
		"Free Golem",        // merged into ROLE_KEY_GOLEM
		"Ancient Crew",      // used nowhere...? or merged into ROLE_KEY_MAROONED_CREW
		"Hermit",            // Merged into ROLE_KEY_MAROONED_CREW
		"Space Doctor",      // used nowhere
		"Escaped Prisoner",  // used nowhere
		"SuperFriend",       // deprecated
		"Exile",             // deprecated
		"Ghost Role"         // deprecated
	),
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)

/proc/get_full_job_name(job)
	var/static/regex/cap_expand = new("cap(?!tain)")
	var/static/regex/cmo_expand = new("cmo")
	var/static/regex/hos_expand = new("hos")
	var/static/regex/hop_expand = new("hop")
	var/static/regex/rd_expand = new("rd")
	var/static/regex/ce_expand = new("ce")
	var/static/regex/qm_expand = new("qm")
	var/static/regex/sec_expand = new("(?<!security )officer")
	var/static/regex/engi_expand = new("(?<!station )engineer")
	var/static/regex/atmos_expand = new("atmos tech")
	var/static/regex/doc_expand = new("(?<!medical )doctor|medic(?!al)")
	var/static/regex/mine_expand = new("(?<!shaft )miner")
	var/static/regex/chef_expand = new("chef")
	var/static/regex/borg_expand = new("(?<!cy)borg")

	job = lowertext(job)
	job = cap_expand.Replace(job, "captain")
	job = cmo_expand.Replace(job, "chief medical officer")
	job = hos_expand.Replace(job, "head of security")
	job = hop_expand.Replace(job, "head of personnel")
	job = rd_expand.Replace(job, "research director")
	job = ce_expand.Replace(job, "chief engineer")
	job = qm_expand.Replace(job, "quartermaster")
	job = sec_expand.Replace(job, "security officer")
	job = engi_expand.Replace(job, "station engineer")
	job = atmos_expand.Replace(job, "atmospheric technician")
	job = doc_expand.Replace(job, "medical doctor")
	job = mine_expand.Replace(job, "shaft miner")
	job = chef_expand.Replace(job, "cook")
	job = borg_expand.Replace(job, "cyborg")
	return job
