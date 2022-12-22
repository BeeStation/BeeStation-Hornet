GLOBAL_LIST_INIT(command_positions, list(
	JOB_PATH_CAPTAIN,
	JOB_PATH_HEADOFPERSONNEL,
	JOB_PATH_HEADOFSECURITY,
	JOB_PATH_CHIEFENGINEER,
	JOB_PATH_RESEARCHDIRECTOR,
	JOB_PATH_CHIEFMEDICALOFFICER))


GLOBAL_LIST_INIT(engineering_positions, list(
	JOB_PATH_CHIEFENGINEER,
	JOB_PATH_STATIONENGINEER,
	JOB_PATH_ATMOSPHERICTECHNICIAN))


GLOBAL_LIST_INIT(medical_positions, list(
	JOB_PATH_CHIEFMEDICALOFFICER,
	JOB_PATH_MEDICALDOCTOR,
	JOB_PATH_GENETICIST,
	JOB_PATH_VIROLOGIST,
	JOB_PATH_PARAMEDIC,
	JOB_PATH_CHEMIST,
	JOB_PATH_BRIGPHYSICIAN,
	JOB_PATH_PSYCHIATRIST))


GLOBAL_LIST_INIT(science_positions, list(
	JOB_PATH_RESEARCHDIRECTOR,
	JOB_PATH_SCIENTIST,
	JOB_PATH_EXPLORATIONCREW,
	JOB_PATH_ROBOTICIST))


GLOBAL_LIST_INIT(supply_positions, list(
	JOB_PATH_HEADOFPERSONNEL,
	JOB_PATH_QUARTERMASTER,
	JOB_PATH_CARGOTECHNICIAN,
	JOB_PATH_SHAFTMINER))


GLOBAL_LIST_INIT(civilian_positions, list(
	JOB_PATH_HEADOFPERSONNEL,
	JOB_PATH_BARTENDER,
	JOB_PATH_BOTANIST,
	JOB_PATH_COOK,
	JOB_PATH_JANITOR,
	JOB_PATH_LAWYER,
	JOB_PATH_CURATOR,
	JOB_PATH_CHAPLAIN,
	JOB_PATH_MIME,
	JOB_PATH_CLOWN,
	JOB_PATH_STAGEMAGICIAN,
	JOB_PATH_VIP,
	JOB_PATH_ASSISTANT))

GLOBAL_LIST_INIT(security_positions, list(
	JOB_PATH_HEADOFSECURITY,
	JOB_PATH_WARDEN,
	JOB_PATH_DETECTIVE,
	JOB_PATH_SECURITYOFFICER,
	JOB_PATH_DEPUTY))


GLOBAL_LIST_INIT(nonhuman_positions, list(
	JOB_PATH_AI,
	JOB_PATH_CYBORG,
	JOB_PATH_PAI))



GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_CREW = list("titles" = command_positions | engineering_positions | medical_positions | science_positions | supply_positions | security_positions | civilian_positions | list(JOB_PATH_AI,JOB_PATH_CYBORG)), // crew positions
	EXP_TYPE_COMMAND = list("titles" = command_positions),
	EXP_TYPE_ENGINEERING = list("titles" = engineering_positions),
	EXP_TYPE_MEDICAL = list("titles" = medical_positions),
	EXP_TYPE_SCIENCE = list("titles" = science_positions),
	EXP_TYPE_SUPPLY = list("titles" = supply_positions),
	EXP_TYPE_SECURITY = list("titles" = security_positions),
	EXP_TYPE_SILICON = list("titles" = list(JOB_PATH_AI,JOB_PATH_CYBORG)), // except for pai
	EXP_TYPE_SERVICE = list("titles" = civilian_positions),
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_SPECIAL = list("Lifebringer","Ash Walker","Exile","Servant Golem","Free Golem","Hermit","Translocated Vet","Escaped Prisoner","Hotel Staff","SuperFriend","Space Syndicate","Ancient Crew","Space Doctor","Space Bartender","Beach Bum","Skeleton","Zombie","Space Bar Patron","Lavaland Syndicate",JOB_NAME_PAI,"Ghost Role"), // Ghost roles
	EXP_TYPE_GHOST = list() // dead people, observers
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
