
////////////////////////////////////////////////////////SLIMEPEOPLE///////////////////////////////////////////////////////////////////

//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

/datum/species/oozeling/slime
	name = "Slimeperson"
	plural_form = "Slimepeople"
	id = SPECIES_SLIMEPERSON
	default_color = "00FFFF"
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		HAIR,
		FACEHAIR,
	)
	inherent_traits = list(
		TRAIT_NOBLOOD
	)
	hair_color = "mutcolor"
	hair_alpha = 150
	var/datum/action/innate/split_body/slime_split
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/swap_body/swap_body

	species_chest = /obj/item/bodypart/chest/slime
	species_head = /obj/item/bodypart/head/slime
	species_l_arm = /obj/item/bodypart/l_arm/slime
	species_r_arm = /obj/item/bodypart/r_arm/slime
	species_l_leg = /obj/item/bodypart/l_leg/slime
	species_r_leg = /obj/item/bodypart/r_leg/slime


/datum/species/oozeling/slime/on_species_loss(mob/living/carbon/C)
	if(slime_split)
		slime_split.Remove(C)
	if(swap_body)
		swap_body.Remove(C)
	bodies -= C // This means that the other bodies maintain a link
	// so if someone mindswapped into them, they'd still be shared.
	bodies = null
	C.blood_volume = min(C.blood_volume, BLOOD_VOLUME_NORMAL)
	..()

/datum/species/oozeling/slime/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		slime_split = new
		slime_split.Grant(C)
		swap_body = new
		swap_body.Grant(C)

		if(!bodies || !bodies.len)
			bodies = list(C)
		else
			bodies |= C

/datum/species/oozeling/slime/spec_death(gibbed, mob/living/carbon/human/H)
	if(slime_split)
		if(!H.mind || !H.mind.active)
			return

		var/list/available_bodies = (bodies - H)
		for(var/mob/living/L in available_bodies)
			if(!swap_body.can_swap(L))
				available_bodies -= L

		if(!LAZYLEN(available_bodies))
			return

		swap_body.swap_to_dupe(H.mind, pick(available_bodies))

//If you're cloned you get your body pool back
/datum/species/oozeling/slime/copy_properties_from(datum/species/oozeling/slime/old_species)
	bodies = old_species.bodies

/datum/species/oozeling/slime/spec_life(mob/living/carbon/human/H)
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(prob(5))
			to_chat(H, span_notice("You feel very bloated!"))
	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.blood_volume += 3
		H.adjust_nutrition(-2.5)

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/is_available()
	if(..())
		var/mob/living/carbon/human/H = owner
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			return 1
		return 0

/datum/action/innate/split_body/on_activate()
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return
	CHECK_DNA_AND_SPECIES(H)

	//Prevent one person from creating 100 bodies.
	var/datum/species/oozeling/slime/species = H.dna.species
	if(length(species.bodies) > CONFIG_GET(number/max_slimeperson_bodies))
		to_chat(H, span_warning("Your mind is spread too thin! You have too many bodies already."))
		return

	H.visible_message(span_notice("[owner] gains a look of concentration while standing perfectly still."), span_notice("You focus intently on moving your body while standing perfectly still..."))

	H.notransform = TRUE

	if(do_after(owner, delay = 6 SECONDS, target = owner, timed_action_flags = IGNORE_HELD_ITEM))
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(H, span_warning("...but fail to stand perfectly still!"))

	H.notransform = FALSE

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/H = owner
	CHECK_DNA_AND_SPECIES(H)

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)

	spare.underwear = "Nude"
	H.dna.transfer_identity(spare, transfer_SE=1)
	spare.dna.features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.updateappearance(mutcolor_update=1)
	spare.domutcheck()
	spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))

	var/datum/component/nanites/owner_nanites = H.GetComponent(/datum/component/nanites)
	if(owner_nanites)
		//copying over nanite programs/cloud sync with 50% saturation in host and spare
		owner_nanites.nanite_volume *= 0.5
		spare.AddComponent(/datum/component/nanites, owner_nanites.nanite_volume)
		SEND_SIGNAL(spare, COMSIG_NANITE_SYNC, owner_nanites, TRUE, TRUE, TRUE) //The trues are to copy activation as well

	H.blood_volume *= 0.45
	H.notransform = 0

	var/datum/species/oozeling/slime/origin_datum = H.dna.species
	origin_datum.bodies |= spare

	var/datum/species/oozeling/slime/spare_datum = spare.dna.species
	spare_datum.bodies = origin_datum.bodies

	H.mind.transfer_to(spare)
	spare.visible_message(span_warning("[H] distorts as a new body \"steps out\" of [H.p_them()]."), span_notice("...and after a moment of disorentation, you're besides yourself!"))


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = NONE
	button_icon_state = "slimeswap"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/swap_body/on_activate()
	if(!isslimeperson(owner))
		to_chat(owner, span_warning("You are not a slimeperson."))
		Remove(owner)
	else
		ui_interact(owner)


/datum/action/innate/swap_body/ui_state(mob/user)
	return GLOB.always_state

/datum/action/innate/swap_body/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeBodySwapper")
		ui.open()
		ui.set_autoupdate(TRUE) // Body status (health, occupied, etc.)

/datum/action/innate/swap_body/ui_data(mob/user)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return

	var/datum/species/oozeling/slime/SS = H.dna.species

	var/list/data = list()
	data["bodies"] = list()
	for(var/b in SS.bodies)
		var/mob/living/carbon/human/body = b
		if(!body || QDELETED(body) || !isslimeperson(body))
			SS.bodies -= b
			continue

		var/list/L = list()
		// HTML colors need a # prefix
		L["htmlcolor"] = "#[body.dna.features["mcolor"]]"
		L["area"] = get_area_name(body, TRUE)
		var/stat = "error"
		switch(body.stat)
			if(CONSCIOUS)
				stat = "Conscious"
			if(UNCONSCIOUS)
				stat = "Unconscious"
			if(DEAD)
				stat = "Dead"
		var/occupied
		if(body == H)
			occupied = "owner"
		else if(body.mind && body.mind.active)
			occupied = "stranger"
		else
			occupied = "available"

		L["status"] = stat
		L["exoticblood"] = body.blood_volume
		L["name"] = body.name
		L["ref"] = "[REF(body)]"
		L["occupied"] = occupied
		var/button
		if(occupied == "owner")
			button = "selected"
		else if(occupied == "stranger")
			button = "danger"
		else if(can_swap(body))
			button = null
		else
			button = "disabled"

		L["swap_button_state"] = button
		L["swappable"] = (occupied == "available") && can_swap(body)

		data["bodies"] += list(L)

	return data

/datum/action/innate/swap_body/ui_act(action, params)
	if(..())
		return
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(owner))
		return
	if(!H.mind || !H.mind.active)
		return
	switch(action)
		if("swap")
			var/datum/species/oozeling/slime/SS = H.dna.species
			var/mob/living/carbon/human/selected = locate(params["ref"]) in SS.bodies
			if(!can_swap(selected))
				return
			SStgui.close_uis(src)
			swap_to_dupe(H.mind, selected)

/datum/action/innate/swap_body/proc/can_swap(mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return FALSE
	var/datum/species/oozeling/slime/SS = H.dna.species

	if(QDELETED(dupe)) 					//Is there a body?
		SS.bodies -= dupe
		return FALSE

	if(!isslimeperson(dupe)) 			//Is it a slimeperson?
		SS.bodies -= dupe
		return FALSE

	if(dupe.stat == DEAD) 				//Is it alive?
		return FALSE

	if(dupe.stat != CONSCIOUS) 			//Is it awake?
		return FALSE

	if(dupe.mind && dupe.mind.active) 	//Is it unoccupied?
		return FALSE

	if(!(dupe in SS.bodies))			//Do we actually own it?
		return FALSE

	return TRUE

/datum/action/innate/swap_body/proc/swap_to_dupe(datum/mind/M, mob/living/carbon/human/dupe)
	if(!can_swap(dupe)) //sanity check
		return
	if(M.current.stat == CONSCIOUS)
		M.current.visible_message(span_notice("[M.current] stops moving and starts staring vacantly into space."), span_notice("You stop moving this body..."))
	else
		to_chat(M.current, span_notice("You abandon this body..."))
	M.transfer_to(dupe)
	dupe.visible_message(span_notice("[dupe] blinks and looks around."), span_notice("...and move this one instead."))

///////////////////////////////////LUMINESCENTS//////////////////////////////////////////

//Luminescents are able to consume and use slime extracts, without them decaying.

/datum/species/oozeling/luminescent
	name = "Luminescent"
	plural_form = null
	id = SPECIES_LUMINESCENT
	examine_limb_id = SPECIES_OOZELING

	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	var/obj/effect/dummy/lighting_obj/moblight/glow
	var/obj/item/slime_extract/current_extract
	var/datum/action/innate/integrate_extract/integrate_extract
	var/datum/action/innate/use_extract/extract_minor
	var/datum/action/innate/use_extract/major/extract_major
	var/extract_cooldown = 0

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/oozeling/luminescent/Destroy(force)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)
	return ..()

/datum/species/oozeling/luminescent/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species)
	..()
	glow = new_jellyperson.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	update_glow(new_jellyperson)
	integrate_extract = new(src)
	integrate_extract.Grant(new_jellyperson)
	extract_minor = new(src)
	extract_minor.Grant(new_jellyperson)
	extract_major = new(src)
	extract_major.Grant(new_jellyperson)

/datum/species/oozeling/luminescent/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(current_extract)
		current_extract.forceMove(C.drop_location())
		current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)

/datum/species/oozeling/luminescent/proc/update_slime_actions()
	integrate_extract.update_name()
	integrate_extract.update_buttons()
	extract_minor.update_buttons()
	extract_major.update_buttons()

/// Updates the glow of our internal glow object
/datum/species/oozeling/luminescent/proc/update_glow(mob/living/carbon/human/glowie, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light_range_power_color(glow_intensity, glow_intensity, glowie.dna.features["mcolor"])

/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	desc = "Eat a slime extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeconsume"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/integrate_extract/proc/update_name()
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(!species || !species.current_extract)
		name = "Integrate Extract"
		desc = "Eat a slime extract to use its properties."
	else
		name = "Eject Extract"
		desc = "Eject your current slime extract."

/datum/action/innate/integrate_extract/update_buttons(status_only, force)
	if(!owner)
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(!species || !species.current_extract)
		button_icon_state = "slimeconsume"
	else
		button_icon_state = "slimeeject"
	..()

/datum/action/innate/integrate_extract/apply_icon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(species?.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/integrate_extract/on_activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(!is_species(H, /datum/species/oozeling/luminescent) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		var/obj/item/slime_extract/S = species.current_extract
		if(!H.put_in_active_hand(S))
			S.forceMove(H.drop_location())
		species.current_extract = null
		to_chat(H, span_notice("You eject [S]."))
		species.update_slime_actions()
	else
		var/obj/item/I = H.get_active_held_item()
		if(istype(I, /obj/item/slime_extract))
			var/obj/item/slime_extract/S = I
			if(!S.Uses)
				to_chat(H, span_warning("[I] is spent! You cannot integrate it."))
				return
			if(!H.temporarilyRemoveItemFromInventory(S))
				return
			S.forceMove(H)
			species.current_extract = S
			to_chat(H, span_notice("You consume [I], and you feel it pulse within you..."))
			species.update_slime_actions()
		else
			to_chat(H, span_warning("You need to hold an unused slime extract in your active hand!"))

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	desc = "Pulse the slime extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeuse1"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	var/activation_type = SLIME_ACTIVATE_MINOR

/datum/action/innate/use_extract/is_available()
	if(..())
		var/mob/living/carbon/human/H = owner
		var/datum/species/oozeling/luminescent/species = H.dna?.species
		if(species && species.current_extract && (world.time > species.extract_cooldown))
			return TRUE
		return FALSE

/datum/action/innate/use_extract/apply_icon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/gazer = owner
	var/datum/species/oozeling/luminescent/species = gazer?.dna?.species

	if(!istype(species, /datum/species/oozeling/luminescent))
		return
	
	if(species.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/use_extract/on_activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(!isluminescent(H) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		species.extract_cooldown = world.time + 10 SECONDS
		var/cooldown = species.current_extract.activate(H, species, activation_type)
		species.extract_cooldown = world.time + cooldown

/datum/action/innate/use_extract/major
	name = "Extract Major Activation"
	desc = "Pulse the slime extract with plasma jelly to activate it."
	button_icon_state = "slimeuse2"
	activation_type = SLIME_ACTIVATE_MAJOR

///////////////////////////////////STARGAZERS//////////////////////////////////////////

//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/// A global list of what mind is linked with what stargazer.
/// Does not include the host stargazer.
/// [/datum/mind] = /datum/weakref -> /datum/species/oozeling/stargazer
GLOBAL_LIST_EMPTY(slime_links_by_mind)

/datum/species/oozeling/stargazer
	name = "\improper Stargazer"
	plural_form = null
	id = SPECIES_STARGAZER
	examine_limb_id = SPECIES_OOZELING
	/// Special "project thought" telepathy action for stargazers.
	var/datum/action/innate/project_thought/project_action

/datum/species/oozeling/stargazer/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species)
	. = ..()
	project_action = new(src)
	project_action.Grant(grant_to)

	grant_to.AddComponent(/datum/component/mind_linker, \
		network_name = "Slime Link", \
		linker_action_path = /datum/action/innate/link_minds, \
		signals_which_destroy_us = list(COMSIG_SPECIES_LOSS), \
	)

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/oozeling/stargazer/Destroy()
	QDEL_NULL(project_action)
	return ..()

/datum/species/oozeling/stargazer/on_species_loss(mob/living/carbon/remove_from)
	QDEL_NULL(project_action)
	return ..()

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/project_thought/on_activate()
	var/mob/living/carbon/human/telepath = owner
	if(telepath.stat == DEAD)
		return
	var/list/recipient_options = list()
	for(var/mob/living/recipient in view(telepath) - telepath)
		if(recipient.stat == DEAD || !recipient.ckey || !recipient.mind)
			continue
		recipient_options.Add(recipient)
	if(!length(recipient_options))
		to_chat(telepath, span_warning("You don't see anyone to send your thought to."))
		return
	var/mob/living/recipient = tgui_input_list(telepath, "Choose a telepathic message recipient", "Telepathy", sort_names(recipient_options))
	if(isnull(recipient))
		return
	var/msg = tgui_input_text(telepath, title = "Telepathy")
	if(isnull(msg))
		return
	msg = trim(msg, MAX_MESSAGE_LEN)
	if(!length(msg))
		return
	msg = telepath.treat_message_min(msg)
	if(CHAT_FILTER_CHECK(msg))
		to_chat(telepath, span_warning("Your message contains forbidden words."), type = MESSAGE_TYPE_WARNING)
		return
	log_directed_talk(telepath, recipient, msg, LOG_SAY, "slime telepathy")
	to_chat(recipient, span_slime("You hear an alien voice in your head... [span_boldmessage("[msg]")]"), type = MESSAGE_TYPE_LOCALCHAT)
	to_chat(telepath, span_slime("You telepathically said: \"[span_boldmessage("[msg]")]\" to [span_name("[recipient]")]."), avoid_highlighting = TRUE, type = MESSAGE_TYPE_LOCALCHAT)
	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		var/follow_link_user = FOLLOW_LINK(ghost, telepath)
		var/follow_link_target = FOLLOW_LINK(ghost, recipient)
		to_chat(ghost, "[follow_link_user] [span_slime(span_name(telepath))] [span_bold("Slime Telepathy --> ")] [follow_link_target] [span_name(recipient)] [span_message(msg)]", type = MESSAGE_TYPE_RADIO)

/datum/action/innate/link_minds
	name = "Link Minds"
	desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	/// The species required to use this ability. Typepath.
	var/req_species = /datum/species/oozeling/stargazer
	/// Whether we're currently linking to someone.
	var/currently_linking = FALSE

/datum/action/innate/link_minds/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/innate/link_minds/is_available()
	. = ..()
	if(!.)
		return
	if(!ishuman(owner) || !is_species(owner, req_species))
		return FALSE
	if(currently_linking)
		return FALSE

	return TRUE

/datum/action/innate/link_minds/on_activate(mob/user, atom/target)
	if(!isliving(owner.pulling) || owner.grab_state < GRAB_AGGRESSIVE)
		to_chat(owner, span_warning("You need to aggressively grab someone to link minds!"))
		return

	var/mob/living/living_target = owner.pulling
	if(living_target.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return

	to_chat(owner, span_notice("You begin linking [living_target]'s mind to yours..."))
	to_chat(living_target, span_warning("You feel a foreign presence within your mind..."))
	currently_linking = TRUE

	if(!do_after(owner, 6 SECONDS, target = living_target, extra_checks = CALLBACK(src, PROC_REF(while_link_callback), living_target)))
		to_chat(owner, span_warning("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, span_warning("The foreign presence leaves your mind."))
		currently_linking = FALSE
		return

	currently_linking = FALSE
	if(QDELETED(src) || QDELETED(owner) || QDELETED(living_target))
		return

	var/datum/component/mind_linker/linker = target
	if(!linker.link_mob(living_target))
		to_chat(owner, span_warning("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, span_warning("The foreign presence leaves your mind."))


/// Callback ran during the do_after of Activate() to see if we can keep linking with someone.
/datum/action/innate/link_minds/proc/while_link_callback(mob/living/linkee)
	if(!is_species(owner, req_species))
		return FALSE
	if(!owner.pulling)
		return FALSE
	if(owner.pulling != linkee)
		return FALSE
	if(owner.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	if(linkee.stat == DEAD)
		return FALSE

	return TRUE
