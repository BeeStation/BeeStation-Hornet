/datum/antagonist/nukeop
	name = "Nuclear Operative"
	roundend_category = "syndicate operatives" //just in case
	antagpanel_category = "NukeOp"
	banning_key = ROLE_OPERATIVE
	required_living_playtime = 8
	antag_moodlet = /datum/mood_event/focused
	show_to_ghosts = TRUE
	hijack_speed = 2 //If you can't take out the station, take the shuttle instead.
	ui_name = "AntagInfoNukeOp"
	leave_behaviour = ANTAGONIST_LEAVE_KEEP
	var/datum/team/nuclear/nuke_team
	var/always_new_team = FALSE //If not assigned a team by default ops will try to join existing ones, set this to TRUE to always create new team.
	var/send_to_spawnpoint = TRUE //Should the user be moved to default spawnpoint.
	var/nukeop_outfit = /datum/outfit/syndicate

/datum/antagonist/nukeop/proc/update_synd_icons_added(mob/living/M)
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.join_hud(M)
	set_antag_hud(M, "synd")

/datum/antagonist/nukeop/proc/update_synd_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.leave_hud(M)
	set_antag_hud(M, null)

/datum/antagonist/nukeop/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_synd_icons_added(M)
	ADD_TRAIT(owner, TRAIT_DISK_VERIFIER, NUKEOP_TRAIT)
	owner.remove_all_quirks()

/datum/antagonist/nukeop/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_synd_icons_removed(M)
	REMOVE_TRAIT(owner, TRAIT_DISK_VERIFIER, NUKEOP_TRAIT)

/datum/antagonist/nukeop/proc/equip_op()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current

	H.set_species(/datum/species/human) //Plasamen burn up otherwise, and lizards are vulnerable to asimov AIs

	H.equipOutfit(nukeop_outfit)
	return TRUE

/datum/antagonist/nukeop/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, span_notice("You are a [nuke_team ? nuke_team.syndicate_name : "syndicate"] agent!"))
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Nuclear Operative",
		"Destroy the station with a nuclear device.")

/datum/antagonist/nukeop/on_gain()
	give_alias()
	forge_objectives()
	. = ..()
	equip_op()
	memorize_code()
	memorize_frequency()
	if(send_to_spawnpoint)
		move_to_spawnpoint()
		// grant extra TC for the people who start in the nukie base ie. not the lone op
		var/extra_tc = CEILING(GLOB.joined_player_list.len / 2, 5)
		var/datum/component/uplink/U = owner.find_syndicate_uplink()
		if (U)
			U.telecrystals += extra_tc



/datum/antagonist/nukeop/get_team()
	return nuke_team

/datum/antagonist/nukeop/ui_static_data(mob/user)
	. = ..()
	.["leader"] = FALSE
	.["lone"] = FALSE
	.["nuke_code"] = nuke_team.memorized_code || "???"

/datum/antagonist/nukeop/proc/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_code(5)
		var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == "ADMIN")
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
			for(var/obj/machinery/nuclearbomb/beer/beernuke in GLOB.nuke_list)
				if(beernuke.r_code == "ADMIN")
					beernuke.r_code = nuke_team.memorized_code
		else
			stack_trace("Syndicate nuke not found during nuke team creation.")
			nuke_team.memorized_code = null

/datum/antagonist/nukeop/proc/give_alias()
	if(nuke_team && nuke_team.syndicate_name)
		var/mob/living/carbon/human/H = owner.current
		if(istype(H)) // Reinforcements get a real name
			var/chosen_name = H.dna.species.random_name(H.gender,0,nuke_team.syndicate_name)
			H.fully_replace_character_name(H.real_name,chosen_name)
		else
			var/number = 1
			number = nuke_team.members.Find(owner)
			owner.current.real_name = "[nuke_team.syndicate_name] Operative #[number]"

/datum/antagonist/nukeop/proc/memorize_code()
	if(nuke_team && nuke_team.tracked_nuke && nuke_team.memorized_code)
		antag_memory += "<B>[nuke_team.tracked_nuke] Code</B>: [nuke_team.memorized_code]<br>"
		to_chat(owner, "The nuclear authorization code is: <B>[nuke_team.memorized_code]</B>")
	else
		to_chat(owner, "Unfortunately the syndicate was unable to provide you with nuclear authorization code.")

/datum/antagonist/nukeop/proc/memorize_frequency()
	if(nuke_team?.team_frequency)
		antag_memory += "<B>Secure Tracking Beacon Frequency</B>: [nuke_team.team_frequency]<br>"
		to_chat(owner, "Your team's unique tracking beacon code is: <B>[nuke_team.team_frequency]</B>")
	else
		to_chat(owner, "You were not assigned a frequency for your hardsuits beacons. You will have to coordinate with each other to decide a frequency to use.")

/datum/antagonist/nukeop/proc/forge_objectives()
	if(!give_objectives)
		return
	if(nuke_team)
		objectives |= nuke_team.objectives

/datum/antagonist/nukeop/proc/move_to_spawnpoint()
	var/team_number = 1
	if(nuke_team)
		team_number = nuke_team.members.Find(owner)
	owner.current.forceMove(GLOB.nukeop_start[((team_number - 1) % GLOB.nukeop_start.len) + 1])

/datum/antagonist/nukeop/leader/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.nukeop_leader_start))

/datum/antagonist/nukeop/create_team(datum/team/nuclear/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/nukeop/N in GLOB.antagonists)
				if(!N.owner)
					continue
				if(N.nuke_team)
					nuke_team = N.nuke_team
					return
		nuke_team = new /datum/team/nuclear
		nuke_team.update_objectives()
		assign_nuke() //This is bit ugly
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	nuke_team = new_team

/datum/antagonist/nukeop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_OPERATIVE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has nuke op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has nuke op'ed [key_name(new_owner)].")

/datum/antagonist/nukeop/get_admin_commands()
	. = ..()
	.["Send to base"] = CALLBACK(src,PROC_REF(admin_send_to_base))
	.["Tell code"] = CALLBACK(src,PROC_REF(admin_tell_code))

/datum/antagonist/nukeop/proc/admin_send_to_base(mob/admin)
	owner.current.forceMove(pick(GLOB.nukeop_start))

/datum/antagonist/nukeop/proc/admin_tell_code(mob/admin)
	var/code
	for (var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
		if (length(bombue.r_code) <= 5 && bombue.r_code != initial(bombue.r_code))
			code = bombue.r_code
			break
	if (code)
		antag_memory += "<B>Syndicate Nuclear Bomb Code</B>: [code]<br>"
		to_chat(owner.current, "The nuclear authorization code is: <B>[code]</B>")
	else
		to_chat(admin, span_danger("No valid nuke found!"))

/datum/antagonist/nukeop/leader
	name = "Nuclear Operative Leader"
	nukeop_outfit = /datum/outfit/syndicate/leader
	always_new_team = TRUE
	var/title

/datum/antagonist/nukeop/leader/memorize_code()
	..()
	if(nuke_team?.memorized_code)
		var/obj/item/paper/nuke_code_paper = new
		nuke_code_paper.add_raw_text("The nuclear authorization code is: <b>[nuke_team.memorized_code]</b>")
		nuke_code_paper.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = owner.current
		if(!istype(H))
			nuke_code_paper.forceMove(get_turf(H))
		else
			H.put_in_hands(nuke_code_paper, TRUE)
			H.update_icons()

/datum/antagonist/nukeop/leader/give_alias()
	title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	if(nuke_team && nuke_team.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/leader/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, "<B>You are the Syndicate [title] for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</B>")
	to_chat(owner, "<B>If you feel you are not up to this task, give your ID to another operative.</B>")
	to_chat(owner, "<B>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</B>")
	owner.announce_objectives()
	addtimer(CALLBACK(src, PROC_REF(nuketeam_name_assign)), 1)
	owner.current.client?.tgui_panel?.give_antagonist_popup("Nuclear Operative Team Leader",
		"Destroy the station with a nuclear explosive by leading your team.")

/datum/antagonist/nukeop/leader/proc/nuketeam_name_assign()
	if(!nuke_team)
		return
	nuke_team.rename_team(ask_name())

/datum/antagonist/nukeop/leader/ui_static_data(mob/user)
	. = ..()
	.["leader"] = TRUE

/datum/team/nuclear/proc/rename_team(new_name)
	syndicate_name = new_name
	name = "Family [syndicate_name]"
	for(var/I in members)
		var/datum/mind/synd_mind = I
		var/mob/living/carbon/human/H = synd_mind.current
		if(!istype(H))
			continue
		var/chosen_name = H.dna.species.random_name(H.gender,0,syndicate_name)
		H.fully_replace_character_name(H.real_name,chosen_name)

/datum/antagonist/nukeop/leader/proc/ask_name()
	var/randomname = pick(GLOB.last_names)
	var/newname = stripped_input(owner.current,"You are the nuke operative [title]. Please choose a last name for your family.", "Name change",randomname)
	if (!newname)
		newname = randomname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = randomname

	return capitalize(newname)

/datum/antagonist/nukeop/lone
	name = "Lone Operative"
	always_new_team = TRUE
	send_to_spawnpoint = FALSE //Handled by event
	nukeop_outfit = /datum/outfit/syndicate/full

/datum/antagonist/nukeop/lone/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_code(5)
		var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == "ADMIN")
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Station self-destruct not found during lone op team creation.")
			nuke_team.memorized_code = null
		nuke_team.name = "Lone Operative - [nuke_team.syndicate_name]"

/datum/antagonist/nukeop/lone/ui_static_data(mob/user)
	. = ..()
	.["lone"] = TRUE

/datum/antagonist/nukeop/reinforcement
	send_to_spawnpoint = FALSE
	nukeop_outfit = /datum/outfit/syndicate/no_crystals

/datum/team/nuclear
	var/syndicate_name
	var/obj/machinery/nuclearbomb/tracked_nuke
	var/core_objective = /datum/objective/nuclear
	var/memorized_code
	var/team_frequency
	var/list/team_discounts

/datum/team/nuclear/New()
	..()
	syndicate_name = syndicate_name()
	name = "Family [syndicate_name]"
	team_frequency = get_free_team_frequency("synd")

/datum/team/nuclear/proc/update_objectives()
	if(core_objective)
		var/datum/objective/O = new core_objective
		O.team = src
		objectives += O
		for(var/datum/mind/M in members)
			log_objective(M, O.explanation_text)

/datum/team/nuclear/proc/disk_rescued()
	for(var/obj/item/disk/nuclear/D in GLOB.poi_list)
		//If emergency shuttle is in transit disk is only safe on it
		if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
			if(!SSshuttle.emergency.is_in_shuttle_bounds(D))
				return FALSE
		//If shuttle escaped check if it's on centcom side
		else if(SSshuttle.emergency.mode == SHUTTLE_ENDGAME)
			if(!D.onCentCom())
				return FALSE
		else //Otherwise disk is safe when on station
			var/turf/T = get_turf(D)
			if(!T || !is_station_level(T.z))
				return FALSE
	return TRUE

/datum/team/nuclear/proc/operatives_dead()
	for(var/I in members)
		var/datum/mind/operative_mind = I
		if(ishuman(operative_mind.current) && (operative_mind.current.stat != DEAD))
			return FALSE
	return TRUE

/datum/team/nuclear/proc/syndies_escaped()
	var/obj/docking_port/mobile/S = SSshuttle.getShuttle("syndicate")
	var/obj/docking_port/stationary/transit/T = locate() in S.loc
	return S && (is_centcom_level(S.z) || T)

/datum/team/nuclear/proc/get_result()
	var/evacuation = EMERGENCY_ESCAPED_OR_ENDGAMED
	var/disk_rescued = disk_rescued()
	var/syndies_didnt_escape = !syndies_escaped()
	var/station_was_nuked = GLOB.station_was_nuked
	var/nuke_off_station = GLOB.nuke_off_station

	if(nuke_off_station == NUKE_SYNDICATE_BASE)
		return NUKE_RESULT_FLUKE
	else if(station_was_nuked && !syndies_didnt_escape)
		return NUKE_RESULT_NUKE_WIN
	else if (station_was_nuked && syndies_didnt_escape)
		return NUKE_RESULT_NOSURVIVORS
	else if (!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		return NUKE_RESULT_WRONG_STATION
	else if (!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		return NUKE_RESULT_WRONG_STATION_DEAD
	else if ((disk_rescued && evacuation) && operatives_dead())
		return NUKE_RESULT_CREW_WIN_SYNDIES_DEAD
	else if (disk_rescued)
		return NUKE_RESULT_CREW_WIN
	else if (!disk_rescued && operatives_dead())
		return NUKE_RESULT_DISK_LOST
	else if (!disk_rescued && evacuation)
		return NUKE_RESULT_DISK_STOLEN
	else
		return	//Undefined result

/datum/team/nuclear/roundend_report()
	var/list/parts = list()
	parts += span_header("[syndicate_name] Operatives:")

	switch(get_result())
		if(NUKE_RESULT_FLUKE)
			parts += span_redtextbig("Humiliating Syndicate Defeat")
			parts += "<B>The crew of [station_name()] gave [syndicate_name] operatives back their bomb! The syndicate base was destroyed!</B> Next time, don't lose the nuke!"
		if(NUKE_RESULT_NUKE_WIN)
			parts += span_greentextbig("Syndicate Major Victory!")
			parts += "<B>[syndicate_name] operatives have destroyed [station_name()]!</B>"
		if(NUKE_RESULT_NOSURVIVORS)
			parts += span_neutraltextbig("Total Annihilation")
			parts +=  "<B>[syndicate_name] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"
		if(NUKE_RESULT_WRONG_STATION)
			parts += span_redtextbig("Crew Minor Victory")
			parts += "<B>[syndicate_name] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't do that!"
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			parts += span_redtextbig("[syndicate_name] operatives have earned Darwin Award!")
			parts += "<B>[syndicate_name] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't do that!"
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			parts += span_redtextbig("Crew Major Victory!")
			parts += "<B>The Research Staff has saved the disk and killed the [syndicate_name] Operatives</B>"
		if(NUKE_RESULT_CREW_WIN)
			parts += span_redtextbig("Crew Major Victory")
			parts += "<B>The Research Staff has saved the disk and stopped the [syndicate_name] Operatives!</B>"
		if(NUKE_RESULT_DISK_LOST)
			parts += span_neutraltextbig("Neutral Victory!")
			parts += "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name] Operatives!</B>"
		if(NUKE_RESULT_DISK_STOLEN)
			parts += span_greentextbig("Syndicate Minor Victory!")
			parts += "<B>[syndicate_name] operatives survived the assault but did not achieve the destruction of [station_name()].</B> Next time, don't lose the disk!"
		else
			parts += span_neutraltextbig("Neutral Victory")
			parts += "<B>Mission aborted!</B>"

	var/text = "<br>[span_header("The syndicate operatives were:")]"
	var/purchases = ""
	var/TC_uses = 0
	var/effective_tc = 0
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	for(var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if(H)
			TC_uses += H.total_spent
			effective_tc += H.effective_amount
			purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)
	text += "<br>"
	var/effective_message = TC_uses < effective_tc ? " / effectively worth [effective_tc] TC" : ""
	text += "(Syndicates used [TC_uses] TC[effective_message]) [purchases]"
	if(TC_uses == 0 && GLOB.station_was_nuked && !operatives_dead())
		text += "<BIG>[icon2html('icons/badass.dmi', world, "badass")]</BIG>"

	parts += text

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/nuclear/antag_listing_name()
	if(syndicate_name)
		return "[syndicate_name] Syndicates"
	else
		return "Syndicates"

/datum/team/nuclear/antag_listing_entry()
	var/disk_report = "<b>Nuclear Disk(s)</b><br>"
	disk_report += "<table cellspacing=5>"
	for(var/obj/item/disk/nuclear/N in GLOB.poi_list)
		disk_report += "<tr><td>[N.name], "
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				disk_report += "carried by <a href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a> "
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				disk_report += "in \a [O.name] "
			disk_loc = disk_loc.loc
		disk_report += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td><td><a href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(N)]'>FLW</a></td></tr>"
	disk_report += "</table>"
	var/common_part = ..()
	return common_part + disk_report

/datum/outfit/syndicate
	name = "Syndicate Operative - Basic"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/modular_computer/tablet/nukeops
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/ballistic/automatic/pistol
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1,\
		/obj/item/knife/combat/survival)

	var/tc = 25
	var/command_radio = FALSE
	var/uplink_type = /obj/item/uplink/nuclear


/datum/outfit/syndicate/leader
	name = "Syndicate Leader - Basic"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	r_hand = /obj/item/nuclear_challenge
	command_radio = TRUE

/datum/outfit/syndicate/no_crystals
	name = "Syndicate Operative - Reinforcement"
	tc = 0

/datum/outfit/syndicate/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE
		R.use_command = TRUE

	if(ispath(uplink_type, /obj/item/uplink/nuclear) || tc) // /obj/item/uplink/nuclear understands 0 tc
		var/obj/item/U = new uplink_type(H, H.key, tc)
		H.equip_to_slot_or_del(U, ITEM_SLOT_BACKPACK)

	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	H.faction |= FACTION_SYNDICATE
	H.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/mod/control/pre_equipped/nuclear
	mask = /obj/item/clothing/mask/gas/syndicate
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/storage/belt/military
	suit_store = /obj/item/gun/ballistic/shotgun/automatic/bulldog
	backpack_contents = list(
		/obj/item/storage/box/survival/syndie=1,\
		/obj/item/gun/ballistic/automatic/pistol=1,\
		/obj/item/knife/combat/survival=1,\
		)
