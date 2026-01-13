/// If we spawn an ERT with the "choose experienced leader" option, select the leader from the top X playtimes
#define ERT_EXPERIENCED_LEADER_CHOOSE_TOP	3

// Yeah, this is stupid, but the preview icon runtimes if we don't do this
/client/proc/create_ert()
	set name = "Create ERT"
	set category = "Round"

	holder?.create_ert()

/datum/admins/proc/create_ert()
	var/datum/ert/template = new /datum/ert/centcom_official
	var/list/settings = list(
		"preview_callback" = CALLBACK(src, PROC_REF(makeERTPreviewIcon)),
		"mainsettings" = list(
			"template" = list("desc" = "Template", "callback" = CALLBACK(src, PROC_REF(makeERTTemplateModified)), "type" = "datum", "path" = "/datum/ert", "subtypesonly" = TRUE, "value" = template.type),
			"teamsize" = list("desc" = "Team Size", "type" = "number", "value" = template.teamsize),
			"mission" = list("desc" = "Mission", "type" = "string", "value" = template.mission),
			"polldesc" = list("desc" = "Ghost poll description", "type" = "string", "value" = template.polldesc),
			"enforce_human" = list("desc" = "Enforce human authority", "type" = "boolean", "value" = "[(CONFIG_GET(flag/enforce_human_authority) ? "Yes" : "No")]"),
			"open_armory" = list("desc" = "Open armory doors", "type" = "boolean", "value" = "[(template.opendoors ? "Yes" : "No")]"),
			"leader_experience" = list("desc" = "Pick an experienced leader", "type" = "boolean", "value" = "[(template.leader_experience ? "Yes" : "No")]"),
			"random_names" = list("desc" = "Randomize names", "type" = "boolean", "value" = "[(template.random_names ? "Yes" : "No")]"),
			"spawn_admin" = list("desc" = "Spawn yourself as briefing officer", "type" = "boolean", "value" = "[(template.spawn_admin ? "Yes" : "No")]"),
		),
	)

	var/list/prefreturn = presentpreflikepicker(usr,"Customize ERT", "Customize ERT", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

	if (isnull(prefreturn))
		return FALSE

	if (prefreturn["button"] == 1)
		var/list/prefs = settings["mainsettings"]

		var/templtype = prefs["template"]["value"]
		if (!ispath(prefs["template"]["value"]))
			templtype = text2path(prefs["template"]["value"]) // new text2path ... doesn't compile in 511

		if (template.type != templtype)
			template = new templtype

		template.teamsize = prefs["teamsize"]["value"]
		template.mission = prefs["mission"]["value"]
		template.polldesc = prefs["polldesc"]["value"]
		template.enforce_human = prefs["enforce_human"]["value"] == "Yes" // these next 5 are effectively toggles
		template.opendoors = prefs["open_armory"]["value"] == "Yes"
		template.leader_experience = prefs["leader_experience"]["value"] == "Yes"
		template.random_names = prefs["random_names"]["value"] == "Yes"
		template.spawn_admin = prefs["spawn_admin"]["value"] == "Yes"

		var/list/spawnpoints = GLOB.emergencyresponseteamspawn
		var/index = 0

		if(template.spawn_admin)
			if(isobserver(usr))
				var/mob/living/carbon/human/admin_officer = new (spawnpoints[1])
				var/chosen_outfit = usr.client?.prefs?.read_preference(/datum/preference/choiced/brief_outfit)
				usr.client.prefs.safe_transfer_prefs_to(admin_officer, is_antag = TRUE)
				admin_officer.equipOutfit(chosen_outfit)
				admin_officer.key = usr.key
			else
				to_chat(usr, span_warning("Could not spawn you in as briefing officer as you are not a ghost!"))

		var/datum/poll_config/config = new()
		config.question = "Do you wish to be considered for [template.polldesc]?"
		config.check_jobban = ROLE_ERT
		config.role_name_text = "emergency response team"
		config.alert_pic = /obj/item/card/id/ert
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(config)
		if(!length(candidates))
			return FALSE

		var/teamSpawned = FALSE

		//Pick the (un)lucky players
		var/numagents = min(template.teamsize,candidates.len)

		//Create team
		var/datum/team/ert/ert_team = new template.team ()
		if(template.rename_team)
			ert_team.name = template.rename_team

		//Assign team objective
		var/datum/objective/missionobj = new ()
		missionobj.team = ert_team
		missionobj.explanation_text = template.mission
		missionobj.completed = TRUE
		ert_team.objectives += missionobj
		ert_team.mission = missionobj

		var/mob/dead/observer/earmarked_leader
		var/leader_spawned = FALSE // just in case the earmarked leader disconnects or becomes unavailable, we can try giving leader to the last guy to get chosen
		var/frontman_spawned = FALSE // if low_priority_leader = TRUE then we don't want to spawn a lead unless at least one other teammember is already spawned

		if(template.leader_experience)
			var/list/candidate_living_exps = list()
			for(var/i in candidates)
				var/mob/dead/observer/potential_leader = i
				candidate_living_exps[potential_leader] = potential_leader.client?.get_exp_living(TRUE)

			candidate_living_exps = sort_list(candidate_living_exps, cmp=/proc/cmp_numeric_dsc)
			if(candidate_living_exps.len > ERT_EXPERIENCED_LEADER_CHOOSE_TOP)
				candidate_living_exps = candidate_living_exps.Cut(ERT_EXPERIENCED_LEADER_CHOOSE_TOP+1) // pick from the top ERT_EXPERIENCED_LEADER_CHOOSE_TOP contenders in playtime
			earmarked_leader = pick(candidate_living_exps)
		else
			earmarked_leader = pick(candidates)

		while(numagents && candidates.len)
			var/spawnloc = spawnpoints[index+1]
			//loop through spawnpoints one at a time
			index = (index + 1) % spawnpoints.len
			var/mob/dead/observer/chosen_candidate
			var/list/mob/dead/observer/candidatesGuaranteedLeaderless = candidates
			candidatesGuaranteedLeaderless -= earmarked_leader
			if(template.low_priority_leader && !frontman_spawned && numagents > 1)
				chosen_candidate = pick(candidatesGuaranteedLeaderless)// this way we make sure our leader DOESN'T get chosen
			else
				chosen_candidate = earmarked_leader || pick(candidates) // this way we make sure that our leader gets chosen
			candidates -= chosen_candidate
			if(!chosen_candidate?.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/ert_operative = new template.mobtype(spawnloc)
			chosen_candidate.client.prefs.safe_transfer_prefs_to(ert_operative, is_antag = TRUE)
			ert_operative.key = chosen_candidate.key

			if(template.enforce_human || !(ert_operative.dna.species.changesource_flags & ERT_SPAWN)) // Don't want any exploding plasmemes
				ert_operative.set_species(/datum/species/human)

			//Give antag datum
			var/datum/antagonist/ert/ert_antag

			if(template.low_priority_leader && !frontman_spawned)
				ert_antag = template.roles[WRAP(numagents,1,length(template.roles) + 1)]
				ert_antag = new ert_antag ()
				frontman_spawned = TRUE
			else
				if((chosen_candidate == earmarked_leader) || (numagents == 1 && !leader_spawned))
					ert_antag = new template.leader_role()
					earmarked_leader = null
					leader_spawned = TRUE
				else
					ert_antag = template.roles[WRAP(numagents, 1, length(template.roles) + 1)]
					ert_antag = new ert_antag()
					frontman_spawned = TRUE

			ert_antag.random_names = template.random_names

			ert_operative.mind.add_antag_datum(ert_antag,ert_team)
			ert_operative.mind.assigned_role = ert_antag.name

			//Logging and cleanup
			log_game("[key_name(ert_operative)] has been selected as an [ert_antag.name]")
			numagents--
			teamSpawned++

		if (teamSpawned)
			message_admins("[template.polldesc] has spawned with the mission: [template.mission]")

		//Open the Armory doors
		if(template.opendoors)
			for(var/obj/machinery/door/poddoor/ert/door in GLOB.airlocks)
				door.open()
				CHECK_TICK
		return TRUE

	return

/datum/admins/proc/makeERTTemplateModified(list/settings)
	. = settings
	var/datum/ert/newtemplate = settings["mainsettings"]["template"]["value"]
	if (isnull(newtemplate))
		return
	if (!ispath(newtemplate))
		newtemplate = text2path(newtemplate)
	newtemplate = new newtemplate
	.["mainsettings"]["teamsize"]["value"] = newtemplate.teamsize
	.["mainsettings"]["mission"]["value"] = newtemplate.mission
	.["mainsettings"]["polldesc"]["value"] = newtemplate.polldesc
	.["mainsettings"]["open_armory"]["value"] = newtemplate.opendoors ? "Yes" : "No"
	.["mainsettings"]["leader_experience"]["value"] = newtemplate.leader_experience ? "Yes" : "No"
	.["mainsettings"]["random_names"]["value"] = newtemplate.random_names ? "Yes" : "No"
	.["mainsettings"]["spawn_admin"]["value"] = newtemplate.spawn_admin ? "Yes" : "No"

/datum/admins/proc/equipAntagOnDummy(mob/living/carbon/human/dummy/mannequin, datum/antagonist/antag)
	for(var/I in mannequin.get_equipped_items(INCLUDE_POCKETS))
		qdel(I)
	if (ispath(antag, /datum/antagonist/ert))
		var/datum/antagonist/ert/ert = antag
		mannequin.equipOutfit(initial(ert.outfit), TRUE)

/datum/admins/proc/makeERTPreviewIcon(list/settings)
	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_ADMIN)

	var/prefs = settings["mainsettings"]
	var/datum/ert/template = prefs["template"]["value"]
	if (isnull(template))
		return null
	if (!ispath(template))
		template = text2path(prefs["template"]["value"]) // new text2path ... doesn't compile in 511

	template = new template
	var/datum/antagonist/ert/ert = template.leader_role

	equipAntagOnDummy(mannequin, ert)

	COMPILE_OVERLAYS(mannequin)
	CHECK_TICK
	var/icon/preview_icon = icon('icons/effects/effects.dmi', "nothing")
	preview_icon.Scale(48+32, 16+32)
	CHECK_TICK
	mannequin.setDir(NORTH)
	var/icon/stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 25, 17)
	CHECK_TICK
	mannequin.setDir(WEST)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 1, 9)
	CHECK_TICK
	mannequin.setDir(SOUTH)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 49, 1)
	CHECK_TICK
	preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2) // Scaling here to prevent blurring in the browser.
	CHECK_TICK
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_ADMIN)
	return preview_icon

#undef ERT_EXPERIENCED_LEADER_CHOOSE_TOP
