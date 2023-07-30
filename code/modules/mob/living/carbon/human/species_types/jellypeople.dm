
////////////////////////////////////////////////////////SLIMEPEOPLE///////////////////////////////////////////////////////////////////

//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

/datum/species/oozeling/slime
	name = "Slimeperson"
	id = SPECIES_SLIMEPERSON
	default_color = "00FFFF"
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
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
			to_chat(H, "<span class='notice'>You feel very bloated!</span>")
	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.blood_volume += 3
		H.adjust_nutrition(-2.5)

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/IsAvailable()
	if(..())
		var/mob/living/carbon/human/H = owner
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			return 1
		return 0

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return
	CHECK_DNA_AND_SPECIES(H)

	//Prevent one person from creating 100 bodies.
	var/datum/species/oozeling/slime/species = H.dna.species
	if(length(species.bodies) > CONFIG_GET(number/max_slimeperson_bodies))
		to_chat(H, "<span class='warning'>Your mind is spread too thin! You have too many bodies already.</span>")
		return

	H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.</span>",
		"<span class='notice'>You focus intently on moving your body while \
		standing perfectly still...</span>")

	H.notransform = TRUE

	if(do_after(owner, delay=60, target=owner, progress=TRUE, timed_action_flags = IGNORE_HELD_ITEM))
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, "<span class='warning'>...but there is not enough of you to go around! You must attain more mass to split!</span>")
	else
		to_chat(H, "<span class='warning'>...but fail to stand perfectly still!</span>")

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
	spare.visible_message("<span class='warning'>[H] distorts as a new body \
		\"steps out\" of [H.p_them()].</span>",
		"<span class='notice'>...and after a moment of disorentation, \
		you're besides yourself!</span>")


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = NONE
	button_icon_state = "slimeswap"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/swap_body/Activate()
	if(!isslimeperson(owner))
		to_chat(owner, "<span class='warning'>You are not a slimeperson.</span>")
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
		M.current.visible_message("<span class='notice'>[M.current] \
			stops moving and starts staring vacantly into space.</span>",
			"<span class='notice'>You stop moving this body...</span>")
	else
		to_chat(M.current, "<span class='notice'>You abandon this body...</span>")
	M.transfer_to(dupe)
	dupe.visible_message("<span class='notice'>[dupe] blinks and looks \
		around.</span>",
		"<span class='notice'>...and move this one instead.</span>")


///////////////////////////////////LUMINESCENTS//////////////////////////////////////////

//Luminescents are able to consume and use slime extracts, without them decaying.

/datum/species/oozeling/luminescent
	name = "Luminescent"
	id = SPECIES_LUMINESCENT
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	var/obj/effect/dummy/luminescent_glow/glow
	var/obj/item/slime_extract/current_extract
	var/datum/action/innate/integrate_extract/integrate_extract
	var/datum/action/innate/use_extract/extract_minor
	var/datum/action/innate/use_extract/major/extract_major
	var/extract_cooldown = 0

	examine_limb_id = SPECIES_OOZELING

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/oozeling/luminescent/Destroy(force, ...)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)
	return ..()


/datum/species/oozeling/luminescent/on_species_loss(mob/living/carbon/C)
	..()
	if(current_extract)
		current_extract.forceMove(C.drop_location())
		current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)

/datum/species/oozeling/luminescent/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	glow = new(C)
	update_glow(C)
	integrate_extract = new(src)
	integrate_extract.Grant(C)
	extract_minor = new(src)
	extract_minor.Grant(C)
	extract_major = new(src)
	extract_major.Grant(C)

/datum/species/oozeling/luminescent/proc/update_slime_actions()
	integrate_extract.update_name()
	integrate_extract.UpdateButtonIcon()
	extract_minor.UpdateButtonIcon()
	extract_major.UpdateButtonIcon()

/datum/species/oozeling/luminescent/proc/update_glow(mob/living/carbon/C, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light(glow_intensity, glow_intensity, C.dna.features["mcolor"])

/obj/effect/dummy/luminescent_glow
	name = "luminescent glow"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = "#FFFFFF"
	light_range = LUMINESCENT_DEFAULT_GLOW
	light_system = MOVABLE_LIGHT
	light_power = 2.5

/obj/effect/dummy/luminescent_glow/Initialize(mapload)
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL


/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	desc = "Eat a slime extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeconsume"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/integrate_extract/proc/update_name()
	var/datum/species/oozeling/luminescent/species = target
	if(!species || !species.current_extract)
		name = "Integrate Extract"
		desc = "Eat a slime extract to use its properties."
	else
		name = "Eject Extract"
		desc = "Eject your current slime extract."

/datum/action/innate/integrate_extract/UpdateButtonIcon(status_only, force)
	var/datum/species/oozeling/luminescent/species = target
	if(!species || !species.current_extract)
		button_icon_state = "slimeconsume"
	else
		button_icon_state = "slimeeject"
	..()

/datum/action/innate/integrate_extract/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)
	var/datum/species/oozeling/luminescent/species = target
	if(species?.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = target
	if(!is_species(H, /datum/species/oozeling/luminescent) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		var/obj/item/slime_extract/S = species.current_extract
		if(!H.put_in_active_hand(S))
			S.forceMove(H.drop_location())
		species.current_extract = null
		to_chat(H, "<span class='notice'>You eject [S].</span>")
		species.update_slime_actions()
	else
		var/obj/item/I = H.get_active_held_item()
		if(istype(I, /obj/item/slime_extract))
			var/obj/item/slime_extract/S = I
			if(!S.Uses)
				to_chat(H, "<span class='warning'>[I] is spent! You cannot integrate it.</span>")
				return
			if(!H.temporarilyRemoveItemFromInventory(S))
				return
			S.forceMove(H)
			species.current_extract = S
			to_chat(H, "<span class='notice'>You consume [I], and you feel it pulse within you...</span>")
			species.update_slime_actions()
		else
			to_chat(H, "<span class='warning'>You need to hold an unused slime extract in your active hand!</span>")

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	desc = "Pulse the slime extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeuse1"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	var/activation_type = SLIME_ACTIVATE_MINOR

/datum/action/innate/use_extract/IsAvailable()
	if(..())
		var/datum/species/oozeling/luminescent/species = target
		if(species && species.current_extract && (world.time > species.extract_cooldown))
			return TRUE
		return FALSE

/datum/action/innate/use_extract/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)
	var/mob/living/carbon/human/H = owner
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(species && species.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/use_extract/Activate()
	var/mob/living/carbon/human/H = owner
	CHECK_DNA_AND_SPECIES(H)
	var/datum/species/oozeling/luminescent/species = H.dna.species
	if(!is_species(H, /datum/species/oozeling/luminescent) || !species)
		return

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
	name = "Stargazer"
	id = SPECIES_STARGAZER
	examine_limb_id = SPECIES_OOZELING
	/// The stargazer's telepathy ability.
	var/datum/action/innate/project_thought/project_thought
	/// The stargazer's mind linking ability.
	var/datum/action/innate/link_minds/link_minds
	/// The stargazer's mind unlink ability
	var/datum/action/innate/unlink_minds/unlink_minds
	/// The stargazer's linked speech ability.
	var/datum/action/innate/linked_speech/linked_speech
	/// A full list of all minds linked to this stargazer's slime link.
	var/list/datum/mind/linked_minds = list()
	/// A full list of all actions linked to this stargazer's slime link.
	/// [datum/mind] = /datum/action/innate/linked_speech
	var/list/datum/action/innate/linked_speech/linked_actions = list()
	/// A weak reference to the body of the owner of the slime link.
	var/datum/weakref/slimelink_owner


//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/oozeling/stargazer/Destroy()
	for(var/datum/mind/link_to_clear in linked_minds)
		unlink_mind(link_to_clear)
	linked_minds.Cut()
	QDEL_NULL(project_thought)
	QDEL_NULL(link_minds)
	QDEL_NULL(unlink_minds)
	QDEL_NULL(linked_speech)
	QDEL_LIST_ASSOC_VAL(linked_actions)
	slimelink_owner = null
	return ..()

/datum/species/oozeling/stargazer/on_species_gain(mob/living/carbon/body, datum/species/old_species)
	. = ..()
	project_thought = new(src)
	project_thought.Grant(body)
	link_minds = new(src)
	link_minds.Grant(body)
	unlink_minds = new(src)
	unlink_minds.Grant(body)
	linked_speech = new(src)
	linked_speech.Grant(body)
	slimelink_owner = WEAKREF(body)
	to_chat(body, "<span class='big slime'>You can use :[MODE_KEY_SLIMELINK] or .[MODE_KEY_SLIMELINK] to talk over your slime link!</span>")
	register_mob_signals(body)

/datum/species/oozeling/stargazer/on_species_loss(mob/living/carbon/body)
	..()
	for(var/datum/mind/link_to_clear in linked_minds)
		unlink_mind(link_to_clear)
	if(project_thought)
		QDEL_NULL(project_thought)
	if(link_minds)
		QDEL_NULL(link_minds)
	slimelink_owner = null
	UnregisterSignal(body, COMSIG_MOB_LOGIN)

/datum/species/oozeling/stargazer/spec_death(gibbed, mob/living/carbon/human/body)
	. = ..()
	for(var/datum/mind/link_to_clear in linked_minds)
		unlink_mind(link_to_clear)

/**
 * Notify a slime link member on login that they can use the slime link saymode.
 */
/datum/species/oozeling/stargazer/proc/login_notify(mob/source)
	SIGNAL_HANDLER
	to_chat(source, "<span class='big slime'>You can use :[MODE_KEY_SLIMELINK] or .[MODE_KEY_SLIMELINK] to talk over the slime link!</span>")

/**
 * Handle whenever a slime link member has their mind transferred, transferring the link to the new body.
 *
 * Arguments
 * * source_mind: The mind that was transferred.
 * * old_body: The body that the mind was transferred from.
 * * new_body: The body that the mind was transferred into.
 */
/datum/species/oozeling/stargazer/proc/mind_transfer(datum/mind/source_mind, mob/old_body, mob/new_body)
	SIGNAL_HANDLER
	if(!linked_minds[source_mind])
		return
	var/datum/action/innate/linked_speech/action = linked_actions[source_mind]
	if(!QDELETED(old_body))
		unregister_mob_signals(old_body, mind_transfer = FALSE)
		action?.Remove(old_body)
	if(!QDELETED(new_body))
		register_mob_signals(new_body, death = TRUE)
		action?.Grant(new_body)

/**
 * Register the slime link-related signals on a mob or mind.
 *
 * Arguments
 * * target: The mob or mind to register the signals on.
 * * death: Whether to register the death signal.
 * * mind_transfer: Whether to register the mind transfer signal.
 */
/datum/species/oozeling/stargazer/proc/register_mob_signals(target, death = FALSE, mind_transfer = FALSE)
	var/datum/mind/mind_target
	var/mob/living/living_target
	if(isliving(target))
		living_target = target
		if(living_target.mind)
			mind_target = living_target.mind
	else if(istype(target, /datum/mind))
		mind_target = target
		if(mind_target.current && isliving(mind_target.current))
			living_target = mind_target.current
	else
		CRASH("Passed invalid target to stargazer/register_mob_signals")
	if(living_target)
		RegisterSignal(living_target, COMSIG_MOB_LOGIN, PROC_REF(login_notify))
		if(death)
			RegisterSignal(living_target, COMSIG_MOB_DEATH, PROC_REF(link_death))
	if(mind_target && mind_transfer)
		RegisterSignal(mind_target, COMSIG_MIND_TRANSFER_TO, PROC_REF(mind_transfer))

/**
 * Unregister the slime link-related signals from a mob or mind.
 *
 * Arguments
 * * target: The mob or mind to unregister the signals from.
 * * mind_transfer: Whether to unregister the mind transfer signal.
 */
/datum/species/oozeling/stargazer/proc/unregister_mob_signals(target, mind_transfer = TRUE)
	var/datum/mind/mind_target
	var/mob/living/living_target
	if(isliving(target))
		living_target = target
		if(living_target.mind)
			mind_target = living_target.mind
	else if(istype(target, /datum/mind))
		mind_target = target
		if(mind_target.current && isliving(mind_target.current))
			living_target = mind_target.current
	else
		CRASH("Passed invalid target to stargazer/unregister_mob_signals")
	if(living_target)
		UnregisterSignal(living_target, list(COMSIG_MOB_LOGIN, COMSIG_MOB_DEATH))
	if(mind_target && mind_transfer)
		UnregisterSignal(mind_target, COMSIG_MIND_TRANSFER_TO)

/**
 * Ensures a mind is a valid candidate for being slime linked.
 *
 * Arguments
 * * target_mind: The mind to validate for slime linking.
 * * initial_connection: Whether or not this is the first connection attempt (rather than validating to ensure a mind is still allowed to be in the slime link).
 * * silent: Whether to display messages when validating or not.
 * Returns TRUE if the mind is a valid candidate for being slime linked, FALSE otherwise.
 */
/datum/species/oozeling/stargazer/proc/validate_mind(datum/mind/target_mind, initial_connection = FALSE, silent = FALSE)
	. = TRUE
	if(!target_mind || !istype(target_mind))
		return FALSE
	var/mob/living/target = target_mind.current
	if(!istype(target) || QDELETED(target))
		return FALSE
	var/mob/living/carbon/human/link_host = slimelink_owner.resolve()
	if(!target.ckey)
		if(!silent)
			to_chat(link_host, "<span class='warning'><span class='name'>[target]</span> is catatonic, you cannot link [target.p_them()]!</span>", type = MESSAGE_TYPE_WARNING)
		return FALSE
	if(target.stat == DEAD || (initial_connection && HAS_TRAIT(target, TRAIT_FAKEDEATH)))
		if(!silent)
			to_chat(link_host, "<span class='warning'><span class='name'>[target]</span> is dead, you cannot link [target.p_them()]!</span>", type = MESSAGE_TYPE_WARNING)
		return FALSE
	if(initial_connection && GLOB.slime_links_by_mind[target_mind])
		var/datum/weakref/other_link_ref = GLOB.slime_links_by_mind[target_mind]
		if(other_link_ref == weak_reference)
			if(!silent)
				to_chat(link_host, "<span class='danger'>We already have a telepathic link with <span class='name'>[target_mind.name]</span>!</span>", type = MESSAGE_TYPE_WARNING)
			return FALSE
		var/datum/species/oozeling/stargazer/other_link = other_link_ref?.resolve()
		// If they're already slime linked, then we can't link to them.
		if(other_link && istype(other_link))
			if(!silent)
				to_chat(link_host, "<span class='danger'><span class='name'>[link_host]</span> already has another telepathic link, there's not enough room in [link_host.p_their()] mind for more!</span>", type = MESSAGE_TYPE_WARNING)
			return FALSE
	var/obj/item/hat = target.get_item_by_slot(ITEM_SLOT_HEAD)
	if(istype(hat, /obj/item/clothing/head/foilhat))
		if(!silent)
			to_chat(link_host, "<span class='danger'>\The [hat] worn by <span class='name'>[link_host]</span> interferes with your telepathic abilities, preventing you from linking [target.p_them()]!</span>", type = MESSAGE_TYPE_WARNING)
			to_chat(target_mind, "<span class='danger'><span class='name'>[link_host]</span>'[link_host.p_s()] no-good syndicate mind-slime is blocked by your protective headgear!</span>", type = MESSAGE_TYPE_WARNING)
		return FALSE
	if(HAS_TRAIT_NOT_FROM(target, TRAIT_MINDSHIELD, "nanites")) //mindshield implant, no dice
		if(!silent)
			to_chat(link_host, "<span class='warning'>Something within <span class='name'>[target]</span>'[target.p_s()] mind interferes with your telepathic abilities, preventing you from linking [target.p_them()]!</span>", type = MESSAGE_TYPE_WARNING)
		return FALSE

/**
 * Handles the death of a linked mob, unlinking them from the slime link.
 *
 * Arguments
 * * source_mob: The mob that died.
 */
/datum/species/oozeling/stargazer/proc/link_death(mob/living/source_mob)
	SIGNAL_HANDLER
	if(!source_mob.mind || !linked_minds[source_mob.mind])
		return
	var/mob/living/carbon/human/link_host = slimelink_owner.resolve()
	if(link_host)
		to_chat("<span class='slime bold'>As you die, you feel your link to <span class='name'>[link_host.mind.name]</span> fizzle out!</span>", type = MESSAGE_TYPE_WARNING)
	unlink_mind(source_mob.mind)

/**
 * Links the mind of another mob to this stargazer's slime link.
 *
 * Arguments
 * * target_mind: The target mind to link to the slime link.
 * Returns TRUE if the mind was successfully linked, FALSE otherwise.
 */
/datum/species/oozeling/stargazer/proc/link_mind(datum/mind/target_mind)
	if(!validate_mind(target_mind, initial_connection = TRUE))
		return FALSE
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	var/mob/living/target = target_mind.current
	if(!owner || !istype(owner) || !target || !istype(target) || linked_minds[target_mind])
		return FALSE
	linked_minds[target_mind] = TRUE
	var/datum/action/innate/linked_speech/action = new(src)
	linked_actions[target_mind] = action
	action.Grant(target_mind.current)
	to_chat(target_mind, "<span class='slime bold'>You are now connected to <span class='name'>[owner.mind.name]</span>'[owner.p_s()] Slime Link.</span>", type = MESSAGE_TYPE_INFO)
	GLOB.slime_links_by_mind[target_mind] = WEAKREF(src)
	register_mob_signals(target, death = TRUE, mind_transfer = TRUE)
	to_chat(target_mind, "<span class='big slime'>You can use :[MODE_KEY_SLIMELINK] or .[MODE_KEY_SLIMELINK] to talk over the slime link!</span>", type = MESSAGE_TYPE_INFO)
	var/log = "[key_name(owner)] linked [key_name(target)] to [owner.p_their()] slime link"
	owner.log_message(log, LOG_GAME)
	target.log_message(log, LOG_GAME, log_globally = FALSE)
	return TRUE

/**
 * Unlinks a mind from this stargazer's slime link.
 *
 * Arguments
 * * target_mind: The mind to unlink from the slime link.
 */
/datum/species/oozeling/stargazer/proc/unlink_mind(datum/mind/target_mind, intentional = FALSE)
	if(!linked_minds[target_mind])
		return
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	var/datum/mind/owner_mind = owner.mind
	var/datum/action/innate/linked_speech/action = linked_actions[target_mind]
	unregister_mob_signals(target_mind)
	var/log = "[key_name(target_mind)] was[intentional ? " intentionally" : ""] unlinked from [key_name(owner)]'s slime link"
	owner.log_message(log, LOG_GAME)
	if(target_mind.current)
		var/mob/living/target = target_mind.current
		action.Remove(target)
		target.log_message(log, LOG_GAME, log_globally = FALSE)
	to_chat(target_mind, "<span class='slime bold'>You are no longer connected to <span class='name'>[owner_mind.name]</span>'[owner.p_s()] Slime Link.</span>", type = MESSAGE_TYPE_WARNING)
	linked_actions -= target_mind
	linked_minds -= target_mind
	qdel(action)
	if(GLOB.slime_links_by_mind[target_mind] == weak_reference)
		GLOB.slime_links_by_mind -= target_mind

/**
 * Sends a chat message over the slime link.
 * Anything calling this proc should ensure to filter and sanitize the message beforehand!
 *
 * Arguments
 * * user: The mob sending the message.
 * * message: The message to send.
 */
/datum/species/oozeling/stargazer/proc/slime_chat(mob/living/user, message)
	if(!istype(user) || !user?.mind || !length(message))
		return
	var/mob/living/carbon/human/link_owner = slimelink_owner.resolve()
	var/datum/mind/owner_mind = link_owner?.mind
	if(!link_owner || !istype(link_owner) || !owner_mind || (user != link_owner && !linked_minds[user.mind]))
		to_chat(user, "<span class='slime bold'>The link seems to have been severed...</span>", type = MESSAGE_TYPE_WARNING)
		unlink_mind(user.mind)
		return
	message = trim(message, MAX_MESSAGE_LEN)
	if(!length(message))
		return
	message = user.treat_message_min(message)
	var/display_name = user.mind.name == user.real_name ? "<span class='name'>[user.real_name]</span>" : "<span class='name'>[user.mind.name]</span> (as <span class='name'>[user.real_name]</span>)"
	var/msg = "<span class='slime italics'>\[<span class='name'>[owner_mind.name]</span>'[link_owner.p_s()] Slime Link\] <b>[display_name]:</b> <span class='message'>[message]</span></span>"
	user.log_talk(message, LOG_SAY, tag="stargazer slime link of [key_name(owner_mind)]")
	var/list/targets = linked_minds.Copy()
	if(owner_mind)
		targets += owner_mind
	for(var/datum/mind/linked_mind in targets)
		if(linked_mind != owner_mind && !validate_mind(linked_mind, silent = TRUE))
			unlink_mind(linked_mind)
			continue
		to_chat(linked_mind, msg, avoid_highlighting = (user.mind == linked_mind), type = MESSAGE_TYPE_RADIO)

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, user)
		to_chat(ghost, "[link] [msg]", type = MESSAGE_TYPE_RADIO)

/**
 * Prompts the owner if they would like to unlink someone from the slime link.
 */
/datum/species/oozeling/stargazer/proc/unlink_prompt()
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	if(!owner || !istype(owner))
		return
	var/list/eligible = list()
	var/list/eligible_names = list()
	var/list/name_counts = list()
	for(var/datum/mind/mind in sort_names(linked_minds))
		var/mob/living/target = mind.current
		if(QDELETED(target) || !validate_mind(mind, silent = TRUE))
			unlink_mind(mind)
			continue
		var/mind_name = avoid_assoc_duplicate_keys(cmptext(mind.name, target.real_name) ? mind.name : "[mind.name] (as [target.real_name])", name_counts)
		eligible[mind_name] = mind
		eligible_names += mind_name
	if(!length(eligible))
		to_chat(owner, "<span class='warning'>There is nobody connected to your slime link to disconnect!</span>", type = MESSAGE_TYPE_WARNING)
		return
	var/target_mind_name = tgui_input_list(owner, "Who do you want to unlink?", "Slime Unlinking", eligible_names)
	if(!target_mind_name)
		return
	var/datum/mind/target_mind = eligible[target_mind_name]
	if(!target_mind || !istype(target_mind))
		return
	if(tgui_alert(owner, "Are you SURE you want to unlink [target_mind_name]? You will need to physically link them again if you want them to re-join the slime link!", "Confirm Unlink", list("Yes", "No")) != "Yes")
		return
	if(!linked_minds[target_mind])
		to_chat(owner, "<span class='warning'><span class='name'>[target_mind.name]</span> isn't linked to you anyways!</span>", type = MESSAGE_TYPE_WARNING)
		return
	to_chat(owner, "<span class='slime bold'>You forcefully cut off your telepathic link with <span class='name'>[target_mind]</span>, completely disconnecting [target_mind.current.p_them()] from the slime link!</span>", type = MESSAGE_TYPE_INFO)
	to_chat(target_mind, "<span class='slime bold'>You suddenly feel as if your telepathic link with <span class='name'>[owner.mind]</span> was severed!</span>", type = MESSAGE_TYPE_WARNING)
	unlink_mind(target_mind, intentional = TRUE)

/datum/action/innate/linked_speech
	name = "Slimelink"
	desc = "Send a psychic message to everyone connected to your slime link."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/linked_speech/Activate()
	var/mob/living/living_owner = owner
	if(!living_owner || !istype(living_owner) || living_owner.stat == DEAD)
		return
	var/message = tgui_input_text(living_owner, "Enter a message to broadcast to everyone in your slime link!", "Slime Link Telepathy", max_length = MAX_MESSAGE_LEN, encode = FALSE,)
	if(!message || !length(message) || living_owner.stat == DEAD)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(living_owner, "<span class='warning'>Your message contains forbidden words.</span>", type = MESSAGE_TYPE_WARNING)
		return
	living_owner.say(".[MODE_KEY_SLIMELINK] [message]")

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/project_thought/Activate()
	var/mob/living/carbon/human/human_owner = owner
	if(!isstargazer(human_owner))
		return
	if(human_owner.stat == DEAD)
		to_chat(human_owner, "<span class='warning'>You're dead, you have no thoughts to project...</span>", type = MESSAGE_TYPE_WARNING)
		return
	var/list/options = list()
	for(var/mob/living/potential_target in view(human_owner) - human_owner)
		if(potential_target.stat == DEAD || !potential_target.ckey || !potential_target.mind)
			continue
		options += potential_target
	if(!length(options))
		to_chat(human_owner, "<span class='warning'>There are no valid beings nearby that you can project a thought onto!</span>", type = MESSAGE_TYPE_WARNING)
		return
	var/mob/living/target = tgui_input_list(human_owner, "Select the target you wish to project a thought onto.", "Stargazer Thought Projection", items = sort_names(options))
	if(QDELETED(target) || !isstargazer(human_owner) || human_owner.stat == DEAD)
		return
	var/msg = tgui_input_text(human_owner, "What message do you wish to project?", "Slime Telepathy", max_length = MAX_MESSAGE_LEN)
	if(!msg || !isstargazer(human_owner) || human_owner.stat == DEAD)
		return
	msg = trim(msg, MAX_MESSAGE_LEN)
	if(!length(msg))
		return
	msg = human_owner.treat_message_min(msg)
	if(CHAT_FILTER_CHECK(msg))
		to_chat(human_owner, "<span class='warning'>Your message contains forbidden words.</span>", type = MESSAGE_TYPE_WARNING)
		return
	log_directed_talk(human_owner, target, msg, LOG_SAY, "stargazer telepathy")
	to_chat(target, "<span class='slime'>You hear an alien voice in your head... <span class='bold message'>[msg]</span></span>", type = MESSAGE_TYPE_LOCALCHAT)
	to_chat(human_owner, "<span class='slime'>You telepathically said: \"<span class='bold message'>[msg]</span>\" to <span class='name'>[target]</span>.</span>", avoid_highlighting = TRUE, type = MESSAGE_TYPE_LOCALCHAT)
	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		var/follow_link_user = FOLLOW_LINK(ghost, human_owner)
		var/follow_link_target = FOLLOW_LINK(ghost, target)
		to_chat(ghost, "[follow_link_user] <span class='slime'><span class='name'>[human_owner]</span> <span class='bold'>Slime Telepathy --> </span> [follow_link_target] <span class='name'>[target]</span> <span class='message'>[msg]</span></span>", type = MESSAGE_TYPE_RADIO)

/datum/action/innate/link_minds
	name = "Link Minds"
	desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/link_minds/Activate()
	var/mob/living/carbon/human/human_owner = owner
	if(!isstargazer(human_owner))
		return
	if(!isliving(human_owner.pulling) || human_owner.grab_state < GRAB_AGGRESSIVE)
		to_chat(human_owner, "<span class='warning'>You need to aggressively grab a living being in order to link their mind!</span>", type = MESSAGE_TYPE_WARNING)
		return
	var/mob/living/target = human_owner.pulling
	var/datum/species/oozeling/stargazer/owner_stargazer = human_owner.dna.species
	if(!target.mind || !target.ckey)
		to_chat(human_owner, "<span class='warning'><span class='name'>[target]</span> has no mind to link!</span>", type = MESSAGE_TYPE_WARNING)
		return
	if(target.mind in owner_stargazer.link_minds)
		to_chat(human_owner, "<span class='notice'><span class='name'>[target]</span> is already a part of your slime link!</span>", type = MESSAGE_TYPE_INFO)
		return
	to_chat(human_owner, "<span class='slime'>You begin linking <span class='name'>[target]</span>'[target.p_s()] mind to yours...</span>", type = MESSAGE_TYPE_INFO)
	target.visible_message("<span class='slime'><span class='name'>[owner]</span> gently places [owner.p_their()] hands on the sides of <span class='name'>[target]</span>'[target.p_s()] head, and begins to concentrate!</span>", \
		"<span class='slime bold'><span class='name'>[owner]</span> gently places [owner.p_their()] hands on the sides of your head, and you feel a foreign, yet benign and non-invasive presence begin to enter your mind...</span>")
	if(!do_after(human_owner, 6 SECONDS, target))
		to_chat(human_owner, "<span class='warning'>You were interrupted while linking <span class='name'>[target]</span>!</span>", type = MESSAGE_TYPE_WARNING)
		to_chat(target, "<span class='slime'>The foreign presence entering your mind quickly fades away as <span class='name'>[human_owner]</span> is interrupted!</span>", type = MESSAGE_TYPE_INFO)
		return
	if(human_owner.pulling != target || human_owner.grab_state < GRAB_AGGRESSIVE)
		to_chat(human_owner, "<span class='warning'>You must grab <span class='name'>[target]</span> aggressively throughout the entire linking process!</span>", type = MESSAGE_TYPE_WARNING)
		return
	if(!target.mind || !target.ckey)
		to_chat(human_owner, "<span class='warning italics'><span class='name'>[target]</span>'[target.p_s()] mind seems to have left [target.p_them()] during the linking processs...</span>", type = MESSAGE_TYPE_WARNING)
		return
	if(owner_stargazer.link_mind(target.mind))
		to_chat(human_owner, "<span class='slime bold'>You connect <span class='name'>[target]</span>'[target.p_s()] mind to your slime link!</span>", type = MESSAGE_TYPE_INFO)
	else
		to_chat(target, "<span class='slime bold'>The foreign presence leaves your mind...</span>", type = MESSAGE_TYPE_INFO)

/datum/action/innate/unlink_minds
	name = "Unlink Mind"
	desc = "Forcefully disconnect a member of your Slime Link, cutting them off from the rest of the link."
	button_icon_state = "mindunlink"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/unlink_minds/Activate()
	var/mob/living/carbon/human/human_owner = owner
	if(!isstargazer(human_owner))
		return
	var/datum/species/oozeling/stargazer/owner_stargazer = human_owner.dna.species
	owner_stargazer.unlink_prompt()
