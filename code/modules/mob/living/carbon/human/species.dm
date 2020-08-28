// This code handles different species in the game.

GLOBAL_LIST_EMPTY(roundstart_races)
GLOBAL_LIST_EMPTY(accepatable_no_hard_check_races)

/// An assoc list of species types to their features (from get_features())
GLOBAL_LIST_EMPTY(features_by_species)

/datum/species
	var/id	// if the game needs to manually check your race to do something not included in a proc here, it will use this
	var/name	// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	/// The formatting of the name of the species in plural context. Defaults to "[name]\s" if unset.
	/// Ex "[Plasmamen] are weak", "[Mothmen] are strong", "[Lizardpeople] don't like", "[Golems] hate"
	var/plural_form
	var/bodyflag = FLAG_HUMAN //Species flags currently used for species restriction on items
	var/default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race
	var/bodytype = BODYTYPE_HUMANOID
	var/sexes = 1		// whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows

	var/list/offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0), OFFSET_RIGHT_HAND = list(0,0), OFFSET_LEFT_HAND = list(0,0))
	var/max_bodypart_count = 6 //The maximum number of bodyparts this species can have.
	var/hair_color	// this allows races to have specific hair colors... if null, it uses the H's hair/facial hair colors. if "mutcolor", it uses the H's mutant_color
	var/hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.
	var/examine_limb_id //This is used for children, felinids and ashwalkers namely

	var/digitigrade_customization = DIGITIGRADE_NEVER //Never, Optional, or Forced digi legs?
	var/use_skintones = FALSE	// does it use skintones or not? (spoiler alert this is only used by humans)
	///If your race bleeds something other than bog standard blood, change this to reagent id. For example, ethereals bleed liquid electricity.
	var/datum/reagent/exotic_blood
	var/exotic_bloodtype = "" //If your race uses a non standard bloodtype (A+, O-, AB-, etc)
	var/meat = /obj/item/food/meat/slab/human //What the species drops on gibbing
	var/skinned_type
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
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
	var/list/mutant_organs = list()		//Internal organs that are unique to this race.

	var/list/forced_features = list()	// A list of features forced on characters

	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/armor = 0		// overall defense for the race... or less defense, if it's negative.
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/stunmod = 1
	var/oxymod = 1
	var/clonemod = 1
	var/toxmod = 1
	var/staminamod = 1		// multiplier for stun duration
	var/attack_type = BRUTE //Type of damage attack does
	var/punchdamage = 7      //highest possible punch damage
	var/siemens_coeff = 1 //base electrocution coefficient
	var/damage_overlay_type = "human" //what kind of damage overlays (if any) appear on our species when wounded?
	var/fixed_mut_color = "" //to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]
	var/inert_mutation 	= /datum/mutation/dwarfism //special mutation that can be found in the genepool. Dont leave empty or changing species will be a headache
	var/deathsound //used to set the mobs deathsound on species change
	var/list/special_step_sounds //Sounds to override barefeet walkng
	var/grab_sound //Special sound for grabbing
	var/blood_color //Blood color for decals
	var/reagent_tag = PROCESS_ORGANIC //Used for metabolizing reagents. We're going to assume you're a meatbag unless you say otherwise.
	var/species_gibs = GIB_TYPE_HUMAN //by default human gibs are used
	var/allow_numbers_in_name // Can this species use numbers in its name?
	var/datum/outfit/outfit_important_for_life /// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/action/innate/flight/fly //the actual flying ability given to flying species

	/// The natural temperature for a body
	var/bodytemp_normal = BODYTEMP_NORMAL
	/// Minimum amount of kelvin moved toward normal body temperature per tick.
	var/bodytemp_autorecovery_min = BODYTEMP_AUTORECOVERY_MINIMUM
	/// The body temperature limit the body can take before it starts taking damage from heat.
	var/bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT
	/// The body temperature limit the body can take before it starts taking damage from cold.
	var/bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT

	// species-only traits. Can be found in DNA.dm
	var/list/species_traits = list()
	// generic traits tied to having the species
	var/list/inherent_traits = list()
	var/list/inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	var/attack_verb = "punch"	// punch-specific attack verb
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	//Breathing! Most changes are in mutantlungs, though
	var/breathid = GAS_O2

	//Blank list. As it runs through regenerate_organs, organs that are missing are added in sequential order to the list
	//List is called in health analyzer and displays all missing organs
	var/list/required_organs = list()

	//Do NOT remove by setting to null. use OR make a RESPECTIVE TRAIT (removing stomach? add the NOSTOMACH trait to your species)
	//why does it work this way? because traits also disable the downsides of not having an organ, removing organs but not having the trait will make your species die

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
	///Replaces default wings with a different organ. (There should be no default wings, only those on moths & apids, thus null)
	var/obj/item/organ/wings/mutantwings = null
	//only an honorary mutantthing because not an organ and not loaded in the same way, you've been warned to do your research
	var/obj/item/mutanthands

	//Bitflag that controls what in game ways can select this species as a spawnable source
	//Think magic mirror and pride mirror, slime extract, ERT etc, see defines
	//in __DEFINES/mobs.dm, defaults to NONE, so people actually have to think about it
	var/changesource_flags = NONE

	//The component to add when swimming
	var/swimming_component = /datum/component/swimming

	//K-Limbs. If a species doesn't have their own limb types. Do not override this, use the K-Limbs overrides at the top of the species datum.
	var/obj/item/bodypart/species_chest = /obj/item/bodypart/chest
	var/obj/item/bodypart/species_head = /obj/item/bodypart/head
	var/obj/item/bodypart/species_l_arm = /obj/item/bodypart/l_arm
	var/obj/item/bodypart/species_r_arm = /obj/item/bodypart/r_arm
	var/obj/item/bodypart/species_r_leg = /obj/item/bodypart/r_leg
	var/obj/item/bodypart/species_l_leg = /obj/item/bodypart/l_leg

	/// if false, having no tongue makes you unable to speak
	var/speak_no_tongue = TRUE

	///List of possible heights
	var/list/species_height = SPECIES_HEIGHTS(BODY_SIZE_SHORT, BODY_SIZE_NORMAL, BODY_SIZE_TALL)

	/// What bleed status effect should we apply?
	var/bleed_effect = /datum/status_effect/bleeding

	// Species specific bitflags. Used for things like if the race is unable to become a changeling.
	var/species_bitflags = NONE

	/// Do we try to prevent reset_perspective() from working? Useful for Dullahans to stop perspective changes when they're looking through their head.
	var/prevent_perspective_change = FALSE

	//Should we preload this species's organs?
	var/preload = TRUE

///////////
// PROCS //
///////////

/datum/species/New()
	if(!plural_form)
		plural_form = "[name]\s"
	return ..()

/// Gets a list of all species available to choose in roundstart.
/proc/get_selectable_species()
	RETURN_TYPE(/list)

	if (!GLOB.roundstart_races.len)
		GLOB.roundstart_races = generate_selectable_species()

	return GLOB.roundstart_races

/proc/generate_selectable_species()
	var/list/selectable_species = list()

	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = new species_type
		if(species.check_roundstart_eligible())
			selectable_species += species.id
			qdel(species)

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

/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/datum/species/proc/check_no_hard_check()
	if(id in (CONFIG_GET(keyed_list/roundstart_no_hard_check)))
		return TRUE
	return FALSE

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



//Called when cloning, copies some vars that should be kept
/datum/species/proc/copy_properties_from(datum/species/old_species)
	return

/** regenerate_organs
  * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does
  *
  * takes all organ slots, removes organs a species should not have, adds organs a species should have.
  * can use replace_current to refresh all organs, creating an entirely new set.
  * Arguments:
  * C - carbon, the owner of the species datum AKA whoever we're regenerating organs in
  * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
  * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
  * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 * * visual_only - boolean, only load organs that change how the species looks. Do not use for normal gameplay stuff
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	//what should be put in if there is no mutantorgan (brains handled seperately)
	var/list/slot_mutantorgans = list(
		ORGAN_SLOT_BRAIN = mutantbrain,
		ORGAN_SLOT_HEART = mutantheart,
		ORGAN_SLOT_LUNGS = mutantlungs,
		ORGAN_SLOT_APPENDIX = mutantappendix,
		ORGAN_SLOT_EYES = mutanteyes,
		ORGAN_SLOT_EARS = mutantears,
		ORGAN_SLOT_TONGUE = mutanttongue,
		ORGAN_SLOT_LIVER = mutantliver,
		ORGAN_SLOT_STOMACH = mutantstomach,
		ORGAN_SLOT_WINGS = mutantwings
	)

	var/list/slot_organs = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_WINGS
	)

	//if theres no added wing type, we want to avoid adding a null
	if(isnull(mutantwings))
		slot_organs -= ORGAN_SLOT_WINGS

	for(var/slot in slot_organs)

		var/obj/item/organ/oldorgan = C.getorganslot(slot) //used in removing
		var/obj/item/organ/neworgan = slot_mutantorgans[slot] //used in adding

		if(visual_only && !initial(neworgan.visual))
			continue

		var/used_neworgan = FALSE
		neworgan = SSwardrobe.provide_type(neworgan)
		var/should_have = neworgan.get_availability(src) //organ proc that points back to a species trait (so if the species is supposed to have this organ)

		if(oldorgan && (!should_have || replace_current) && !(oldorgan.zone in excluded_zones) && !(oldorgan.organ_flags & (ORGAN_UNREMOVABLE)))
			if(slot == ORGAN_SLOT_BRAIN)
				var/obj/item/organ/brain/brain = oldorgan
				if(!brain.decoy_override)//"Just keep it if it's fake" - confucius, probably
					brain.Remove(C,TRUE, TRUE) //brain argument used so it doesn't cause any... sudden death.
					QDEL_NULL(brain)
					oldorgan = null
			else
				oldorgan.Remove(C, special = TRUE)
				required_organs -= oldorgan.type
				QDEL_NULL(oldorgan) //we cannot just tab this out because we need to skip the deleting if it is a decoy brain.

		if(oldorgan)
			oldorgan.setOrganDamage(0)
		else if(should_have && !(initial(neworgan.zone) in excluded_zones))
			used_neworgan = TRUE
			neworgan.Insert(C, TRUE, FALSE)
			required_organs |= neworgan.type

		if(!used_neworgan)
			qdel(neworgan)

	if(old_species)
		for(var/mutantorgan in old_species.mutant_organs)
			// Snowflake check. If our species share this mutant organ, let's not remove it
			// just yet as we'll be properly replacing it later.
			if(mutantorgan in mutant_organs)
				continue
			var/obj/item/organ/I = C.getorgan(mutantorgan)
			if(I)
				I.Remove(C, TRUE)
				required_organs -= I.type
				QDEL_NULL(I)

	for(var/organ_path in mutant_organs)
		var/obj/item/organ/current_organ = C.getorgan(organ_path)
		if(!current_organ || replace_current)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			// If there's an existing mutant organ, we're technically replacing it.
			// Let's abuse the snowflake proc. Basically retains
			// feature parity with every other organ too.
			if(current_organ)
				current_organ.before_organ_replacement(replacement)
			// organ.Insert will qdel any current organs in that slot, so we don't need to.
			replacement.Insert(C, TRUE, FALSE)
			required_organs |= replacement.type

/datum/species/proc/replace_body(mob/living/carbon/C, var/datum/species/new_species)
	new_species ||= C.dna.species //If no new species is provided, assume its src.
	//Note for future: Potentionally add a new C.dna.species() to build a template species for more accurate limb replacement

	if((new_species.digitigrade_customization == DIGITIGRADE_OPTIONAL && C.dna.features["legs"] == "Digitigrade Legs") || new_species.digitigrade_customization == DIGITIGRADE_FORCED)
		new_species.species_r_leg = /obj/item/bodypart/r_leg/digitigrade
		new_species.species_l_leg = /obj/item/bodypart/l_leg/digitigrade

	for(var/obj/item/bodypart/old_part as() in C.bodyparts)
		if(old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES)
			continue

		switch(old_part.body_zone)
			if(BODY_ZONE_HEAD)
				var/obj/item/bodypart/head/new_part = new new_species.species_head()
				new_part.replace_limb(C, TRUE, is_creating = TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_CHEST)
				var/obj/item/bodypart/chest/new_part = new new_species.species_chest()
				new_part.replace_limb(C, TRUE, is_creating = TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_L_ARM)
				var/obj/item/bodypart/l_arm/new_part = new new_species.species_l_arm()
				new_part.replace_limb(C, TRUE, is_creating = TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_R_ARM)
				var/obj/item/bodypart/r_arm/new_part = new new_species.species_r_arm()
				new_part.replace_limb(C, TRUE, is_creating = TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_L_LEG)
				var/obj/item/bodypart/l_leg/new_part = new new_species.species_l_leg()
				new_part.replace_limb(C, TRUE, is_creating = TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_R_LEG)
				var/obj/item/bodypart/r_leg/new_part = new new_species.species_r_leg()
				new_part.replace_limb(C, TRUE, is_creating = TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)


/datum/species/proc/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	// Drop the items the new species can't wear
	if((AGENDER in species_traits))
		C.gender = PLURAL
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src,thing.species_exception)))
			C.dropItemToGround(thing)
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	replace_body(C)

	C.mob_biotypes = inherent_biotypes

	regenerate_organs(C, old_species, visual_only = C.visual_only_organs)

	if(exotic_bloodtype && C.dna.blood_type != exotic_bloodtype)
		C.dna.blood_type = exotic_bloodtype

	if(old_species?.mutanthands)
		for(var/obj/item/I in C.held_items)
			if(istype(I, old_species.mutanthands))
				qdel(I)

	if(mutanthands)
		// Drop items in hands
		// If you're lucky enough to have a TRAIT_NODROP item, then it stays.
		for(var/V in C.held_items)
			var/obj/item/I = V
			if(istype(I))
				C.dropItemToGround(I)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				INVOKE_ASYNC(C, /mob/proc/put_in_hands, new mutanthands) // async due to prefs UI calling this and using SHOULD_NOT_SLEEP

	if(NOMOUTH in species_traits)
		for(var/obj/item/bodypart/head/head in C.bodyparts)
			head.mouth = FALSE

	for(var/X in inherent_traits)
		ADD_TRAIT(C, X, SPECIES_TRAIT)

	if(TRAIT_VIRUSIMMUNE in inherent_traits)
		for(var/datum/disease/A in C.diseases)
			A.cure(FALSE)

	for(var/datum/disease/A in C.diseases)//if we can't have the disease, dont keep it
		var/curedisease = TRUE
		for(var/host_type in A.infectable_biotypes)
			if(host_type in inherent_biotypes)
				curedisease = FALSE
				break
		if(curedisease)
			A.cure(FALSE)

	if(TRAIT_TOXIMMUNE in inherent_traits)
		C.setToxLoss(0, TRUE, TRUE)

	if(TRAIT_NOMETABOLISM in inherent_traits)
		C.reagents.end_metabolization(C, keep_liverless = TRUE)

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	C.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species, multiplicative_slowdown=speedmod)

	// All languages associated with this language holder are added with source [LANGUAGE_SPECIES]
	// rather than source [LANGUAGE_ATOM], so we can track what to remove if our species changes again
	var/datum/language_holder/gaining_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in gaining_holder.understood_languages)
		C.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.spoken_languages)
		C.grant_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.blocked_languages)
		C.add_blocked_language(language, LANGUAGE_SPECIES)

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)


/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	SIGNAL_HANDLER

	if(C.dna.species.exotic_bloodtype)
		C.dna.blood_type = random_blood_type()

	if(NOMOUTH in species_traits)
		for(var/obj/item/bodypart/head/head in C.bodyparts)
			head.mouth = TRUE

	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(C.dna.mutation_index) && (inert_mutation in C.dna.mutation_index))
		C.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = C.dna.mutation_index.Find(inert_mutation)
		C.dna.mutation_index[location] = new_species.inert_mutation
		C.dna.default_mutation_genes[location] = C.dna.mutation_index[location]
		C.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		C.dna.default_mutation_genes[new_species.inert_mutation] = C.dna.mutation_index[new_species.inert_mutation]

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction -= i
	C.remove_movespeed_modifier(/datum/movespeed_modifier/species)

	// Removes all languages previously associated with [LANGUAGE_SPECIES], gaining our new species will add new ones back
	var/datum/language_holder/losing_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in losing_holder.understood_languages)
		C.remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.spoken_languages)
		C.remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.blocked_languages)
		C.remove_blocked_language(language, LANGUAGE_SPECIES)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HD) //Decapitated
		return

	if(HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/datum/sprite_accessory/S
	var/list/standing = list()

	var/hair_hidden = FALSE //ignored if the matching dynamic_X_suffix is non-empty
	var/facialhair_hidden = FALSE // ^

	var/dynamic_hair_suffix = "" //if this is non-null, and hair+suffix matches an iconstate, then we render that hair instead
	var/dynamic_fhair_suffix = ""
	var/obj/item/clothing/head/wig/worn_wig

	if(H.head)// Wig stuff
		if(istype(H.head, /obj/item/clothing/head/wig))
			worn_wig = H.head
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			if(hat.attached_wig)
				worn_wig = hat.attached_wig

	//for augmented heads
	if(!IS_ORGANIC_LIMB(HD) && !worn_wig) //Wig overrides mechanical heads not having hair
		return

	//we check if our hat or helmet hides our facial hair.
	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix //mask > head in terms of facial hair
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.facial_hair_style && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hair_styles_list[H.facial_hair_style]
		if(S?.icon_state)

			//List of all valid dynamic_fhair_suffixes
			var/static/list/fextensions
			if(!fextensions)
				var/icon/fhair_extensions = icon('icons/mob/facialhair_extensions.dmi')
				fextensions = list()
				for(var/s in fhair_extensions.IconStates(1))
					fextensions[s] = TRUE
				qdel(fhair_extensions)

			//Is hair+dynamic_fhair_suffix a valid iconstate?
			var/fhair_state = S.icon_state
			var/fhair_file = S.icon
			if(fextensions[fhair_state+dynamic_fhair_suffix])
				fhair_state += dynamic_fhair_suffix
				fhair_file = 'icons/mob/facialhair_extensions.dmi'

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, CALCULATE_MOB_OVERLAY_LAYER(HAIR_LAYER))

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						facial_overlay.color = "#" + H.dna.features["mcolor"]
					else if (hair_color =="fixedmutcolor")
						facial_overlay.color = "#[fixed_mut_color]"
					else
						facial_overlay.color = "#" + hair_color
				else
					facial_overlay.color = "#" + H.facial_hair_color
			else
				facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha

			standing += facial_overlay
			standing += emissive_blocker(facial_overlay.icon, facial_overlay.icon_state, facial_overlay.layer, facial_overlay.alpha)

	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I) && !istype(I, /obj/item/clothing/head/wig))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(!hair_hidden || dynamic_hair_suffix || worn_wig)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = CALCULATE_MOB_OVERLAY_LAYER(HAIR_LAYER))
		var/mutable_appearance/gradient_overlay = mutable_appearance(layer = CALCULATE_MOB_OVERLAY_LAYER(HAIR_LAYER))
		if(!hair_hidden && !H.getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			if(!(NOBLOOD in species_traits))
				hair_overlay.icon = 'icons/mob/human_face.dmi'
				hair_overlay.icon_state = "debrained"

		else if((H.hair_style && (HAIR in species_traits)) || worn_wig)
			var/current_hair_style = H.hair_style
			var/current_hair_color = H.hair_color
			var/current_gradient_style = H.gradient_style
			var/current_gradient_color = H.gradient_color
			if(worn_wig)
				current_hair_style = worn_wig.hair_style
				current_hair_color = worn_wig.hair_color
				current_gradient_style = worn_wig.gradient_style
				current_gradient_color = worn_wig.gradient_color
			S = GLOB.hair_styles_list[current_hair_style]
			if(S?.icon_state)

				//List of all valid dynamic_hair_suffixes
				var/static/list/extensions
				if(!extensions)
					var/icon/hair_extensions = icon('icons/mob/hair_extensions.dmi') //hehe
					extensions = list()
					for(var/s in hair_extensions.IconStates(1))
						extensions[s] = TRUE
					qdel(hair_extensions)

				//Is hair+dynamic_hair_suffix a valid iconstate?
				var/hair_state = S.icon_state
				var/hair_file = S.icon
				if(extensions[hair_state+dynamic_hair_suffix])
					hair_state += dynamic_hair_suffix
					hair_file = 'icons/mob/hair_extensions.dmi'

				hair_overlay.icon = hair_file
				hair_overlay.icon_state = hair_state

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							hair_overlay.color = "#" + H.dna.features["mcolor"]
						else if(hair_color == "fixedmutcolor")
							hair_overlay.color = "#[fixed_mut_color]"
						else
							hair_overlay.color = "#" + hair_color
					else
						hair_overlay.color = "#" + current_hair_color
					if(worn_wig)//Total override
						hair_overlay.color = current_hair_color
					//Gradients
					var/gradient_style = current_gradient_style
					var/gradient_color = current_gradient_color
					if(gradient_style)
						var/datum/sprite_accessory/gradient = GLOB.hair_gradients_list[gradient_style]
						var/icon/temp = icon(gradient.icon, gradient.icon_state)
						var/icon/temp_hair = icon(hair_file, hair_state)
						temp.Blend(temp_hair, ICON_ADD)
						gradient_overlay.icon = temp
						gradient_overlay.color = "#" + gradient_color

				else
					hair_overlay.color = forced_colour

				hair_overlay.alpha = hair_alpha
				if(worn_wig)
					hair_overlay.alpha = 255
				if(OFFSET_FACE in H.dna.species.offset_features)
					hair_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
					hair_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
		if(hair_overlay.icon)
			standing += hair_overlay
			standing += gradient_overlay
			standing += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, hair_overlay.layer, hair_overlay.alpha)

	if(standing.len)
		H.overlays_standing[HAIR_LAYER] = standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	if(HD && !(HAS_TRAIT(H, TRAIT_HUSK)))
		// lipstick
		if(H.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[H.lip_style]", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
			lip_overlay.color = H.lip_color
			if(OFFSET_FACE in H.dna.species.offset_features)
				lip_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				lip_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += lip_overlay

		// eyes
		if(!(NOEYESPRITES in species_traits))
			var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			if(!E)
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
			else
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', E.eye_icon_state, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
			if((EYECOLOR in species_traits) && E)
				eye_overlay.color = "#" + H.eye_color
			if(OFFSET_FACE in H.dna.species.offset_features)
				eye_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				eye_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += eye_overlay

		// blush
		if (HAS_TRAIT(H, TRAIT_BLUSHING)) // Caused by either the *blush emote or the "drunk" mood event
			var/mutable_appearance/blush_overlay = mutable_appearance('icons/mob/human_face.dmi', "blush", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER)) //should appear behind the eyes
			blush_overlay.color = COLOR_BLUSH_PINK

			if(OFFSET_FACE in H.dna.species.offset_features)
				blush_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				blush_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
			standing += blush_overlay

		//crying
		if (HAS_TRAIT(H, TRAIT_CRYING)) // Caused by either using *cry or being pepper sprayed
			var/mutable_appearance/tears_overlay = mutable_appearance('icons/mob/human_face.dmi', "tears", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
			tears_overlay.color = COLOR_DARK_CYAN

			if(OFFSET_FACE in H.dna.species.offset_features)
				tears_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FACE][1]
				tears_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FACE][2]
				standing += tears_overlay

	//organic body markings
	if(HAS_MARKINGS in species_traits)
		var/obj/item/bodypart/chest/chest = H.get_bodypart(BODY_ZONE_CHEST)
		var/obj/item/bodypart/r_arm/right_arm = H.get_bodypart(BODY_ZONE_R_ARM)
		var/obj/item/bodypart/l_arm/left_arm = H.get_bodypart(BODY_ZONE_L_ARM)
		var/obj/item/bodypart/r_leg/right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
		var/obj/item/bodypart/l_leg/left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
		var/datum/sprite_accessory/markings = GLOB.moth_markings_list[H.dna.features["moth_markings"]]
		var/markings_icon_state = markings.icon_state
		if(ismoth(H) && HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			markings_icon_state = "burnt_off"

		if(!HAS_TRAIT(H, TRAIT_HUSK))
			if(HD && (IS_ORGANIC_LIMB(HD)))
				var/mutable_appearance/markings_head_overlay = mutable_appearance(markings.icon, "[markings_icon_state]_head", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += markings_head_overlay

			if(chest && (IS_ORGANIC_LIMB(chest)))
				var/mutable_appearance/markings_chest_overlay = mutable_appearance(markings.icon, "[markings_icon_state]_chest", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += markings_chest_overlay

			if(right_arm && (IS_ORGANIC_LIMB(right_arm)))
				var/mutable_appearance/markings_r_arm_overlay = mutable_appearance(markings.icon, "[markings_icon_state]_r_arm", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += markings_r_arm_overlay

			if(left_arm && (IS_ORGANIC_LIMB(left_arm)))
				var/mutable_appearance/markings_l_arm_overlay = mutable_appearance(markings.icon, "[markings_icon_state]_l_arm", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += markings_l_arm_overlay

			if(right_leg && (IS_ORGANIC_LIMB(right_leg)))
				var/mutable_appearance/markings_r_leg_overlay = mutable_appearance(markings.icon, "[markings_icon_state]_r_leg", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += markings_r_leg_overlay

			if(left_leg && (IS_ORGANIC_LIMB(left_leg)))
				var/mutable_appearance/markings_l_leg_overlay = mutable_appearance(markings.icon, "[markings_icon_state]_l_leg", CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				standing += markings_l_leg_overlay


	//Underwear, Undershirts & Socks
	if(!(NO_UNDERWEAR in species_traits))
		if(H.underwear && !(H.dna.species.bodytype & BODYTYPE_DIGITIGRADE))
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[H.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				if(H.dna.species.sexes && H.dna.features["body_model"] == FEMALE && (underwear.use_default_gender == MALE))
					underwear_overlay = wear_female_version(underwear.icon_state, underwear.icon, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), FEMALE_UNIFORM_FULL)
				else
					underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				if(!underwear.use_static)
					underwear_overlay.color = "#" + H.underwear_color
				standing += underwear_overlay

		if(H.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[H.undershirt]
			if(undershirt)
				if(H.dna.species.sexes && H.dna.features["body_model"] == FEMALE)
					standing += wear_female_version(undershirt.icon_state, undershirt.icon, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
				else
					standing += mutable_appearance(undershirt.icon, undershirt.icon_state, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))

		if(H.socks && H.num_legs >= 2 && !(H.dna.species.bodytype & BODYTYPE_DIGITIGRADE) && !(NOSOCKS in species_traits))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[H.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(H)

/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing	= list()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	REMOVE_LUM_SOURCE(H, LUM_SOURCE_MUTANT_BODYPART)

	if(!mutant_bodyparts)
		return

	var/obj/item/bodypart/head/HD = H.get_bodypart(BODY_ZONE_HEAD)

	if(mutant_bodyparts["tail_lizard"])
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_lizard"

	if(mutant_bodyparts["waggingtail_lizard"])
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_lizard"
		else if (mutant_bodyparts["tail_lizard"])
			bodyparts_to_add -= "waggingtail_lizard"

	if(mutant_bodyparts["tail_human"])
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "tail_human"


	if(mutant_bodyparts["waggingtail_human"])
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingtail_human"
		else if (mutant_bodyparts["tail_human"])
			bodyparts_to_add -= "waggingtail_human"

	if(mutant_bodyparts["spines"])
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "spines"

	if(mutant_bodyparts["waggingspines"])
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "waggingspines"
		else if (mutant_bodyparts["tail"])
			bodyparts_to_add -= "waggingspines"

	if(mutant_bodyparts["snout"]) //Take a closer look at that snout!
		if((H.wear_mask?.flags_inv & HIDESNOUT) || (H.head?.flags_inv & HIDESNOUT) || !HD)
			bodyparts_to_add -= "snout"

	if(mutant_bodyparts["frills"])
		if(!H.dna.features["frills"] || H.dna.features["frills"] == "None" || (H.head?.flags_inv & HIDEEARS) || !HD)
			bodyparts_to_add -= "frills"

	if(mutant_bodyparts["horns"])
		if(!H.dna.features["horns"] || H.dna.features["horns"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			bodyparts_to_add -= "horns"

	if(mutant_bodyparts["ears"])
		if(!H.dna.features["ears"] || H.dna.features["ears"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			bodyparts_to_add -= "ears"

	if(mutant_bodyparts["wings"])
		if(!H.dna.features["wings"] || H.dna.features["wings"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "wings"

	if(mutant_bodyparts["wings_open"])
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception)))
			bodyparts_to_add -= "wings_open"
		else if (mutant_bodyparts["wings"])
			bodyparts_to_add -= "wings_open"

	if(mutant_bodyparts["moth_antennae"])
		if(!H.dna.features["moth_antennae"] || H.dna.features["moth_antennae"] == "None" || !HD)
			bodyparts_to_add -= "moth_antennae"

	if(mutant_bodyparts["ipc_screen"])
		if(!H.dna.features["ipc_screen"] || H.dna.features["ipc_screen"] == "None" || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEYES)) || !HD)
			bodyparts_to_add -= "ipc_screen"

	if(mutant_bodyparts["ipc_antenna"])
		if(!H.dna.features["ipc_antenna"] || H.dna.features["ipc_antenna"] == "None" || (H.head?.flags_inv & HIDEEARS) || !HD)
			bodyparts_to_add -= "ipc_antenna"

	if(mutant_bodyparts["apid_antenna"])
		if(!H.dna.features["apid_antenna"] || H.dna.features["apid_antenna"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			bodyparts_to_add -= "apid_antenna"

	if(mutant_bodyparts["apid_headstripe"])
		if(!H.dna.features["apid_headstripe"] || H.dna.features["apid_headstripe"] == "None" || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEYES)) || !HD)
			bodyparts_to_add -= "apid_headstripe"
	if(mutant_bodyparts["psyphoza_cap"])
		if(!H.dna.features["psyphoza_cap"] || H.dna.features["psyphoza_cap"] == "None" || !HD)
			bodyparts_to_add -= "psyphoza_cap"
	if("diona_leaves" in mutant_bodyparts)
		if(!H.dna.features["diona_leaves"] || H.dna.features["diona_leaves"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_leaves"
	if("diona_thorns" in mutant_bodyparts)
		if(!H.dna.features["diona_thorns"] || H.dna.features["diona_thorns"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_thorns"
	if("diona_flowers" in mutant_bodyparts)
		if(!H.dna.features["diona_flowers"] || H.dna.features["diona_flowers"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_flowers"
	if("diona_moss" in mutant_bodyparts)
		if(!H.dna.features["diona_moss"] || H.dna.features["diona_moss"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_moss"
	if("diona_mushroom" in mutant_bodyparts)
		if(!H.dna.features["diona_mushroom"] || H.dna.features["diona_mushroom"] == "None" || !HD)
			bodyparts_to_add -= "diona_mushroom"
	if("diona_antennae" in mutant_bodyparts)
		if(!H.dna.features["diona_antennae"] || H.dna.features["diona_antennae"] == "None" || !HD)
			bodyparts_to_add -= "diona_antennae"
	if("diona_eyes" in mutant_bodyparts)
		if(!H.dna.features["diona_eyes"] || H.dna.features["diona_eyes"] == "None" || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEYES)) || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			bodyparts_to_add -= "diona_eyes"
	if("diona_pbody" in mutant_bodyparts)
		if(!H.dna.features["diona_pbody"] || H.dna.features["diona_pbody"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "diona_pbody"


	////PUT ALL YOUR WEIRD ASS REAL-LIMB HANDLING HERE
	///Digi handling
	if(H.dna.species.bodytype & BODYTYPE_DIGITIGRADE)
		var/uniform_compatible = FALSE
		var/suit_compatible = FALSE
		if(!(H.w_uniform) || (H.w_uniform.supports_variations & DIGITIGRADE_VARIATION) || (H.w_uniform.supports_variations & DIGITIGRADE_VARIATION_NO_NEW_ICON)) //Checks uniform compatibility
			uniform_compatible = TRUE
		if((!H.wear_suit) || (H.wear_suit.supports_variations & DIGITIGRADE_VARIATION) || !(H.wear_suit.body_parts_covered & LEGS) || (H.wear_suit.supports_variations & DIGITIGRADE_VARIATION_NO_NEW_ICON)) //Checks suit compatability
			suit_compatible = TRUE

		if((uniform_compatible && suit_compatible) || (suit_compatible && H.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
			for(var/obj/item/bodypart/BP as() in H.bodyparts)
				if(BP.bodytype & BODYTYPE_DIGITIGRADE)
					BP.limb_id = "digitigrade"

		else
			for(var/obj/item/bodypart/BP as() in H.bodyparts)
				if(BP.bodytype & BODYTYPE_DIGITIGRADE)
					BP.limb_id = "lizard"
	///End digi handling


	////END REAL-LIMB HANDLING
	H.update_body_parts()


	if(!bodyparts_to_add)
		return

	var/g = (H.dna.features["body_model"] == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/S
			switch(bodypart)
				if("tail_lizard")
					S = GLOB.tails_list_lizard[H.dna.features["tail_lizard"]]
				if("waggingtail_lizard")
					S = GLOB.animated_tails_list_lizard[H.dna.features["tail_lizard"]]
				if("tail_human")
					S = GLOB.tails_list_human[H.dna.features["tail_human"]]
				if("waggingtail_human")
					S = GLOB.animated_tails_list_human[H.dna.features["tail_human"]]
				if("spines")
					S = GLOB.spines_list[H.dna.features["spines"]]
				if("waggingspines")
					S = GLOB.animated_spines_list[H.dna.features["spines"]]
				if("snout")
					S = GLOB.snouts_list[H.dna.features["snout"]]
				if("frills")
					S = GLOB.frills_list[H.dna.features["frills"]]
				if("horns")
					S = GLOB.horns_list[H.dna.features["horns"]]
				if("ears")
					S = GLOB.ears_list[H.dna.features["ears"]]
				if("body_markings")
					S = GLOB.body_markings_list[H.dna.features["body_markings"]]
				if("wings")
					S = GLOB.wings_list[H.dna.features["wings"]]
				if("wingsopen")
					S = GLOB.wings_open_list[H.dna.features["wings"]]
				if("legs")
					S = GLOB.legs_list[H.dna.features["legs"]]
				if("moth_wings")
					if(HAS_TRAIT(H, TRAIT_MOTH_BURNT))
						S = GLOB.moth_wings_list["Burnt Off"]
					else
						S = GLOB.moth_wings_list[H.dna.features["moth_wings"]]
				if("moth_antennae")
					if(HAS_TRAIT(H, TRAIT_MOTH_BURNT))
						S = GLOB.moth_antennae_list["Burnt Off"]
					else
						S = GLOB.moth_antennae_list[H.dna.features["moth_antennae"]]
				if("moth_wingsopen")
					S = GLOB.moth_wingsopen_list[H.dna.features["moth_wings"]]
				if("moth_markings")
					S = GLOB.moth_markings_list[H.dna.features["moth_markings"]]
				if("caps")
					S = GLOB.caps_list[H.dna.features["caps"]]
				if("ipc_screen")
					S = GLOB.ipc_screens_list[H.dna.features["ipc_screen"]]
				if("ipc_antenna")
					S = GLOB.ipc_antennas_list[H.dna.features["ipc_antenna"]]
				if("ipc_chassis")
					S = GLOB.ipc_chassis_list[H.dna.features["ipc_chassis"]]
				if("insect_type")
					S = GLOB.insect_type_list[H.dna.features["insect_type"]]
				if("apid_antenna")
					S = GLOB.apid_antenna_list[H.dna.features["apid_antenna"]]
				if("apid_stripes")
					S = GLOB.apid_stripes_list[H.dna.features["apid_stripes"]]
				if("apid_headstripes")
					S = GLOB.apid_headstripes_list[H.dna.features["apid_headstripes"]]
				if("psyphoza_cap")
					S = GLOB.psyphoza_cap_list[H.dna.features["psyphoza_cap"]]
				if("diona_leaves")
					S = GLOB.diona_leaves_list[H.dna.features["diona_leaves"]]
				if("diona_thorns")
					S = GLOB.diona_thorns_list[H.dna.features["diona_thorns"]]
				if("diona_flowers")
					S = GLOB.diona_flowers_list[H.dna.features["diona_flowers"]]
				if("diona_moss")
					S = GLOB.diona_moss_list[H.dna.features["diona_moss"]]
				if("diona_mushroom")
					S = GLOB.diona_mushroom_list[H.dna.features["diona_mushroom"]]
				if("diona_antennae")
					S = GLOB.diona_antennae_list[H.dna.features["diona_antennae"]]
				if("diona_eyes")
					S = GLOB.diona_eyes_list[H.dna.features["diona_eyes"]]
				if("diona_pbody")
					S = GLOB.diona_pbody_list[H.dna.features["diona_pbody"]]


			if(!S || S.icon_state == "none" || !S?.icon_state)
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(S.icon, layer = CALCULATE_MOB_OVERLAY_LAYER(layer))

			// Add on emissives, if they have one
			if (S.emissive_state)
				accessory_overlay.overlays.Add(emissive_appearance(S.icon, S.emissive_state, CALCULATE_MOB_OVERLAY_LAYER(layer), S.emissive_alpha, filters = H.filters))
				ADD_LUM_SOURCE(H, LUM_SOURCE_MUTANT_BODYPART)

			//A little rename so we don't have to use tail_lizard or tail_human when naming the sprites.
			if(bodypart == "tail_lizard" || bodypart == "tail_human")
				bodypart = "tail"
			else if(bodypart == "waggingtail_lizard" || bodypart == "waggingtail_human")
				bodypart = "waggingtail"

			if(S.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[S.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[S.icon_state]_[layertext]"

			if(S.center)
				accessory_overlay = center_image(accessory_overlay, S.dimension_x, S.dimension_y)

			if(!(HAS_TRAIT(H, TRAIT_HUSK)))
				if(!forced_colour)
					switch(S.color_src)
						if(MUTCOLORS)
							if(fixed_mut_color)
								accessory_overlay.color = "#[fixed_mut_color]"
							else
								accessory_overlay.color = "#[H.dna.features["mcolor"]]"
						if(HAIR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = "#[H.dna.features["mcolor"]]"
							else
								accessory_overlay.color = "#[H.hair_color]"
						if(FACEHAIR)
							accessory_overlay.color = "#[H.facial_hair_color]"
						if(EYECOLOR)
							accessory_overlay.color = "#[H.eye_color]"
				else
					accessory_overlay.color = forced_colour
			standing += accessory_overlay

			if(S.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(S.icon, layer = CALCULATE_MOB_OVERLAY_LAYER(layer))
				if(S.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[bodypart]inner_[S.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[bodypart]inner_[S.icon_state]_[layertext]"

				if(S.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, S.dimension_x, S.dimension_y)

				standing += inner_accessory_overlay

		H.overlays_standing[layer] = standing.Copy()
		standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)


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


/datum/species/proc/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		H.setOxyLoss(0)
		H.losebreath = 0

		var/takes_crit_damage = (!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		if((H.health <= H.crit_threshold) && takes_crit_damage)
			H.adjustBruteLoss(0.5 * delta_time)
	if(H.getorgan(/obj/item/organ/wings))
		handle_flight(H)

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

/datum/species/proc/auto_equip(mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE
	if(I.species_restricted & H.dna?.species.bodyflag)
		to_chat(H, span_warning("Your species cannot wear this item!"))
		return FALSE

	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(H.wear_mask)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MASK))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_NECK)
			if(H.wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACK)
			if(H.back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_OCLOTHING)
			if(H.wear_suit)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_OCLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_GLOVES)
			if(H.gloves)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_GLOVES) )
				return FALSE
			if(H.num_hands < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(H.shoes)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_FEET) )
				return FALSE
			if(H.num_legs < 2)
				return FALSE
			if((bodytype & BODYTYPE_DIGITIGRADE) && !(I.supports_variations & DIGITIGRADE_VARIATION))
				if(!disable_warning)
					to_chat(H, span_warning("The footwear around here isn't compatible with your feet!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			if(H.belt)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(H.glasses)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EYES))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
			if(E?.no_glasses)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_HEAD)
			if(H.head)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HEAD))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EARS)
			if(H.ears)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EARS))
				return FALSE
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ICLOTHING)
			if(H.w_uniform)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ICLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ID)
			if(H.wear_id)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ID) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(H.l_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_LPOCKET) )
				return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.r_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_RPOCKET) )
				return TRUE
			return FALSE
		if(ITEM_SLOT_SUITSTORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.s_store)
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, span_warning("You need a suit before you can attach this [I.name]!"))
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, "The [I.name] is too big to attach.") //should be src?
				return FALSE
			if(istype(I, /obj/item/modular_computer/tablet) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed))
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			if(H.handcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(H.num_legs < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEGCUFFED)
			if(H.legcuffed)
				return FALSE
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
	H.visible_message(span_notice("[H] start putting on [I]."), span_notice("You start putting on [I]."))
	return do_after(H, I.equip_delay_self, target = H)

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null)
	H.update_mutant_bodyparts()

// Do species-specific reagent handling here
// Return 1 if it should do normal processing too
// Return 0 if it shouldn't deplete and do its normal effect
// Other return values will cause weird badness

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
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

/datum/species/proc/check_species_weakness(obj/item, mob/living/attacker)
	return 0 //This is not a boolean, it's the multiplier for the damage that the user takes from the item.It is added onto the check_weakness value of the mob, and then the force of the item is multiplied by this value

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	outfit_important_for_life= new()
	outfit_important_for_life.equip(human_to_equip)

////////
//LIFE//
////////

/datum/species/proc/handle_digestion(mob/living/carbon/human/H, delta_time, times_fired)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(H, TRAIT_FAT, OBESITY))//I share your pain, past coder.
		if(H.overeatduration < (200 SECONDS))
			to_chat(H, "<span class='notice'>You feel fit again!</span>")
			REMOVE_TRAIT(H, TRAIT_FAT, OBESITY)
			REMOVE_TRAIT(H, TRAIT_OFF_BALANCE_TACKLER, OBESITY)
			H.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()
	else
		if(H.overeatduration >= (200 SECONDS))
			to_chat(H, "<span class='danger'>You suddenly feel blubbery!</span>")
			ADD_TRAIT(H, TRAIT_FAT, OBESITY)
			ADD_TRAIT(H, TRAIT_OFF_BALANCE_TACKLER, OBESITY)
			H.add_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()

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
				H.Jitter(5)
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
			var/obj/item/organ/stomach/battery/battery = H.getorganslot(ORGAN_SLOT_STOMACH)
			if(!istype(battery))
				H.throw_alert("nutrition", /atom/movable/screen/alert/nocell)
			else
				H.throw_alert("nutrition", /atom/movable/screen/alert/emptycell)

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return FALSE

/**
 * Species based handling for irradiation
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The mob requesting handling
 * - delta_time: The amount of time that has passed since the last tick
 * - times_fired: The number of times SSmobs has fired
 */
/datum/species/proc/handle_mutations_and_radiation(mob/living/carbon/human/source, delta_time, times_fired)
	if(HAS_TRAIT(source, TRAIT_RADIMMUNE))
		source.radiation = 0
		return TRUE

	. = FALSE
	var/radiation = source.radiation

	if(radiation > RAD_MOB_KNOCKDOWN && DT_PROB(RAD_MOB_KNOCKDOWN_PROB, delta_time))
		if(!source.IsParalyzed())
			source.emote("collapse")
		source.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(source, "<span class='danger'>You feel weak.</span>")

	if(radiation > RAD_MOB_VOMIT && DT_PROB(RAD_MOB_VOMIT_PROB, delta_time))
		source.vomit(10, TRUE)

	if(radiation > RAD_MOB_MUTATE && DT_PROB(RAD_MOB_MUTATE_PROB, delta_time))
		to_chat(source, "<span class='danger'>You mutate!</span>")
		source.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		source.emote("gasp")
		source.domutcheck()

	if(radiation > RAD_MOB_HAIRLOSS && DT_PROB(RAD_MOB_HAIRLOSS_PROB, delta_time))
		if(!(source.hair_style == "Bald") && (HAIR in species_traits) && !HAS_TRAIT(source, TRAIT_NOHAIRLOSS))
			to_chat(source, "<span class='danger'>Your hair starts to fall out in clumps.</span>")
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
	target.facial_hair_style = "Shaved"
	target.hair_style = "Bald"
	target.update_hair()

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

/datum/species/proc/spec_fully_heal(mob/living/carbon/human/H)
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

		var/atk_verb = user.dna.species.attack_verb
		if(target.body_position == LYING_DOWN)
			atk_verb = ATTACK_EFFECT_KICK

		switch(atk_verb)//this code is really stupid but some genius apparently made "claw" and "slash" two attack types but also the same one so it's needed i guess
			if(ATTACK_EFFECT_KICK)
				user.do_attack_animation(target, ATTACK_EFFECT_KICK)
			if(ATTACK_EFFECT_SLASH, ATTACK_EFFECT_CLAW)//smh
				user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
			if(ATTACK_EFFECT_SMASH)
				user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
			else
				user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

		var/damage = user.dna.species.punchdamage

		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.get_combat_bodyzone(target)))

		if(!damage || !affecting)//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, user.dna.species.miss_sound, 25, 1, -1)
			target.visible_message(span_danger("[user]'s [atk_verb] misses [target]!"), \
							span_danger("You avoid [user]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] misses [target]!"))
			log_combat(user, target, "attempted to punch")
			return FALSE

		var/armor_block = target.run_armor_check(affecting, MELEE)

		playsound(target.loc, user.dna.species.attack_sound, 25, 1, -1)

		target.visible_message(span_danger("[user] [atk_verb]ed [target]!"), \
						span_userdanger("You're [atk_verb]ed by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [atk_verb] [target]!"))

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		user.dna.species.spec_unarmedattack(user, target)

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		if(atk_verb == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage
			target.apply_damage(damage*1.5, attack_type, affecting, armor_block)
			if((damage * 1.5) >= 9)
				target.force_say()
			log_combat(user, target, "kicked", "punch")
		else//other attacks deal full raw damage + 1.5x in stamina damage
			target.apply_damage(damage, attack_type, affecting, armor_block)
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

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style, modifiers)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return
	if(M.mind)
		attacker_style = M.mind.martial_art
	if((M != H) && M.combat_mode && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		log_combat(M, H, "attempted to touch")
		H.visible_message("<span class='warning'>[M] attempts to touch [H]!</span>", \
						"<span class='danger'>[M] attempts to touch you!</span>", "<span class='hear'>You hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='warning'>You attempt to touch [H]!</span>")
		return

	SEND_SIGNAL(M, COMSIG_MOB_ATTACK_HAND, M, H, attacker_style)
	SEND_SIGNAL(H, COMSIG_MOB_HAND_ATTACKED, H, M, attacker_style)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		disarm(M, H, attacker_style)
		return // dont attack after
	if(M.combat_mode)
		harm(M, H, attacker_style)
	else
		help(M, H, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	// Allows you to put in item-specific reactions based on species
	if(user != H)
		if(H.check_shields(I, I.force, "the [I.name]", MELEE_ATTACK, I.armour_penetration))
			return FALSE
	if(H.check_block())
		H.visible_message(span_warning("[H] blocks [I]!"), \
						span_userdanger("You block [I]!"))
		return FALSE

	var/hit_area
	if(!affecting) //Something went wrong. Maybe the limb is missing?
		affecting = H.bodyparts[1]

	hit_area = parse_zone(affecting.body_zone)
	var/def_zone = affecting.body_zone

	var/armor_block = H.run_armor_check(affecting, MELEE, span_notice("Your armor has protected your [hit_area]!"), span_warning("Your armor has softened a hit to your [hit_area]!"),I.armour_penetration)
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)
	var/limb_damage = affecting.get_damage() //We need to save this for later to simplify dismemberment
	apply_damage(I.force, I.damtype, def_zone, armor_block, H)

	if (I.bleed_force)
		var/armour_block = user.run_armor_check(affecting, BLEED, armour_penetration = I.armour_penetration, silent = (I.force > 0))
		var/hit_amount = (100 - armour_block) / 100
		H.add_bleeding(I.bleed_force * hit_amount)
		if(IS_ORGANIC_LIMB(affecting))
			I.add_mob_blood(H)	//Make the weapon bloody, not the person.
			if(get_dist(user, H) <= 1)	//people with TK won't get smeared with blood
				user.add_mob_blood(H)
			switch(hit_area)
				if(BODY_ZONE_HEAD)
					if(H.wear_mask)
						H.wear_mask.add_mob_blood(H)
						H.update_inv_wear_mask()
					if(H.head)
						H.head.add_mob_blood(H)
						H.update_inv_head()
					if(H.glasses && prob(33))
						H.glasses.add_mob_blood(H)
						H.update_inv_glasses()

				if(BODY_ZONE_CHEST)
					if(H.wear_suit)
						H.wear_suit.add_mob_blood(H)
						H.update_inv_wear_suit()
					if(H.w_uniform)
						H.w_uniform.add_mob_blood(H)
						H.update_inv_w_uniform()

	H.send_item_attack_message(I, user, hit_area)

	if(!I.force)
		return 0 //item force is zero

	var/dismember_limb = FALSE
	var/weapon_sharpness = I.is_sharp()

	if(((HAS_TRAIT(H, TRAIT_EASYDISMEMBER) && limb_damage) || (weapon_sharpness == SHARP_DISMEMBER_EASY)) && prob(I.force))
		dismember_limb = TRUE
		//Easy dismemberment on the mob allows even blunt weapons to potentially delimb, but only if the limb is already damaged
		//Certain weapons are so sharp/strong they have a chance to cleave right through a limb without following the normal restrictions

	else if(weapon_sharpness > SHARP || (weapon_sharpness == SHARP && H.stat == DEAD))
		//Delimbing cannot normally occur with blunt weapons
		//You also aren't cutting someone's arm off with a scalpel unless they're already dead

		if(limb_damage >= affecting.max_damage)
			dismember_limb = TRUE
			//You can only cut a limb off if it is already damaged enough to be fully disabled

	if(dismember_limb && ((affecting.body_zone != BODY_ZONE_HEAD && affecting.body_zone != BODY_ZONE_CHEST) || H.stat != CONSCIOUS) && affecting.dismember(I.damtype))
		I.add_mob_blood(H)
		playsound(get_turf(H), I.get_dismember_sound(), 80, 1)

	if(I.damtype == BRUTE && (I.force >= max(10, armor_block) && hit_area == BODY_ZONE_HEAD))
		if(!I.is_sharp() && H.mind && H.stat == CONSCIOUS && H != user && (H.health - (I.force * I.attack_weight)) <= 0) // rev deconversion through blunt trauma.
			var/datum/antagonist/rev/rev = H.mind.has_antag_datum(/datum/antagonist/rev)
			if(rev)
				rev.remove_revolutionary(FALSE, user)
		if(Iforce > 10 || Iforce >= 5 && prob(33))
			H.force_say(user)
	else if (I.damtype == BURN && H.is_bleeding())
		H.cauterise_wounds(AMOUNT_TO_BLEED_INTENSITY(I.force / 3))
		to_chat(user, span_userdanger("The heat from [I] cauterizes your bleeding!"))
		playsound(src, 'sound/surgery/cautery2.ogg', 70)
	return TRUE

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE, spread_damage = FALSE)
	SEND_SIGNAL(H, COMSIG_MOB_APPLY_DAMGE, damage, damagetype, def_zone)
	var/hit_percent = (100-(blocked+armor))/100
	hit_percent = (hit_percent * (100-H?.physiology?.damage_resistance))/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone))
			BP = def_zone
		else
			if(!def_zone)
				def_zone = check_zone(def_zone)
			BP = H.get_bodypart(check_zone(def_zone))
			if(!BP)
				BP = H.bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * brutemod * H.physiology.brute_mod
			if(BP)
				if(BP.receive_damage(damage_amount, 0))
					H.update_damage_overlays()
			else//no bodypart, we deal damage with a more general method.
				H.adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * burnmod * H.physiology.burn_mod
			if(BP)
				if(BP.receive_damage(0, damage_amount))
					H.update_damage_overlays()
			else
				H.adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			var/damage_amount = forced ? damage : damage * hit_percent * toxmod * H.physiology.tox_mod
			H.adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			var/damage_amount = forced ? damage : damage * oxymod * hit_percent * H.physiology.oxy_mod
			H.adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			var/damage_amount = forced ? damage : damage * hit_percent * clonemod * H.physiology.clone_mod
			H.adjustCloneLoss(damage_amount, forced = forced)
		if(STAMINA)
			var/damage_amount = forced ? damage : damage * hit_percent * staminamod * H.physiology.stamina_mod
			if(BP)
				if(BP.receive_damage(0, 0, damage_amount))
					H.update_stamina(TRUE)
			else
				H.adjustStaminaLoss(damage_amount, forced = forced)
		if(BRAIN)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.brain_mod
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)
	return 1

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

/////////////
//BREATHING//
/////////////

/datum/species/proc/breathe(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return TRUE

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
	if(humi.stat < DEAD && !IS_IN_STASIS(humi))
		body_temperature_core(humi, delta_time, times_fired)

	//These do run in status
	body_temperature_skin(humi, delta_time, times_fired)
	body_temperature_alerts(humi, delta_time, times_fired)

	//Do not cause more damage in statis
	if(!IS_IN_STASIS(humi))
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

	// Changes to the skin temperature based on the area
	var/area_skin_diff = area_temp - humi.bodytemperature
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
		var/core_skin_diff = humi.coretemperature - humi.bodytemperature
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
			humi.throw_alert("temp", /atom/movable/screen/alert/hot, 1)
		else if(bodytemp in BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			humi.throw_alert("temp", /atom/movable/screen/alert/hot, 2)
		else
			humi.throw_alert("temp", /atom/movable/screen/alert/hot, 3)

	// Body temperature is too cold, and we do not have resist traits
	else if(humi.bodytemperature < bodytemp_cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		// clear any hot moods and apply cold mood
		SEND_SIGNAL(humi, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(humi, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		// Apply cold slow down
		humi.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((bodytemp_cold_damage_limit - humi.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		// Display alerts based how cold it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in BODYTEMP_COLD_WARNING_2 to bodytemp_cold_damage_limit)
			humi.throw_alert("temp", /atom/movable/screen/alert/cold, 1)
		else if(bodytemp in BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			humi.throw_alert("temp", /atom/movable/screen/alert/cold, 2)
		else
			humi.throw_alert("temp", /atom/movable/screen/alert/cold, 3)

	// We are not to hot or cold, remove status and moods
	// Optimization here, we check these things based off the old temperature to avoid unneeded work
	// We're not perfect about this, because it'd just add more work to the base case, and resistances are rare
	else if (old_bodytemp > bodytemp_heat_damage_limit || old_bodytemp < bodytemp_cold_damage_limit)
		humi.clear_alert("temp")
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

	if(humi.coretemperature < bodytemp_cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		var/damage_type = BURN
		var/damage_mod = coldmod * humi.physiology.cold_mod
		if(humi.coretemperature in 201 to bodytemp_cold_damage_limit)
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
			if(!HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.adjustBruteLoss(min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod * delta_time)
				H.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)
			else
				H.clear_alert("pressure")

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
			else
				H.adjustBruteLoss(LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod * delta_time)
				H.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, delta_time, times_fired, no_protection = FALSE)
	if(!CanIgniteMob(H))
		return TRUE
	if(H.on_fire)
		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		var/obscured = H.check_obscured_slots(TRUE)
		//HEAD//

		if(H.glasses && !(obscured & ITEM_SLOT_EYES))
			burning_items += H.glasses
		if(H.wear_mask && !(obscured & ITEM_SLOT_MASK))
			burning_items += H.wear_mask
		if(H.wear_neck && !(obscured & ITEM_SLOT_NECK))
			burning_items += H.wear_neck
		if(H.ears && !(obscured & ITEM_SLOT_EARS))
			burning_items += H.ears
		if(H.head)
			burning_items += H.head

		//CHEST//
		if(H.w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
			burning_items += H.w_uniform
		if(H.wear_suit)
			burning_items += H.wear_suit

		//ARMS & HANDS//
		var/obj/item/clothing/arm_clothes = null
		if(H.gloves && !(obscured & ITEM_SLOT_GLOVES))
			arm_clothes = H.gloves
		else if(H.wear_suit && ((H.wear_suit.body_parts_covered & HANDS) || (H.wear_suit.body_parts_covered & ARMS)))
			arm_clothes = H.wear_suit
		else if(H.w_uniform && ((H.w_uniform.body_parts_covered & HANDS) || (H.w_uniform.body_parts_covered & ARMS)))
			arm_clothes = H.w_uniform
		if(arm_clothes)
			burning_items |= arm_clothes

		//LEGS & FEET//
		var/obj/item/clothing/leg_clothes = null
		if(H.shoes && !(obscured & ITEM_SLOT_FEET))
			leg_clothes = H.shoes
		else if(H.wear_suit && ((H.wear_suit.body_parts_covered & FEET) || (H.wear_suit.body_parts_covered & LEGS)))
			leg_clothes = H.wear_suit
		else if(H.w_uniform && ((H.w_uniform.body_parts_covered & FEET) || (H.w_uniform.body_parts_covered & LEGS)))
			leg_clothes = H.w_uniform
		if(leg_clothes)
			burning_items |= leg_clothes

		for(var/obj/item/I as() in burning_items)
			I.fire_act((H.fire_stacks * 50)) //damage taken is reduced to 2% of this value by fire_act()

		var/thermal_protection = H.get_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
			H.adjust_bodytemperature(5.5 * delta_time)
		else
			H.adjust_bodytemperature((BODYTEMP_HEATING_MAX + (H.fire_stacks * 12)) * 0.5 * delta_time)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)

/datum/species/proc/CanIgniteMob(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return FALSE
	return TRUE

/datum/species/proc/ExtinguishMob(mob/living/carbon/human/H)
	return

/datum/species/proc/spec_revival(mob/living/carbon/human/H)
	return


////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	var/obj/item/organ/wings/wings = H.getorganslot(ORGAN_SLOT_WINGS)
	if(H.getorgan(/obj/item/organ/wings))
		if(wings.flight_level >= WINGS_FLYING && H.movement_type & FLYING)
			flyslip(H)
	. = max(stunmod + H.physiology.stun_add, 0) * H.physiology.stun_mod * amount

//////////////
//Space Move//
//////////////

/datum/species/proc/space_move(mob/living/carbon/human/H)
	if(H.loc && !isspaceturf(H.loc) && H.getorgan(/obj/item/organ/wings))
		var/obj/item/organ/wings/wings = H.getorganslot(ORGAN_SLOT_WINGS)
		if(wings.flight_level == WINGS_FLIGHTLESS)
			var/datum/gas_mixture/current = H.loc.return_air()
			if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
				return TRUE
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

////////////////
//Tail Wagging//
////////////////

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)
	var/obj/item/organ/tail/tail = H?.getorganslot(ORGAN_SLOT_TAIL)
	tail?.set_wagging(H, FALSE)

///////////////
//FLIGHT SHIT//
///////////////

/datum/species/proc/handle_flight(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		if(!CanFly(H))
			toggle_flight(H)
			return FALSE
		return TRUE
	else
		return FALSE

/datum/species/proc/CanFly(mob/living/carbon/human/H)
	var/obj/item/organ/wings/wings = H.getorganslot(ORGAN_SLOT_WINGS)
	if(!H.getorgan(/obj/item/organ/wings))
		return FALSE
	if(H.stat || H.body_position == LYING_DOWN)
		return FALSE
	var/turf/T = get_turf(H)
	if(!T)
		return FALSE
	if(ismoth(H) && HAS_TRAIT(H, TRAIT_MOTH_BURNT))
		return FALSE
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && !(environment.return_pressure() > 30) && wings.flight_level <= WINGS_FLYING)
		to_chat(H, span_warning("The atmosphere is too thin for you to fly!"))
		return FALSE
	else
		return TRUE

/datum/species/proc/flyslip(mob/living/carbon/human/H)
	var/obj/buckled_obj
	if(H.buckled)
		buckled_obj = H.buckled

	to_chat(H, span_notice("Your wings spazz out and launch you!"))

	for(var/obj/item/I in H.held_items)
		H.accident(I)

	var/olddir = H.dir

	H.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(H)
		step(buckled_obj, olddir)
	else
		new /datum/forced_movement(H, get_ranged_target_turf(H, olddir, 4), 1, FALSE, CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon, spin), 1, 1))
	return TRUE

//UNSAFE PROC, should only be called through the Activate or other sources that check for CanFly
/datum/species/proc/toggle_flight(mob/living/carbon/human/H)
	if(!HAS_TRAIT_FROM(H, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT))
		stunmod *= 2
		speedmod -= 0.35
		ADD_TRAIT(H, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT)
		H.pass_flags |= PASSTABLE
		if((H.dna.species.mutant_bodyparts["wings"]) || (H.dna.species.mutant_bodyparts["moth_wings"]))
			H.Togglewings()
	else
		stunmod *= 0.5
		speedmod += 0.35
		REMOVE_TRAIT(H, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT)
		H.pass_flags &= ~PASSTABLE
		if((H.dna.species.mutant_bodyparts["wingsopen"]) || (H.dna.species.mutant_bodyparts["moth_wingsopen"]))
			H.Togglewings()
		if(isturf(H.loc))
			var/turf/T = H.loc
			T.Entered(H)
	H.refresh_gravity()

///Calls the DMI data for a custom icon for a given bodypart from the Species Datum.
/datum/species/proc/get_custom_icons(var/part)
	return
/*Here's what a species that has a unique icon for every slot would look like. If your species doesnt have any custom icons for a given part, return null.
/datum/species/teshari/get_custom_icons(var/part)
	switch(part)
		if("uniform")
			return 'icons/mob/species/teshari/tesh_uniforms.dmi'
		if("gloves")
			return 'icons/mob/species/teshari/tesh_gloves.dmi'
		if("glasses")
			return 'icons/mob/species/teshari/tesh_glasses.dmi'
		if("ears")
			return 'icons/mob/species/teshari/tesh_ears.dmi'
		if("shoes")
			return 'icons/mob/species/teshari/tesh_shoes.dmi'
		if("head")
			return 'icons/mob/species/teshari/tesh_head.dmi'
		if("belt")
			return 'icons/mob/species/teshari/tesh_belts.dmi'
		if("suit")
			return 'icons/mob/species/teshari/tesh_suits.dmi'
		if("mask")
			return 'icons/mob/species/teshari/tesh_masks.dmi'
		if("back")
			return 'icons/mob/species/teshari/tesh_back.dmi'
		if("generic")
			return 'icons/mob/species/teshari/tesh_generic.dmi'
		else
			return
*/

/datum/species/proc/get_item_offsets_for_index(i)
	return

/datum/species/proc/get_harm_descriptors()
	return

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
/// Should only need to override if the feature is not attached to a mutant bodypart or trait
/datum/species/proc/get_features()
	var/cached_features = GLOB.features_by_species[type]
	if (!isnull(cached_features))
		return cached_features

	var/list/features = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]

		if ( \
			(preference.relevant_mutant_bodypart in mutant_bodyparts) \
			|| (preference.relevant_species_trait in species_traits) \
		)
			features += preference.db_key

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
	if(TRAIT_NOHUNGER in inherent_traits)
		return null

	var/list/food_flags = FOOD_FLAGS

	return list(
		"liked_food" = bitfield_to_list(initial(mutanttongue.liked_food), food_flags),
		"disliked_food" = bitfield_to_list(initial(mutanttongue.disliked_food), food_flags),
		"toxic_food" = bitfield_to_list(initial(mutanttongue.toxic_food), food_flags),
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
	species_perks += create_pref_combat_perks()
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
 * Adds adds any perks related to combat.
 * For example, the damage type of their punches.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_combat_perks()
	var/list/to_add = list()

	if(attack_type != BRUTE)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Elemental Attacker",
			SPECIES_PERK_DESC = "[plural_form] deal [attack_type] damage with their punches instead of brute.",
		))

	return to_add

/**
 * Adds adds any perks related to sustaining damage.
 * For example, brute damage vulnerability, or fire damage resistance.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_damage_perks()
	var/list/to_add = list()

	// Brute related
	if(brutemod > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Brutal Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to brute damage.",
		))
	else if(brutemod < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Brutal Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to bruising and brute damage.",
		))

	// Burn related
	if(burnmod > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Fire Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to fire and burn damage.",
		))
	else if(burnmod < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Fire Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to flames, and burn damage.",
		))

	if(TRAIT_SHOCKIMMUNE in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shock Immune",
			SPECIES_PERK_DESC = "[plural_form] are entirely resistant to electrical shocks.",
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

	// NOBLOOD takes priority by default
	if(NOBLOOD in species_traits)
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

	return to_add

/**
 * Adds adds any perks related to the species' inherent_biotypes flags.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_biotypes_perks()
	var/list/to_add = list()

	if(MOB_UNDEAD in inherent_biotypes)
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

	// Grab galactic common as a path, for comparisons
	var/datum/language/common_language = /datum/language/common

	// Now let's find all the languages they can speak that aren't common
	var/list/bonus_languages = list()
	var/datum/language_holder/basic_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/datum/language/language_type as anything in basic_holder.spoken_languages)
		if(ispath(language_type, common_language))
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

/datum/species/proc/get_types_to_preload()
	var/list/to_store = list()
	to_store += mutant_organs
	//for(var/obj/item/organ/external/horny as anything in external_organs)
	//	to_store += horny //Haha get it?

	//Don't preload brains, cause reuse becomes a horrible headache
	to_store += mutantheart
	to_store += mutantlungs
	to_store += mutanteyes
	to_store += mutantears
	to_store += mutanttongue
	to_store += mutantliver
	to_store += mutantstomach
	to_store += mutantappendix
	//Store wings for now...
	to_store += mutantwings
	//We don't cache mutant hands because it's not constrained enough, too high a potential for failure
	return to_store
