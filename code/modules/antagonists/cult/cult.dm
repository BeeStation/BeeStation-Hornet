/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	ui_name = "AntagInfoBloodCult"
	antag_hud_name = "cult"
	antag_moodlet = /datum/mood_event/cult
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new
	var/datum/action/innate/cult/blood_magic/magic = new
	banning_key = ROLE_CULTIST
	required_living_playtime = 6
	var/give_equipment = FALSE
	var/datum/team/cult/cult_team

	///Mass teleport ability, only granted to the leader
	var/datum/action/innate/cult/master/finalreck/reckoning
	///Blood mark ability, only granted to the leader
	var/datum/action/innate/cult/master/cultmark/bloodmark
	///Blood pulse ability, only granted to the leader
	var/datum/action/innate/cult/master/pulse/throwing


/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.active_antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
	for(var/datum/objective/objective in (cult_team.objectives-objectives))
		log_objective(owner, objective.explanation_text)
	objectives |= cult_team.objectives

/datum/antagonist/cult/Destroy()
	QDEL_NULL(communion)
	QDEL_NULL(vote)
	QDEL_NULL(reckoning)
	QDEL_NULL(bloodmark)
	QDEL_NULL(throwing)
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	if(!is_convertable_to_cult(new_owner.current, cult_team))
		return FALSE
	return ..()

/datum/antagonist/cult/greet()
	to_chat(owner, span_userdanger("You are a member of the cult!"))
	owner.current.playsound_local(get_turf(owner.current), 'sound/effects/antag/bloodcult/bloodcult_gain.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Blood Cult",
		"Use your ritual dagger to draw runes with your blood and expand your cult until you have enough influence to summon the great Nar'Sie!")

/datum/antagonist/cult/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	if(give_equipment)
		equip_cultist(TRUE)

	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color="#960000")

/datum/antagonist/cult/proc/equip_cultist(metal=TRUE)
	var/mob/living/carbon/C = owner.current
	if(!istype(C))
		return
	handle_clown_mutation(C, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	. += cult_give_item(/obj/item/melee/cultblade/dagger, C)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, C)
	to_chat(owner, span_cult("These will help you start the cult on this station. Use them well, and remember - you are not the only one."))


/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)

	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		//Our last attempt, we force the item into the backpack
		if(istype(mob.back, /obj/item/storage/backpack))
			var/obj/item/storage/backpack/B = mob.back
			B.atom_storage?.attempt_insert(B, T, null, TRUE, TRUE)
			to_chat(mob, span_danger("You have a [item_name] in your backpack."))
			return TRUE
		else
			message_admins("[ADMIN_FULLMONTY(mob)] the cultist couldn't be equipped.")
			return FALSE
	else
		to_chat(mob, span_danger("You have a [item_name] in your [where]."))
		if(where == "backpack")
			mob.back.atom_storage?.show_contents(mob)
		return TRUE

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = mob_override || owner.current
	handle_clown_mutation(current, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	current.faction |= FACTION_CULT
	current.grant_language(/datum/language/narsie, source = LANGUAGE_CULTIST)

	current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image

	if(!cult_team.cult_leader_datum)
		vote.Grant(current)
	communion.Grant(current)
	if(ishuman(current))
		magic.Grant(current)
	if(is_cult_leader()) // Give them their abilities + a warning to cultists if they die
		grant_leader_abilities(current)
		RegisterSignal(current, COMSIG_MOB_STATCHANGE, PROC_REF(deathrattle))
	if(cult_team.cult_risen)
		current.AddElement(/datum/element/cult_eyes, initial_delay = 0 SECONDS)
	if(cult_team.cult_ascendent)
		current.AddElement(/datum/element/cult_halo, initial_delay = 0 SECONDS)

	add_team_hud(current, /datum/antagonist/cult)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current || mob_override
	current.faction -= FACTION_CULT
	current.remove_language(/datum/language/narsie, source = LANGUAGE_CULTIST)

	vote.Remove(current)
	communion.Remove(current)
	magic.Remove(current)
	remove_leader_abilities(current)
	UnregisterSignal(current, COMSIG_MOB_STATCHANGE)

	current.clear_alert("bloodsense")

	if (HAS_TRAIT(current, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		current.RemoveElement(/datum/element/cult_eyes)
	if (HAS_TRAIT(current, TRAIT_CULT_HALO))
		current.RemoveElement(/datum/element/cult_halo)

/datum/antagonist/cult/on_removal()
	if(!silent)
		owner.current.visible_message("[span_deconversionmessage("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!")]", null, null, null, owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant."))
		owner.current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color="#960000")
	if(is_cult_leader())
		cult_team.cult_leader_datum = null
	if(cult_team.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image
	owner.current.update_alt_appearances()
	. = ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src,PROC_REF(admin_give_dagger))
	.["Dagger and Metal"] = CALLBACK(src,PROC_REF(admin_give_metal))
	.["Remove Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_take_all))

	if(is_cult_leader())
		.["Demote From Leader"] = CALLBACK(src, PROC_REF(demote_from_leader))
	else if(!cult_team.cult_leader_datum)
		.["Make Cult Leader"] = CALLBACK(src, PROC_REF(make_cult_leader))

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(metal=FALSE))
		to_chat(admin, span_danger("Spawning dagger failed!"))

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(metal=TRUE))
		to_chat(admin, span_danger("Spawning runed metal failed!"))

/datum/antagonist/cult/proc/admin_take_all(mob/admin)
	var/mob/living/current = owner.current
	for(var/o in current.GetAllContents())
		if(istype(o, /obj/item/melee/cultblade/dagger) || istype(o, /obj/item/stack/sheet/runed_metal))
			qdel(o)

/datum/antagonist/cult/proc/is_cult_leader() // Are they the leader?
	return cult_team?.cult_leader_datum == src

/datum/antagonist/cult/proc/grant_leader_abilities(mob/living/current) // They got promoted or chosen, let's give them their abilities
	if(!cult_team.reckoning_complete)
		if(!reckoning)
			reckoning = new
		reckoning.Grant(current)
	if(!bloodmark)
		bloodmark = new
	if(!throwing)
		throwing = new
	bloodmark.Grant(current)
	throwing.Grant(current)
	current.update_action_buttons_icon()

/datum/antagonist/cult/proc/remove_leader_abilities(mob/living/current) // Opposite of giving, we take them away
	reckoning?.Remove(current)
	bloodmark?.Remove(current)
	throwing?.Remove(current)
	current.update_action_buttons_icon()

/datum/antagonist/cult/proc/make_cult_leader() // Let's make them the leader
	if(cult_team.cult_leader_datum)
		return FALSE
	cult_team.cult_leader_datum = src

	antag_hud_name = "cultmaster"
	leave_behaviour = ANTAGONIST_LEAVE_KEEP
	add_team_hud(owner.current, /datum/antagonist/cult)
	RegisterSignal(owner.current, COMSIG_MOB_STATCHANGE, PROC_REF(deathrattle))

	grant_leader_abilities(owner.current)

	for(var/datum/mind/cult_mind as anything in cult_team.members)
		if(!cult_mind.current)
			continue
		var/datum/antagonist/cult/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum?.vote.Remove(cult_mind.current)
		if(!cult_mind.current.incapacitated)
			to_chat(cult_mind.current, span_cultlarge("[owner.current] has won the cult's support and is now their master. Follow [owner.current.p_their()] orders to the best of your ability!"))

	to_chat(owner.current, "[span_cultlarge("You are the cult's Master")]. As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
	targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of summoning the entire living cult to your location <b><i>once</i></b>.")
	to_chat(owner.current, "Use these abilities to direct the cult to victory at any cost.")

	return TRUE

/datum/antagonist/cult/proc/demote_from_leader() // They got demoted from leader, let the cult choose a new one
	if(!is_cult_leader())
		return FALSE
	cult_team.cult_leader_datum = null
	cult_team.cult_vote_called = FALSE

	antag_hud_name = initial(antag_hud_name)
	leave_behaviour = initial(leave_behaviour)
	add_team_hud(owner.current, /datum/antagonist/cult)
	UnregisterSignal(owner.current, COMSIG_MOB_STATCHANGE)

	remove_leader_abilities(owner.current)

	for(var/datum/mind/cult_mind as anything in cult_team.members)
		if(!cult_mind.current)
			continue
		var/datum/antagonist/cult/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum?.vote.Grant(cult_mind.current)

	to_chat(owner.current, span_cultlarge("You have been demoted from being the cult's Master, you are now an acolyte once more!"))

	return TRUE

/datum/antagonist/cult/proc/deathrattle(datum/source) // Our leader is dead, what will we ever do
	SIGNAL_HANDLER

	if(owner.current.stat != DEAD)
		return
	if(!QDELETED(GLOB.narsie))
		return
	if(!is_cult_leader())
		return

	var/area/current_area = get_area(owner.current)
	for(var/datum/mind/cult_mind as anything in cult_team.members)
		if(!isliving(cult_mind.current))
			continue
		SEND_SOUND(cult_mind.current, sound('sound/hallucinations/veryfar_noise.ogg'))
		to_chat(cult_mind.current, span_cultlarge("The Cult's Master, [owner.current.name], has fallen in \the [current_area]!"))
