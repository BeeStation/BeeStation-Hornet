
/// Helper to format the text that gets thrown onto the chem hud element.
#define FORMAT_CHEM_CHARGES_TEXT(charges) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(charges)]</font></div>")

/datum/antagonist/changeling
	name = "\improper Changeling"
	roundend_category = "changelings"
	antagpanel_category = "Changeling"
	banning_key = ROLE_CHANGELING
	required_living_playtime = 4
	ui_name = "AntagInfoChangeling"
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	/// Whether to give this changeling objectives or not
	give_objectives = TRUE
	leave_behaviour = ANTAGONIST_LEAVE_KEEP
	/// Whether we assign objectives which compete with other lings
	var/competitive_objectives = FALSE

	// Changeling Stuff.
	// If you want good boy points,
	// separate the changeling (antag)
	// and the changeling (mechanics).

	/// list of datum/changeling_profile
	var/list/stored_profiles = list()
	/// The original profile of this changeling.
	var/datum/changeling_profile/first_profile = null
	/// The amount of DNA gained. Includes DNA sting.
	var/absorbed_count = 0
	/// The number of chemicals the changeling currently has.
	var/chem_charges = 20
	/// The max chemical storage the changeling currently has.
	var/total_chem_storage = 75
	/// The chemical recharge rate per life tick.
	var/chem_recharge_rate = 0.5
	/// Any additional modifiers triggered by changelings that modify the chem_recharge_rate.
	var/chem_recharge_slowdown = 0
	/// The range this ling can sting things.
	var/sting_range = 2
	/// Changeling name, what other lings see over the hivemind when talking.
	var/changelingID = "Changeling"
	/// The number of genetics points (to buy powers) this ling currently has.
	var/genetic_points = 10
	/// The max number of genetics points (to buy powers) this ling can have..
	var/total_genetic_points = 10
	/// List of all powers we start with.
	var/list/innate_powers = list()
	/// Associated list of all powers we have evolved / bought from the emporium. [path] = [instance of path]
	var/list/purchased_powers = list()

	/// The voice we're mimicing via the changeling voice ability.
	var/mimicing = ""
	/// Whether we can currently respec in the cellular emporium.
	var/can_respec = FALSE

	/// The currently active changeling sting.
	var/datum/action/changeling/sting/chosen_sting
	/// A reference to our cellular emporium datum.
	var/datum/cellular_emporium/cellular_emporium
	/// A reference to our cellular emporium action (which opens the UI for the datum).
	var/datum/action/innate/cellular_emporium/emporium_action

	/// Static typecache of all changeling powers that are usable.
	var/static/list/all_powers = typecacheof(/datum/action/changeling, ignore_root_path = TRUE)

	/// Static list of possible ids. Initialized into the greek alphabet the first time it is used
	var/static/list/possible_changeling_IDs

	/// Static list of what each slot associated with (in regard to changeling flesh items).
	var/static/list/slot2type = list(
		"head" = /obj/item/clothing/head/changeling,
		"wear_mask" = /obj/item/clothing/mask/changeling,
		"wear_neck" = /obj/item/changeling,
		"back" = /obj/item/changeling,
		"wear_suit" = /obj/item/clothing/suit/changeling,
		"w_uniform" = /obj/item/clothing/under/changeling,
		"shoes" = /obj/item/clothing/shoes/changeling,
		"belt" = /obj/item/changeling,
		"gloves" = /obj/item/clothing/gloves/changeling,
		"glasses" = /obj/item/clothing/glasses/changeling,
		"ears" = /obj/item/changeling,
		"wear_id" = /obj/item/card/id/changeling,
		"s_store" = /obj/item/changeling,
	)

	///	Keeps track of the currently selected profile.
	var/datum/changeling_profile/current_profile

	/// A list of languages granted to changelings
	var/static/list/granted_languages = list(
		/datum/language/apidite,
		/datum/language/buzzwords,
		/datum/language/calcic,
		/datum/language/common,
		/datum/language/uncommon,
		/datum/language/draconic,
		/datum/language/moffic,
		/datum/language/monkey,
		/datum/language/slime,
		/datum/language/sonus,
		/datum/language/sylvan,
		/datum/language/terrum,
		/datum/language/voltaic,
	)

/datum/antagonist/changeling/New()
	. = ..()
	for(var/datum/antagonist/changeling/other_ling in GLOB.antagonists)
		if(!other_ling.owner || other_ling.owner == owner)
			continue
		competitive_objectives = TRUE
		break

/datum/antagonist/changeling/Destroy()
	QDEL_NULL(emporium_action)
	QDEL_NULL(cellular_emporium)
	current_profile = null
	return ..()

/datum/antagonist/changeling/on_gain()
	generate_name()
	create_emporium()
	create_innate_actions()
	create_initial_profile()
	if(give_objectives)
		forge_objectives()
	handle_clown_mutation(owner.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
	owner.current.get_language_holder().omnitongue = TRUE
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	for(var/datum/language/language as anything in granted_languages)
		owner.current.grant_language(language, source = LANGUAGE_CHANGELING)
	return ..()

/datum/antagonist/changeling/apply_innate_effects(mob/living/mob_override)
	var/mob/mob_to_tweak = mob_override || owner.current
	if(!isliving(mob_to_tweak))
		return

	var/mob/living/living_mob = mob_to_tweak
	handle_clown_mutation(living_mob, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
	RegisterSignal(living_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(living_mob, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(living_mob, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(on_fullhealed))

	if(living_mob.hud_used)
		living_mob.hud_used.lingchemdisplay.invisibility = 0
		living_mob.hud_used.lingchemdisplay.maptext = FORMAT_CHEM_CHARGES_TEXT(chem_charges)
	else
		RegisterSignal(living_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

	if(!iscarbon(mob_to_tweak))
		return

	var/mob/living/carbon/carbon_mob = mob_to_tweak
	RegisterSignals(carbon_mob, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON), PROC_REF(on_click_sting))

	// Brains are optional for lings.
	var/obj/item/organ/brain/our_ling_brain = carbon_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(our_ling_brain)
		our_ling_brain.organ_flags &= ~ORGAN_VITAL
		our_ling_brain.decoy_override = TRUE

/datum/antagonist/changeling/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/mob/living/M = source
	if(M.hud_used)
		M.hud_used.lingchemdisplay.invisibility = 0
		M.hud_used.lingchemdisplay.maptext = FORMAT_CHEM_CHARGES_TEXT(chem_charges)

/datum/antagonist/changeling/proc/generate_name()
	var/static/list/left_changling_names = GLOB.greek_letters.Copy()

	var/honorific
	if(owner.current.gender == FEMALE)
		honorific = "Ms."
	else
		honorific = "Mr."
	if(length(left_changling_names))
		changelingID = pick_n_take(left_changling_names)
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [pick(GLOB.greek_letters)] No.[rand(1,9)]"

/datum/antagonist/changeling/remove_innate_effects(mob/living/mob_override)
	var/mob/living/living_mob = mob_override || owner.current
	handle_clown_mutation(living_mob, removing = FALSE)
	UnregisterSignal(living_mob, list(COMSIG_MOB_LOGIN, COMSIG_LIVING_LIFE, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON, COMSIG_MOB_HUD_CREATED))
	living_mob?.hud_used?.lingchemdisplay?.invisibility = INVISIBILITY_ABSTRACT

/datum/antagonist/changeling/on_removal()
	remove_changeling_powers(include_innate = TRUE)
	owner.current.remove_all_languages(LANGUAGE_CHANGELING, TRUE)
	if(!iscarbon(owner.current))
		return
	var/mob/living/carbon/carbon_owner = owner.current
	var/obj/item/organ/brain/not_ling_brain = carbon_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(not_ling_brain && (not_ling_brain.decoy_override != initial(not_ling_brain.decoy_override)))
		not_ling_brain.organ_flags |= ORGAN_VITAL
		not_ling_brain.decoy_override = FALSE
	return ..()

/datum/antagonist/changeling/farewell()
	to_chat(owner.current, span_userdanger("You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!"))

/*
 * Instantiate the cellular emporium for the changeling.
 */
/datum/antagonist/changeling/proc/create_emporium()
	cellular_emporium = new(src)
	emporium_action = new(cellular_emporium)
	emporium_action.Grant(owner.current)

/*
 * Instantiate all the default actions of a ling (transform, dna sting, absorb, etc)
 * Any Changeling action with `dna_cost == 0` will be added here automatically
 */
/datum/antagonist/changeling/proc/create_innate_actions()
	for(var/datum/action/changeling/path as anything in all_powers)
		if(initial(path.dna_cost) != 0)
			continue

		var/datum/action/changeling/innate_ability = new path()
		innate_powers += innate_ability
		innate_ability.on_purchase(owner.current, TRUE)

/*
 * Signal proc for [COMSIG_MOB_LOGIN].
 * Gives us back our action buttons if we lose them on log-in.
 */
/datum/antagonist/changeling/proc/on_login(datum/source)
	SIGNAL_HANDLER

	if(!isliving(source))
		return
	var/mob/living/living_source = source
	if(!living_source.mind)
		return

	regain_powers()

/*
 * Signal proc for [COMSIG_LIVING_LIFE].
 * Handles regenerating chemicals on life ticks.
 */
/datum/antagonist/changeling/proc/on_life(datum/source, delta_time, times_fired)
	SIGNAL_HANDLER

	if(!iscarbon(owner.current))
		return

	// If dead, we only regenerate up to half chem storage.
	if(owner.current.stat == DEAD)
		adjust_chemicals((chem_recharge_rate - chem_recharge_slowdown) * delta_time, total_chem_storage * 0.5)

	// If we're not dead - we go up to the full chem cap.
	else
		adjust_chemicals((chem_recharge_rate - chem_recharge_slowdown) * delta_time)

/**
 * Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL], getting admin-healed restores our chemicals.
 */
/datum/antagonist/changeling/proc/on_fullhealed(datum/source, heal_flags)
	SIGNAL_HANDLER

	if(heal_flags & HEAL_ADMIN)
		adjust_chemicals(INFINITY)

/**
 * Signal proc for [COMSIG_MOB_MIDDLECLICKON] and [COMSIG_MOB_ALTCLICKON].
 * Allows the changeling to sting people with a click.
 */
/datum/antagonist/changeling/proc/on_click_sting(mob/living/carbon/ling, atom/clicked)
	SIGNAL_HANDLER

	// nothing to handle
	if(!chosen_sting)
		return
	if(!isliving(ling) || clicked == ling || ling.stat != CONSCIOUS)
		return
	// sort-of hack done here: we use in_given_range here because it's quicker.
	// actual ling stings do pathfinding to determine whether the target's "in range".
	// however, this is "close enough" preliminary checks to not block click
	if(!isliving(clicked) || !IN_GIVEN_RANGE(ling, clicked, sting_range))
		return

	INVOKE_ASYNC(chosen_sting, TYPE_PROC_REF(/datum/action/changeling/sting, try_to_sting), ling, clicked)

	return COMSIG_MOB_CANCEL_CLICKON

/*
 * Adjust the chem charges of the ling by [amount]
 * and clamp it between 0 and override_cap (if supplied) or total_chem_storage (if no override supplied)
 */
/datum/antagonist/changeling/proc/adjust_chemicals(amount, override_cap)
	if(!isnum(amount))
		return
	var/cap_to = isnum(override_cap) ? override_cap : total_chem_storage
	chem_charges = clamp(chem_charges + amount, 0, cap_to)

	owner.current.hud_used?.lingchemdisplay.maptext = FORMAT_CHEM_CHARGES_TEXT(chem_charges)

/*
 * Remove changeling powers from the current Changeling's purchased_powers list.
 *
 * if [include_innate] = TRUE, will also remove all powers from the Changeling's innate_powers list.
 */
/datum/antagonist/changeling/proc/remove_changeling_powers(include_innate = FALSE)
	if(!isliving(owner.current))
		return

	if(chosen_sting)
		chosen_sting.unset_sting(owner.current)

	QDEL_LIST_ASSOC_VAL(purchased_powers)
	if(include_innate)
		QDEL_LIST(innate_powers)

	genetic_points = total_genetic_points
	chem_charges = min(chem_charges, total_chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)

/*
 * For resetting all of the changeling's action buttons. (IE, re-granting them all.)
 */
/datum/antagonist/changeling/proc/regain_powers()
	emporium_action.Grant(owner.current)
	for(var/datum/action/changeling/power as anything in innate_powers)
		if(power.needs_button)
			power.Grant(owner.current)

	for(var/power_path in purchased_powers)
		var/datum/action/changeling/power = purchased_powers[power_path]
		if(istype(power) && power.needs_button)
			power.Grant(owner.current)

/*
 * The act of purchasing a certain power for a changeling.
 *
 * [sting_path] - the power that's being purchased / evolved.
 */
/datum/antagonist/changeling/proc/purchase_power(datum/action/changeling/sting_path)
	if(!ispath(sting_path))
		CRASH("Changeling purchase_power attempted to purchase an invalid typepath!")

	if(purchased_powers[sting_path])
		to_chat(owner.current, span_warning("We have already evolved this ability!"))
		return FALSE

	if(genetic_points < initial(sting_path.dna_cost))
		to_chat(owner.current, span_warning("We have reached our capacity for abilities!"))
		return FALSE

	if(absorbed_count < initial(sting_path.req_dna))
		to_chat(owner.current, span_warning("We lack the DNA to evolve this ability!"))
		return FALSE

	if(initial(sting_path.dna_cost) < 0)
		to_chat(owner.current, span_warning("We cannot evolve this ability!"))
		return FALSE

	//To avoid potential exploits by buying new powers while in stasis, which clears your verblist. // Probably not a problem anymore, but whatever.
	if(HAS_TRAIT(owner.current, TRAIT_DEATHCOMA))
		to_chat(owner.current, span_warning("We lack the energy to evolve new abilities right now!"))
		return FALSE

	var/datum/action/changeling/new_action = new sting_path()

	if(!new_action)
		to_chat(owner.current, "This is awkward. Changeling power purchase failed, please report this bug to a coder!")
		CRASH("Changeling purchase_power was unable to create a new changeling action for path [sting_path]!")

	genetic_points -= new_action.dna_cost
	purchased_powers[sting_path] = new_action
	new_action.on_purchase(owner.current) // Grant() is ran in this proc, see changeling_powers.dm.
	return TRUE

/*
 * Changeling's ability to re-adapt all of their learned powers.
 */
/datum/antagonist/changeling/proc/readapt()
	if(!ishuman(owner.current))
		to_chat(owner.current, span_danger("We can't remove our evolutions in this form!"))
		return
	if(HAS_TRAIT_FROM(owner.current, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		to_chat(owner.current, span_warning("We are too busy reforming ourselves to readapt right now!"))
		return

	if(can_respec)
		to_chat(owner.current, span_notice("We have removed our evolutions from this form, and are now ready to readapt."))
		remove_changeling_powers()
		can_respec = FALSE
		SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, "Readapt")
		log_game("Genetic powers refunded by [owner.current.ckey]/[owner.current.name] the [owner.current.job], [genetic_points] GP remaining.")
		return TRUE

	to_chat(owner.current, span_warning("You lack the power to readapt your evolutions!"))
	return FALSE

/*
 * Get the corresponding changeling profile for the passed name.
 */
/datum/antagonist/changeling/proc/get_dna(searched_dna_name)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(searched_dna_name == found_profile.name)
			return found_profile

/*
 * Checks if we have a changeling profile with the passed DNA.
 */
/datum/antagonist/changeling/proc/has_profile_with_dna(datum/dna/searched_dna)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(searched_dna.is_same_as(found_profile.dna))
			return TRUE
	return FALSE

/*
 * Checks if this changeling can absorb the DNA of [target].
 * if [verbose] = TRUE, give feedback as to why they cannot absorb the DNA.
 */
/datum/antagonist/changeling/proc/can_absorb_dna(mob/living/carbon/human/target, verbose = TRUE)
	if(!target)
		return FALSE
	if(!iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/user = owner.current

	if(!target.has_dna())
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return FALSE
	if(has_profile_with_dna(target.dna))
		if(verbose)
			to_chat(user, span_warning("We already have this DNA in storage!"))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_NOT_TRANSMORPHIC) || HAS_TRAIT(target, TRAIT_NO_DNA_COPY))
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_BADDNA))
		if(verbose)
			to_chat(user, span_warning("[target]'s DNA is ruined beyond usability!"))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(verbose)
			to_chat(user, span_warning("[target]'s body is ruined beyond usability!"))
		return FALSE
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		if(verbose)
			to_chat(user, span_warning("We could gain no benefit from absorbing a lesser creature."))
		return FALSE
	return TRUE

/*
 * Create a new changeling profile datum based off of [target].
 *
 * target - the human we're basing the new profile off of.
 * protect - if TRUE, set the new profile to protected, preventing it from being removed (without force).
 */
/datum/antagonist/changeling/proc/create_profile(mob/living/carbon/human/target, protect = 0)
	var/datum/changeling_profile/new_profile = new()

	target.dna.real_name = target.real_name //Set this again, just to be sure that it's properly set.

	// Set up a copy of their DNA in our profile.
	var/datum/dna/new_dna = new target.dna.type()
	target.dna.copy_dna(new_dna)
	new_profile.dna = new_dna
	new_profile.name = target.real_name
	new_profile.protected = protect

	new_profile.age = target.age
	//new_profile.physique = target.physique

	// Clothes, of course
	new_profile.underwear = target.underwear
	new_profile.underwear_color = target.underwear_color
	new_profile.undershirt = target.undershirt
	new_profile.socks = target.socks

	var/obj/item/card/id/id_card = target.wear_id?.GetID()
	if (istype(id_card))
		new_profile.id_job_name = id_card.assignment
		new_profile.id_hud_state = id_card.hud_state

	// Hair and facial hair gradients, alongside their colours.
	//new_profile.grad_style = LAZYLISTDUPLICATE(target.grad_style)
	//new_profile.grad_color = LAZYLISTDUPLICATE(target.grad_color)

	// Make an icon snapshot of what they currently look like
	var/datum/icon_snapshot/entry = new()
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(HANDS_LAYER, HANDCUFF_LAYER, LEGCUFF_LAYER))
	new_profile.profile_snapshot = entry

	var/list/slots = list("head", "wear_mask", "wear_neck", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		if(!(slot in target.vars))
			continue
		var/obj/item/clothing/clothing_item = target.vars[slot]
		if(!clothing_item)
			continue
		new_profile.name_list[slot] = clothing_item.name
		new_profile.appearance_list[slot] = clothing_item.appearance
		new_profile.type_list[slot] = clothing_item.type
		new_profile.flags_cover_list[slot] = clothing_item.flags_cover
		new_profile.lefthand_file_list[slot] = clothing_item.lefthand_file
		new_profile.righthand_file_list[slot] = clothing_item.righthand_file
		new_profile.inhand_icon_state_list[slot] = clothing_item.inhand_icon_state
		new_profile.worn_icon_list[slot] = clothing_item.worn_icon
		new_profile.worn_icon_state_list[slot] = clothing_item.worn_icon_state
		new_profile.exists_list[slot] = 1

	return new_profile

/*
 * Add a new profile to our changeling's profile list.
 * Pops the first profile in the list if we're above our limit of profiles.
 *
 * new_profile - the profile being added.
 */
/datum/antagonist/changeling/proc/add_profile(datum/changeling_profile/new_profile)
	if(!first_profile)
		first_profile = new_profile
		current_profile = first_profile

	stored_profiles += new_profile
	absorbed_count++

/*
 * Create a new profile from the given [profile_target]
 * and add it to our profile list via add_profile.
 *
 * profile_target - the human we're making a profile based off of
 * protect - if TRUE, mark the new profile as protected. If protected, it cannot be removed / popped from the profile list (without force).
 */
/datum/antagonist/changeling/proc/add_new_profile(mob/living/carbon/human/profile_target, protect = FALSE)
	var/datum/changeling_profile/new_profile = create_profile(profile_target, protect)
	add_profile(new_profile)
	return new_profile

/*
 * Remove a given profile from the profile list.
 *  *
 * profile_target - the human we want to remove from our profile list (looks for a profile with a matching name)
 * force - if TRUE, removes the profile even if it's protected.
 */
/datum/antagonist/changeling/proc/remove_profile(mob/living/carbon/human/profile_target, force = FALSE)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(profile_target.real_name == found_profile.name)
			if(found_profile.protected && !force)
				continue
			stored_profiles -= found_profile
			qdel(found_profile)

/*
 * Removes the highest changeling profile from the list
 * that isn't protected and returns TRUE if successful.
 *
 * Returns TRUE if a profile was removed, FALSE otherwise.
 */
/datum/antagonist/changeling/proc/push_out_profile()
	var/datum/changeling_profile/profle_to_remove
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(!found_profile.protected)
			profle_to_remove = found_profile
			break

	if(profle_to_remove)
		stored_profiles -= profle_to_remove
		return TRUE
	return FALSE

/*
 * Create a profile based on the changeling's initial appearance.
 */
/datum/antagonist/changeling/proc/create_initial_profile()
	var/mob/living/carbon/carbon_owner = owner.current //only carbons have dna now, so we have to typecast
	if(HAS_TRAIT(carbon_owner, TRAIT_NOT_TRANSMORPHIC))
		carbon_owner.set_species(/datum/species/human)
		var/prefs_name = carbon_owner.client?.prefs?.read_character_preference(/datum/preference/name/backup_human)
		if(prefs_name)
			carbon_owner.fully_replace_character_name(carbon_owner.real_name, prefs_name)
		else
			carbon_owner.fully_replace_character_name(carbon_owner.real_name, carbon_owner.generate_random_mob_name())
		for(var/datum/record/crew/record in GLOB.manifest.general)
			if(record.name == carbon_owner.real_name)
				record.species = carbon_owner.dna.species.name
				record.gender = carbon_owner.gender

				//Not directly assigning carbon_owner.appearance because it might not update in time at roundstart
				record.character_appearance = get_flat_existing_human_icon(carbon_owner, list(SOUTH, WEST))

	if(ishuman(carbon_owner))
		add_new_profile(carbon_owner)

/datum/antagonist/changeling/greet()
	to_chat(owner.current, "<b>You must complete the following tasks:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

	owner.announce_objectives()

	owner.current.client?.tgui_panel?.give_antagonist_popup("Changeling",
		"You have absorbed the form of [owner.current] and have infiltrated the station. Use your changeling powers to complete your objectives.")

/datum/antagonist/changeling/farewell()
	to_chat(owner.current, span_userdanger("You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!"))

/// Generate objectives for our changeling.
/datum/antagonist/changeling/proc/forge_objectives()
	//OBJECTIVES - random traitor objectives. Unique objectives "steal brain" and "identity theft".
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/escape_objective_possible = TRUE
	switch(competitive_objectives ? rand(1,2) : 1)
		if(1)
			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = owner
			absorb_objective.gen_amount_goal(6, 8)
			objectives += absorb_objective
			log_objective(owner, absorb_objective.explanation_text)
		if(2)
			var/datum/objective/absorb_most/ac = new
			ac.owner = owner
			objectives += ac
			log_objective(owner, ac.explanation_text)

	if(prob(60))
		if(prob(85))
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
			log_objective(owner, steal_objective.explanation_text)
		else
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			objectives += download_objective
			log_objective(owner, download_objective.explanation_text)

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/GLOB.joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = owner
		destroy_objective.find_target()
		objectives += destroy_objective
		log_objective(owner, destroy_objective.explanation_text)
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
			log_objective(owner, kill_objective.explanation_text)
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			objectives += maroon_objective
			log_objective(owner, maroon_objective.explanation_text)

			if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = owner
				if(identity_theft.is_valid_target(maroon_objective.target))
					identity_theft.set_target(maroon_objective.target)
					identity_theft.update_explanation_text()
					objectives += identity_theft
					log_objective(owner, identity_theft.explanation_text)
					escape_objective_possible = FALSE
				else
					qdel(identity_theft)

	if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
			log_objective(owner, escape_objective.explanation_text)
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = owner
			identity_theft.find_target()
			objectives += identity_theft
			log_objective(owner, identity_theft.explanation_text)
		escape_objective_possible = FALSE

/datum/antagonist/changeling/proc/update_changeling_icons_added()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_CHANGELING]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "changeling")

/datum/antagonist/changeling/proc/update_changeling_icons_removed()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_CHANGELING]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/changeling/admin_add(datum/mind/new_owner,mob/admin)
	. = ..()
	to_chat(new_owner.current, span_boldannounce("Our powers have awoken. A flash of memory returns to us...we are a changeling!"))

/datum/antagonist/changeling/get_admin_commands()
	. = ..()
	if(stored_profiles.len && (owner.current.real_name != first_profile.name))
		.["Transform to initial appearance."] = CALLBACK(src,PROC_REF(admin_restore_appearance))

/*
 * Restores the appearance of the changeling to the original DNA.
 */
/datum/antagonist/changeling/proc/admin_restore_appearance(mob/admin)
	if(!stored_profiles.len || !iscarbon(owner.current))
		to_chat(admin, span_danger("Resetting DNA failed!"))
		return

	var/mob/living/carbon/carbon_owner = owner.current
	first_profile.dna.transfer_identity(carbon_owner, transfer_SE = TRUE)
	carbon_owner.real_name = first_profile.name
	carbon_owner.updateappearance(mutcolor_update = TRUE)
	carbon_owner.domutcheck()

/*
 * Transform the currentc hangeing [user] into the [chosen_profile].
 */
/datum/antagonist/changeling/proc/transform(mob/living/carbon/human/user, datum/changeling_profile/chosen_profile)
	var/static/list/slot2slot = list(
		"head" = ITEM_SLOT_HEAD,
		"wear_mask" = ITEM_SLOT_MASK,
		"wear_neck" = ITEM_SLOT_NECK,
		"back" = ITEM_SLOT_BACK,
		"wear_suit" = ITEM_SLOT_OCLOTHING,
		"w_uniform" = ITEM_SLOT_ICLOTHING,
		"shoes" = ITEM_SLOT_FEET,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"glasses" = ITEM_SLOT_EYES,
		"ears" = ITEM_SLOT_EARS,
		"wear_id" = ITEM_SLOT_ID,
		"s_store" = ITEM_SLOT_SUITSTORE,
	)

	var/datum/dna/chosen_dna = chosen_profile.dna
	user.real_name = chosen_profile.name
	user.underwear = chosen_profile.underwear
	user.underwear_color = chosen_profile.underwear_color
	user.undershirt = chosen_profile.undershirt
	user.socks = chosen_profile.socks
	user.age = chosen_profile.age
	//user.physique = chosen_profile.physique
	//user.grad_style = LAZYLISTDUPLICATE(chosen_profile.grad_style)
	//user.grad_color = LAZYLISTDUPLICATE(chosen_profile.grad_color)

	chosen_dna.transfer_identity(user, TRUE)

	for(var/obj/item/bodypart/limb as anything in user.bodyparts)
		limb.update_limb(is_creating = TRUE)

	user.updateappearance(mutcolor_update = TRUE)
	user.domutcheck()

	//vars hackery. not pretty, but better than the alternative.
	for(var/slot in slot2type)
		if(istype(user.vars[slot], slot2type[slot]) && !(chosen_profile.exists_list[slot])) //remove unnecessary flesh items
			qdel(user.vars[slot])
			continue

		if((user.vars[slot] && !istype(user.vars[slot], slot2type[slot])) || !(chosen_profile.exists_list[slot]))
			continue

		if(istype(user.vars[slot], slot2type[slot]) && slot == "wear_id") //always remove old flesh IDs, so they get properly updated
			qdel(user.vars[slot])

		var/obj/item/new_flesh_item
		var/equip = FALSE
		if(!user.vars[slot])
			var/slot_type = slot2type[slot]
			equip = TRUE
			new_flesh_item = new slot_type(user)

		else if(istype(user.vars[slot], slot2type[slot]))
			new_flesh_item = user.vars[slot]

		new_flesh_item.appearance = chosen_profile.appearance_list[slot]
		new_flesh_item.name = chosen_profile.name_list[slot]
		new_flesh_item.flags_cover = chosen_profile.flags_cover_list[slot]
		new_flesh_item.lefthand_file = chosen_profile.lefthand_file_list[slot]
		new_flesh_item.righthand_file = chosen_profile.righthand_file_list[slot]
		new_flesh_item.inhand_icon_state = chosen_profile.inhand_icon_state_list[slot]
		new_flesh_item.worn_icon = chosen_profile.worn_icon_list[slot]
		new_flesh_item.worn_icon_state = chosen_profile.worn_icon_state_list[slot]

		REMOVE_TRAIT(new_flesh_item, TRAIT_VALUE_MIMIC_PATH, FROM_CHAMELEON)
		ADD_VALUE_TRAIT(new_flesh_item, TRAIT_VALUE_MIMIC_PATH, CHANGELING_TRAIT, chosen_profile.type_list[slot], PRIORITY_CHANGELING_MIMIC)

		if(istype(new_flesh_item, /obj/item/card/id/changeling) && chosen_profile.id_job_name)
			var/obj/item/card/id/changeling/flesh_id = new_flesh_item
			flesh_id.assignment = chosen_profile.id_job_name
			flesh_id.hud_state = chosen_profile.id_hud_state

		if(equip)
			user.equip_to_slot_or_del(new_flesh_item, slot2slot[slot])
			if(!QDELETED(new_flesh_item))
				ADD_TRAIT(new_flesh_item, TRAIT_NODROP, CHANGELING_TRAIT)

	user.regenerate_icons()
	current_profile = chosen_profile
	user.name = user.get_visible_name()

// Changeling profile themselves. Store a data to store what every DNA instance looked like.
/datum/changeling_profile
	/// The name of the profile / the name of whoever this profile source.
	var/name = "a bug"
	/// Whether this profile is protected - if TRUE, it cannot be removed from a changeling's profiles without force
	var/protected = FALSE
	/// The DNA datum associated with our profile from the profile source
	var/datum/dna/dna
	/// Assoc list of item slot to item name - stores the name of every item of this profile.
	var/list/name_list = list()
	/// Assoc list of item slot to type - stores the type of every item of this profile.
	var/list/type_list = list()
	/// Assoc list of item slot to apperance - stores the appearance of every item of this profile.
	var/list/appearance_list = list()
	/// Assoc list of item slot to flag - stores the flags_cover of every item of this profile.
	var/list/flags_cover_list = list()
	/// Assoc list of item slot to boolean - stores whether an item in that slot exists
	var/list/exists_list = list()
	/// Assoc list of item slot to file - stores the lefthand file of the item in that slot
	var/list/lefthand_file_list = list()
	/// Assoc list of item slot to file - stores the righthand file of the item in that slot
	var/list/righthand_file_list = list()
	/// Assoc list of item slot to file - stores the inhand file of the item in that slot
	var/list/inhand_icon_state_list = list()
	/// Assoc list of item slot to file - stores the worn icon file of the item in that slot
	var/list/worn_icon_list = list()
	/// Assoc list of item slot to string - stores the worn icon state of the item in that slot
	var/list/worn_icon_state_list = list()
	/// The underwear worn by the profile source
	var/underwear
	/// The colour of the underwear worn by the profile source
	var/underwear_color
	/// The undershirt worn by the profile source
	var/undershirt
	/// The socks worn by the profile source
	var/socks
	/// Icon snapshot of the profile
	var/datum/icon_snapshot/profile_snapshot

	/// ID HUD icon associated with the profile
	var/id_job_name
	var/id_hud_state

	/// The age of the profile source.
	var/age
	/// The body type of the profile source.
	var/physique
	/// The hair and facial hair gradient styles of the profile source.
	var/list/grad_style = list("None", "None")
	/// The hair and facial hair gradient colours of the profile source.
	var/list/grad_color = list(null, null)

/datum/changeling_profile/Destroy()
	qdel(dna)
	. = ..()

/*
 * Copy every aspect of this file into a new instance of a profile.
 * Must be suppied with an instance.
 */
/datum/changeling_profile/proc/copy_profile(datum/changeling_profile/new_profile)
	new_profile.name = name
	new_profile.protected = protected
	new_profile.dna = new dna.type
	dna.copy_dna(new_profile.dna)
	new_profile.name_list = name_list.Copy()
	new_profile.appearance_list = appearance_list.Copy()
	new_profile.flags_cover_list = flags_cover_list.Copy()
	new_profile.exists_list = exists_list.Copy()
	new_profile.inhand_icon_state_list = inhand_icon_state_list.Copy()
	new_profile.lefthand_file_list = lefthand_file_list.Copy()
	new_profile.righthand_file_list = righthand_file_list.Copy()
	new_profile.worn_icon_list = worn_icon_list.Copy()
	new_profile.worn_icon_state_list = worn_icon_state_list.Copy()
	new_profile.underwear = underwear
	new_profile.underwear_color = underwear_color
	new_profile.undershirt = undershirt
	new_profile.socks = socks
	new_profile.id_job_name = id_job_name
	new_profile.id_hud_state = id_hud_state
	new_profile.age = age
	new_profile.physique = physique
	new_profile.grad_style = LAZYLISTDUPLICATE(grad_style)
	new_profile.grad_color = LAZYLISTDUPLICATE(grad_color)

/datum/antagonist/changeling/xenobio
	name = "Xenobio Changeling"
	give_objectives = FALSE
	show_in_roundend = FALSE //These are here for admin tracking purposes only
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/changeling/roundend_report()
	var/list/parts = list()

	var/changeling_win = TRUE
	if(!owner.current)
		changeling_win = FALSE

	parts += printplayer(owner)
	parts += "<b>Genomes Extracted:</b> [absorbed_count]<br>"

	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!</b>")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				changeling_win = 0
			count++

	if(changeling_win)
		parts += span_greentext("The changeling was successful!")
	else
		parts += span_redtext("The changeling has failed.")

	return parts.Join("<br>")


///a changeling that has lost their powers. does nothing, other than signify they suck
/datum/antagonist/fallen_changeling
	name = "\improper Fallen Changeling"
	roundend_category = "changelings"
	antagpanel_category = "Changeling"
	banning_key = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/fallen_changeling
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/mood_event/fallen_changeling
	description = "My powers! Where are my powers?!"
	mood_change = -4

#undef FORMAT_CHEM_CHARGES_TEXT
