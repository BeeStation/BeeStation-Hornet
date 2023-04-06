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
			jobs_to_revolt = list(JOB_KEY_ASSISTANT)
			nation_name = pick("Assa", "Mainte", "Tunnel", "Gris", "Grey", "Liath", "Grigio", "Ass", "Assi")
		if("white")
			jobs_to_revolt = list(JOB_KEY_CHIEFMEDICALOFFICER, JOB_KEY_MEDICALDOCTOR, JOB_KEY_CHEMIST, JOB_KEY_GENETICIST, JOB_KEY_VIROLOGIST, JOB_KEY_PARAMEDIC)
			nation_name = pick("Mede", "Healtha", "Recova", "Chemi", "Geneti", "Viro", "Psych")
		if("yellow")
			jobs_to_revolt = list(JOB_KEY_CHIEFENGINEER, JOB_KEY_STATIONENGINEER, JOB_KEY_ATMOSPHERICTECHNICIAN)
			nation_name = pick("Atomo", "Engino", "Power", "Teleco")
		if("purple")
			jobs_to_revolt = list(JOB_KEY_RESEARCHDIRECTOR,JOB_KEY_SCIENTIST, JOB_KEY_ROBOTICIST)
			nation_name = pick("Sci", "Griffa", "Explosi", "Mecha", "Xeno")
		if("brown")
			jobs_to_revolt = list(JOB_KEY_QUARTERMASTER, JOB_KEY_CARGOTECHNICIAN, JOB_KEY_SHAFTMINER)
			nation_name = pick("Cargo", "Guna", "Suppli", "Mule", "Crate", "Ore", "Mini", "Shaf")
		if("whatevercolorrepresentstheservicepeople") //the few, the proud, the technically aligned
			jobs_to_revolt = list(JOB_KEY_BARTENDER, JOB_KEY_COOK, JOB_KEY_BOTANIST, JOB_KEY_CLOWN, JOB_KEY_MIME, JOB_KEY_JANITOR, JOB_KEY_CHAPLAIN)
			nation_name = pick("Honka", "Boozo", "Fatu", "Danka", "Mimi", "Libra", "Jani", "Religi")

	nation_name += pick("stan", "topia", "land", "nia", "ca", "tova", "dor", "ador", "tia", "sia", "ano", "tica", "tide", "cis", "marea", "co", "taoide", "slavia", "stotzka")

	var/datum/team/nation/nation = new
	nation.name = nation_name

	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		if(H.mind)
			var/datum/mind/M = H.mind
			if(M.get_display_station_role() && !(M.has_antag_datum(/datum/antagonist)))
				if(M.has_job(jobs_to_revolt))
					citizens += H
					M.add_antag_datum(/datum/antagonist/separatist,nation)
					H.log_message("Was made into a separatist, long live [nation_name]!", LOG_ATTACK, color="red")

	if(citizens.len)
		var/message
		for(var/job in jobs_to_revolt)
			message += "[job],"
		message_admins("The nation of [nation_name] has been formed. Affected jobs are [message]")
