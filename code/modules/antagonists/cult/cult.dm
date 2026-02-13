#define SUMMON_POSSIBILITIES 3

/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	ui_name = "AntagInfoBloodCult"
	antag_moodlet = /datum/mood_event/cult
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new
	var/datum/action/innate/cult/blood_magic/magic = new
	banning_key = ROLE_CULTIST
	required_living_playtime = 4
	var/ignore_implant = FALSE
	var/give_equipment = FALSE
	var/datum/team/cult/cult_team


/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
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
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(. && !ignore_implant)
		. = is_convertable_to_cult(new_owner.current,cult_team)

/datum/antagonist/cult/greet()
	to_chat(owner, span_userdanger("You are a member of the cult!"))
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Blood Cult",
		"Use your ritual dagger to draw runes with your blood and expand your cult until you have enough influence to summon the great Nar'Sie!")

/datum/antagonist/cult/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	if(give_equipment)
		equip_cultist(TRUE)
	add_antag_hud(ANTAG_HUD_CULT, "cult", current)
	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color="#960000")

	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image
	current.update_alt_appearances()

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
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction |= FACTION_CULT
	current.grant_language(/datum/language/narsie, source = LANGUAGE_CULTIST)
	if(!cult_team.cult_master)
		vote.Grant(current)
	communion.Grant(current)
	if(ishuman(current))
		magic.Grant(current)
	current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(cult_team.cult_risen)
		cult_team.rise(current)
		if(cult_team.cult_ascendent)
			cult_team.ascend(current)

/datum/antagonist/cult/master/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(!cult_team.reckoning_complete)
		reckoning.Grant(current)
	bloodmark.Grant(current)
	throwing.Grant(current)
	current.update_action_buttons_icon()
	current.apply_status_effect(/datum/status_effect/cult_master)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= FACTION_CULT
	current.remove_language(/datum/language/narsie, source = LANGUAGE_CULTIST)
	vote.Remove(current)
	communion.Remove(current)
	magic.Remove(current)
	current.clear_alert("bloodsense")
	if(ishuman(current))
		var/mob/living/carbon/human/H = current
		H.eye_color = initial(H.eye_color)
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		REMOVE_TRAIT(H, CULT_EYES, null)
		if (H.remove_overlay(HALO_LAYER))
			REMOVE_LUM_SOURCE(H, LUM_SOURCE_HOLY)
		H.update_body()

/datum/antagonist/cult/master/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	reckoning.Remove(current)
	bloodmark.Remove(current)
	throwing.Remove(current)
	current.update_action_buttons_icon()
	current.remove_status_effect(/datum/status_effect/cult_master)

/datum/antagonist/cult/on_removal()
	remove_antag_hud(ANTAG_HUD_CULT, owner.current)
	if(!silent)
		owner.current.visible_message("[span_deconversionmessage("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!")]", null, null, null, owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant."))
		owner.current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color="#960000")
	if(cult_team.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image
	owner.current.update_alt_appearances()
	. = ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src,PROC_REF(admin_give_dagger))
	.["Dagger and Metal"] = CALLBACK(src,PROC_REF(admin_give_metal))
	.["Remove Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_take_all))

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

/datum/antagonist/cult/master
	ignore_implant = TRUE
	show_in_antagpanel = FALSE //Feel free to add this later
	leave_behaviour = ANTAGONIST_LEAVE_KEEP
	var/datum/action/innate/cult/master/finalreck/reckoning = new
	var/datum/action/innate/cult/master/cultmark/bloodmark = new
	var/datum/action/innate/cult/master/pulse/throwing = new

/datum/antagonist/cult/master/Destroy()
	QDEL_NULL(reckoning)
	QDEL_NULL(bloodmark)
	QDEL_NULL(throwing)
	return ..()

/datum/antagonist/cult/master/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	set_antag_hud(current, "cultmaster")

/datum/antagonist/cult/master/greet()
	to_chat(owner.current, "[span_cultlarge("You are the cult's Master")]. As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
	targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of summoning the entire living cult to your location <b><i>once</i></b>.")
	to_chat(owner.current, "Use these abilities to direct the cult to victory at any cost.")

/datum/team/cult
	name = "Bloodcult"

	var/atom/blood_target
	var/image/blood_target_image
	var/blood_target_reset_timer

	var/cult_vote_called = FALSE
	var/mob/living/cult_master
	var/reckoning_complete = FALSE
	var/cult_risen = FALSE
	var/cult_ascendent = FALSE

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/// Sets a blood target for the cult.
/datum/team/cult/proc/set_blood_target(atom/new_target, mob/marker, duration = 90 SECONDS)
	if(QDELETED(new_target))
		CRASH("A null or invalid target was passed to set_blood_target.")

	if(blood_target_reset_timer)
		return FALSE

	blood_target = new_target
	RegisterSignal(blood_target, COMSIG_QDELETING, PROC_REF(unset_blood_target_and_timer))
	var/area/target_area = get_area(new_target)

	blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', new_target, "glow", ABOVE_MOB_LAYER)
	blood_target_image.appearance_flags = RESET_COLOR
	blood_target_image.pixel_x = -new_target.pixel_x
	blood_target_image.pixel_y = -new_target.pixel_y

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		to_chat(cultist.current, (("<span class='bold'><span class='cultlarge'>[marker] has marked [blood_target] in the [target_area.name] as the cult's top priority, get there immediately!</span></span>")))
		SEND_SOUND(cultist.current, sound(pick('sound/hallucinations/over_here2.ogg','sound/hallucinations/over_here3.ogg'), 0, 1, 75))
		cultist.current.client.images += blood_target_image

	blood_target_reset_timer = addtimer(CALLBACK(src, PROC_REF(unset_blood_target)), duration, TIMER_STOPPABLE)
	return TRUE

/// Unsets out blood target, clearing the images from all the cultists.
/datum/team/cult/proc/unset_blood_target()
	blood_target_reset_timer = null

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		if(QDELETED(blood_target))
			to_chat(cultist.current, (("<span class='bold'><span class='cultlarge'>The blood mark's target is lost!</span></span>")))
		else
			to_chat(cultist.current, (("<span class='bold'><span class='cultlarge'>The blood mark has expired!</span></span>")))
		cultist.current.client.images -= blood_target_image

	UnregisterSignal(blood_target, COMSIG_QDELETING)
	blood_target = null

	QDEL_NULL(blood_target_image)

/// Unsets our blood target when they get deleted.
/datum/team/cult/proc/unset_blood_target_and_timer(datum/source)
	SIGNAL_HANDLER

	deltimer(blood_target_reset_timer)
	unset_blood_target()

/datum/team/cult/proc/check_size()
	if(cult_ascendent)
		return
	var/alive = 0
	var/cultplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(IS_CULTIST(M))
				++cultplayers
			else
				++alive
	var/ratio = cultplayers/alive
	if(ratio > CULT_RISEN && !cult_risen)
		for(var/datum/mind/B in members)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/i_see_you2.ogg')
				to_chat(B.current, span_cultlarge("The veil weakens as your cult grows, your eyes begin to glow..."))
				log_game("The blood cult was given red eyes at cult population of [cultplayers].")
				addtimer(CALLBACK(src, PROC_REF(rise), B.current), 200)
		cult_risen = TRUE

	if(ratio > CULT_ASCENDENT && !cult_ascendent)
		for(var/datum/mind/B in members)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, span_cultlarge("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!"))
				log_game("The blood cult was given halos at cult population of [cultplayers].")
				addtimer(CALLBACK(src, PROC_REF(ascend), B.current), 200)
		cult_ascendent = TRUE


/datum/team/cult/proc/rise(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		H.eye_color = BLOODCULT_EYE
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		ADD_TRAIT(H, CULT_EYES, CULT_TRAIT)
		H.update_body()

/datum/team/cult/proc/ascend(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		if(istype(H.wear_neck, /obj/item/clothing/neck/cloak/fakehalo))
			H.dropItemToGround(H.wear_neck)
		if(H.overlays_standing[HALO_LAYER]) // It appears you have this already. Applying this again will break the overlay
			return
		new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
		var/istate = pick("halo1","halo2","halo3","halo4","halo5","halo6")
		var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', istate, CALCULATE_MOB_OVERLAY_LAYER(HALO_LAYER))
		new_halo_overlay.overlays.Add(emissive_appearance('icons/effects/32x64.dmi', istate, CALCULATE_MOB_OVERLAY_LAYER(HALO_LAYER), 160, filters = H.filters))
		ADD_LUM_SOURCE(H, LUM_SOURCE_HOLY)
		H.overlays_standing[HALO_LAYER] = new_halo_overlay
		H.apply_overlay(HALO_LAYER)


/datum/objective/sacrifice
	var/sacced = FALSE
	var/icon/sac_image

/datum/objective/sacrifice/proc/make_image()
	var/icon/reshape
	if(target)
		for(var/datum/record/locked/R as() in GLOB.manifest.locked)
			var/datum/mind/M = R.weakref_mind.resolve()
			if(target == M)
				reshape = R.character_appearance
				break
	if(!reshape)
		reshape = icon('icons/mob/observer.dmi', "ghost", SOUTH)
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	sac_image = reshape

/datum/objective/sacrifice/find_target(list/dupe_search_range, list/blacklist)
	if(!istype(team, /datum/team/cult))
		return
	var/list/target_candidates = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(is_valid_target(possible_target) && !is_convertable_to_cult(possible_target.current) && !(possible_target in blacklist))
			target_candidates += possible_target
	if(target_candidates.len == 0)
		message_admins("Cult Sacrifice: Could not find unconvertible target, checking for convertible target.")
		for(var/datum/mind/possible_target in get_crewmember_minds())
			if(is_valid_target(possible_target) && !(possible_target in blacklist))
				target_candidates += possible_target
	list_clear_nulls(target_candidates)
	if(LAZYLEN(target_candidates))
		set_target(pick(target_candidates))
	else
		message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. WELP!")
		set_target(null)
	update_explanation_text()

/datum/objective/sacrifice/set_target(datum/mind/new_target)
	..()
	make_image()
	for(var/datum/mind/M in get_owners())
		if(M.current)
			M.current.clear_alert("bloodsense")
			M.current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)

/datum/objective/sacrifice/on_target_cryo()
	find_target(null, list(target))
	update_explanation_text()
	var/message
	if(!target)
		message = "<BR>[span_userdanger("Your target is no longer within reach. The veil is now weak enough to proceed to the final objective.")]"
	else
		message = "<BR>[span_userdanger("You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")].")]"
	for(var/datum/mind/own as() in get_owners())
		to_chat(own.current, message)
		own.announce_objectives()

/datum/objective/sacrifice/is_valid_target(datum/mind/possible_target)
	if(!istype(possible_target) || !possible_target.current)
		return FALSE
	if(isipc(possible_target.current))
		return FALSE
	if(possible_target.has_antag_datum(/datum/antagonist/cult))
		return FALSE
	return ..()

/datum/objective/sacrifice/check_completion()
	//Target's a clockie
	if(target?.has_antag_datum(/datum/antagonist/servant_of_ratvar))
		return TRUE
	return sacced || !target || ..()

/datum/objective/sacrifice/update_explanation_text()
	if(target)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking a Sacrifice rune with [target.p_them()] on it and three acolytes around it."
	else
		explanation_text = "The veil has already been weakened here, proceed to the final objective."

/datum/objective/eldergod
	var/summoned = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon_area = pick(GLOB.areas - summon_spots)
		if(summon_area && is_station_level(summon_area.z) && (summon_area.area_flags & VALID_TERRITORY))
			summon_spots += summon_area
		sanity++
	update_explanation_text()

/datum/objective/eldergod/update_explanation_text()
	explanation_text = "Summon Nar'Sie by invoking the rune 'Summon Nar'Sie'. <b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/eldergod/check_completion()
	return summoned || ..()


/datum/team/cult/proc/setup_objectives()
	var/datum/objective/sacrifice/sac_objective = new
	sac_objective.team = src
	sac_objective.find_target()
	objectives += sac_objective

	var/datum/objective/eldergod/summon_objective = new
	summon_objective.team = src
	objectives += summon_objective

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			return FALSE
	return TRUE

/datum/team/cult/roundend_report()
	var/list/parts = list()

	if(check_cult_victory())
		parts += span_greentextbig("The cult has succeeded! Nar'Sie has snuffed out another torch in the void!")
	else
		parts += span_redtextbig("The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!")

	if(objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			parts += "<b>Objective #[count]</b>: [objective.get_completion_message()]"
			count++

	if(members.len)
		parts += span_header("The cultists were:")
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

#undef SUMMON_POSSIBILITIES
