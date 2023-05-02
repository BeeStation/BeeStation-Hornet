GLOBAL_LIST_EMPTY(exp_to_update)
GLOBAL_PROTECT(exp_to_update)

// Procs
/datum/job/proc/required_playtime_remaining(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_exp_tracking))
		return 0
	if(!SSdbcore.Connect())
		return 0
	if(!exp_requirements || !exp_type)
		return 0
	if(!job_is_xp_locked(get_jkey()))
		return 0
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights_for(C,R_ADMIN))
		return 0
	var/isexempt = C.prefs.db_flags & DB_FLAG_EXEMPT
	if(isexempt)
		return 0
	if(C.prefs.job_exempt)
		return 0
	var/my_exp = C.calc_exp_type(get_exp_req_type())
	var/job_requirement = get_exp_req_amount()
	if(my_exp >= job_requirement)
		return 0
	else
		return (job_requirement - my_exp)

/datum/job/proc/get_exp_req_amount()
	if(get_jkey() in (GLOB.command_positions | list(JOB_KEY_AI)))
		var/uerhh = CONFIG_GET(number/use_exp_restrictions_heads_hours)
		if(uerhh)
			return uerhh * 60
	return exp_requirements

/datum/job/proc/get_exp_req_type()
	if(get_jkey() in (GLOB.command_positions | list(JOB_KEY_AI)))
		if(CONFIG_GET(flag/use_exp_restrictions_heads_department) && exp_type_department)
			return exp_type_department
	return exp_type

/proc/job_is_xp_locked(job_key)
	if(!CONFIG_GET(flag/use_exp_restrictions_heads) && (job_key in (GLOB.command_positions | list(JOB_KEY_AI))))
		return FALSE
	if(!CONFIG_GET(flag/use_exp_restrictions_other) && !(job_key in (GLOB.command_positions | list(JOB_KEY_AI))))
		return FALSE
	return TRUE

/client/proc/calc_exp_type(exptype)
	var/list/explist = prefs.exp.Copy()
	var/amount = 0
	var/list/typelist = GLOB.exp_jobsmap[exptype]
	if(!typelist)
		return -1
	for(var/job in typelist["titles"])
		if(job in explist)
			amount += explist[job]
	return amount

/client/proc/get_exp_living(pure_numeric = FALSE)
	if(!prefs.exp || !prefs.exp[EXP_TYPE_LIVING])
		return pure_numeric ? 0 : "No data"
	var/exp_living = text2num(prefs.exp[EXP_TYPE_LIVING])
	return pure_numeric ? exp_living : get_exp_format(exp_living)

/proc/get_exp_format(expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "0h"

/datum/controller/subsystem/blackbox/proc/update_exp(mins, ann = FALSE)
	if(!SSdbcore.Connect())
		return -1
	for(var/client/L in GLOB.clients)
		if(L.is_afk())
			continue
		L.update_exp_list(mins,ann)

/datum/controller/subsystem/blackbox/proc/update_exp_db()
	set waitfor = FALSE
	var/list/old_minutes = GLOB.exp_to_update
	GLOB.exp_to_update = null
	SSdbcore.MassInsert(format_table_name("role_time"), old_minutes, duplicate_key = "ON DUPLICATE KEY UPDATE minutes = minutes + VALUES(minutes)")

//resets a client's exp to what was in the db.
/client/proc/set_exp_from_db()
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	var/datum/DBQuery/exp_read = SSdbcore.NewQuery(
		"SELECT job, minutes FROM [format_table_name("role_time")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!exp_read.Execute(async = TRUE))
		qdel(exp_read)
		return -1
	var/list/play_records = list()
	while(exp_read.NextRow())
		play_records[exp_read.item[1]] = text2num(exp_read.item[2])
	qdel(exp_read)

	for(var/rtype in SSjob.name_occupations)
		if(!play_records[rtype])
			play_records[rtype] = 0
	for(var/rtype in GLOB.exp_specialmap)
		if(!play_records[rtype])
			play_records[rtype] = 0

	prefs.exp = play_records

//updates player db flags
/client/proc/update_flag_db(newflag, state = FALSE)

	if(!SSdbcore.Connect())
		return -1

	if(!set_db_player_flags())
		return -1

	if((prefs.db_flags & newflag) && !state)
		prefs.db_flags &= ~newflag
	else
		prefs.db_flags |= newflag

	var/datum/DBQuery/flag_update = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET flags=:flags WHERE ckey=:ckey",
		list("flags" = "[prefs.db_flags]", "ckey" = ckey)
	)

	if(!flag_update.Execute())
		qdel(flag_update)
		return -1
	qdel(flag_update)


/client/proc/update_exp_list(minutes, announce_changes = FALSE)
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	if (!isnum_safe(minutes))
		return -1
	var/list/play_records = list()
	var/is_admin = FALSE
	if(holder && !holder.deadmined)
		is_admin = TRUE

	if(isliving(mob))
		if(mob.stat != DEAD)
			play_records[EXP_TYPE_LIVING] += minutes

			process_ten_minute_living()

			if(announce_changes)
				to_chat(src,"<span class='notice'>You got: [minutes] Living EXP!</span>")

			if(mob.mind.get_display_station_role()) // having station role means a crew - valid to have playtime
				var/datum/job/J = SSjob.GetJob(mob.mind.get_job())
				if(J)
					play_records[J.get_jkey()] += minutes
					if(announce_changes)
						to_chat(src,"<span class='notice'>You got: [minutes] [J.get_jkey()] EXP!</span>")
			if(length(mob.mind.get_special_role(TRUE))) // it gives all special type playtime as long as they have
				for(var/each_role in mob.mind.get_special_role(TRUE))
					if(!(each_role in GLOB.exp_specialmap[EXP_TYPE_ANTAG] + GLOB.exp_specialmap[EXP_TYPE_SPECIAL]))
						var/static/list/informed_players = list()
						if(!informed_players["[mob.mind.name][each_role]"])
							stack_trace("[key_name(mob)] has an incorrect role to track playtime: [each_role]")
							informed_players["[mob.mind.name][each_role]"] = TRUE
						continue
					play_records[each_role] += minutes
					if(announce_changes)
						to_chat(mob,"<span class='notice'>You got: [minutes] [each_role] EXP!</span>")
		else // mob.stat == DEAD
			if(is_admin)
				play_records[EXP_TYPE_ADMIN] += minutes
				if(announce_changes)
					to_chat(src,"<span class='notice'>You got: [minutes] Admin EXP!</span>")
			play_records[EXP_TYPE_DEAD] += minutes // they're in a dead body
			if(announce_changes)
				to_chat(src,"<span class='notice'>You got: [minutes] Dead EXP!</span>")
	else if(isobserver(mob)) // being a ghost
		if(is_admin)
			play_records[EXP_TYPE_ADMIN] += minutes
			if(announce_changes)
				to_chat(src,"<span class='notice'>You got: [minutes] Admin EXP!</span>")
		if(!mob.mind || mob.mind.is_cryoed || (is_admin && mob.mind?.current.stat != DEAD)) // mindless ghost(or is_cryo mind) would mean they're just an observer, or admin doing something...
			play_records[EXP_TYPE_OBSERVER] += minutes
			if(announce_changes)
				to_chat(src,"<span class='notice'>You got: [minutes] Observer EXP!</span>")
		else
			play_records[EXP_TYPE_DEAD] += minutes // mind-having ghost would mean they're dead
			if(announce_changes)
				to_chat(src,"<span class='notice'>You got: [minutes] Dead EXP!</span>")
	else if(minutes)	//Let "refresh" checks go through
		return

	for(var/jtype in play_records)
		var/jvalue = play_records[jtype]
		if (!jvalue)
			continue
		if (!isnum_safe(jvalue))
			CRASH("invalid job value [jtype]:[jvalue]")
		LAZYINITLIST(GLOB.exp_to_update)
		GLOB.exp_to_update.Add(list(list(
			"job" = jtype,
			"ckey" = ckey,
			"minutes" = jvalue)))
		prefs.exp[jtype] += jvalue
	addtimer(CALLBACK(SSblackbox, TYPE_PROC_REF(/datum/controller/subsystem/blackbox, update_exp_db)),20,TIMER_OVERRIDE|TIMER_UNIQUE)


//ALWAYS call this at beginning to any proc touching player flags, or your database admin will probably be mad
/client/proc/set_db_player_flags()
	if(!SSdbcore.Connect())
		return FALSE

	var/datum/DBQuery/flags_read = SSdbcore.NewQuery(
		"SELECT flags FROM [format_table_name("player")] WHERE ckey=:ckey",
		list("ckey" = ckey)
	)

	if(!flags_read.Execute(async = TRUE))
		qdel(flags_read)
		return FALSE

	if(flags_read.NextRow())
		prefs.db_flags = text2num(flags_read.item[1])
	else if(isnull(prefs.db_flags))
		prefs.db_flags = 0	//This PROBABLY won't happen, but better safe than sorry.
	qdel(flags_read)
	return TRUE
