GLOBAL_LIST_INIT(command_lightup_areas, typecacheof(list(
	/area/station/command,
	/area/station/command/gateway,
	/area/station/security/brig,
	/area/station/command/teleporter
)))

GLOBAL_LIST_INIT(engineering_lightup_areas, zebra_typecacheof(list(
	/area/station/construction = TRUE,
	/area/station/engineering = TRUE,
	/area/station/security/checkpoint/engineering = TRUE,
	/area/station/solars = TRUE,
	/area/station/tcommsat = TRUE,
	/area/station/commons/vacant_room = TRUE,
	/area/station/engineering/atmos = FALSE,
	/area/station/engineering/gravity_generator = FALSE,
)))

GLOBAL_LIST_INIT(medical_lightup_areas, zebra_typecacheof(list(
	/area/station/medical = TRUE,
	/area/station/security/checkpoint/medical = TRUE,
	/area/station/medical/abandoned = FALSE,
	/area/station/medical/pharmacy = FALSE,
	/area/station/medical/chemistry = FALSE,
	/area/station/medical/genetics = FALSE,
	/area/station/medical/morgue = FALSE,
	/area/station/medical/surgery = FALSE,
	/area/station/medical/virology = FALSE,
)))

GLOBAL_LIST_INIT(science_lightup_areas, zebra_typecacheof(list(
	/area/station/science = TRUE,
	/area/station/security/checkpoint/science = TRUE,
	/area/station/science/explab = FALSE,
	/area/station/science/misc_lab = FALSE,
	/area/station/science/mixing = FALSE,
	/area/station/science/nanite = FALSE,
	/area/station/science/robotics = FALSE,
	/area/station/science/server = FALSE,
	/area/station/science/storage = FALSE,
	/area/station/science/xenobiology = FALSE,
)))

GLOBAL_LIST_INIT(supply_lightup_areas, zebra_typecacheof(list(
	/area/station/cargo = TRUE,
	/area/station/cargo = TRUE,
	/area/station/security/checkpoint/supply = TRUE,
	/area/station/cargo/exploration_dock = FALSE,
	/area/station/cargo/exploration_prep = FALSE,
	/area/station/cargo/qm = FALSE,
	/area/station/cargo/qm_bedroom = FALSE,
)))

GLOBAL_LIST_INIT(security_lightup_areas, zebra_typecacheof(list(
	/area/station/security = TRUE,
	/area/station/security/detectives_office = FALSE,
	/area/station/security/warden = FALSE,
)))

/// Put any removed jobs here so they can still show in playtime listings.
GLOBAL_LIST_INIT(exp_removed_jobs, list(
//	"Virologist",
))
GLOBAL_PROTECT(exp_removed_jobs)

/// Put any removed jobs here so they can still show in playtime listings.
GLOBAL_LIST_INIT(exp_removed_jobsmap, list(
//	EXP_TYPE_CREW = list("Virologist"),
//	EXP_TYPE_MEDICAL = list("Virologist"),
))
GLOBAL_PROTECT(exp_removed_jobsmap)

// DO NOT INITIALIZE HERE. department subsystem initializes this.
GLOBAL_LIST_EMPTY(exp_jobsmap)
GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_SPECIAL = list("Lifebringer","Ash Walker","Exile","Servant Golem","Free Golem","Hermit","Translocated Vet","Escaped Prisoner","Hotel Staff","SuperFriend","Space Syndicate","Ancient Crew","Space Doctor","Beach Bum","Skeleton","Zombie","Lavaland Syndicate",JOB_NAME_PAI,"Ghost Role"), // Ghost roles
	EXP_TYPE_GHOST = list() // dead people, observers
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)

//this is necessary because antags happen before job datums are handed out, but NOT before they come into existence
//so I can't simply use job datum.department_head straight from the mind datum, laaaaame.
/proc/get_department_heads(job_title)
	if(!job_title)
		return list()

	for(var/datum/job/J in SSjob.occupations)
		if(J.title == job_title)
			return J.department_head //this is a list

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

	job = LOWER_TEXT(job)
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
