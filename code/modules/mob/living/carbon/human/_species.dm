// This code handles different species in the game.

GLOBAL_LIST_EMPTY(roundstart_races)
GLOBAL_LIST_EMPTY(accepatable_no_hard_check_races)
///List of all roundstart languages by path except common
GLOBAL_LIST_EMPTY(uncommon_roundstart_languages)

/// An assoc list of species types to their features (from get_features())
GLOBAL_LIST_EMPTY(features_by_species)

/**
 * # species datum
 *
 * Datum that handles different species in the game.
 *
 * This datum handles species in the game, such as lizardpeople, mothmen, zombies, skeletons, etc.
 * It is used in [carbon humans][mob/living/carbon/human] to determine various things about them, like their food preferences, if they have biological genders, their damage resistances, and more.
 *
 */
/datum/species
	///If the game needs to manually check your race to do something not included in a proc here, it will use this.
	var/id
	///This is used for children, it will determine their default limb ID for use of examine. See [/mob/living/carbon/human/proc/examine].
	var/examine_limb_id
	///This is the fluff name. They are displayed on health analyzers and in the character setup menu. Leave them generic for other servers to customize.
	var/name
	/**
	 * The formatting of the name of the species in plural context. Defaults to "[name]\s" if unset.
	 *  Ex "[Plasmamen] are weak", "[Mothmen] are strong", "[Lizardpeople] don't like", "[Golems] hate"
	 */
	var/plural_form

	///Whether or not the race has sexual characteristics (biological genders). At the moment this is only FALSE for skeletons and shadows
	var/sexes = TRUE

	///The maximum number of bodyparts this species can have.
	var/max_bodypart_count = 6
	/// This allows races to have specific hair colors.
	/// If null, it uses the mob's hair/facial hair colors.
	/// If USE_MUTANT_COLOR, it uses the mob's mutant_color.
	/// If USE_FIXED_MUTANT_COLOR, it uses fixedmutcolor
	var/hair_color_mode
	///The alpha used by the hair. 255 is completely solid, 0 is invisible.
	var/hair_alpha = 255
	///The alpha used by the facial hair. 255 is completely solid, 0 is invisible.
	var/facial_hair_alpha = 255

	///Never, Optional, or Forced digi legs?
	var/digitigrade_customization = DIGITIGRADE_NEVER
	/// The color used for blush overlay
	var/blush_color = COLOR_BLUSH_PINK
	///If your race bleeds something other than bog standard blood, change this to reagent id. For example, ethereals bleed liquid electricity.
	var/datum/reagent/exotic_blood
	///If your race uses a non standard bloodtype (A+, O-, AB-, etc). For example, lizards have L type blood.
	var/exotic_bloodtype
	///What the species drops when gibbed by a gibber machine.
	var/meat = /obj/item/food/meat/slab/human
	///What skin the species drops when gibbed by a gibber machine.
	var/skinned_type
	///flags for inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example.
	var/no_equip_flags
	/// What languages this species can understand and say.
	/// Use a [language holder datum][/datum/language_holder] typepath in this var.
	/// Should never be null.
	var/datum/language_holder/species_language_holder = /datum/language_holder/human_basic
	/**
	  * Visible CURRENT bodyparts that are unique to a species.
	  * DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK
	  * SHIT UP! Changes to this list for non-species specific bodyparts (ie
	  * cat ears and tails) should be assigned at organ level if possible.
	  * Assoc values are defaults for given bodyparts, also modified by aforementioned organs.
	  * They also allow for faster '[]' list access versus 'in'. Other than that, they are useless right now.
	  * Layer hiding is handled by [/datum/species/proc/handle_mutant_bodyparts] below.
	  */
	var/list/mutant_bodyparts = list()
	///The bodyparts this species uses. assoc of bodypart string - bodypart type. Make sure all the fucking entries are in or I'll skin you alive.
	var/list/bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	///Internal organs that are unique to this race, like a tail or other cosmetic organs. list(typepath of organ 1, typepath of organ 2 = "Round").
	var/list/mutant_organs = list()
	///Replaces default brain with a different organ
	var/obj/item/organ/brain/mutantbrain = /obj/item/organ/brain
	///Replaces default heart with a different organ
	var/obj/item/organ/heart/mutantheart = /obj/item/organ/heart
	///Replaces default lungs with a different organ
	var/obj/item/organ/lungs/mutantlungs = /obj/item/organ/lungs
	///Replaces default eyes with a different organ
	var/obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	///Replaces default ears with a different organ
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	///Replaces default tongue with a different organ
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	///Replaces default liver with a different organ
	var/obj/item/organ/liver/mutantliver = /obj/item/organ/liver
	///Replaces default stomach with a different organ
	var/obj/item/organ/stomach/mutantstomach = /obj/item/organ/stomach
	///Replaces default appendix with a different organ.
	var/obj/item/organ/appendix/mutantappendix = /obj/item/organ/appendix

	/// Store body marking defines. See mobs.dm for bitflags
	var/list/body_markings = list()

	/**
	 * Percentage modifier for overall defense of the race, or less defense, if it's negative
	 * THIS MODIFIES ALL DAMAGE TYPES.
	 **/
	var/damage_modifier = 0
	///multiplier for damage from cold temperature
	var/coldmod = 1
	///multiplier for damage from hot temperature
	var/heatmod = 1
	///multiplier for stun durations
	var/stunmod = 1
	///multiplier for damage from cloning
	var/clonemod = 1
	///multiplier for damage from toxins
	var/toxmod = 1
	///Base electrocution coefficient.  Basically a multiplier for damage from electrocutions.
	var/siemens_coeff = 1
	///To use MUTCOLOR with a fixed color that's independent of the mcolor feature in DNA.
	var/fixed_mut_color = ""
	///Special mutation that can be found in the genepool exclusively in this species. Dont leave empty or changing species will be a headache
	var/inert_mutation = /datum/mutation/dwarfism
	///Used to set the mob's death_sound upon species change
	var/death_sound
	///Sounds to override barefeet walking
	var/list/special_step_sounds
	///Special sound for grabbing
	var/grab_sound
	var/reagent_tag = PROCESS_ORGANIC //Used for metabolizing reagents. We're going to assume you're a meatbag unless you say otherwise.
	var/species_gibs = GIB_TYPE_HUMAN //by default human gibs are used
	var/allow_numbers_in_name // Can this species use numbers in its name?
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life

	/// The natural temperature for a body
	var/bodytemp_normal = BODYTEMP_NORMAL
	/// Minimum amount of kelvin moved toward normal body temperature per tick.
	var/bodytemp_autorecovery_min = BODYTEMP_AUTORECOVERY_MINIMUM
	/// The body temperature limit the body can take before it starts taking damage from heat.
	var/bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT
	/// The body temperature limit the body can take before it starts taking damage from cold.
	var/bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT

	///Does our species have colors for its' damage overlays?
	var/use_damage_color = TRUE

	/// Generic traits tied to having the species.
	var/list/inherent_traits = list()
	/// Bitflags of biotypes the mob belongs to. Used by diseases.
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	///What gas does this species breathe? Used by suffocation screen alerts, most of actual gas breathing is handled by mutantlungs. See [life.dm][code/modules/mob/living/carbon/human/life.dm]
	var/breathid = GAS_O2

	///Bitflag that controls what in game ways something can select this species as a spawnable source, such as magic mirrors. See [mob defines][code/__DEFINES/mobs.dm] for possible sources.
	var/changesource_flags = NONE

	//The component to add when swimming
	var/swimming_component = /datum/component/swimming

	/// if false, having no tongue makes you unable to speak
	var/speak_no_tongue = TRUE

	///List of possible heights
	var/list/species_height = SPECIES_HEIGHTS(BODY_SIZE_SHORT, BODY_SIZE_NORMAL, BODY_SIZE_TALL)

	/// What bleed status effect should we apply?
	var/bleed_effect = /datum/status_effect/bleeding

	/// Should we preload this species's organs?
	var/preload = TRUE


	/// Do we try to prevent reset_perspective() from working?
	var/prevent_perspective_change = FALSE

	///List of results you get from knife-butchering. null means you cant butcher it. Associated by resulting type - value of amount
	var/list/knife_butcher_results


	/**
	 * Was on_species_gain ever actually called?
	 * Species code is really odd...
	 **/
	var/properly_gained = FALSE

	/// The name key for the species, if the user changes from one species
	/// to another which has a different name key, their name will be reset
	/// to a random name.
	/// If null, then it will always change.
	var/name_key = null

///////////
// PROCS //
///////////


/datum/species/New()
	if(!plural_form)
		plural_form = "[name]\s"
	if(!examine_limb_id)
		examine_limb_id = id

	return ..()

/// Gets a list of all species available to choose in roundstart.
/proc/get_selectable_species()
	RETURN_TYPE(/list)

	if (!GLOB.roundstart_races.len)
		GLOB.roundstart_races = generate_selectable_species_and_languages()

	return GLOB.roundstart_races

/**
 * Generates species available to choose in character setup at roundstart
 *
 * This proc generates which species are available to pick from in character setup.
 * If there are no available roundstart species, defaults to human.
 */
/proc/generate_selectable_species_and_languages()
	var/list/selectable_species = list()

	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = GLOB.species_prototypes[species_type]
		if(species.check_roundstart_eligible())
			selectable_species += species.id
			var/datum/language_holder/temp_holder = GLOB.prototype_language_holders[species.species_language_holder]
			for(var/datum/language/spoken_language as anything in temp_holder.understood_languages)
				GLOB.uncommon_roundstart_languages |= spoken_language

	GLOB.uncommon_roundstart_languages -= /datum/language/common
	if(!selectable_species.len)
		selectable_species += get_fallback_species_id()

	return selectable_species

/proc/get_fallback_species_id()
	var/fallback = CONFIG_GET(string/fallback_default_species)
	var/id = fallback
	if(fallback == "random") // absolute schizoposting
		if(length(GLOB.roundstart_races))
			id = pick(GLOB.roundstart_races)
		else
			var/datum/species/type = pick(subtypesof(/datum/species))
			id = initial(type.id)
	return id

/// Gets a list of species that are allowed to be used from the DB even if they are disabled due to roundstart_no_hard_check
/// Use get_selectable_species() for new/editing characters.
/proc/get_acceptable_species()
	RETURN_TYPE(/list)

	if (!GLOB.accepatable_no_hard_check_races.len)
		GLOB.accepatable_no_hard_check_races = generate_acceptable_species()

	return GLOB.accepatable_no_hard_check_races

/proc/generate_acceptable_species()
	var/list/base = get_selectable_species() // normally allowed species.
	var/list/no_hard_check = CONFIG_GET(keyed_list/roundstart_no_hard_check)
	no_hard_check = no_hard_check.Copy()
	for(var/species_id in no_hard_check)
		if(!GLOB.species_list[species_id])
			continue
		base += species_id
		no_hard_check -= species_id
	for(var/species_id in no_hard_check) // warn any invalid species in the config.
		stack_trace("WARNING: roundstart_no_hard_check contains invalid species ID: [species_id]")
	return base

/**
 * Checks if a species is eligible to be picked at roundstart.
 *
 * Checks the config to see if this species is allowed to be picked in the character setup menu.
 * Used by [/proc/generate_selectable_species_and_languages].
 */
/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/**
 * Generates a random name for a carbon.
 *
 * This generates a random unique name based on a human's species and gender.
 * Arguments:
 * * gender - The gender that the name should adhere to. Use MALE for male names, use anything else for female names.
 * * unique - If true, ensures that this new name is not a duplicate of anyone else's name currently on the station.
 * * last_name - Do we use a given last name or pick a random new one?
 */
/datum/species/proc/random_name(gender, unique, lastname, attempts)

	if(gender == MALE)
		. = pick(GLOB.first_names_male)
	else
		. = pick(GLOB.first_names_female)

	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.last_names)]"

	if(unique && attempts < 10)
		. = .(gender, TRUE, lastname, ++attempts)

/**
 * Copies some vars and properties over that should be kept when creating a copy of this species.
 *
 * Used by slimepeople to copy themselves, and by the DNA datum to hardset DNA to a species
 * Arguments:
 * * old_species - The species that the carbon used to be before copying
 */
/datum/species/proc/copy_properties_from(datum/species/old_species, pref_load, regenerate_icons)
	return

/**
 * Gets the default mutant organ for the species based on the provided slot.
 */
/datum/species/proc/get_mutant_organ_type_for_slot(slot)
	switch(slot)
		if(ORGAN_SLOT_BRAIN)
			return mutantbrain
		if(ORGAN_SLOT_HEART)
			return mutantheart
		if(ORGAN_SLOT_LUNGS)
			return mutantlungs
		if(ORGAN_SLOT_APPENDIX)
			return mutantappendix
		if(ORGAN_SLOT_EYES)
			return mutanteyes
		if(ORGAN_SLOT_EARS)
			return mutantears
		if(ORGAN_SLOT_TONGUE)
			return mutanttongue
		if(ORGAN_SLOT_LIVER)
			return mutantliver
		if(ORGAN_SLOT_STOMACH)
			return mutantstomach
		else
			// Non-standard organs we might have
			for(var/obj/item/organ/extra_organ as anything in mutant_organs)
				if(initial(extra_organ.slot) == slot)
					return extra_organ

/**
 * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does.
 *
 * Takes all organ slots, removes organs a species should not have, adds organs a species should have.
 * can use replace_current to refresh all organs, creating an entirely new set.
 *
 * Arguments:
 * * organ_holder - carbon, the owner of the species datum AKA whoever we're regenerating organs in
 * * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
 * * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
 * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 * * visual_only - boolean, only load organs that change how the species looks. Do not use for normal gameplay stuff
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/organ_holder, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	for(var/slot in get_all_slots())
		var/obj/item/organ/existing_organ = organ_holder.get_organ_slot(slot)
		var/obj/item/organ/new_organ = get_mutant_organ_type_for_slot(slot)
		var/old_organ_type = old_species?.get_mutant_organ_type_for_slot(slot)

		// if we have an extra organ that before changing that the species didnt have, remove it
		if(!new_organ)
			if(existing_organ && (old_organ_type == existing_organ.type || replace_current))
				existing_organ.Remove(organ_holder)
				qdel(existing_organ)
			continue

		if(existing_organ)
			// we dont want to remove organs that were not from the old species (such as from freak surgery or prosthetics)
			if(existing_organ.type != old_organ_type && !replace_current)
				continue

			// we don't want to remove organs that are the same as the new one
			if(existing_organ.type == new_organ)
				continue

		if(visual_only && (!initial(new_organ.bodypart_overlay) && !initial(new_organ.visual)))
			continue

		var/used_neworgan = FALSE
		new_organ = SSwardrobe.provide_type(new_organ)
		var/should_have = new_organ.get_availability(src, organ_holder) && should_visual_organ_apply_to(new_organ, organ_holder)

		// Check for an existing organ, and if there is one check to see if we should remove it
		var/health_pct = 1
		var/remove_existing = !isnull(existing_organ) && !(existing_organ.zone in excluded_zones) && !(existing_organ.organ_flags & ORGAN_UNREMOVABLE)
		if(remove_existing)
			health_pct = (existing_organ.maxHealth - existing_organ.damage) / existing_organ.maxHealth
			if(slot == ORGAN_SLOT_BRAIN)
				var/obj/item/organ/brain/existing_brain = existing_organ
				existing_brain.before_organ_replacement(new_organ)
				existing_brain.Remove(organ_holder, special = TRUE, movement_flags = NO_ID_TRANSFER)
			else
				existing_organ.before_organ_replacement(new_organ)
				existing_organ.Remove(organ_holder, special = TRUE)

			QDEL_NULL(existing_organ)
		if(isnull(existing_organ) && should_have && !(new_organ.zone in excluded_zones) && organ_holder.get_bodypart(deprecise_zone(new_organ.zone)))
			used_neworgan = TRUE
			new_organ.set_organ_damage(new_organ.maxHealth * (1 - health_pct))
			new_organ.Insert(organ_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

		if(!used_neworgan)
			QDEL_NULL(new_organ)

/datum/species/proc/worn_items_fit_body_check(mob/living/carbon/wearer)
	for(var/obj/item/equipped_item in wearer.get_equipped_items(INCLUDE_POCKETS))
		var/equipped_item_slot = wearer.get_slot_by_item(equipped_item)
		if(!equipped_item.mob_can_equip(wearer, equipped_item_slot, bypass_equip_delay_self = TRUE, ignore_equipped = TRUE))
			wearer.dropItemToGround(equipped_item, force = TRUE)

/datum/species/proc/replace_body(mob/living/carbon/target, datum/species/new_species)
	new_species ||= target.dna.species //If no new species is provided, assume its src.
	//Note for future: Potentially add a new C.dna.species() to build a template species for more accurate limb replacement

	var/list/final_bodypart_overrides = new_species.bodypart_overrides.Copy()
	if((new_species.digitigrade_customization == DIGITIGRADE_OPTIONAL && target.dna.features["legs"] == DIGITIGRADE_LEGS) || new_species.digitigrade_customization == DIGITIGRADE_FORCED)
		final_bodypart_overrides[BODY_ZONE_R_LEG] = /obj/item/bodypart/leg/right/digitigrade
		final_bodypart_overrides[BODY_ZONE_L_LEG] = /obj/item/bodypart/leg/left/digitigrade

	for(var/obj/item/bodypart/old_part as anything in target.bodyparts)
		if((old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES) || (old_part.bodypart_flags & BODYPART_IMPLANTED))
			continue

		var/path = final_bodypart_overrides?[old_part.body_zone]
		var/obj/item/bodypart/new_part
		if(path)
			new_part = new path()
			new_part.replace_limb(target, TRUE)
			new_part.update_limb(is_creating = TRUE)
			//new_part.set_initial_damage(old_part.brute_dam, old_part.burn_dam)
		qdel(old_part)


/**
 * Proc called when a carbon becomes this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_GAIN] signal.
 * Arguments:
 * * C - Carbon, this is whoever became the new species.
 * * old_species - The species that the carbon used to be before becoming this race, used for regenerating organs.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 * * regenerate_icons - Whether or not to update the bodies icons
 */
/datum/species/proc/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load, regenerate_icons = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	C.living_flags |= STOP_OVERLAY_UPDATE_BODY_PARTS //Don't call update_body_parts() for every single bodypart overlay added.
	// Drop the items the new species can't wear
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	C.mob_biotypes = inherent_biotypes
	C.butcher_results = knife_butcher_results?.Copy()

	if(old_species.type != type)
		replace_body(C, src)

	regenerate_organs(C, old_species, replace_current = FALSE, visual_only = C.visual_only_organs)

	// Drop the items the new species can't wear
	INVOKE_ASYNC(src, PROC_REF(worn_items_fit_body_check), C, TRUE)

	//Assigns exotic blood type if the species has one
	if(exotic_bloodtype && C.dna.blood_type != exotic_bloodtype)
		C.dna.blood_type = get_blood_type(exotic_bloodtype)
	//Otherwise, check if the previous species had an exotic bloodtype and we do not have one and assign a random blood type
	//(why the fuck is blood type not tied to a fucking DNA block?)
	else if(old_species.exotic_bloodtype && !exotic_bloodtype)
		C.dna.blood_type = random_blood_type()

	if(TRAIT_NOMOUTH in inherent_traits)
		for(var/obj/item/bodypart/head/head in C.bodyparts)
			head.mouth = FALSE

	add_body_markings(C)

	if(length(inherent_traits))
		C.add_traits(inherent_traits, SPECIES_TRAIT)

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	// All languages associated with this language holder are added with source [LANGUAGE_SPECIES]
	// rather than source [LANGUAGE_ATOM], so we can track what to remove if our species changes again
	var/datum/language_holder/gaining_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in gaining_holder.understood_languages)
		C.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.spoken_languages)
		C.grant_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.blocked_languages)
		C.add_blocked_language(language, LANGUAGE_SPECIES)
	if(regenerate_icons)
		C.regenerate_icons()

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)

	properly_gained = TRUE

	C.living_flags &= ~STOP_OVERLAY_UPDATE_BODY_PARTS

/**
 * Proc called when a carbon is no longer this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_LOSS] signal.
 * Arguments:
 * * C - Carbon, this is whoever lost this species.
 * * new_species - The new species that the carbon became, used for genetics mutations.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)

	human.living_flags |= STOP_OVERLAY_UPDATE_BODY_PARTS //Don't call update_body_parts() for every single bodypart overlay removed.
	human.butcher_results = null
	if(TRAIT_NOMOUTH in inherent_traits)
		for(var/obj/item/bodypart/head/head in human.bodyparts)
			head.mouth = TRUE
	for(var/trait in inherent_traits)
		REMOVE_TRAIT(human, trait, SPECIES_TRAIT)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(human.dna.mutation_index) && (inert_mutation in human.dna.mutation_index))
		human.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = human.dna.mutation_index.Find(inert_mutation)
		human.dna.mutation_index[location] = new_species.inert_mutation
		human.dna.default_mutation_genes[location] = human.dna.mutation_index[location]
		human.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		human.dna.default_mutation_genes[new_species.inert_mutation] = human.dna.mutation_index[new_species.inert_mutation]

	if(inherent_factions)
		for(var/i in inherent_factions)
			human.faction -= i

	remove_body_markings(human)

	// Removes all languages previously associated with [LANGUAGE_SPECIES], gaining our new species will add new ones back
	var/datum/language_holder/losing_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in losing_holder.understood_languages)
		human.remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.spoken_languages)
		human.remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.blocked_languages)
		human.remove_blocked_language(language, LANGUAGE_SPECIES)

	SEND_SIGNAL(human, COMSIG_SPECIES_LOSS, src)

	human.living_flags &= ~STOP_OVERLAY_UPDATE_BODY_PARTS


/**
 * Handles the body of a human
 *
 * Handles lipstick, having no eyes, eye color, undergarnments like underwear, undershirts, and socks, and body layers.
 * Calls [handle_mutant_bodyparts][/datum/species/proc/handle_mutant_bodyparts]
 * Arguments:
 * * species_human - Human, whoever we're handling the body for
 */
/datum/species/proc/handle_body(mob/living/carbon/human/species_human)
	species_human.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	if(!HAS_TRAIT(species_human, TRAIT_HUSK))
		var/obj/item/bodypart/head/noggin = species_human.get_bodypart(BODY_ZONE_HEAD)
		if(noggin?.head_flags & HEAD_EYESPRITES)
			// eyes (missing eye sprites get handled by the head itself, but sadly we have to do this stupid shit here, for now)
			var/obj/item/organ/eyes/eye_organ = species_human.get_organ_slot(ORGAN_SLOT_EYES)
			if(eye_organ)
				eye_organ.refresh(call_update = FALSE)
				for(var/mutable_appearance/eye_overlay in eye_organ.generate_body_overlay(species_human))
					//eye_overlay.pixel_y += height_offset
					standing += eye_overlay

	//Underwear, Undershirts & Socks
	if(!HAS_TRAIT(species_human, TRAIT_NO_UNDERWEAR))
		if(species_human.underwear)
			var/datum/sprite_accessory/underwear/underwear = SSaccessories.underwear_list[species_human.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				if(species_human.dna.species.sexes && species_human.physique == FEMALE && underwear.gender_specific)
					underwear_overlay = mutable_appearance(wear_female_version(underwear.icon_state, underwear.icon, FEMALE_UNIFORM_FULL), layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				else
					underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				if(!underwear.use_static)
					underwear_overlay.color = species_human.underwear_color
				standing += underwear_overlay

		if(species_human.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = SSaccessories.undershirt_list[species_human.undershirt]
			if(undershirt)
				var/mutable_appearance/working_shirt
				if(species_human.dna.species.sexes && species_human.physique == FEMALE)
					working_shirt = mutable_appearance(wear_female_version(undershirt.icon_state, undershirt.icon), layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				else
					working_shirt = mutable_appearance(undershirt.icon, undershirt.icon_state, layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += working_shirt

		if(species_human.socks && species_human.num_legs >= 2 && !(species_human.bodyshape & BODYSHAPE_DIGITIGRADE) && !(TRAIT_NOSOCKS in inherent_traits))
			var/datum/sprite_accessory/socks/socks = SSaccessories.socks_list[species_human.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))

	if(standing.len)
		species_human.overlays_standing[BODY_LAYER] = standing

	species_human.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(species_human)

/**
 * Handles the mutant bodyparts of a human
 *
 * Handles the adding and displaying of, layers, colors, and overlays of mutant bodyparts and accessories.
 * Handles digitigrade leg displaying and squishing.
 * Arguments:
 * * H - Human, whoever we're handling the body for
 * * forced_colour - The forced color of an accessory. Leave null to use mutant color.
 */
/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/source, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing = list()

	source.remove_overlay(BODY_BEHIND_LAYER)
	source.remove_overlay(BODY_ADJ_LAYER)
	source.remove_overlay(BODY_FRONT_LAYER)

	REMOVE_LUM_SOURCE(source, LUM_SOURCE_MUTANT_BODYPART)
	// Remove any existing IPC screen emissive overlays
	REMOVE_LUM_SOURCE(source, LUM_SOURCE_IPC_SCREEN)

	if(!mutant_bodyparts)
		return

	var/obj/item/bodypart/head/noggin = source.get_bodypart(BODY_ZONE_HEAD)

	if(mutant_bodyparts["ipc_screen"])
		if(!source.dna.features["ipc_screen"] || source.dna.features["ipc_screen"] == "None" || (source.head && (source.head.flags_inv & HIDEEYES)) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEEYES)) || !noggin)
			bodyparts_to_add -= "ipc_screen"

	if(mutant_bodyparts["ipc_antenna"])
		if(!source.dna.features["ipc_antenna"] || source.dna.features["ipc_antenna"] == "None" || (source.head?.flags_inv & HIDEEARS) || !noggin)
			bodyparts_to_add -= "ipc_antenna"

	if(mutant_bodyparts["apid_antenna"])
		if(!source.dna.features["apid_antenna"] || source.dna.features["apid_antenna"] == "None" || source.head && (source.head.flags_inv & HIDEHAIR) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEHAIR)) || !noggin)
			bodyparts_to_add -= "apid_antenna"

	if(mutant_bodyparts["apid_headstripe"])
		if(!source.dna.features["apid_headstripe"] || source.dna.features["apid_headstripe"] == "None" || (source.wear_mask && (source.wear_mask.flags_inv & HIDEEYES)) || !noggin)
			bodyparts_to_add -= "apid_headstripe"

	if(mutant_bodyparts["psyphoza_cap"])
		if(!source.dna.features["psyphoza_cap"] || source.dna.features["psyphoza_cap"] == "None" || !noggin)
			bodyparts_to_add -= "psyphoza_cap"

	if(mutant_bodyparts["diona_leaves"])
		if(!source.dna.features["diona_leaves"] || source.dna.features["diona_leaves"] == "None" || (source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT) && (!source.wear_suit.species_exception || !is_type_in_list(src, source.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_leaves"

	if(mutant_bodyparts["diona_thorns"])
		if(!source.dna.features["diona_thorns"] || source.dna.features["diona_thorns"] == "None" || (source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT) && (!source.wear_suit.species_exception || !is_type_in_list(src, source.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_thorns"

	if(mutant_bodyparts["diona_flowers"])
		if(!source.dna.features["diona_flowers"] || source.dna.features["diona_flowers"] == "None" || (source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT) && (!source.wear_suit.species_exception || !is_type_in_list(src, source.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_flowers"

	if(mutant_bodyparts["diona_moss"])
		if(!source.dna.features["diona_moss"] || source.dna.features["diona_moss"] == "None" || (source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT) && (!source.wear_suit.species_exception || !is_type_in_list(src, source.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_moss"

	if(mutant_bodyparts["diona_mushroom"])
		if(!source.dna.features["diona_mushroom"] || source.dna.features["diona_mushroom"] == "None" || !noggin)
			bodyparts_to_add -= "diona_mushroom"

	if(mutant_bodyparts["diona_antennae"])
		if(!source.dna.features["diona_antennae"] || source.dna.features["diona_antennae"] == "None" || !noggin)
			bodyparts_to_add -= "diona_antennae"

	if(mutant_bodyparts["diona_eyes"])
		if(!source.dna.features["diona_eyes"] || source.dna.features["diona_eyes"] == "None" || (source.wear_mask && (source.wear_mask.flags_inv & HIDEEYES)) || source.head && (source.head.flags_inv & HIDEHAIR) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEHAIR)) || !noggin)
			bodyparts_to_add -= "diona_eyes"

	if(mutant_bodyparts["diona_pbody"])
		if(!source.dna.features["diona_pbody"] || source.dna.features["diona_pbody"] == "None" || (source.wear_suit && (source.wear_suit.flags_inv & HIDEJUMPSUIT) && (!source.wear_suit.species_exception || !is_type_in_list(src, source.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_pbody"

	if(!bodyparts_to_add)
		return

	var/g = (source.physique == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/accessory
			switch(bodypart)
				if("ipc_screen")
					accessory = SSaccessories.ipc_screens_list[source.dna.features["ipc_screen"]]
				if("ipc_antenna")
					accessory = SSaccessories.ipc_antennas_list[source.dna.features["ipc_antenna"]]
				if("ipc_chassis")
					accessory = SSaccessories.ipc_chassis_list[source.dna.features["ipc_chassis"]]
				if("insect_type")
					accessory = SSaccessories.insect_type_list[source.dna.features["insect_type"]]
				if("apid_antenna")
					accessory = SSaccessories.apid_antenna_list[source.dna.features["apid_antenna"]]
				if("apid_stripes")
					accessory = SSaccessories.apid_stripes_list[source.dna.features["apid_stripes"]]
				if("apid_headstripes")
					accessory = SSaccessories.apid_headstripes_list[source.dna.features["apid_headstripes"]]
				if("psyphoza_cap")
					accessory = SSaccessories.psyphoza_cap_list[source.dna.features["psyphoza_cap"]]
				if("diona_leaves")
					accessory = SSaccessories.diona_leaves_list[source.dna.features["diona_leaves"]]
				if("diona_thorns")
					accessory = SSaccessories.diona_thorns_list[source.dna.features["diona_thorns"]]
				if("diona_flowers")
					accessory = SSaccessories.diona_flowers_list[source.dna.features["diona_flowers"]]
				if("diona_moss")
					accessory = SSaccessories.diona_moss_list[source.dna.features["diona_moss"]]
				if("diona_mushroom")
					accessory = SSaccessories.diona_mushroom_list[source.dna.features["diona_mushroom"]]
				if("diona_antennae")
					accessory = SSaccessories.diona_antennae_list[source.dna.features["diona_antennae"]]
				if("diona_eyes")
					accessory = SSaccessories.diona_eyes_list[source.dna.features["diona_eyes"]]
				if("diona_pbody")
					accessory = SSaccessories.diona_pbody_list[source.dna.features["diona_pbody"]]


			if(!accessory || accessory.icon_state == "none")
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(accessory.icon, layer = CALCULATE_MOB_OVERLAY_LAYER(layer))

			// Add on emissives, if they have one
			if (accessory.emissive_state)
				accessory_overlay.overlays.Add(emissive_appearance(accessory.icon, accessory.emissive_state, layer = layer, alpha = accessory.emissive_alpha, filters = source.filters))
				ADD_LUM_SOURCE(source, LUM_SOURCE_MUTANT_BODYPART)

			if(accessory.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[accessory.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[accessory.icon_state]_[layertext]"

			if(accessory.center)
				accessory_overlay = center_image(accessory_overlay, accessory.dimension_x, accessory.dimension_y)

			if(!(HAS_TRAIT(source, TRAIT_HUSK)))
				if(!forced_colour)
					switch(accessory.color_src)
						if(MUTANT_COLOR)
							accessory_overlay.color = fixed_mut_color || source.dna.features["mcolor"]
						if(HAIR_COLOR)
							accessory_overlay.color = get_fixed_hair_color(source) || source.hair_color
						if(FACIAL_HAIR_COLOR)
							accessory_overlay.color = get_fixed_hair_color(source) || source.facial_hair_color
						if(EYE_COLOR)
							accessory_overlay.color = source.eye_color
				else
					accessory_overlay.color = forced_colour
			standing += accessory_overlay

		source.overlays_standing[layer] = standing.Copy()
		standing = list()

	source.apply_overlay(BODY_BEHIND_LAYER)
	source.apply_overlay(BODY_ADJ_LAYER)
	source.apply_overlay(BODY_FRONT_LAYER)

	if(mutant_bodyparts["ipc_screen"] && noggin)
		if(!source.dna.features["ipc_screen"] || source.dna.features["ipc_screen"] == "None")
			// Sanity check
		else if((source.head && (source.head.flags_inv & HIDEEYES)) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEEYES)))
			// Blocked, skip
		else
			// Snowflake, im sorry. We should eventually make this its own mutant organ
			var/datum/sprite_accessory/screen_accessory = SSaccessories.ipc_screens_list[source.dna.features["ipc_screen"]]
			if(screen_accessory?.emissive_state)
				var/emissive_layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_ADJ_LAYER)
				var/mutable_appearance/ipc_screen_emissive = emissive_appearance(screen_accessory.icon, screen_accessory.emissive_state, layer = emissive_layer, alpha = screen_accessory.emissive_alpha, filters = source.filters)
				source.add_overlay(ipc_screen_emissive)
				ADD_LUM_SOURCE(source, LUM_SOURCE_IPC_SCREEN)

//This exists so sprite accessories can still be per-layer without having to include that layer's
//number in their sprite name, which causes issues when those numbers change.
/datum/species/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"

///Proc that will randomise the hair, or primary appearance element (i.e. for moths wings) of a species' associated mob
/datum/species/proc/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	human_mob.set_hairstyle(random_hairstyle(human_mob.gender), update = FALSE)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob,
/// but will not update the body right away.
/datum/species/proc/randomize_active_underwear_only(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob
/datum/species/proc/randomize_active_underwear(mob/living/carbon/human/human_mob)
	randomize_active_underwear_only(human_mob)
	human_mob.update_body()

/datum/species/proc/randomize_active_features(mob/living/carbon/human/human_mob)
	var/list/new_features = randomize_features()
	for(var/feature_key in new_features)
		human_mob.dna.features[feature_key] = new_features[feature_key]
	human_mob.updateappearance(mutcolor_update = TRUE)

/**
 * Returns a list of features, randomized, to be used by DNA
 */
/datum/species/proc/randomize_features()
	SHOULD_CALL_PARENT(TRUE)

	var/list/new_features = list()
	var/static/list/organs_to_randomize = list()
	for(var/obj/item/organ/organ_path as anything in mutant_organs)
		if(!organ_path.bodypart_overlay)
			continue
		var/overlay_path = initial(organ_path.bodypart_overlay)
		var/datum/bodypart_overlay/mutant/sample_overlay = organs_to_randomize[overlay_path]
		if(isnull(sample_overlay))
			sample_overlay = new overlay_path()
			organs_to_randomize[overlay_path] = sample_overlay

		new_features["[sample_overlay.feature_key]"] = pick(sample_overlay.get_global_feature_list())

	return new_features

/datum/species/proc/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	if(H.stat == DEAD)
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH) && (H.health < H.crit_threshold) && !HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		H.adjustBruteLoss(0.5 * delta_time)

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/H)
	return

/datum/species/proc/spec_gib(no_brain, no_organs, no_bodyparts, mob/living/carbon/human/H)
	var/prev_lying = H.lying_prev
	if(H.stat != DEAD)
		H.death(TRUE)

	if(!prev_lying)
		H.gib_animation()

	H.spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		H.spread_bodyparts(no_brain, no_organs)

	H.spawn_gibs(no_bodyparts)
	qdel(H) //src doesn't work, we aren't in the mob anymore, this just deletes the species!!
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	if(no_equip_flags & slot)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	// if there's an item in the slot we want, fail
	if(!ignore_equipped)
		if(H.get_item_by_slot(slot))
			return FALSE

	// this check prevents us from equipping something to a slot it doesn't support, WITH the exceptions of storage slots (pockets, suit storage, and backpacks)
	// we don't require having those slots defined in the item's slot_flags, so we'll rely on their own checks further down
	if(!(I.slot_flags & slot))
		var/excused = FALSE
		// Anything that's small or smaller can fit into a pocket by default
		if((slot & (ITEM_SLOT_RPOCKET|ITEM_SLOT_LPOCKET)) && I.w_class <= WEIGHT_CLASS_SMALL)
			excused = TRUE
		else if(slot & (ITEM_SLOT_SUITSTORE|ITEM_SLOT_BACKPACK|ITEM_SLOT_HANDS))
			excused = TRUE
		if(!excused)
			return FALSE

	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_NECK)
			return TRUE
		if(ITEM_SLOT_BACK)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_OCLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_GLOVES)
			if(H.num_hands < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(H.num_legs < 2)
				return FALSE
			if((H.bodyshape & BODYSHAPE_DIGITIGRADE) && !(I.item_flags & IGNORE_DIGITIGRADE))
				if(!(I.supports_variations_flags & DIGITIGRADE_VARIATIONS))
					if(!disable_warning)
						to_chat(H, span_warning("The footwear around here isn't compatible with your feet!"))
					return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
			if(eyes?.no_glasses)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_HEAD)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EARS)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ICLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ID)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(!isnull(H.l_store) && H.l_store != I) // no pocket swaps at all
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!isnull(H.r_store) && H.r_store != I)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_SUITSTORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, span_warning("You need a suit before you can attach this [I.name]!"))
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, span_warning("You somehow have a suit with no defined allowed items for suit storage, stop that."))
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, span_warning("The [I.name] is too big to attach!")) //should be src?
				return FALSE
			if(istype(I, /obj/item/modular_computer/tablet) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed))
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(H.num_hands < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEGCUFFED)
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(H.num_legs < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACKPACK)
			if(H.back && H.back.atom_storage?.can_insert(I, H, messages = TRUE))
				return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message(span_notice("[H] start putting on [I]..."), span_notice("You start putting on [I]..."))
	return do_after(H, I.equip_delay_self, target = H)

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null)
	H.update_mutant_bodyparts()

/**
 * Handling special reagent types.
 *
 * Return False to run the normal on_mob_life() for that reagent.
 * Return True to not run the normal metabolism effects.
 * NOTE: If you return TRUE, that reagent will not be removed liike normal! You must handle it manually.
 */
/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	if(chem.type == exotic_blood)
		H.blood_volume = min(H.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
		H.reagents.del_reagent(chem.type)
		return TRUE
	//This handles dumping unprocessable reagents.
	var/dump_reagent = TRUE
	if((chem.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_SYNTHETIC))		//SYNTHETIC-oriented reagents require PROCESS_SYNTHETIC
		dump_reagent = FALSE
	if((chem.process_flags & ORGANIC) && (H.dna.species.reagent_tag & PROCESS_ORGANIC))		//ORGANIC-oriented reagents require PROCESS_ORGANIC
		dump_reagent = FALSE
	if(dump_reagent)
		chem.holder.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return FALSE

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	var/datum/outfit/outfit = new outfit_important_for_life()
	outfit.equip(human_to_equip)
	qdel(outfit)

////////
//LIFE//
////////

/datum/species/proc/handle_digestion(mob/living/carbon/human/H, delta_time, times_fired)
	if(HAS_TRAIT(H, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(H, TRAIT_FAT, OBESITY))//I share your pain, past coder.
		if(H.overeatduration < (200 SECONDS))
			to_chat(H, "<span class='notice'>You feel fit again!</span>")
			REMOVE_TRAIT(H, TRAIT_FAT, OBESITY)
			REMOVE_TRAIT(H, TRAIT_OFF_BALANCE_TACKLER, OBESITY)
			H.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_worn_undersuit()
			H.update_worn_oversuit()
	else
		if(H.overeatduration >= (200 SECONDS))
			to_chat(H, "<span class='danger'>You suddenly feel blubbery!</span>")
			ADD_TRAIT(H, TRAIT_FAT, OBESITY)
			ADD_TRAIT(H, TRAIT_OFF_BALANCE_TACKLER, OBESITY)
			H.add_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_worn_undersuit()
			H.update_worn_oversuit()

	// nutrition decrease and satiety
	if (H.nutrition > 0 && H.stat != DEAD && !HAS_TRAIT(H, TRAIT_NOHUNGER))
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(1 - 0.002 * mood.sanity, 0.5) //0.85 to 0.75
		// Whether we cap off our satiety or move it towards 0
		if(H.satiety > MAX_SATIETY)
			H.satiety = MAX_SATIETY
		else if(H.satiety > 0)
			H.satiety--
		else if(H.satiety < -MAX_SATIETY)
			H.satiety = -MAX_SATIETY
		else if(H.satiety < 0)
			H.satiety++
			if(DT_PROB(round(-H.satiety/77), delta_time))
				H.set_jitter_if_lower(10 SECONDS)
			hunger_rate = 3 * HUNGER_FACTOR
		hunger_rate *= H.physiology.hunger_mod
		H.adjust_nutrition(-hunger_rate * delta_time)

	if(H.nutrition > NUTRITION_LEVEL_FULL)
		if(H.overeatduration < 20 MINUTES) //capped so people don't take forever to unfat
			H.overeatduration = min(H.overeatduration + (1 SECONDS * delta_time), 20 MINUTES)
	else
		if(H.overeatduration > 0)
			H.overeatduration = max(H.overeatduration - (2 SECONDS * delta_time), 0) //doubled the unfat rate

	//metabolism change
	if(H.nutrition > NUTRITION_LEVEL_FAT)
		H.metabolism_efficiency = 1
	else if(H.nutrition > NUTRITION_LEVEL_FED && H.satiety > 80)
		if(H.metabolism_efficiency != 1.25 && !HAS_TRAIT(H, TRAIT_NOHUNGER))
			to_chat(H, span_notice("You feel vigorous."))
			H.metabolism_efficiency = 1.25
	else if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if(H.metabolism_efficiency != 0.8)
			to_chat(H, span_notice("You feel sluggish."))
		H.metabolism_efficiency = 0.8
	else
		if(H.metabolism_efficiency == 1.25)
			to_chat(H, span_notice("You no longer feel vigorous."))
		H.metabolism_efficiency = 1

	if(HAS_TRAIT(H, TRAIT_POWERHUNGRY))
		handle_charge(H)
	else
		switch(H.nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				H.throw_alert("nutrition", /atom/movable/screen/alert/fat)
				H.remove_movespeed_modifier(MOVESPEED_ID_VISIBLE_HUNGER)
				H.remove_actionspeed_modifier(ACTIONSPEED_ID_SATIETY)
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_FULL)
				H.clear_alert("nutrition")
				H.remove_movespeed_modifier(MOVESPEED_ID_VISIBLE_HUNGER)
				H.add_actionspeed_modifier(/datum/actionspeed_modifier/well_fed)
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				H.clear_alert("nutrition")
				H.remove_movespeed_modifier(MOVESPEED_ID_VISIBLE_HUNGER)
				H.remove_actionspeed_modifier(ACTIONSPEED_ID_SATIETY)
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				H.throw_alert("nutrition", /atom/movable/screen/alert/hungry)
				H.add_movespeed_modifier(/datum/movespeed_modifier/visible_hunger/hungry)
				H.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)
			if(0 to NUTRITION_LEVEL_STARVING)
				H.throw_alert("nutrition", /atom/movable/screen/alert/starving)
				H.add_movespeed_modifier(/datum/movespeed_modifier/visible_hunger/starving)
				H.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)

/datum/species/proc/handle_charge(mob/living/carbon/human/H)
	switch(H.nutrition)
		if(NUTRITION_LEVEL_FED to INFINITY)
			H.clear_alert("nutrition")
			H.remove_movespeed_modifier(MOVESPEED_ID_VISIBLE_HUNGER)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/well_fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			H.throw_alert("nutrition", /atom/movable/screen/alert/lowcell, 1)
			H.remove_movespeed_modifier(MOVESPEED_ID_VISIBLE_HUNGER)
			H.remove_actionspeed_modifier(ACTIONSPEED_ID_SATIETY)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.throw_alert("nutrition", /atom/movable/screen/alert/lowcell, 2)
			H.add_movespeed_modifier(/datum/movespeed_modifier/visible_hunger/hungry)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)
		if(1 to NUTRITION_LEVEL_STARVING)
			H.throw_alert("nutrition", /atom/movable/screen/alert/lowcell, 3)
			H.add_movespeed_modifier(/datum/movespeed_modifier/visible_hunger/starving)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)
		else
			H.add_movespeed_modifier(/datum/movespeed_modifier/visible_hunger/starving)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)
			var/obj/item/organ/stomach/battery/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
			if(!istype(battery))
				H.throw_alert("nutrition", /atom/movable/screen/alert/nocell)
			else
				H.throw_alert("nutrition", /atom/movable/screen/alert/emptycell)

/**
 * Species based handling for irradiation
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The mob requesting handling
 * - intensity: The intensity of the irradiation
 * - delta_time: The amount of time that has passed since the last tick
 */
/datum/species/proc/handle_radiation(mob/living/carbon/human/source, intensity, delta_time)
	if(intensity > RAD_MOB_KNOCKDOWN && DT_PROB(RAD_MOB_KNOCKDOWN_PROB, delta_time))
		if(!source.IsParalyzed())
			source.emote("collapse")
		source.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(source, span_danger("You feel weak."))

	if(intensity > RAD_MOB_VOMIT && DT_PROB(RAD_MOB_VOMIT_PROB, delta_time))
		source.vomit(10, TRUE)

	if(intensity > RAD_MOB_HAIRLOSS && DT_PROB(RAD_MOB_HAIRLOSS_PROB, delta_time))
		var/obj/item/bodypart/head/head = source.get_bodypart(BODY_ZONE_HEAD)
		if(!(source.hairstyle == "Bald") && (head?.head_flags & HEAD_HAIR|HEAD_FACIAL_HAIR) && !HAS_TRAIT(source, TRAIT_NOHAIRLOSS))
			to_chat(source, span_danger("Your hair starts to fall out in clumps..."))
			addtimer(CALLBACK(src, PROC_REF(go_bald), source), 5 SECONDS)

/datum/species/proc/handle_blood(mob/living/carbon/human/H)
	return FALSE

/**
 * Makes the target human bald.
 *
 * Arguments:
 * - [target][/mob/living/carbon/human]: The mob to make go bald.
 */
/datum/species/proc/go_bald(mob/living/carbon/human/target)
	if(QDELETED(target)) //may be called from a timer
		return
	target.set_facial_hairstyle("Shaved", update = FALSE)
	target.set_hairstyle("Bald") //This calls update_body_parts()

////////////////
// MOVE SPEED //
////////////////


/// MOVESPEED HEALTH DEFICIENCY DELAY FACTORS ///
//  YOU PROBABLY SHOULDN'T TOUCH THESE UNLESS YOU GRAPH EM OUT
#define HEALTH_DEF_MOVESPEED_DAMAGE_MIN 30
#define HEALTH_DEF_MOVESPEED_DELAY_MAX 15
#define HEALTH_DEF_MOVESPEED_DIV 350
#define HEALTH_DEF_MOVESPEED_FLIGHT_DIV 1050
#define HEALTH_DEF_MOVESPEED_POW 1.6

#undef HEALTH_DEF_MOVESPEED_DAMAGE_MIN
#undef HEALTH_DEF_MOVESPEED_DELAY_MAX
#undef HEALTH_DEF_MOVESPEED_DIV
#undef HEALTH_DEF_MOVESPEED_FLIGHT_DIV
#undef HEALTH_DEF_MOVESPEED_POW

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_updatehealth(mob/living/carbon/human/H)
	return

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style?.help_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE

	if(target.body_position == STANDING_UP || (target.health >= 0 && !HAS_TRAIT(target, TRAIT_FAKEDEATH)))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return TRUE
	else
		user.do_cpr(target)

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s grab!"), \
						span_userdanger("You block [user]'s grab!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your grab at [target] was blocked!"))
		return FALSE
	if(attacker_style?.grab_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	target.grabbedby(user)
	return TRUE

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && !attacker_style?.pacifist_style)
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s attack!"), \
						span_userdanger("You block [user]'s attack!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your attack at [target] was blocked!"))
		return FALSE
	if(attacker_style?.harm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	else

		var/obj/item/organ/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
		var/obj/item/bodypart/attacking_bodypart
		if(brain)
			attacking_bodypart = brain.get_attacking_limb(target)
		if(!attacking_bodypart)
			attacking_bodypart = user.get_active_hand()
		var/atk_verb = attacking_bodypart.unarmed_attack_verb
		var/atk_effect = attacking_bodypart.unarmed_attack_effect

		if(atk_effect == ATTACK_EFFECT_BITE)
			if(user.is_mouth_covered(mask_only = TRUE))
				to_chat(user, span_warning("You can't [atk_verb] with your mouth covered!"))
				return FALSE
		user.do_attack_animation(target, atk_effect)

		var/damage = attacking_bodypart.unarmed_damage

		var/obj/item/bodypart/affecting = target.get_bodypart(target.get_random_valid_zone(target.get_combat_bodyzone(src)))

		if(!damage || !affecting)//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, attacking_bodypart.unarmed_miss_sound, 25, TRUE, -1)
			target.visible_message(span_danger("[user]'s [atk_verb] misses [target]!"), \
							span_danger("You avoid [user]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] misses [target]!"))
			log_combat(user, target, "attempted to punch")
			return FALSE

		var/armor_block = target.run_armor_check(affecting, MELEE)

		playsound(target.loc, attacking_bodypart.unarmed_attack_sound, 25, TRUE, -1)

		target.visible_message(span_danger("[user] [atk_verb]ed [target]!"), \
						span_userdanger("You're [atk_verb]ed by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [atk_verb] [target]!"))

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		user.dna.species.spec_unarmedattack(user, target)

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		var/attack_direction = get_dir(user, target)
		var/attack_type = attacking_bodypart.attack_type
		if(atk_effect == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage
			if((damage) >= 9)
				target.force_say()
			log_combat(user, target, "kicked", "punch")
			target.apply_damage(damage, attack_type, affecting, armor_block, attack_direction = attack_direction)
		else//other attacks deal full raw damage + 1.5x in stamina damage
			target.apply_damage(damage, attack_type, affecting, armor_block, attack_direction = attack_direction)
			target.apply_damage(damage*1.5, STAMINA, affecting, armor_block)
			if(damage >= 9)
				target.force_say()
			log_combat(user, target, "punched", "punch")

/datum/species/proc/spec_unarmedattack(mob/living/carbon/human/user, atom/target, modifiers)
	return FALSE

/datum/species/proc/disarm(mob/living/carbon/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[user]'s shove is blocked by [target]!"), \
						span_danger("You block [user]'s shove!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your shove at [target] was blocked!"))
		return FALSE
	if(attacker_style?.disarm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	if(user.resting || user.IsKnockdown())
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	else
		user.disarm(target)

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	return

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/attacker, mob/living/carbon/human/target, datum/martial_art/attacker_style, modifiers)
	if(!istype(attacker))
		return
	CHECK_DNA_AND_SPECIES(attacker)
	CHECK_DNA_AND_SPECIES(target)

	if(!istype(attacker)) //sanity check for drones.
		return
	if(attacker.mind)
		attacker_style = attacker.mind.martial_art
	if((attacker != target) && !attacker_style?.bypass_blocking && attacker.combat_mode && target.check_shields(attacker, 0, attacker.name, attack_type = UNARMED_ATTACK))
		log_combat(attacker, target, "attempted to touch")
		target.visible_message(span_warning("[attacker] attempts to touch [target]!"), \
						span_danger("[attacker] attempts to touch you!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_warning("You attempt to touch [target]!"))
		return

	SEND_SIGNAL(attacker, COMSIG_MOB_ATTACK_HAND, attacker, target, attacker_style)
	SEND_SIGNAL(target, COMSIG_MOB_HAND_ATTACKED, target, attacker, attacker_style)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		disarm(attacker, target, attacker_style)
		return // dont attack after
	if(attacker.combat_mode)
		harm(attacker, target, attacker_style)
	else
		help(attacker, target, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/weapon, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/human)
	// Allows you to put in item-specific reactions based on species
	if(user != human)
		if(human.check_shields(weapon, weapon.force, "the [weapon.name]", MELEE_ATTACK, weapon.armour_penetration))
			return FALSE
	if(human.check_block())
		human.visible_message(span_warning("[human] blocks [weapon]!"), \
						span_userdanger("You block [weapon]!"))
		return FALSE

	affecting ||= human.bodyparts[1] //Something went wrong. Maybe the limb is missing?
	var/hit_area = affecting.plaintext_zone

	var/armor_block = human.run_armor_check(
		def_zone = affecting,
		attack_flag = MELEE,
		absorb_text = span_notice("Your armor has protected your [hit_area]!"),
		soften_text = span_warning("Your armor has softened a hit to your [hit_area]!"),
		armour_penetration = weapon.armour_penetration,
	)
	var/limb_damage = affecting.get_damage() //We need to save this for later to simplify dismemberment

	if (weapon.bleed_force)
		var/armour_block = user.run_armor_check(affecting, BLEED, armour_penetration = weapon.armour_penetration, silent = (weapon.force > 0))
		var/hit_amount = (100 - armour_block) / 100
		human.add_bleeding(weapon.bleed_force * hit_amount)
		if(IS_ORGANIC_LIMB(affecting))
			weapon.add_mob_blood(human)	//Make the weapon bloody, not the person.
			if(get_dist(user, human) <= 1)	//people with TK won't get smeared with blood
				user.add_mob_blood(human)
			switch(hit_area)
				if(BODY_ZONE_HEAD)
					if(human.wear_mask)
						human.wear_mask.add_mob_blood(human)
						human.update_worn_mask()
					if(human.head)
						human.head.add_mob_blood(human)
						human.update_worn_head()
					if(human.glasses && prob(33))
						human.glasses.add_mob_blood(human)
						human.update_worn_glasses()

				if(BODY_ZONE_CHEST)
					if(human.wear_suit)
						human.wear_suit.add_mob_blood(human)
						human.update_worn_oversuit()
					if(human.w_uniform)
						human.w_uniform.add_mob_blood(human)
						human.update_worn_undersuit()

	human.send_item_attack_message(weapon, user, hit_area, affecting)
	var/damage_dealt = human.apply_damage(
		damage = weapon.force,
		damagetype = weapon.damtype,
		def_zone = affecting,
		blocked = armor_block,
		sharpness = weapon.get_sharpness(),
		attack_direction = get_dir(user, human),
	)

	if(damage_dealt <= 0)
		return FALSE //item force is zero

	var/dismember_limb = FALSE
	var/weapon_sharpness = weapon.get_sharpness()
	var/mob_dismember_weakness = HAS_TRAIT(human, TRAIT_EASYDISMEMBER)

	if(((mob_dismember_weakness && limb_damage) || (weapon_sharpness == SHARP_DISMEMBER_EASY)) && prob(weapon.force))
		dismember_limb = TRUE
		//Easy dismemberment on the mob allows even blunt weapons to potentially delimb, but only if the limb is already damaged
		//Certain weapons are so sharp/strong they have a chance to cleave right through a limb without following the normal restrictions

	else if(weapon_sharpness > SHARP || mob_dismember_weakness || (weapon_sharpness == SHARP && human.stat == DEAD))
		//Delimbing cannot normally occur with blunt weapons
		//You also aren't cutting someone's arm off with a scalpel unless they're already dead

		if(limb_damage >= affecting.max_damage)
			dismember_limb = TRUE
			//You can only cut a limb off if it is already damaged enough to be fully disabled

	if(dismember_limb && affecting.dismember(weapon.damtype))
		weapon.add_mob_blood(human)
		playsound(get_turf(human), weapon.get_dismember_sound(), 80, 1)

	if(weapon.damtype == BRUTE && (weapon.force >= max(10, armor_block) && hit_area == BODY_ZONE_HEAD))
		if(!weapon.get_sharpness() && human.mind && human.stat == CONSCIOUS && human != user && (human.health - (weapon.force * weapon.attack_weight)) <= 0) // rev deconversion through blunt trauma.
			var/datum/antagonist/rev/rev = IS_REVOLUTIONARY(human)
			if(rev)
				rev.remove_revolutionary(FALSE, user)
		if(weapon.force > 10 || weapon.force >= 5 && prob(33))
			human.force_say(user)
	else if (weapon.damtype == BURN && human.is_bleeding())
		human.cauterise_wounds(AMOUNT_TO_BLEED_INTENSITY(weapon.force / 3))
		to_chat(human, span_userdanger("The heat from [weapon] cauterizes your bleeding!"))
		playsound(human, 'sound/surgery/cautery2.ogg', 70)
	return TRUE

/datum/species/proc/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(P.type)
		if(/obj/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))
		if(/obj/projectile/energy/florayield)
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))

/datum/species/proc/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	// called before a projectile hit
	return 0

//////////////////////////
// ENVIRONMENT HANDLERS //
//////////////////////////

/**
 * Environment handler for species
 *
 * vars:
 * * environment (required) The environment gas mix
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_environment(mob/living/carbon/human/humi, datum/gas_mixture/environment, delta_time, times_fired)
	handle_environment_pressure(humi, environment, delta_time, times_fired)

/**
 * Body temperature handler for species
 *
 * These procs manage body temp, bamage, and alerts
 * Some of these will still fire when not alive to balance body temp to the room temp.
 * vars:
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_body_temperature(mob/living/carbon/human/humi, delta_time, times_fired)
	//when in a cryo unit we suspend all natural body regulation
	if(istype(humi.loc, /obj/machinery/cryo_cell))
		return

	//Only stabilise core temp when alive and not in statis
	if(humi.stat < DEAD && !HAS_TRAIT(humi, TRAIT_STASIS))
		body_temperature_core(humi, delta_time, times_fired)

	//These do run in status
	body_temperature_skin(humi, delta_time, times_fired)
	body_temperature_alerts(humi, delta_time, times_fired)

	//Do not cause more damage in statis
	if(!HAS_TRAIT(humi, TRAIT_STASIS))
		body_temperature_damage(humi, delta_time, times_fired)

/**
 * Used to stabilize the core temperature back to normal on living mobs
 *
 * The metabolisim heats up the core of the mob trying to keep it at the normal body temp
 * vars:
 * * humi (required) The mob we will stabilize
 */
/datum/species/proc/body_temperature_core(mob/living/carbon/human/humi, delta_time, times_fired)
	var/natural_change = get_temp_change_amount(humi.get_body_temp_normal() - humi.coretemperature, 0.06 * delta_time)
	humi.adjust_coretemperature(humi.metabolism_efficiency * natural_change)

/**
 * Used to normalize the skin temperature on living mobs
 *
 * The core temp effects the skin, then the enviroment effects the skin, then we refect that back to the core.
 * This happens even when dead so bodies revert to room temp over time.
 * vars:
 * * humi (required) The mob we will targeting
 * - delta_time: The amount of time that is considered as elapsing
 * - times_fired: The number of times SSmobs has fired
 */
/datum/species/proc/body_temperature_skin(mob/living/carbon/human/humi, delta_time, times_fired)

	// change the core based on the skin temp
	var/skin_core_diff = humi.bodytemperature - humi.coretemperature
	// change rate of 0.04 per second to be slightly below area to skin change rate and still have a solid curve
	var/skin_core_change = get_temp_change_amount(skin_core_diff, 0.04 * delta_time)

	humi.adjust_coretemperature(skin_core_change)

	// get the enviroment details of where the mob is standing
	var/datum/gas_mixture/environment = humi.loc?.return_air()
	if(!environment) // if there is no environment (nullspace) drop out here.
		return

	// Get the temperature of the environment for area
	var/area_temp = humi.get_temperature(environment)

	// Get the insulation value based on the area's temp
	var/thermal_protection = humi.get_insulation_protection(area_temp)
	var/original_bodytemp = humi.bodytemperature

	// Changes to the skin temperature based on the area
	var/area_skin_diff = area_temp - original_bodytemp
	if(!humi.on_fire || area_skin_diff > 0)
		// change rate of 0.05 as area temp has large impact on the surface
		var/area_skin_change = get_temp_change_amount(area_skin_diff, 0.05 * delta_time)

		// We need to apply the thermal protection of the clothing when applying area to surface change
		// If the core bodytemp goes over the normal body temp you are overheating and becom sweaty
		// This will cause the insulation value of any clothing to reduced in effect (70% normal rating)
		// we add 10 degree over normal body temp before triggering as thick insulation raises body temp
		if(humi.get_body_temp_normal(apply_change=FALSE) + 10 < humi.coretemperature)
			// we are overheating and sweaty insulation is not as good reducing thermal protection
			area_skin_change = (1 - (thermal_protection * 0.7)) * area_skin_change
		else
			area_skin_change = (1 - thermal_protection) * area_skin_change

		humi.adjust_bodytemperature(area_skin_change)

	// Core to skin temp transfer, when not on fire
	if(!humi.on_fire)
		// Get the changes to the skin from the core temp
		var/core_skin_diff = humi.coretemperature - original_bodytemp
		// change rate of 0.045 to reflect temp back to the skin at the slight higher rate then core to skin
		var/core_skin_change = (1 + thermal_protection) * get_temp_change_amount(core_skin_diff, 0.045 * delta_time)

		// We do not want to over shoot after using protection
		if(core_skin_diff > 0)
			core_skin_change = min(core_skin_change, core_skin_diff)
		else
			core_skin_change = max(core_skin_change, core_skin_diff)

		humi.adjust_bodytemperature(core_skin_change)


/**
 * Used to set alerts and debuffs based on body temperature
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_alerts(mob/living/carbon/human/humi)
	var/old_bodytemp = humi.old_bodytemperature
	var/bodytemp = humi.bodytemperature
	// Body temperature is too hot, and we do not have resist traits
	if(bodytemp > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		// Clear cold mood and apply hot mood
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(humi, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		//Remove any slowdown from the cold.
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		// display alerts based on how hot it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in bodytemp_heat_damage_limit to BODYTEMP_HEAT_WARNING_2)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
		else if(bodytemp in BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
		else
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)

	// Body temperature is too cold, and we do not have resist traits
	else if(bodytemp < bodytemp_cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		// clear any hot moods and apply cold mood
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(humi, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		// Apply cold slow down
		humi.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((bodytemp_cold_damage_limit - humi.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		// Display alerts based how cold it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in BODYTEMP_COLD_WARNING_2 to bodytemp_cold_damage_limit)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
		else if(bodytemp in BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
		else
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)

	// We are not to hot or cold, remove status and moods
	// Optimization here, we check these things based off the old temperature to avoid unneeded work
	// We're not perfect about this, because it'd just add more work to the base case, and resistances are rare
	else if (old_bodytemp > bodytemp_heat_damage_limit || old_bodytemp < bodytemp_cold_damage_limit)
		humi.clear_alert(ALERT_TEMPERATURE)
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "hot")

	// Store the old bodytemp for future checking
	humi.old_bodytemperature = bodytemp

/**
 * Used to apply wounds and damage based on core/body temp
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_damage(mob/living/carbon/human/humi, delta_time, times_fired)

	//If the body temp is above the wound limit start adding exposure stacks
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT)
		humi.heat_exposure_stacks = min(humi.heat_exposure_stacks + (0.5 * delta_time), 40)
	else //When below the wound limit, reduce the exposure stacks fast.
		humi.heat_exposure_stacks = max(humi.heat_exposure_stacks - (2 * delta_time), 0)

	//when exposure stacks are greater then 10 + rand20 try to apply wounds and reset stacks
	if(humi.heat_exposure_stacks > (10 + rand(0, 20)))
		apply_burn_wounds(humi, delta_time, times_fired)
		humi.heat_exposure_stacks = 0

	// Body temperature is too hot, and we do not have resist traits
	// Apply some burn damage to the body
	if(humi.coretemperature > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		var/firemodifier = humi.fire_stacks / 50
		if (!humi.on_fire) // We are not on fire, reduce the modifier
			firemodifier = min(firemodifier, 0)

		// this can go below 5 at log 2.5
		var/burn_damage = max(log(2 - firemodifier, (humi.coretemperature - humi.get_body_temp_normal(apply_change=FALSE))) - 5, 0)

		// Apply species and physiology modifiers to heat damage
		burn_damage = burn_damage * heatmod * humi.physiology.heat_mod * 0.5 * delta_time

		// 40% for level 3 damage on humans to scream in pain
		if (humi.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4)
			humi.emote("scream")

		// Apply the damage to all body parts
		humi.apply_damage(burn_damage, BURN, spread_damage = TRUE)

	// For cold damage, we cap at the threshold if you're dead
	if(humi.getFireLoss() >= abs(HEALTH_THRESHOLD_DEAD) && humi.stat == DEAD)
		return

	// Apply some burn / brute damage to the body (Dependent if the person is hulk or not)
	var/is_hulk = HAS_TRAIT(humi, TRAIT_HULK)

	var/cold_damage_limit = bodytemp_cold_damage_limit + (is_hulk ? BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER : 0)

	if(humi.coretemperature < cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		var/damage_type = is_hulk ? BRUTE : BURN // Why?
		var/damage_mod = coldmod * humi.physiology.cold_mod * (is_hulk ? HULK_COLD_DAMAGE_MOD : 1)
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(humi.coretemperature in 201 to cold_damage_limit)
			humi.apply_damage(COLD_DAMAGE_LEVEL_1 * damage_mod * delta_time, damage_type)
		else if(humi.coretemperature in 120 to 200)
			humi.apply_damage(COLD_DAMAGE_LEVEL_2 * damage_mod * delta_time, damage_type)
		else
			humi.apply_damage(COLD_DAMAGE_LEVEL_3 * damage_mod * delta_time, damage_type)

/**
 * Used to apply burn wounds on random limbs
 *
 * This is called from body_temperature_damage when exposure to extream heat adds up and causes a wound.
 * The wounds will increase in severity as the temperature increases.
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/apply_burn_wounds(mob/living/carbon/human/humi, delta_time, times_fired)
	// If we are resistant to heat exit
	if(HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		return

	// If our body temp is to low for a wound exit
	if(humi.bodytemperature < BODYTEMP_HEAT_WOUND_LIMIT)
		return

	// Lets pick a random body part and check for an existing burn
	var/obj/item/bodypart/bodypart = pick(humi.bodyparts)
	/* No wounds yet
	var/datum/wound/burn/existing_burn = locate(/datum/wound/burn) in bodypart.wounds

	// If we have an existing burn try to upgrade it
	if(existing_burn)
		switch(existing_burn.severity)
			if(WOUND_SEVERITY_MODERATE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400) // 800k
					bodypart.force_wound_upwards(/datum/wound/burn/severe)
			if(WOUND_SEVERITY_SEVERE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800) // 3200k
					bodypart.force_wound_upwards(/datum/wound/burn/critical)
	else // If we have no burn apply the lowest level burn
		bodypart.force_wound_upwards(/datum/wound/burn/moderate)
	*/

	// always take some burn damage
	var/burn_damage = HEAT_DAMAGE_LEVEL_1
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400)
		burn_damage = HEAT_DAMAGE_LEVEL_2
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800)
		burn_damage = HEAT_DAMAGE_LEVEL_3

	humi.apply_damage(burn_damage * delta_time, BURN, bodypart)

/// Handle the air pressure of the environment
/datum/species/proc/handle_environment_pressure(mob/living/carbon/human/H, datum/gas_mixture/environment, delta_time, times_fired)
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure)

	// Set alerts and apply damage based on the amount of pressure
	switch(adjusted_pressure)
		// Very high pressure, show an alert and take damage
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.clear_alert("pressure")
			else
				var/pressure_damage = min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod * H.physiology.brute_mod * delta_time
				H.adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				H.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)

		// High pressure, show an alert
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 1)

		// No pressure issues here clear pressure alerts
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert("pressure")

		// Low pressure here, show an alert
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert("pressure")
			else
				H.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 1)

		// Very low pressure, show an alert and take damage
		else
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert("pressure")
			else if(HAS_TRAIT(H, TRAIT_LOWPRESSURELEAKING))
				H.add_bleeding(BLEED_CUT, FALSE)
				H.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)
			else
				var/pressure_damage = LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod * H.physiology.brute_mod * delta_time
				H.adjustBruteLoss(pressure_damage, required_bodytype = BODYTYPE_ORGANIC)
				H.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, delta_time, times_fired, no_protection = FALSE)
	return no_protection


////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	if(H.movement_type & FLYING)
		var/obj/item/organ/wings/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(wings)
			wings.toggle_flight(H)
			wings.fly_slip(H)
	. = max(stunmod + H.physiology.stun_add, 0) * H.physiology.stun_mod * amount

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

/datum/species/proc/get_harm_descriptors()
	SHOULD_CALL_PARENT(FALSE)
	return list(
		BLEED = "bleeding",
		BRUTE = "bruising",
		BURN = "burns"
	)

/datum/species/proc/z_impact_damage(mob/living/carbon/human/H, turf/T, levels)
	// Check if legs are functional for catrobatics
	var/obj/item/bodypart/left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if((left_leg && !left_leg.bodypart_disabled) || (right_leg && !right_leg.bodypart_disabled))
		if(HAS_TRAIT(H, TRAIT_LIGHT_LANDING) && levels == 1)
			// Nailed it!
			H.visible_message(
				span_notice("[H] lands elegantly on [H.p_their()] feet!"),
				span_warning("You fall [levels] level\s onto [T], perfecting the landing!")
			)
			H.Stun(35)
			return

	// Apply general impact damage
	H.apply_general_zimpact_damage(T, levels)
	if(levels < 2)
		return

	// SPLAT! Chance to gib
	if(levels >= 3 && prob(min((levels ** 2) * 2, 50)))
		H.gib()
		return

	// Chance to dismember limbs
	if(prob(min((levels - 1) * 15, 75)))
		var/list/limbs = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		if(levels >= 3 && prob(25))
			for(var/selected_part in limbs)
				var/obj/item/bodypart/bp = H.get_bodypart(selected_part)
				if(bp)
					bp.dismember()
			return

		var/selected_part = pick(limbs)
		var/obj/item/bodypart/bp = H.get_bodypart(selected_part)
		if(bp)
			bp.dismember()

/datum/species/proc/get_laugh_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_scream_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_cough_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_cry_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_gasp_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_sigh_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_sneeze_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_sniff_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_giggle_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_clear_sound(mob/living/carbon/user)
	return

/datum/species/proc/get_huff_sound(mob/living/carbon/user)
	return

/// Returns a list of strings representing features this species has.
/// Used by the preferences UI to know what buttons to show.
/datum/species/proc/get_features()
	var/cached_features = GLOB.features_by_species[type]
	if (!isnull(cached_features))
		return cached_features

	var/list/features = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]

		if ( \
			(preference.relevant_mutant_bodypart in mutant_bodyparts) \
			|| (preference.relevant_inherent_trait in inherent_traits) \
			|| (preference.relevant_external_organ in get_mut_organs()) \
			|| (preference.relevant_head_flag && check_head_flags(preference.relevant_head_flag)) \
			|| (preference.relevant_body_markings in body_markings) \
		)
			features += preference.db_key

	for (var/obj/item/organ/organ_type as anything in mutant_organs)
		var/preference = initial(organ_type.preference)
		if (!isnull(preference))
			features += preference

	GLOB.features_by_species[type] = features

	return features

/// Given a human, will adjust it before taking a picture for the preferences UI.
/// This should create a CONSISTENT result, so the icons don't randomly change.
/datum/species/proc/prepare_human_for_preview(mob/living/carbon/human/human)
	return

/**
 * Owner login
 */

/**
 * A simple proc to be overwritten if something needs to be done when a mob logs in. Does nothing by default.
 *
 * Arguments:
 * * owner - The owner of our species.
 */
/datum/species/proc/on_owner_login(mob/living/carbon/human/owner)
	return

/**
 * Gets a short description for the specices. Should be relatively succinct.
 * Used in the preference menu.
 *
 * Returns a string.
 */

/datum/species/proc/get_species_description()
	SHOULD_CALL_PARENT(FALSE)

	stack_trace("Species [name] ([type]) did not have a description set, and is a selectable roundstart race! Override get_species_description.")
	return "No species description set, file a bug report!"

/**
 * Gets the lore behind the type of species. Can be long.
 * Used in the preference menu.
 *
 * Returns a list of strings.
 * Between each entry in the list, a newline will be inserted, for formatting.
 */
/datum/species/proc/get_species_lore()
	SHOULD_CALL_PARENT(FALSE)
	RETURN_TYPE(/list)

	stack_trace("Species [name] ([type]) did not have lore set, and is a selectable roundstart race! Override get_species_lore.")
	return list("No species lore set, file a bug report!")

/**
 * Translate the species liked foods from bitfields into strings
 * and returns it in the form of an associated list.
 *
 * Returns a list, or null if they have no diet.
 */
/datum/species/proc/get_species_diet()
	if((TRAIT_NOHUNGER in inherent_traits) || !mutanttongue)
		return null

	var/list/food_flags = FOOD_FLAGS
	var/obj/item/organ/tongue/fake_tongue = mutanttongue

	return list(
		"liked_food" = bitfield_to_list(initial(fake_tongue.liked_foodtypes), food_flags),
		"disliked_food" = bitfield_to_list(initial(fake_tongue.disliked_foodtypes), food_flags),
		"toxic_food" = bitfield_to_list(initial(fake_tongue.toxic_foodtypes), food_flags),
	)

/**
 * Generates a list of "perks" related to this species
 * (Postives, neutrals, and negatives)
 * in the format of a list of lists.
 * Used in the preference menu.
 *
 * "Perk" format is as followed:
 * list(
 *   SPECIES_PERK_TYPE = type of perk (postiive, negative, neutral - use the defines)
 *   SPECIES_PERK_ICON = icon shown within the UI
 *   SPECIES_PERK_NAME = name of the perk on hover
 *   SPECIES_PERK_DESC = description of the perk on hover
 * )
 *
 * Returns a list of lists.
 * The outer list is an assoc list of [perk type]s to a list of perks.
 * The innter list is a list of perks. Can be empty, but won't be null.
 */
/datum/species/proc/get_species_perks()
	var/list/species_perks = list()

	// Let us get every perk we can conceive of in one big list.
	// The order these are called (kind of) matters.
	// Species unique perks first, as they're more important than genetic perks,
	// and language perk last, as it comes at the end of the perks list
	species_perks += create_pref_unique_perks()
	species_perks += create_pref_blood_perks()
	species_perks += create_pref_damage_perks()
	species_perks += create_pref_temperature_perks()
	species_perks += create_pref_traits_perks()
	species_perks += create_pref_biotypes_perks()
	species_perks += create_pref_language_perk()

	// Some overrides may return `null`, prevent those from jamming up the list.
	list_clear_nulls(species_perks)

	// Now let's sort them out for cleanliness and sanity
	var/list/perks_to_return = list(
		SPECIES_POSITIVE_PERK = list(),
		SPECIES_NEUTRAL_PERK = list(),
		SPECIES_NEGATIVE_PERK =  list(),
	)

	for(var/list/perk as anything in species_perks)
		var/perk_type = perk[SPECIES_PERK_TYPE]
		// If we find a perk that isn't postiive, negative, or neutral,
		// it's a bad entry - don't add it to our list. Throw a stack trace and skip it instead.
		if(isnull(perks_to_return[perk_type]))
			stack_trace("Invalid species perk ([perk[SPECIES_PERK_NAME]]) found for species [name]. \
				The type should be positive, negative, or neutral. (Got: [perk_type])")
			continue

		perks_to_return[perk_type] += list(perk)

	return perks_to_return

/**
 * Used to add any species specific perks to the perk list.
 *
 * Returns null by default. When overriding, return a list of perks.
 */
/datum/species/proc/create_pref_unique_perks()
	return null

/**
 * Adds adds any perks related to sustaining damage.
 * For example, brute damage vulnerability, or fire damage resistance.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_damage_perks()
	// We use the chest to figure out brute and burn mod perks
	var/obj/item/bodypart/chest/fake_chest = bodypart_overrides[BODY_ZONE_CHEST]

	var/list/to_add = list()

	// Brute related
	if(initial(fake_chest.brute_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Brutal Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to brute damage.",
		))
	else if(initial(fake_chest.brute_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Brutal Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to brute damage.",
		))

	// Burn related
	if(initial(fake_chest.burn_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Burn Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to burn damage.",
		))
	else if(initial(fake_chest.burn_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Burn Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to burn damage.",
		))

	//Toxin related
	if(toxmod > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Toxin Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to toxins and toxin damage.",
		))

	else if(toxmod < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Toxin Resistance",
			SPECIES_PERK_DESC = "[plural_form] are resistant to toxins, and toxin damage.",
		))

	if(TRAIT_SHOCKIMMUNE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shock Immune",
			SPECIES_PERK_DESC = "[plural_form] are entirely resistant to electrical shocks.",
		))

	if(TRAIT_GENELESS in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "No Genes",
			SPECIES_PERK_DESC = "[plural_form] have no genes, making genetic scrambling a useless weapon, but also locking them out from getting genetic powers.",
		))

	else if(siemens_coeff > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shock Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to being shocked.",
		))
	else if(siemens_coeff < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Shock Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to being shocked.",
		))

	return to_add

/**
 * Adds adds any perks related to how the species deals with temperature.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_temperature_perks()
	var/list/to_add = list()

	// Hot temperature tolerance
	if(heatmod > 1/* || bodytemp_heat_damage_limit < BODYTEMP_HEAT_DAMAGE_LIMIT*/)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-high",
			SPECIES_PERK_NAME = "Heat Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to high temperatures.",
		))

	if(heatmod < 1/* || bodytemp_heat_damage_limit > BODYTEMP_HEAT_DAMAGE_LIMIT*/)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Heat Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to hotter environments.",
		))

	// Cold temperature tolerance
	if(coldmod > 1/* || bodytemp_cold_damage_limit > BODYTEMP_COLD_DAMAGE_LIMIT*/)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to cold temperatures.",
		))

	if(coldmod < 1/* || bodytemp_cold_damage_limit < BODYTEMP_COLD_DAMAGE_LIMIT*/)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Cold Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to colder environments.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' blood (or lack thereof).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_blood_perks()
	var/list/to_add = list()

	// TRAIT_NOBLOOD takes priority by default
	if(TRAIT_NOBLOOD in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Bloodletted",
			SPECIES_PERK_DESC = "[plural_form] do not have blood.",
		))

	// Otherwise, check if their exotic blood is a valid typepath
	else if(ispath(exotic_blood))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = initial(exotic_blood.name),
			SPECIES_PERK_DESC = "[name] blood is [initial(exotic_blood.name)], which can make receiving medical treatment harder.",
		))

	// Otherwise otherwise, see if they have an exotic bloodtype set
	else if(exotic_bloodtype)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Exotic Blood",
			SPECIES_PERK_DESC = "[plural_form] have \"[exotic_bloodtype]\" type blood, which can make receiving medical treatment harder.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_traits list.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_traits_perks()
	var/list/to_add = list()

	if(TRAIT_LIMBATTACHMENT in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-plus",
			SPECIES_PERK_NAME = "Limbs Easily Reattached",
			SPECIES_PERK_DESC = "[plural_form] limbs are easily reattached, and as such do not \
				require surgery to restore. Simply pick it up and pop it back in, champ!",
		))

	if(TRAIT_EASYDISMEMBER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Limbs Easily Dismembered",
			SPECIES_PERK_DESC = "[plural_form] limbs are not secured well, and as such they are easily dismembered.",
		))

	if(TRAIT_NODISMEMBER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-shield",
			SPECIES_PERK_NAME = "Well-Attached Limbs",
			SPECIES_PERK_DESC = "[plural_form] cannot be dismembered.",
		))

	if(TRAIT_TOXINLOVER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Toxins Lover",
			SPECIES_PERK_DESC = "Toxins damage dealt to [plural_form] are reversed - healing toxins will instead cause harm, and \
				causing toxins will instead cause healing. Be careful around purging chemicals!",
		))

	if(TRAIT_NOFIRE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fire-extinguisher",
			SPECIES_PERK_NAME = "Fireproof",
			SPECIES_PERK_DESC = "[plural_form] are entirely immune to catching fire.",
		))

	if(TRAIT_NOHUNGER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "utensils",
			SPECIES_PERK_NAME = "No Hunger",
			SPECIES_PERK_DESC = "[plural_form] are never hungry.",
		))

	if(TRAIT_RADIMMUNE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "radiation",
			SPECIES_PERK_NAME = "Radiation Immune",
			SPECIES_PERK_DESC = "[plural_form] are entirely immune to radiation.",
		))

	if(TRAIT_RESISTHIGHPRESSURE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "High-Pressure Resistance",
			SPECIES_PERK_DESC = "[plural_form] are resistant to high atmospheric pressures.",
		))

	if(TRAIT_RESISTLOWPRESSURE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "level-down-alt",
			SPECIES_PERK_NAME = "Low-Pressure Resistance",
			SPECIES_PERK_DESC = "[plural_form] are resistant to low atmospheric pressures.",
		))

	if(TRAIT_TOXIMMUNE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Toxin Immune",
			SPECIES_PERK_DESC = "[plural_form] are immune to toxin damage.",
		))

	if(TRAIT_PIERCEIMMUNE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Tough Skin",
			SPECIES_PERK_DESC = "[plural_form] have tough skin, blocking piercing and embedding of sharp objects, including needles.",
		))

	if(TRAIT_POWERHUNGRY in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "[plural_form] can feed on electricity from APCs and powercells; and do not otherwise need to eat.",
		))

		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "No Genes",
			SPECIES_PERK_DESC = "[plural_form] have no genes, making genetic scrambling a useless weapon, but also locking them out from getting genetic powers.",
		))

	if (TRAIT_NOBREATH in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "No Respiration",
			SPECIES_PERK_DESC = "[plural_form] have no need to breathe!",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_biotypes flags.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_biotypes_perks()
	var/list/to_add = list()

	if(inherent_biotypes & MOB_UNDEAD)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Undead",
			SPECIES_PERK_DESC = "[plural_form] are of the undead! The undead do not have the need to eat or breathe, and \
				most viruses will not be able to infect a walking corpse. Their worries mostly stop at remaining in one piece, really.",
		))

	return to_add

/**
 * Adds in a language perk based on all the languages the species
 * can speak by default (according to their language holder).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_language_perk()

	// Grab galactic common and metalanguage as paths, for comparisons
	var/datum/language/common_language = /datum/language/common
	var/datum/language/metalanguage = /datum/language/metalanguage

	// Now let's find all the languages they can speak that aren't common or metalanguage
	var/list/bonus_languages = list()
	var/datum/language_holder/basic_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/datum/language/language_type as anything in basic_holder.spoken_languages)
		if(ispath(language_type, common_language) || ispath(language_type, metalanguage))
			continue
		bonus_languages += initial(language_type.name)

	if(!length(bonus_languages))
		return // You're boring

	var/list/to_add = list()
	if(common_language in basic_holder.spoken_languages)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Native Speaker",
			SPECIES_PERK_DESC = "Alongside [initial(common_language.name)], [plural_form] gain the ability to speak [english_list(bonus_languages)].",
		))

	else
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Foreign Speaker",
			SPECIES_PERK_DESC = "[plural_form] may not speak [initial(common_language.name)], but they can speak [english_list(bonus_languages)].",
		))

	return to_add

//generic action proc for keybind stuff
/datum/species/proc/primary_species_action()
	return

//Use this to return dynamic heights, such as making felinids shorter on halloween or something
/datum/species/proc/get_species_height()
	return species_height

/datum/species/proc/get_mut_organs(include_brain = TRUE)
	var/list/mut_organs = list()
	mut_organs += mutant_organs
	if (include_brain)
		mut_organs += mutantbrain
	mut_organs += mutantheart
	mut_organs += mutantlungs
	mut_organs += mutanteyes
	mut_organs += mutantears
	mut_organs += mutanttongue
	mut_organs += mutantliver
	mut_organs += mutantstomach
	mut_organs += mutantappendix
	list_clear_nulls(mut_organs)
	return mut_organs

/datum/species/proc/get_types_to_preload()
	return get_mut_organs(FALSE)

/// Creates body parts for the target completely from scratch based on the species
/datum/species/proc/create_fresh_body(mob/living/carbon/target)
	target.create_bodyparts(bodypart_overrides)

/**
 * Checks if the species has a head with these head flags, by default.
 * Admittedly, this is a very weird and seemingly redundant proc, but it
 * gets used by some preferences (such as hair style) to determine whether
 * or not they are accessible.
 **/
/datum/species/proc/check_head_flags(check_flags = NONE)
	var/obj/item/bodypart/head/fake_head = bodypart_overrides[BODY_ZONE_HEAD]
	return (initial(fake_head.head_flags) & check_flags)
/**
 * Get what hair color is used by this species for a mob.
 *
 * Arguments
 * * for_mob - The mob to get the hair color for. Required.
 *
 * Returns a color string or null.
 */
/datum/species/proc/get_fixed_hair_color(mob/living/carbon/for_mob)
	ASSERT(!isnull(for_mob))
	switch(hair_color_mode)
		if(USE_MUTANT_COLOR)
			return for_mob.dna.features["mcolor"]
		if(USE_FIXED_MUTANT_COLOR)
			return fixed_mut_color

	return null

/// Add species appropriate body markings
/datum/species/proc/add_body_markings(mob/living/carbon/human/hooman)
	for(var/markings_type in body_markings) //loop through possible species markings
		var/datum/bodypart_overlay/simple/body_marking/markings = new markings_type() // made to die... mostly because we cant use initial on lists but its convenient and organized
		var/accessory_name = hooman.dna.features[markings.dna_feature_key] || body_markings[markings_type] //get the accessory name from dna
		for(var/obj/item/bodypart/part as anything in markings.applies_to) //check through our limbs
			var/obj/item/bodypart/people_part = hooman.get_bodypart(initial(part.body_zone)) // and see if we have a compatible marking for that limb
			if(isnull(people_part))
				continue

			var/datum/bodypart_overlay/simple/body_marking/overlay = new markings_type()
			overlay.set_appearance(accessory_name, hooman.dna.features["mcolor"])
			people_part.add_bodypart_overlay(overlay)

		qdel(markings)

/// Remove body markings
/datum/species/proc/remove_body_markings(mob/living/carbon/human/hooman)
	for(var/obj/item/bodypart/part as anything in hooman.bodyparts)
		for(var/datum/bodypart_overlay/simple/body_marking/marking in part.bodypart_overlays)
			part.remove_bodypart_overlay(marking)
