//I wish we had interfaces sigh, and i'm not sure giving team and antag common root is a better solution here

//Name shown on antag list
/datum/antagonist/proc/antag_listing_name()
	if(!owner)
		return "Unassigned"
	if(owner.current)
		return "<a href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[REF(owner.current)]'>[owner.current.real_name]</a> "
	else
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(owner)]'>[owner.name]</a> "

//Whatever interesting things happened to the antag admins should know about
//Include additional information about antag in this part
/datum/antagonist/proc/antag_listing_status()
	if(!owner)
		return "(Unassigned)"
	if(!owner.current)
		return "<font color=red>(Body destroyed)</font>"
	else
		if(owner.current.stat == DEAD)
			return "<font color=red>(DEAD)</font>"
		else if(!owner.current.client)
			return "(No client)"

//Builds the common FLW PM TP commands part
//Probably not going to be overwritten by anything but you never know
/datum/antagonist/proc/antag_listing_commands()
	if(!owner)
		return
	var/list/parts = list()
	parts += "<a href='byond://?priv_msg=[ckey(owner.key)]'>PM</a>"
	if(owner.current) //There's body to follow
		parts += "<a href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(owner.current)]'>FLW</a>"
	else
		parts += ""
	parts += "<a href='byond://?_src_=holder;[HrefToken()];traitor=[REF(owner)]'>Show Objective</a>"
	return parts //Better as one cell or two/three

//Builds table row for the antag
// Jim (Status) FLW PM TP
/datum/antagonist/proc/antag_listing_entry()
	var/list/parts = list()
	if(show_name_in_check_antagonists)
		parts += "[antag_listing_name()]([name])"
	else
		parts += antag_listing_name()
	parts += antag_listing_status()
	parts += antag_listing_commands()
	return "<tr><td>[parts.Join("</td><td>")]</td></tr>"


/datum/team/proc/get_team_antags(antag_type,specific = FALSE)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(A.get_team() == src && (!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type))
			. += A

//Builds section for the team
/datum/team/proc/antag_listing_entry()
	//NukeOps:
	// Jim (Status) FLW PM TP
	// Joe (Status) FLW PM TP
	//Disk:
	// Deep Space FLW
	var/list/parts = list()
	parts += "<b>[antag_listing_name()]</b><br>"
	parts += "<table cellspacing=5>"
	for(var/datum/antagonist/A in get_team_antags())
		parts += A.antag_listing_entry()
	parts += "</table>"
	parts += antag_listing_footer()
	return parts.Join()

/datum/team/proc/antag_listing_name()
	return name

/datum/team/proc/antag_listing_footer()
	return

/datum/admins/proc/build_antag_listing()
	var/list/sections = list()
	var/list/priority_sections = list()

	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_teams |= A.get_team()
		all_antagonists += A

	for(var/datum/team/T in all_teams)
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		sections += T.antag_listing_entry()

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	var/current_category
	var/list/current_section = list()
	for(var/i in 1 to all_antagonists.len)
		var/datum/antagonist/current_antag = all_antagonists[i]
		var/datum/antagonist/next_antag
		if(i < all_antagonists.len)
			next_antag = all_antagonists[i+1]
		if(!current_category)
			current_category = current_antag.roundend_category
			current_section += "<b>[capitalize(current_category)]</b><br>"
			current_section += "<table cellspacing=5>"
		current_section += current_antag.antag_listing_entry() // Name - (Traitor) - FLW | PM | TP

		if(!next_antag || next_antag.roundend_category != current_antag.roundend_category) //End of section
			current_section += "</table>"
			sections += current_section.Join()
			current_section.Cut()
			current_category = null
	var/list/all_sections = priority_sections + sections
	return all_sections.Join("<br>")

/datum/admins/proc/check_antagonists()
	if(!SSticker.HasRoundStarted())
		alert("The game hasn't started yet!")
		return
	var/list/dat = list("<h1><B>Round Status</B></h1>")
	dat += "Round Duration: <B>[time2text(world.timeofday - SSticker.round_start_timeofday, "hh:mm:ss", 0)]</B><BR>"
	dat += "<B>Emergency shuttle</B><BR>"
	if(EMERGENCY_IDLE_OR_RECALLED)
		dat += "<a href='byond://?_src_=holder;[HrefToken()];call_shuttle=1'>Call Shuttle</a><br>"
	else
		var/timeleft = SSshuttle.emergency.timeLeft()
		if(SSshuttle.emergency.mode == SHUTTLE_CALL)
			dat += "ETA: <a href='byond://?_src_=holder;[HrefToken()];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_leading(num2text(timeleft % 60), 2, "0")]</a><BR>"
			dat += "<a href='byond://?_src_=holder;[HrefToken()];call_shuttle=2'>Send Back</a><br>"
		else
			dat += "ETA: <a href='byond://?_src_=holder;[HrefToken()];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_leading(num2text(timeleft % 60), 2, "0")]</a><BR>"
	dat += "<B>Continuous Round Status</B><BR>"
	dat += "<BR>"
	dat += "<a href='byond://?_src_=holder;[HrefToken()];end_round=[REF(usr)]'>End Round Now</a><br>"
	dat += "<a href='byond://?_src_=holder;[HrefToken()];delay_round_end=1'>[SSticker.delay_end ? "Undelay Round End" : "Delay Round End"]</a><br>"
	dat += "<a href='byond://?_src_=holder;[HrefToken()];check_teams=1'>Check Teams</a>"
	var/connected_players = GLOB.clients_unsafe.len
	var/lobby_players = 0
	var/observers = 0
	var/observers_connected = 0
	var/living_players = 0
	var/living_players_connected = 0
	var/living_players_antagonist = 0
	var/brains = 0
	var/other_players = 0
	var/living_skipped = 0
	var/drones = 0
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey)
			if(isnewplayer(M))
				lobby_players++
				continue
			else if(M.stat != DEAD && M.mind && !isbrain(M))
				if(isdrone(M))
					drones++
					continue
				if(is_centcom_level(M.z))
					living_skipped++
					continue
				living_players++
				if(M.mind.special_role)
					living_players_antagonist++
				if(M.client)
					living_players_connected++
			else if(M.stat == DEAD || isobserver(M))
				observers++
				if(M.client)
					observers_connected++
			else if(isbrain(M))
				brains++
			else
				other_players++
	dat += "<BR><b><font color='blue' size='3'>Players:|[connected_players - lobby_players] ingame|[connected_players] connected|[lobby_players] lobby|</font></b>"
	dat += "<BR><b><font color='green'>Living Players:|[living_players_connected] active|[living_players - living_players_connected] disconnected|[living_players_antagonist] antagonists|</font></b>"
	dat += "<BR><b><font color='#bf42f4'>SKIPPED \[On centcom Z-level\]: [living_skipped] living players|[drones] living drones|</font></b>"
	dat += "<BR><b><font color='red'>Dead/Observing players:|[observers_connected] active|[observers - observers_connected] disconnected|[brains] brains|</font></b>"
	if(other_players)
		dat += "<BR>[span_userdanger("[other_players] players in invalid state or the statistics code is bugged!")]"
	dat += "<br><br>"

	dat += build_antag_listing()

	usr << browse(HTML_SKELETON_TITLE("Round Status", dat.Join()), "window=roundstatus;size=500x500")
