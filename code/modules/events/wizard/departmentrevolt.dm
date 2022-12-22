/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 0 //An order that requires order in a round of chaos was maybe not the best idea. Requiescat in pace departmental uprising August 2014 - March 2015
	typepath = /datum/round_event/wizard/deprevolt
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/deprevolt/start()

	var/list/tidecolor
	var/list/jobs_to_revolt	= 	list()
	var/nation_name
	var/list/citizens	=		list()

	tidecolor = pick("grey", "white", "yellow", "purple", "brown", "whatevercolorrepresentstheservicepeople")
	switch(tidecolor)
		if("grey") //God help you
			jobs_to_revolt = list(JOB_PATH_ASSISTANT)
			nation_name = pick("Assa", "Mainte", "Tunnel", "Gris", "Grey", "Liath", "Grigio", "Ass", "Assi")
		if("white")
			jobs_to_revolt = list(JOB_PATH_CHIEFMEDICALOFFICER, JOB_PATH_MEDICALDOCTOR, JOB_PATH_CHEMIST, JOB_PATH_GENETICIST, JOB_PATH_VIROLOGIST, JOB_PATH_PARAMEDIC)
			nation_name = pick("Mede", "Healtha", "Recova", "Chemi", "Geneti", "Viro", "Psych")
		if("yellow")
			jobs_to_revolt = list(JOB_PATH_CHIEFENGINEER, JOB_PATH_STATIONENGINEER, JOB_PATH_ATMOSPHERICTECHNICIAN)
			nation_name = pick("Atomo", "Engino", "Power", "Teleco")
		if("purple")
			jobs_to_revolt = list(JOB_PATH_RESEARCHDIRECTOR,JOB_PATH_SCIENTIST, JOB_PATH_ROBOTICIST)
			nation_name = pick("Sci", "Griffa", "Explosi", "Mecha", "Xeno")
		if("brown")
			jobs_to_revolt = list(JOB_PATH_QUARTERMASTER, JOB_PATH_CARGOTECHNICIAN, JOB_PATH_SHAFTMINER)
			nation_name = pick("Cargo", "Guna", "Suppli", "Mule", "Crate", "Ore", "Mini", "Shaf")
		if("whatevercolorrepresentstheservicepeople") //the few, the proud, the technically aligned
			jobs_to_revolt = list(JOB_PATH_BARTENDER, JOB_PATH_COOK, JOB_PATH_BOTANIST, JOB_PATH_CLOWN, JOB_PATH_MIME, JOB_PATH_JANITOR, JOB_PATH_CHAPLAIN)
			nation_name = pick("Honka", "Boozo", "Fatu", "Danka", "Mimi", "Libra", "Jani", "Religi")

	nation_name += pick("stan", "topia", "land", "nia", "ca", "tova", "dor", "ador", "tia", "sia", "ano", "tica", "tide", "cis", "marea", "co", "taoide", "slavia", "stotzka")

	var/datum/team/nation/nation = new
	nation.name = nation_name

	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		if(H.mind)
			var/datum/mind/M = H.mind
			if(M.get_mind_role(JTYPE_JOB_PATH) && !(M.has_antag_datum(/datum/antagonist)))
				for(var/job in jobs_to_revolt)
					if(M.get_mind_role(JTYPE_JOB_PATH, as_basic_job=TRUE) == job)
						citizens += H
						M.add_antag_datum(/datum/antagonist/separatist,nation)
						H.log_message("Was made into a separatist, long live [nation_name]!", LOG_ATTACK, color="red")

	if(citizens.len)
		var/message
		for(var/job in jobs_to_revolt)
			message += "[job],"
		message_admins("The nation of [nation_name] has been formed. Affected jobs are [message]")
