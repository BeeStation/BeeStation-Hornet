/* Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	- Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	- When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transferred to the new mob like so:

			mind.transfer_to(new_mob)

	- You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transferring the mind with transfer_to you will cause bugs like DCing
		the player.

	- IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	- When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mind for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	/// Key of the mob
	var/key
	/// The display name of the mob (client.display_name())
	var/display_name
	/// The display name of this mob, with an icon if applicable
	var/display_name_chat
	/// The name linked to this mind
	var/name
	/// replaces name for observers name if set
	var/ghostname
	/// Current mob this mind datum is attached to
	var/mob/living/current
	/// Is this mind active?
	var/active = FALSE

	var/memory
	var/list/quirks = list()

	/// The role that this mob was assigned, as a text value, may be a job which GetJob can be called to fetch
	var/assigned_role
	var/special_role
	var/list/restricted_roles = list()
	/// Martial art on this mind
	var/datum/martial_art/martial_art = null
	var/static/default_martial_art = new/datum/martial_art
	var/list/antag_datums
	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/holy_role = NONE //is this person a chaplain or admin role allowed to use bibles, Any rank besides 'NONE' allows for this.
	var/isAntagTarget = FALSE
	var/no_cloning_at_all = FALSE

	var/datum/mind/enslaved_to //If this mind's master is another mob (i.e. adamantine golems)
	var/unconvertable = FALSE
	var/late_joiner = FALSE

	var/last_death = 0

	var/force_escaped = FALSE  // Set by Into The Sunset command of the shuttle manipulator

	var/list/learned_recipes //List of learned recipe TYPES.
	var/list/crew_objectives = list()

	/// A lazy list of statuses to add next to this mind in the traitor panel
	var/list/special_statuses
	/// your bank account id in your mind
	var/account_id
	/// A holder datum used to handle holoparasites and their shared behavior.
	var/datum/holoparasite_holder/holoparasite_holder

	/// A list of all antag stashes that we can see
	var/list/antag_stashes = null

	/// Boolean value indicating if the mob attached to this mind entered cryosleep.
	var/cryoed = FALSE

	/// What color our soul is
	var/soul_glimmer

	///Assoc list of addiction values, key is the type of withdrawal (as singleton type), and the value is the amount of addiction points (as number)
	var/list/addiction_points
	///Assoc list of key active addictions and value amount of cycles that it has been active.
	var/list/active_addictions

/datum/mind/New(key)
	src.key = key
	var/client/found_client = GLOB.directory[ckey(key)]
	if(found_client)
		src.display_name = found_client.display_name()
		src.display_name_chat = found_client.display_name_chat()
	martial_art = default_martial_art
	setup_soul_glimmer()

/datum/mind/Destroy()
	SSticker.minds -= src
	QDEL_LIST(antag_datums)
	set_current(null)
	return ..()

/datum/mind/proc/set_current(mob/new_current)
	if(new_current && QDELING(new_current))
		CRASH("Tried to set a mind's current var to a qdeleted mob, what the fuck")
	if(current)
		UnregisterSignal(src, COMSIG_QDELETING)
	current = new_current
	if(current)
		RegisterSignal(src, COMSIG_QDELETING, PROC_REF(clear_current))

/datum/mind/proc/clear_current(datum/source)
	SIGNAL_HANDLER
	set_current(null)

/datum/mind/proc/transfer_to(mob/new_character, force_key_move = 0)
	if(current)	// remove ourself from our old body's mind variable
		current.mind = null
		UnregisterSignal(current, COMSIG_LIVING_DEATH)
		SStgui.on_transfer(current, new_character)

	if(key)
		if(new_character.key != key)					//if we're transferring into a body with a key associated which is not ours
			new_character.ghostize(TRUE,SENTIENCE_ERASE)						//we'll need to ghostize so that key isn't mobless.
	else
		key = new_character.key
		var/client/found_client = GLOB.directory[ckey(key)]
		if(found_client)
			src.display_name = found_client.display_name()
			src.display_name_chat = found_client.display_name_chat()

	if(new_character.mind)								//disassociate any mind curently in our new body's mind variable
		new_character.mind.set_current(null)

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud//we need this because leave_hud() will clear this list
	var/mob/living/old_current = current
	if(old_current)
		//transfer anyone observing the old character to the new one
		old_current.transfer_observers_to(new_character)

		// Offload all mind languages from the old holder to a temp one
		var/datum/language_holder/empty/temp_holder = new()
		var/datum/language_holder/old_holder = old_current.get_language_holder()
		var/datum/language_holder/new_holder = new_character.get_language_holder()
		// Off load mind languages to the temp holder momentarily
		new_holder.transfer_mind_languages(temp_holder)
		// Transfer the old holder's mind languages to the new holder
		old_holder.transfer_mind_languages(new_holder)
		// And finally transfer the temp holder's mind languages back to the old holder
		temp_holder.transfer_mind_languages(old_holder)

	set_current(new_character) //associate ourself with our new body
	new_character.mind = src							//and associate our new body with ourself

	for(var/datum/quirk/T as() in quirks) //Retarget all traits this mind has
		T.transfer_mob(new_character)
	for(var/a in antag_datums)	//Makes sure all antag datums effects are applied in the new body
		var/datum/antagonist/A = a
		A.on_body_transfer(old_current, current)
	if(iscarbon(new_character))
		var/mob/living/carbon/C = new_character
		C.last_mind = src
	transfer_antag_huds(hud_to_transfer) //Inherit the antag HUD
	transfer_martial_arts(new_character) //Todo: Port this proc
	RegisterSignal(new_character, COMSIG_LIVING_DEATH, PROC_REF(set_death_time))
	if(active || force_key_move)
		new_character.key = key //now transfer the key to link the client to our new body
	if(new_character.client)
		LAZYCLEARLIST(new_character.client.recent_examines)

	SEND_SIGNAL(src, COMSIG_MIND_TRANSFERRED, old_current)
	SEND_SIGNAL(src, COMSIG_MIND_TRANSFER_TO, old_current, new_character)
	// Update SSD indicators
	if(isliving(old_current))
		old_current.med_hud_set_status()
	if(isliving(current))
		current.med_hud_set_status()

/datum/mind/proc/set_death_time()
	SIGNAL_HANDLER

	last_death = world.time

/datum/mind/proc/store_memory(new_text)
	var/newlength = length(memory) + length(new_text)
	if(newlength > MAX_MESSAGE_LEN * 100)
		memory = copytext(memory, -newlength-MAX_MESSAGE_LEN * 100)
	memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null

// Datum antag mind procs
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team, datum/dynamic_ruleset/ruleset)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/A
	if(!ispath(datum_type_or_instance))
		A = datum_type_or_instance
		if(!istype(A))
			return
	else
		A = new datum_type_or_instance()
	//Choose snowflake variation if antagonist handles it
	var/datum/antagonist/S = A.specialization(src)
	if(S && S != A)
		qdel(A)
		A = S
	if(!A.can_be_owned(src))
		qdel(A)
		return
	A.owner = src
	LAZYADD(antag_datums, A)
	A.create_team(team)
	S.spawning_ruleset = ruleset
	var/datum/team/antag_team = A.get_team()
	if(antag_team)
		antag_team.add_member(src)
	INVOKE_ASYNC(A, TYPE_PROC_REF(/datum/antagonist, on_gain))
	log_game("[key_name(src)] has gained antag datum [A.name]([A.type])")
	return A

/datum/mind/proc/remove_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/antag = has_antag_datum(datum_type)
	if(antag)
		antag.on_removal()
		return TRUE

/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	for(var/datum/antagonist/antag as anything in antag_datums)
		antag.on_removal()

/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	RETURN_TYPE(/datum/antagonist)
	if(!datum_type)
		return

	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

/datum/mind/proc/equip_traitor(datum/antagonist/traitor/antag_datum, employer = "The Syndicate", silent = FALSE, datum/antagonist/uplink_owner, telecrystals = TELECRYSTALS_DEFAULT)
	if(!current)
		return
	var/mob/living/carbon/human/traitor_mob = current
	if (!istype(traitor_mob))
		return

	var/obj/item/implant/uplink/starting/I = new(traitor_mob)
	I.implant(traitor_mob, null, silent = TRUE)
	var/datum/component/uplink/U = I.GetComponents(/datum/component/uplink)[1]
	if(!silent)
		U.unlock_text = "[employer] [employer == "You" ? "have" : "has"] cunningly implanted [employer == "You" ? "yourself" : "you"] with a Syndicate Uplink. Simply trigger the uplink to access it."
		to_chat(traitor_mob, span_boldnotice("[U.unlock_text]"))
		traitor_mob.mind.store_memory()
	return I

/datum/mind/proc/equip_standard_uplink(employer = "The Syndicate", silent = FALSE, datum/antagonist/uplink_owner, telecrystals = TELECRYSTALS_DEFAULT, directive_flags = NONE)
	RETURN_TYPE(/datum/component/uplink)
	if(!current)
		return
	var/mob/living/carbon/human/traitor_mob = current
	if (!istype(traitor_mob))
		return
	if (!traitor_mob.mind)
		return

	var/list/all_contents = traitor_mob.GetAllContents()
	var/obj/item/modular_computer/tablet/pda/PDA = locate() in all_contents
	var/obj/item/radio/R = locate() in all_contents
	var/obj/item/pen/P

	if (PDA) // Prioritize PDA pen, otherwise the pocket protector pens will be chosen, which causes numerous ahelps about missing uplink
		P = locate() in PDA
	if (!P) // If we couldn't find a pen in the PDA, or we didn't even have a PDA, do it the old way
		P = locate() in all_contents
		if(!P) // I do not have a pen.
			var/obj/item/pen/inowhaveapen
			if(istype(traitor_mob.back,/obj/item/storage)) //ok buddy you better have a backpack!
				inowhaveapen = new /obj/item/pen(traitor_mob.back)
			else
				inowhaveapen = new /obj/item/pen(traitor_mob.loc)
				traitor_mob.put_in_hands(inowhaveapen) // I hope you don't have arms and your traitor pen gets stolen for all this trouble you've caused.
			P = inowhaveapen

	var/obj/item/uplink_loc

	var/uplink_spawn_location = traitor_mob.client?.prefs?.read_character_preference(/datum/preference/choiced/uplink_location)
	switch(uplink_spawn_location)
		if(UPLINK_PDA)
			uplink_loc = PDA
			if(!uplink_loc)
				uplink_loc = R
			if(!uplink_loc)
				uplink_loc = P
		if(UPLINK_RADIO)
			if(HAS_TRAIT(traitor_mob, TRAIT_MUTE))  // cant speak code into headset
				to_chat(traitor_mob, "Using a radio uplink would be impossible with your muteness! Equipping PDA Uplink..")
				uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R
				if(!uplink_loc)
					uplink_loc = P
			else
				uplink_loc = R
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = P
		if(UPLINK_PEN)
			uplink_loc = P

	var/datum/component/uplink/U = uplink_loc.AddComponent(/datum/component/uplink, traitor_mob.mind, TRUE, FALSE, starting_tc = telecrystals, directive_flags = directive_flags)
	if(!U)
		CRASH("Uplink creation failed.")
	U.setup_unlock_code()
	if(uplink_loc == R)
		U.unlock_text = "[employer] [employer == "You" ? "have" : "has"] cunningly disguised a Syndicate Uplink as your [R.name]. Simply speak [U.unlock_code] into the :d channel to unlock its hidden features."
	else if(uplink_loc == PDA)
		U.unlock_text = "[employer] [employer == "You" ? "have" : "has"] cunningly disguised a Syndicate Uplink as your [PDA.name]. Simply enter the code \"[U.unlock_code]\" into the ring tone selection to unlock its hidden features."
	else if(uplink_loc == P)
		U.unlock_text = "[employer] [employer == "You" ? "have" : "has"] cunningly disguised a Syndicate Uplink as your [P.name]. Simply twist the top of the pen [english_list(U.unlock_code)] from its starting position to unlock its hidden features."
	if(!silent)
		to_chat(traitor_mob, span_traitorobjective("[U.unlock_text]"))

	if(uplink_owner)
		uplink_owner.antag_memory += U.unlock_note + "<br>"
	else
		traitor_mob.mind.store_memory(U.unlock_note)
	return U

//Link a new mobs mind to the creator of said mob. They will join any team they are currently on, and will only switch teams when their creator does.

/datum/mind/proc/enslave_mind_to_creator(datum/mind/creator)
	if(ismob(creator))
		var/mob/mob_creator = creator
		creator = mob_creator.mind
	if(!creator || !istype(creator))
		return
	var/datum/antagonist/master_cultist = creator.has_antag_datum(/datum/antagonist/cult)
	if(master_cultist)
		add_antag_datum(/datum/antagonist/cult, ruleset = master_cultist.spawning_ruleset)
	else if(creator.has_antag_datum(/datum/antagonist/servant_of_ratvar))
		INVOKE_ASYNC(src, PROC_REF(add_servant_of_ratvar), current, TRUE)
	if(creator.has_antag_datum(/datum/antagonist/rev))
		var/datum/antagonist/rev/converter = creator.has_antag_datum(/datum/antagonist/rev, TRUE)
		converter.add_revolutionary(src, FALSE)
	var/datum/antagonist/nukeop/creator_nukie = creator.has_antag_datum(/datum/antagonist/nukeop, TRUE)
	if(creator_nukie)
		var/datum/antagonist/nukeop/nukie_datum = new()
		nukie_datum.send_to_spawnpoint = FALSE
		nukie_datum.nukeop_outfit = null
		add_antag_datum(nukie_datum, creator_nukie.nuke_team, ruleset = nukie_datum.spawning_ruleset)
	enslaved_to = creator
	if(creator.current)
		current.faction |= creator.current.faction
		creator.current.faction |= current.faction
	if(creator.special_role)
		message_admins("[ADMIN_LOOKUPFLW(current)] has been created by [ADMIN_LOOKUPFLW(creator.current)], an antagonist.")
		to_chat(current, span_userdanger("Despite your creator's current allegiances, your true master remains [creator.name]. If their loyalties change, so do yours. This will never change unless your creator's body is destroyed."))

/datum/mind/proc/show_memory(mob/recipient, window=1)
	if(!recipient)
		recipient = current
	var/output = "<B>[current.real_name]'s Memories:</B><br>"
	output += memory


	var/list/antag_objectives = get_all_antag_objectives()
	for(var/datum/antagonist/A in antag_datums)
		output += A.antag_memory

	if(antag_objectives.len)
		output += "<br><B>Objectives:</B>"
		var/obj_count = 1
		for(var/datum/objective/objective in antag_objectives)
			output += "<br><B>Objective #[obj_count++]</B>: [objective.explanation_text]"
			if (objective.name == "gimmick")
				output += " - This objective is optional and not tracked, so just have fun with it!"
			var/list/datum/mind/other_owners = objective.get_owners() - src
			if(other_owners.len)
				output += "<ul>"
				for(var/datum/mind/M in other_owners)
					output += "<li>Conspirator: [M.name]</li>"
				output += "</ul>"
	if(crew_objectives.len)
		output += "<br><B>Optional Objectives:</B>"
		for(var/datum/objective/objective as() in crew_objectives)
			output += "<br>[objective.explanation_text]"

	if(window)
		recipient << browse(HTML_SKELETON(output),"window=memory")
	else if(antag_objectives.len || crew_objectives.len || memory)
		to_chat(recipient, "<i>[output]</i>")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	var/self_antagging = usr == current

	if(href_list["add_antag"])
		add_antag_wrapper(text2path(href_list["add_antag"]),usr)
	if(href_list["remove_antag"])
		var/datum/antagonist/A = locate(href_list["remove_antag"]) in antag_datums
		if(!istype(A))
			to_chat(usr,span_warning("Invalid antagonist ref to be removed."))
			return
		A.admin_remove(usr)

	if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in sort_list(get_all_jobs())
		if (!new_role)
			return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = stripped_multiline_input(usr, "Write new memory", "Memory", memory, MAX_MESSAGE_LEN)
		if (isnull(new_memo))
			return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/objective_pos //Edited objectives need to keep same order in antag objective list
		var/def_value
		var/datum/antagonist/target_antag
		var/datum/objective/old_objective //The old objective we're replacing/editing
		var/datum/objective/new_objective //New objective we're be adding

		if(href_list["obj_edit"])
			for(var/datum/antagonist/A in antag_datums)
				old_objective = locate(href_list["obj_edit"]) in A.objectives
				if(old_objective)
					target_antag = A
					objective_pos = A.objectives.Find(old_objective)
					break
			if(!old_objective)
				to_chat(usr,"Invalid objective.")
				return
		else
			if(href_list["target_antag"])
				var/datum/antagonist/X = locate(href_list["target_antag"]) in antag_datums
				if(X)
					target_antag = X
			if(!target_antag)
				switch(antag_datums.len)
					if(0)
						target_antag = add_antag_datum(/datum/antagonist/custom)
					if(1)
						target_antag = antag_datums[1]
					else
						var/datum/antagonist/target = input("Which antagonist gets the objective:", "Antagonist", "(new custom antag)") as null|anything in sort_list(antag_datums) + "(new custom antag)"
						if (QDELETED(target))
							return
						else if(target == "(new custom antag)")
							target_antag = add_antag_datum(/datum/antagonist/custom)
						else
							target_antag = target

		if(!GLOB.admin_objective_list)
			generate_admin_objective_list()

		if(old_objective)
			if(old_objective.name in GLOB.admin_objective_list)
				def_value = old_objective.name

		var/selected_type = tgui_input_list(usr, "Select objective type:", "Objective type", GLOB.admin_objective_list, def_value)
		selected_type = GLOB.admin_objective_list[selected_type]
		if (!selected_type)
			return

		if(!old_objective)
			//Add new one
			new_objective = new selected_type
			new_objective.owner = src
			new_objective.admin_edit(usr)
			target_antag.objectives += new_objective
			message_admins("[key_name_admin(usr)] added a new objective for [current]: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] added a new objective for [current]: [new_objective.explanation_text]")
			log_objective(new_objective.owner, new_objective.explanation_text, usr)
		else
			if(old_objective.type == selected_type)
				//Edit the old
				old_objective.admin_edit(usr)
				new_objective = old_objective
			else
				//Replace the old
				new_objective = new selected_type
				new_objective.owner = src
				new_objective.admin_edit(usr)
				target_antag.objectives -= old_objective
				target_antag.objectives.Insert(objective_pos, new_objective)
			message_admins("[key_name_admin(usr)] edited [current]'s objective to [new_objective.explanation_text]")
			log_admin("[key_name(usr)] edited [current]'s objective to [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective
		for(var/datum/antagonist/A in antag_datums)
			objective = locate(href_list["obj_delete"]) in A.objectives
			if(istype(objective))
				A.objectives -= objective
				break
		if(!objective)
			to_chat(usr,"Invalid objective.")
			return
		//qdel(objective) Needs cleaning objective destroys
		message_admins("[key_name_admin(usr)] removed an objective for [current]: [objective.explanation_text]")
		log_admin("[key_name(usr)] removed an objective for [current]: [objective.explanation_text]")

	else if(href_list["obj_completed"])
		var/datum/objective/objective
		for(var/datum/antagonist/A in antag_datums)
			objective = locate(href_list["obj_completed"]) in A.objectives
			if(istype(objective))
				objective = objective
				break
		if(!objective)
			to_chat(usr,"Invalid objective.")
			return
		objective.completed = !objective.completed
		log_admin("[key_name(usr)] toggled the win state for [current]'s objective: [objective.explanation_text]")

	else if (href_list["silicon"])
		switch(href_list["silicon"])
			if("unemag")
				var/mob/living/silicon/robot/R = current
				if (istype(R))
					R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [R].")
					log_admin("[key_name(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if(isAI(current))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")
					log_admin("[key_name(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.dropItemToGround(W, TRUE) //The TRUE forces all items to drop, since this is an admin undress.
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
				log_admin("[key_name(usr)] removed [current]'s uplink.")
			if("crystals")
				if(check_rights(R_FUN, 0))
					var/datum/component/uplink/U = find_syndicate_uplink()
					if(U)
						var/crystals = input("Amount of telecrystals for [key]","Syndicate uplink", U.telecrystals) as null | num
						if(!isnull(crystals))
							U.telecrystals = crystals
							message_admins("[key_name_admin(usr)] changed [current]'s telecrystal count to [crystals].")
							log_admin("[key_name(usr)] changed [current]'s telecrystal count to [crystals].")
			if("uplink")
				if(!equip_traitor(has_antag_datum(/datum/antagonist/traitor)))
					to_chat(usr, span_danger("Equipping a syndicate failed!"))
					log_admin("[key_name(usr)] tried and failed to give [current] an uplink.")
				else
					log_admin("[key_name(usr)] gave [current] an uplink.")

	else if (href_list["obj_announce"])
		announce_objectives()

	//Something in here might have changed your mob
	if(self_antagging && (!usr || !usr.client) && current.client)
		usr = current
	traitor_panel()


/datum/mind/proc/get_all_antag_objectives()
	var/list/antag_objectives = list()
	for(var/datum/antagonist/A in antag_datums)
		antag_objectives |= A.objectives
		var/datum/team/team = A.get_team()
		if(team)
			antag_objectives |= team.objectives
	return antag_objectives

/datum/mind/proc/get_all_objectives()
	return get_all_antag_objectives() | crew_objectives

/datum/mind/proc/is_murderbone()
	if(enslaved_to?.is_murderbone())
		return TRUE
	for(var/datum/objective/O as() in get_all_objectives())
		if(O.murderbone_flag)
			return TRUE
	return FALSE

/datum/mind/proc/announce_objectives()
	var/obj_count = 1
	var/list/antag_objectives = get_all_antag_objectives()
	if(antag_objectives.len)
		to_chat(current, span_notice("Your current objectives:"))
		for(var/datum/objective/O as() in antag_objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [O.explanation_text]")
			obj_count++
		// Objectives are often stored in the static data of antag uis, so we should update those as well
		for(var/datum/antagonist/antag as anything in antag_datums)
			antag.update_static_data(current)
	if(crew_objectives.len)
		to_chat(current, span_notice("Your optional objectives:"))
		for(var/datum/objective/C as() in crew_objectives)
			to_chat(current, "[C.explanation_text]")

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.GetAllContents()
	for (var/i in L)
		var/atom/movable/I = i
		for (var/datum/component/uplink/uplink in I.GetComponents(/datum/component/uplink))
			if (uplink.owner == src || !uplink.owner)
				return uplink

/datum/mind/proc/take_uplink()
	qdel(find_syndicate_uplink())

/datum/mind/proc/transfer_martial_arts(mob/living/new_character)
	if(!ishuman(new_character))
		return
	if(martial_art)
		if(martial_art.base) //Is the martial art temporary?
			martial_art.remove(new_character)
		else
			martial_art.teach(new_character)
/datum/mind/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	for(var/mob/dead/observer/G in (ghosts_with_clients ? GLOB.player_list : GLOB.dead_mob_list))
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()

/// Sets our can_hijack to the fastest speed our antag datums allow.
/datum/mind/proc/get_hijack_speed()
	. = 0
	if(enslaved_to)
		. = max(., enslaved_to.get_hijack_speed())
	for(var/datum/antagonist/A in antag_datums)
		. = max(., A.hijack_speed())

/datum/mind/proc/has_objective(objective_type)
	for(var/datum/antagonist/A in antag_datums)
		for(var/O in A.objectives)
			if(istype(O,objective_type))
				return TRUE

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

/datum/mind/proc/has_martialart(string)
	if(martial_art && martial_art.id == string)
		return martial_art
	return FALSE

///Adds addiction points to the specified addiction
/datum/mind/proc/add_addiction_points(type, amount)
	LAZYSET(addiction_points, type, min(LAZYACCESS(addiction_points, type) + amount, MAX_ADDICTION_POINTS))
	var/datum/addiction/affected_addiction = SSaddiction.all_addictions[type]
	return affected_addiction.on_gain_addiction_points(src)

///Adds addiction points to the specified addiction
/datum/mind/proc/remove_addiction_points(type, amount)
	LAZYSET(addiction_points, type, max(LAZYACCESS(addiction_points, type) - amount, 0))
	var/datum/addiction/affected_addiction = SSaddiction.all_addictions[type]
	return affected_addiction.on_lose_addiction_points(src)

/mob/dead/new_player/sync_mind()
	return

/mob/dead/observer/sync_mind()
	return

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key
		var/client/found_client = GLOB.directory[ckey(key)]
		if(found_client)
			mind.display_name = found_client.display_name()
			mind.display_name_chat = found_client.display_name_chat()

	else
		mind = new /datum/mind(key)
		SSticker.minds += mind
	if(!mind.name)
		mind.name = real_name
	mind.set_current(src)

/mob/living/carbon/mind_initialize()
	..()
	last_mind = mind

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "Unassigned" //default

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = JOB_NAME_AI

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = JOB_NAME_CYBORG

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = ROLE_PAI
	mind.special_role = ""

// Quirk Procs //

/datum/mind/proc/add_quirk(quirktype, spawn_effects) //separate proc due to the way these ones are handled
	if(HAS_TRAIT(src, quirktype))
		return
	var/datum/quirk/T = quirktype
	var/qname = initial(T.name)
	if(!SSquirks || !SSquirks.quirks[qname])
		return
	new quirktype (src, current, spawn_effects)
	return TRUE

/datum/mind/proc/remove_quirk(quirktype)
	for(var/datum/quirk/Q in quirks)
		if(Q.type == quirktype)
			qdel(Q)
			return TRUE
	return FALSE

/datum/mind/proc/remove_all_quirks()
	for(var/datum/quirk/Q in quirks)
		qdel(Q)

/datum/mind/proc/has_quirk(quirktype)
	for(var/datum/quirk/Q in quirks)
		if(Q.type == quirktype)
			return TRUE
	return FALSE

/datum/mind/proc/holoparasite_holder()
	if(!holoparasite_holder)
		holoparasite_holder = new(src)
	return holoparasite_holder

/datum/mind/proc/setup_soul_glimmer()
	// initialise to calculate how many soul colours will be given to people
	var/static/max_soul_pool
	if(!max_soul_pool)
		var/pop_value = length(GLOB.player_list)
		var/decrement = SOUL_GLIMMER_POP_REQ_CREEP_STARTING
		while(pop_value > 0)
			pop_value -= decrement++ // 4, 5, 6, 7...
			max_soul_pool++
			if(max_soul_pool >= length(GLOB.soul_glimmer_colors))
				break // Failsafe loop even if our codebase won't have +100 pop count...
		max_soul_pool = clamp(max_soul_pool, SOUL_GLIMMER_MINIMUM_POP_COLOR, length(GLOB.soul_glimmer_colors))

	// build a list for colours to give
	var/static/list/options_to_give
	if(!length(options_to_give))
		options_to_give = GLOB.soul_glimmer_colors.Copy(1, max_soul_pool+1) // Copy(1, 3) = copy items 1-2. Not 3. Be careful.

	soul_glimmer = pick_n_take(options_to_give)
