// This code handles different species in the game.

GLOBAL_LIST_EMPTY(roundstart_races)

/datum/species
	// if the game needs to manually check your race to do something not included in a proc here, it will use this
	var/id
	// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	var/name

//COSEMETIC-------------------------------------------------
	// whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows
	var/sexes = 1
	// if alien colors are disabled, this is the color that will be used by that race
	var/default_color = "#FFF"
	//The maximum number of bodyparts this species can have.
	var/max_bodypart_count = 6
	// this allows races to have specific hair colors... if null, it uses the human_host's hair/facial hair colors. if "mutcolor", it uses the human_host's mutant_color
	var/hair_color
	// the alpha used by the hair. 255 is completely solid, 0 is transparent.
	var/hair_alpha = 255
	// if you use Dyncolor and are not ethereal, use this
	var/dyncolor = ""
	// If your race wants to bleed something other than bog standard blood, change this to reagent id.
	var/exotic_blood = ""
	//If your race uses a non standard bloodtype (A+, O-, AB-, etc)
	var/exotic_bloodtype = ""
	//the skin tone list to pull from
	var/skin_tone_list = "human" //monkestation edit: add species specific skin tones - defaults to human
	//alternate eye directory
	var/alt_eye //monkestation edit: add simians
	//to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]
	var/fixed_mut_color = ""
	//Blood color for decals
	var/blood_color // this may become un-needed we should be able to read the color of the reagent
	/// does it use skintones or not? (spoiler alert this is only used by humans)
	var/use_skintones = FALSE
//----------------------------------------------------------

//LISTS-----------------------------------------------------
	// what are the offsets of where things should be placed
	var/list/offset_features = list(
		OFFSET_UNIFORM = list(0,0),
		OFFSET_ID = list(0,0),
		OFFSET_GLOVES = list(0,0),
		OFFSET_GLASSES = list(0,0),
		OFFSET_EARS = list(0,0),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,0),
		OFFSET_FACEMASK = list(0,0),
		OFFSET_HEAD = list(0,0),
		OFFSET_FACE = list(0,0),
		OFFSET_BELT = list(0,0),
		OFFSET_BACK = list(0,0),
		OFFSET_SUIT = list(0,0),
		OFFSET_NECK = list(0,0),
		OFFSET_RIGHT_HAND = list(0,0),
		OFFSET_LEFT_HAND = list(0,0))
	// slots the race can't equip stuff to
	var/list/no_equip = list()
	// Default mutant bodyparts for this species. Don't forget to set one for every mutant bodypart you allow this species to have.
	var/list/default_features = list("body_size" = "Normal")
	// A list of features forced on characters
	var/list/forced_features = list()
	// Visible CURRENT bodyparts that are unique to a species. DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK SHIT UP! Changes to this list for non-species specific bodyparts (ie cat ears and tails) should be assigned at organ level if possible. Layer hiding is handled by handle_mutant_bodyparts() below.
	var/list/mutant_bodyparts = list()
	//Internal organs that are unique to this race.
	var/list/mutant_organs = list()
	// species-only traits. Can be found in DNA.dm
	var/list/species_traits = list()
	// generic traits tied to having the species
	var/list/inherent_traits = list()
	// the biotypes tied to having the species
	var/list/inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions
//----------------------------------------------------------

//COMBAT----------------------------------------------------
	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/speedmod = 0
	// overall defense for the race... or less defense, if it's negative.
	var/armor = 0
	// multiplier for brute damage
	var/brutemod = 1
	// multiplier for burn damage
	var/burnmod = 1
	// multiplier for cold damage
	var/coldmod = 1
	// multiplier for heat damage
	var/heatmod = 1
	// multiplier for stamina damage
	var/stunmod = 1
	// multiplier for oxyegen damage
	var/oxymod = 1
	// multiplier for celluar damage
	var/clonemod = 1
	// multiplier for toxin damage
	var/toxmod = 1
	// multiplier for stun duration
	var/staminamod = 1
	//multiplier for overriding max health
	var/maxhealthmod = 1
	//Type of damage attack does
	var/attack_type = BRUTE
	//highest possible punch damage
	var/punchdamage = 7
	//base electrocution coefficient
	var/siemens_coeff = 1
//----------------------------------------------------------

//FLAGS-----------------------------------------------------
	//Bitflag that controls what in game ways can select this species as a spawnable source
	//Think magic mirror and pride mirror, slime extract, ERT etc, see defines
	//in __DEFINES/mobs.dm, defaults to NONE, so people actually have to think about it
	var/changesource_flags = NONE

	//bitflags of what types of food you like
	var/liked_food = NONE
	//bitflags of what types of food you dislike
	var/disliked_food = GROSS
	//bitflags of what types of food is toxic to you
	var/toxic_food = TOXIC
	//Species flags currently used for species restriction on items
	var/bodyflag = FLAG_HUMAN
	// the body type of the species
	var/bodytype = BODYTYPE_HUMANOID
//----------------------------------------------------------

//SOUND AND TEXT--------------------------------------------
	//This is used for children, felinids and ashwalkers namely
	var/examine_limb_id
	// affects the speech message
	var/say_mod = "says"
	//the language holder of the host
	var/species_language_holder = /datum/language_holder
	//used to set the mobs deathsound on species change
	var/deathsound
	//Sounds to override barefeet walkng
	var/list/special_step_sounds
	//Special sound for grabbing
	var/grab_sound

	// the verb used when attacked
	var/attack_verb = "punch"
	// sound that follows a successful attack
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	// sound that follows an unsuccessful attack
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'
//----------------------------------------------------------

//SPECIAL SPECIES VARIABLES---------------------------------
	//Never, Optional, or Forced digi legs?
	var/digitigrade_customization = DIGITIGRADE_NEVER
	// Can this species use numbers in its name?
	var/allow_numbers_in_name
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life
	//the actual flying ability given to flying species
	var/datum/action/innate/flight/fly

//----------------------------------------------------------

//ORGAN and BODYPARTS---------------------------------------
	var/obj/item/organ/lungs/mutantlungs = null
	var/breathid = "o2"

	var/obj/item/organ/brain/mutant_brain = /obj/item/organ/brain
	var/obj/item/organ/heart/mutant_heart = /obj/item/organ/heart
	var/obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	var/obj/item/mutanthands
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	var/obj/item/organ/tail/mutanttail = null
	var/obj/item/organ/wings/mutantwings = null

	var/obj/item/organ/liver/mutantliver
	var/obj/item/organ/stomach/mutantstomach
	var/override_float = FALSE

	//K-Limbs. If a species doesn't have their own limb types. Do not override this, use the K-Limbs overrides at the top of the species datum.
	var/obj/item/bodypart/species_chest = /obj/item/bodypart/chest
	var/obj/item/bodypart/species_head = /obj/item/bodypart/head
	var/obj/item/bodypart/species_l_arm = /obj/item/bodypart/l_arm
	var/obj/item/bodypart/species_r_arm = /obj/item/bodypart/r_arm
	var/obj/item/bodypart/species_r_leg = /obj/item/bodypart/r_leg
	var/obj/item/bodypart/species_l_leg = /obj/item/bodypart/l_leg
//----------------------------------------------------------

	//What the species drops on gibbing
	var/meat = /obj/item/reagent_containers/food/snacks/meat/slab/human
	//what the skin type is when butchered
	var/skinned_type
	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/nojumpsuit = FALSE
	//special mutation that can be found in the genepool. Dont leave empty or changing species will be a headache
	var/inert_mutation 	= DWARFISM
	//Used for metabolizing reagents. We're going to assume you're a meatbag unless you say otherwise.
	var/reagent_tag = PROCESS_ORGANIC
	//by default human gibs are used
	var/species_gibs = GIB_TYPE_HUMAN
	//The component to add when swimming
	var/swimming_component = /datum/component/swimming


	/// if false, having no tongue makes you unable to speak
	var/speak_no_tongue = TRUE

///////////
// PROCS //
///////////


/proc/generate_selectable_species()
	for(var/I in subtypesof(/datum/species))
		var/datum/species/S = new I
		if(S.check_roundstart_eligible())
			GLOB.roundstart_races += S.id
			qdel(S)
	if(!GLOB.roundstart_races.len)
		GLOB.roundstart_races += "human"

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

//Please override this locally if you want to define when what species qualifies for what rank if human authority is enforced.
/datum/species/proc/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.command_positions)
		return 0
	return 1

//Will regenerate missing organs
/datum/species/proc/regenerate_organs(mob/living/carbon/C,datum/species/old_species,replace_current=TRUE)
	var/obj/item/organ/brain/brain = C.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/lungs = C.getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX)
	var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
	var/obj/item/organ/tongue/tongue = C.getorganslot(ORGAN_SLOT_TONGUE)
	var/obj/item/organ/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
	var/obj/item/organ/stomach/stomach = C.getorganslot(ORGAN_SLOT_STOMACH)
	var/obj/item/organ/tail/tail = C.getorganslot(ORGAN_SLOT_TAIL)
	var/obj/item/organ/wings/wings = C.getorganslot(ORGAN_SLOT_WINGS)

	var/should_have_brain = TRUE
	var/should_have_heart = !(NOBLOOD in species_traits)
	var/should_have_lungs = !(TRAIT_NOBREATH in inherent_traits)
	var/should_have_appendix = !((TRAIT_NOHUNGER in inherent_traits) || (TRAIT_POWERHUNGRY in inherent_traits))
	var/should_have_eyes = TRUE
	var/should_have_ears = TRUE
	var/should_have_tongue = TRUE
	var/should_have_liver = !(TRAIT_NOMETABOLISM in inherent_traits)
	var/should_have_stomach = !(NOSTOMACH in species_traits)
	var/should_have_tail = mutanttail
	var/should_have_wings = mutantwings

	if(heart && (!should_have_heart || replace_current))
		heart.Remove(C,1)
		QDEL_NULL(heart)
	if(should_have_heart && !heart)
		heart = new mutant_heart()
		heart.Insert(C)

	if(lungs && (!should_have_lungs || replace_current))
		lungs.Remove(C,1)
		QDEL_NULL(lungs)
	if(should_have_lungs && !lungs)
		if(mutantlungs)
			lungs = new mutantlungs()
		else
			lungs = new()
		lungs.Insert(C)

	if(liver && (!should_have_liver || replace_current))
		liver.Remove(C,1)
		QDEL_NULL(liver)
	if(should_have_liver && !liver)
		if(mutantliver)
			liver = new mutantliver()
		else
			liver = new()
		liver.Insert(C)

	if(stomach && (!should_have_stomach || replace_current))
		stomach.Remove(C,1)
		QDEL_NULL(stomach)
	if(should_have_stomach && !stomach)
		if(mutantstomach)
			stomach = new mutantstomach()
		else
			stomach = new()
		stomach.Insert(C)

	if(appendix && (!should_have_appendix || replace_current))
		appendix.Remove(C,1)
		QDEL_NULL(appendix)
	if(should_have_appendix && !appendix)
		appendix = new()
		appendix.Insert(C)

	if(tail && (!should_have_tail || replace_current))
		tail.Remove(C,1)
		QDEL_NULL(tail)
	if(should_have_tail && !tail)
		tail = new mutanttail()
		tail.Insert(C)

	if(wings && (!should_have_wings || replace_current))
		wings.Remove(C,1)
		QDEL_NULL(wings)
	if(should_have_wings && !wings)
		wings = new mutantwings()
		wings.Insert(C)

	if(C.get_bodypart(BODY_ZONE_HEAD))
		if(brain && (replace_current || !should_have_brain))
			if(!brain.decoy_override)//Just keep it if it's fake
				brain.Remove(C,TRUE,TRUE)
				QDEL_NULL(brain)
		if(should_have_brain && !brain)
			brain = new mutant_brain()
			brain.Insert(C, TRUE, TRUE)

		if(eyes && (replace_current || !should_have_eyes))
			eyes.Remove(C,1)
			QDEL_NULL(eyes)
		if(should_have_eyes && !eyes)
			eyes = new mutanteyes
			eyes.Insert(C)

		if(ears && (replace_current || !should_have_ears))
			ears.Remove(C,1)
			QDEL_NULL(ears)
		if(should_have_ears && !ears)
			ears = new mutantears
			ears.Insert(C)

		if(tongue && (replace_current || !should_have_tongue))
			tongue.Remove(C,1)
			QDEL_NULL(tongue)
		if(should_have_tongue && !tongue)
			tongue = new mutanttongue
			tongue.Insert(C)

	if(old_species)
		for(var/mutantorgan in old_species.mutant_organs)
			var/obj/item/organ/I = C.getorgan(mutantorgan)
			if(I)
				I.Remove(C)
				QDEL_NULL(I)

	for(var/path in mutant_organs)
		var/obj/item/organ/I = new path()
		I.Insert(C)

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
				new_part.replace_limb(C, TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_CHEST)
				var/obj/item/bodypart/chest/new_part = new new_species.species_chest()
				new_part.replace_limb(C, TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_L_ARM)
				var/obj/item/bodypart/l_arm/new_part = new new_species.species_l_arm()
				new_part.replace_limb(C, TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_R_ARM)
				var/obj/item/bodypart/r_arm/new_part = new new_species.species_r_arm()
				new_part.replace_limb(C, TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_L_LEG)
				var/obj/item/bodypart/l_leg/new_part = new new_species.species_l_leg()
				new_part.replace_limb(C, TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)
			if(BODY_ZONE_R_LEG)
				var/obj/item/bodypart/r_leg/new_part = new new_species.species_r_leg()
				new_part.replace_limb(C, TRUE)
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

	regenerate_organs(C,old_species)

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
				C.put_in_hands(new mutanthands())

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

	C.add_movespeed_modifier(MOVESPEED_ID_SPECIES, TRUE, 100, override=TRUE, multiplicative_slowdown=speedmod, movetypes=(~FLYING))

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
	C.remove_movespeed_modifier(MOVESPEED_ID_SPECIES)
	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

/datum/species/proc/handle_hair(mob/living/carbon/human/human_host, forced_colour)
	human_host.remove_overlay(HAIR_LAYER)
	var/obj/item/bodypart/head/HD = human_host.get_bodypart(BODY_ZONE_HEAD)
	if(!HD) //Decapitated
		return

	if(HAS_TRAIT(human_host, TRAIT_HUSK))
		return
	var/datum/sprite_accessory/S
	var/list/standing = list()

	var/hair_hidden = FALSE //ignored if the matching dynamic_X_suffix is non-empty
	var/facialhair_hidden = FALSE // ^

	var/dynamic_hair_suffix = "" //if this is non-null, and hair+suffix matches an iconstate, then we render that hair instead
	var/dynamic_fhair_suffix = ""

	//for augmented heads
	if(!IS_ORGANIC_LIMB(HD))
		return

	//we check if our hat or helmet hides our facial hair.
	if(human_host.head)
		var/obj/item/I = human_host.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(human_host.wear_mask)
		var/obj/item/clothing/mask/M = human_host.wear_mask
		dynamic_fhair_suffix = M.dynamic_fhair_suffix //mask > head in terms of facial hair
		if(M.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(human_host.facial_hair_style && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hair_styles_list[human_host.facial_hair_style]
		if(S)

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

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, -HAIR_LAYER)

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						facial_overlay.color = "#" + human_host.dna.features["mcolor"]
					else if (hair_color =="fixedmutcolor")
						facial_overlay.color = "#[fixed_mut_color]"
					else
						facial_overlay.color = "#" + hair_color
				else
					facial_overlay.color = "#" + human_host.facial_hair_color
			else
				facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha

			standing += facial_overlay

	if(human_host.head)
		var/obj/item/I = human_host.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(human_host.wear_mask)
		var/obj/item/clothing/mask/M = human_host.wear_mask
		if(!dynamic_hair_suffix) //head > mask in terms of head hair
			dynamic_hair_suffix = M.dynamic_hair_suffix
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(!hair_hidden || dynamic_hair_suffix)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = -HAIR_LAYER)
		var/mutable_appearance/gradient_overlay = mutable_appearance(layer = -HAIR_LAYER)
		if(!hair_hidden && !human_host.getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			if(!(NOBLOOD in species_traits))
				hair_overlay.icon = 'icons/mob/human_face.dmi'
				hair_overlay.icon_state = "debrained"

		else if(human_host.hair_style && (HAIR in species_traits))
			S = GLOB.hair_styles_list[human_host.hair_style]
			if(S)

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
							hair_overlay.color = "#" + human_host.dna.features["mcolor"]
						else if(hair_color == "fixedmutcolor")
							hair_overlay.color = "#[fixed_mut_color]"
						else
							hair_overlay.color = "#" + hair_color
					else
						hair_overlay.color = "#" + human_host.hair_color

					//Gradients
					var/gradient_style = human_host.gradient_style
					var/gradient_color = human_host.gradient_color
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
				if(OFFSET_FACE in human_host.dna.species.offset_features)
					hair_overlay.pixel_x += human_host.dna.species.offset_features[OFFSET_FACE][1]
					hair_overlay.pixel_y += human_host.dna.species.offset_features[OFFSET_FACE][2]
		if(hair_overlay.icon)
			standing += hair_overlay
			standing += gradient_overlay

	if(standing.len)
		human_host.overlays_standing[HAIR_LAYER] = standing

	human_host.apply_overlay(HAIR_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/human_host)
	human_host.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	var/obj/item/bodypart/head/HD = human_host.get_bodypart(BODY_ZONE_HEAD)

	if(HD && !(HAS_TRAIT(human_host, TRAIT_HUSK)))
		// lipstick
		if(human_host.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[human_host.lip_style]", -BODY_LAYER)
			lip_overlay.color = human_host.lip_color
			if(OFFSET_FACE in human_host.dna.species.offset_features)
				lip_overlay.pixel_x += human_host.dna.species.offset_features[OFFSET_FACE][1]
				lip_overlay.pixel_y += human_host.dna.species.offset_features[OFFSET_FACE][2]
			standing += lip_overlay

		// eyes
		if(!(NOEYESPRITES in species_traits))
			var/obj/item/organ/eyes/E = human_host.getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			if(!E)
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
			else
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', E.eye_icon_state, -BODY_LAYER)
			if((EYECOLOR in species_traits) && E)
				eye_overlay.color = "#" + human_host.eye_color
			if(OFFSET_FACE in human_host.dna.species.offset_features)
				eye_overlay.pixel_x += human_host.dna.species.offset_features[OFFSET_FACE][1]
				eye_overlay.pixel_y += human_host.dna.species.offset_features[OFFSET_FACE][2]
			standing += eye_overlay

	//Underwear, Undershirts & Socks
	if(!(NO_UNDERWEAR in species_traits))
		if(human_host.underwear && !(human_host.dna.species.bodytype & BODYTYPE_DIGITIGRADE))
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[human_host.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				if(human_host.dna.species.sexes && human_host.gender == FEMALE && (underwear.gender == MALE))
					underwear_overlay = wear_female_version(underwear.icon_state, underwear.icon, BODY_LAYER, FEMALE_UNIFORM_FULL)
				else
					underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)
				if(!underwear.use_static)
					underwear_overlay.color = "#" + human_host.underwear_color
				standing += underwear_overlay

		if(human_host.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[human_host.undershirt]
			if(undershirt)
				if(human_host.dna.species.sexes && human_host.gender == FEMALE)
					standing += wear_female_version(undershirt.icon_state, undershirt.icon, BODY_LAYER)
				else
					standing += mutable_appearance(undershirt.icon, undershirt.icon_state, -BODY_LAYER)

		if(human_host.socks && human_host.get_num_legs(FALSE) >= 2 && !(human_host.dna.species.bodytype & BODYTYPE_DIGITIGRADE) && !(NOSOCKS in species_traits))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[human_host.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)

	if(standing.len)
		human_host.overlays_standing[BODY_LAYER] = standing

	human_host.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(human_host)

/*This proc seems wildly ineffecient and can be done way nicer in the future but basically
* it runs through all the mutant parts possible and starts to remove ones you don't have
* this leaves you with a list of all mutant bodyparts we possess and should be worried about.
*/
/datum/species/proc/handle_mutant_bodylist(mob/living/carbon/human/human_host)
	//create a copy of all mutant_bodyparts so we can remove useless ones
	var/list/list_of_bodyparts = mutant_bodyparts.Copy()
	// the head object from the host used to check if its covered later
	var/obj/item/bodypart/head/HD = human_host.get_bodypart(BODY_ZONE_HEAD)

	//TAILS - these need custom code for now can probably remove that later but uh -Borbop
	if("tail_lizard" in mutant_bodyparts)
		if(human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "tail_lizard"

	if("waggingtail_lizard" in mutant_bodyparts)
		if(human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "waggingtail_lizard"
		else if ("tail_lizard" in mutant_bodyparts)
			list_of_bodyparts -= "waggingtail_lizard"

	if("tail_human" in mutant_bodyparts)
		if(human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "tail_human"

	if("waggingtail_human" in mutant_bodyparts)
		if(human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "waggingtail_human"
		else if ("tail_human" in mutant_bodyparts)
			list_of_bodyparts -= "waggingtail_human"
	if("spines" in mutant_bodyparts)
		if(!human_host.dna.features["spines"] || human_host.dna.features["spines"] == "None" || human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "spines"

	if("waggingspines" in mutant_bodyparts)
		if(!human_host.dna.features["spines"] || human_host.dna.features["spines"] == "None" || human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "waggingspines"
		else if ("tail" in mutant_bodyparts)
			list_of_bodyparts -= "waggingspines"

	if("snout" in mutant_bodyparts) //Take a closer look at that snout!
		if((human_host.wear_mask?.flags_inv & HIDEFACE) || (human_host.head?.flags_inv & HIDEFACE) || !HD)
			list_of_bodyparts -= "snout"

	if("frills" in mutant_bodyparts)
		if(!human_host.dna.features["frills"] || human_host.dna.features["frills"] == "None" || (human_host.head?.flags_inv & HIDEEARS) || !HD)
			list_of_bodyparts -= "frills"

	if("horns" in mutant_bodyparts)
		if(!human_host.dna.features["horns"] || human_host.dna.features["horns"] == "None" || human_host.head && (human_host.head.flags_inv & HIDEHAIR) || (human_host.wear_mask && (human_host.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			list_of_bodyparts -= "horns"

	if("ears" in mutant_bodyparts)
		if(!human_host.dna.features["ears"] || human_host.dna.features["ears"] == "None" || human_host.head && (human_host.head.flags_inv & HIDEHAIR) || (human_host.wear_mask && (human_host.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			list_of_bodyparts -= "ears"

	if("wings" in mutant_bodyparts)
		if(!human_host.dna.features["wings"] || human_host.dna.features["wings"] == "None" || (human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT) && (!human_host.wear_suit.species_exception || !is_type_in_list(src, human_host.wear_suit.species_exception))))
			list_of_bodyparts -= "wings"

	if("wings_open" in mutant_bodyparts)
		if(human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT) && (!human_host.wear_suit.species_exception || !is_type_in_list(src, human_host.wear_suit.species_exception)))
			list_of_bodyparts -= "wings_open"
		else if ("wings" in mutant_bodyparts)
			list_of_bodyparts -= "wings_open"

	if("ipc_screen" in mutant_bodyparts)
		if(!human_host.dna.features["ipc_screen"] || human_host.dna.features["ipc_screen"] == "None" || (human_host.wear_mask && (human_host.wear_mask.flags_inv & HIDEEYES)) || !HD)
			list_of_bodyparts -= "ipc_screen"

	if("ipc_antenna" in mutant_bodyparts)
		if(!human_host.dna.features["ipc_antenna"] || human_host.dna.features["ipc_antenna"] == "None" || human_host.head && (human_host.head.flags_inv & HIDEHAIR) || (human_host.wear_mask && (human_host.wear_mask.flags_inv & HIDEHAIR)) || !HD)
			list_of_bodyparts -= "ipc_antenna"

	//monkestation edit: add simian species
	if("tail_monkey" in mutant_bodyparts)
		if(human_host.wear_suit && (human_host.wear_suit.flags_inv & HIDEJUMPSUIT))
			list_of_bodyparts -= "tail_monkey"

	return list_of_bodyparts

/datum/species/proc/grab_sprite_accessory(bodypart, mob/living/carbon/human/human_host)
	var/datum/sprite_accessory/accessory_type

	switch(bodypart)
		if("tail_lizard")
			accessory_type = GLOB.tails_list_lizard[human_host.dna.features["tail_lizard"]]
		if("waggingtail_lizard")
			accessory_type = GLOB.animated_tails_list_lizard[human_host.dna.features["tail_lizard"]]
		if("tail_human")
			accessory_type = GLOB.tails_list_human[human_host.dna.features["tail_human"]]
		if("waggingtail_human")
			accessory_type = GLOB.animated_tails_list_human[human_host.dna.features["tail_human"]]
		if("spines")
			accessory_type = GLOB.spines_list[human_host.dna.features["spines"]]
		if("waggingspines")
			accessory_type = GLOB.animated_spines_list[human_host.dna.features["spines"]]
		if("snout")
			accessory_type = GLOB.snouts_list[human_host.dna.features["snout"]]
		if("frills")
			accessory_type = GLOB.frills_list[human_host.dna.features["frills"]]
		if("horns")
			accessory_type = GLOB.horns_list[human_host.dna.features["horns"]]
		if("ears")
			accessory_type = GLOB.ears_list[human_host.dna.features["ears"]]
		if("body_markings")
			accessory_type = GLOB.body_markings_list[human_host.dna.features["body_markings"]]
		if("wings")
			accessory_type = GLOB.wings_list[human_host.dna.features["wings"]]
		if("wingsopen")
			accessory_type = GLOB.wings_open_list[human_host.dna.features["wings"]]
		if("legs")
			accessory_type = GLOB.legs_list[human_host.dna.features["legs"]]
		if("moth_wings")
			accessory_type = GLOB.moth_wings_list[human_host.dna.features["moth_wings"]]
		if("moth_wingsopen")
			accessory_type = GLOB.moth_wingsopen_list[human_host.dna.features["moth_wings"]]
		if("caps")
			accessory_type = GLOB.caps_list[human_host.dna.features["caps"]]
		if("ipc_screen")
			accessory_type = GLOB.ipc_screens_list[human_host.dna.features["ipc_screen"]]
		if("ipc_antenna")
			accessory_type = GLOB.ipc_antennas_list[human_host.dna.features["ipc_antenna"]]
		if("ipc_chassis")
			accessory_type = GLOB.ipc_chassis_list[human_host.dna.features["ipc_chassis"]]
		if("insect_type")
			accessory_type = GLOB.insect_type_list[human_host.dna.features["insect_type"]]

	return accessory_type

//monkestation edit end
/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/human_host, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing	= list()

	human_host.remove_overlay(BODY_BEHIND_LAYER)
	human_host.remove_overlay(BODY_ADJ_LAYER)
	human_host.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts)
		return

	// off loading this to a secondary proc for easier reading of the code
	bodyparts_to_add = handle_mutant_bodylist(human_host)

	////PUT ALL YOUR WEIRD ASS REAL-LIMB HANDLING HERE
	///Digi handling
	if(human_host.dna.species.bodytype & BODYTYPE_DIGITIGRADE)
		var/uniform_compatible = FALSE
		var/suit_compatible = FALSE
		if(!(human_host.w_uniform) || (human_host.w_uniform.supports_variations & DIGITIGRADE_VARIATION) || (human_host.w_uniform.supports_variations & DIGITIGRADE_VARIATION_NO_NEW_ICON)) //Checks uniform compatibility
			uniform_compatible = TRUE
		if((!human_host.wear_suit) || (human_host.wear_suit.supports_variations & DIGITIGRADE_VARIATION) || !(human_host.wear_suit.body_parts_covered & LEGS) || (human_host.wear_suit.supports_variations & DIGITIGRADE_VARIATION_NO_NEW_ICON)) //Checks suit compatability
			suit_compatible = TRUE

		if((uniform_compatible && suit_compatible) || (suit_compatible && human_host.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
			for(var/obj/item/bodypart/BP as() in human_host.bodyparts)
				if(BP.bodytype & BODYTYPE_DIGITIGRADE)
					BP.limb_id = "digitigrade"

		else
			for(var/obj/item/bodypart/BP as() in human_host.bodyparts)
				if(BP.bodytype & BODYTYPE_DIGITIGRADE)
					BP.limb_id = "lizard"
	///End digi handling


	////END REAL-LIMB HANDLING
	human_host.update_body_parts()


	if(!bodyparts_to_add)
		return

	var/g = (human_host.gender == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/accessory_type
			// another new proc again for code clarity
			accessory_type = grab_sprite_accessory(bodypart, human_host)

			if(!accessory_type || accessory_type.icon_state == "none")
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(accessory_type.icon, layer = -layer)

			//A little rename so we don't have to use tail_lizard or tail_human when naming the sprites.
			if(bodypart == "tail_lizard" || bodypart == "tail_human")
				bodypart = "tail"
			else if(bodypart == "waggingtail_lizard" || bodypart == "waggingtail_human")
				bodypart = "waggingtail"

			if(accessory_type.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[accessory_type.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[accessory_type.icon_state]_[layertext]"

			if(accessory_type.center)
				accessory_overlay = center_image(accessory_overlay, accessory_type.dimension_x, accessory_type.dimension_y)

			if(!(HAS_TRAIT(human_host, TRAIT_HUSK)))
				if(!forced_colour)
					switch(accessory_type.color_src)
						if(MUTCOLORS)
							if(fixed_mut_color)
								accessory_overlay.color = "#[fixed_mut_color]"
							else
								accessory_overlay.color = "#[human_host.dna.features["mcolor"]]"
						if(HAIR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = "#[human_host.dna.features["mcolor"]]"
							else
								accessory_overlay.color = "#[human_host.hair_color]"
						if(FACEHAIR)
							accessory_overlay.color = "#[human_host.facial_hair_color]"
						if(EYECOLOR)
							accessory_overlay.color = "#[human_host.eye_color]"
				else
					accessory_overlay.color = forced_colour
			if(istype(accessory_type, /datum/sprite_accessory/body_markings))
				accessory_overlay.color = "#" + human_host.dna.features["bellycolor"]

			standing += accessory_overlay

			if((istype(accessory_type, /datum/sprite_accessory/tails_animated/lizard) || istype(accessory_type, /datum/sprite_accessory/tails/lizard))&& ("body_markings" in mutant_bodyparts)) //can't use inner as this needs to support infinite unique tail types and inner wouldn't allow that
				//quick access for the belly accessory
				var/datum/sprite_accessory/belly_accessory = GLOB.body_markings_list[human_host.dna.features["body_markings"]]
				//variable to store the icon_state for our tail body marking
				var/tail_icon_state = "[belly_accessory.icon_state]_" + accessory_overlay.icon_state


				var/mutable_appearance/tail_body_overlay = mutable_appearance(accessory_type.icon, layer = -layer)
				tail_body_overlay.icon_state = tail_icon_state
				tail_body_overlay.color = "#" + human_host.dna.features["bellycolor"]

				standing += tail_body_overlay

			if(accessory_type.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(accessory_type.icon, layer = -layer)
				if(accessory_type.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[bodypart]inner_[accessory_type.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[bodypart]inner_[accessory_type.icon_state]_[layertext]"

				if(accessory_type.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, accessory_type.dimension_x, accessory_type.dimension_y)

				standing += inner_accessory_overlay

		human_host.overlays_standing[layer] = standing.Copy()
		standing = list()

	human_host.apply_overlay(BODY_BEHIND_LAYER)
	human_host.apply_overlay(BODY_ADJ_LAYER)
	human_host.apply_overlay(BODY_FRONT_LAYER)


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


/datum/species/proc/spec_life(mob/living/carbon/human/human_host)
	if(HAS_TRAIT(human_host, TRAIT_NOBREATH))
		human_host.setOxyLoss(0)
		human_host.losebreath = 0

		var/takes_crit_damage = (!HAS_TRAIT(human_host, TRAIT_NOCRITDAMAGE))
		if((human_host.health <= human_host.crit_threshold) && takes_crit_damage)
			human_host.adjustBruteLoss(1)
	if(human_host.getorgan(/obj/item/organ/wings))
		handle_flight(human_host)

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/human_host)
	return

/datum/species/proc/auto_equip(mob/living/carbon/human/human_host)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/human_host, bypass_equip_delay_self = FALSE)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE
	if(I.species_restricted & human_host.dna?.species.bodyflag)
		to_chat(human_host, "<span class='warning'>Your species cannot wear this item!</span>")
		return FALSE
	var/num_arms = human_host.get_num_arms(FALSE)
	var/num_legs = human_host.get_num_legs(FALSE)

	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(human_host.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(human_host.wear_mask)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MASK))
				return FALSE
			if(!human_host.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_NECK)
			if(human_host.wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACK)
			if(human_host.back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_OCLOTHING)
			if(human_host.wear_suit)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_OCLOTHING) )
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_GLOVES)
			if(human_host.gloves)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_GLOVES) )
				return FALSE
			if(num_arms < 2)
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(human_host.shoes)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_FEET) )
				return FALSE
			if(num_legs < 2)
				return FALSE
			if((bodytype & BODYTYPE_DIGITIGRADE) && !(I.supports_variations & DIGITIGRADE_VARIATION))
				if(!disable_warning)
					to_chat(human_host, "<span class='warning'>The footwear around here isn't compatible with your feet!</span>")
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			if(human_host.belt)
				return FALSE

			var/obj/item/bodypart/O = human_host.get_bodypart(BODY_ZONE_CHEST)

			if(!human_host.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(human_host, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(human_host.glasses)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EYES))
				return FALSE
			if(!human_host.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/eyes/E = human_host.getorganslot(ORGAN_SLOT_EYES)
			if(E?.no_glasses)
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_HEAD)
			if(human_host.head)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HEAD))
				return FALSE
			if(!human_host.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_EARS)
			if(human_host.ears)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EARS))
				return FALSE
			if(!human_host.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_ICLOTHING)
			if(human_host.w_uniform)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ICLOTHING) )
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_ID)
			if(human_host.wear_id)
				return FALSE

			var/obj/item/bodypart/O = human_host.get_bodypart(BODY_ZONE_CHEST)
			if(!human_host.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(human_host, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ID) )
				return FALSE
			return equip_delay_self_check(I, human_host, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(human_host.l_store)
				return FALSE

			var/obj/item/bodypart/O = human_host.get_bodypart(BODY_ZONE_L_LEG)

			if(!human_host.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(human_host, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_LPOCKET) )
				return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(human_host.r_store)
				return FALSE

			var/obj/item/bodypart/O = human_host.get_bodypart(BODY_ZONE_R_LEG)

			if(!human_host.w_uniform && !nojumpsuit && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(human_host, "<span class='warning'>You need a jumpsuit before you can attach this [I.name]!</span>")
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_RPOCKET) )
				return TRUE
			return FALSE
		if(ITEM_SLOT_SUITSTORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(human_host.s_store)
				return FALSE
			if(!human_host.wear_suit)
				if(!disable_warning)
					to_chat(human_host, "<span class='warning'>You need a suit before you can attach this [I.name]!</span>")
				return FALSE
			if(!human_host.wear_suit.allowed)
				if(!disable_warning)
					to_chat(human_host, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(human_host, "The [I.name] is too big to attach.") //should be src?
				return FALSE
			if(istype(I, /obj/item/modular_computer/tablet) || istype(I, /obj/item/pen) || is_type_in_list(I, human_host.wear_suit.allowed))
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			if(human_host.handcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(num_arms < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEGCUFFED)
			if(human_host.legcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(num_legs < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACKPACK)
			if(human_host.back)
				if(SEND_SIGNAL(human_host.back, COMSIG_TRY_STORAGE_CAN_INSERT, I, human_host, TRUE))
					return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/human_host, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	human_host.visible_message("<span class='notice'>[human_host] start putting on [I].</span>", "<span class='notice'>You start putting on [I].</span>")
	return do_after(human_host, I.equip_delay_self, target = human_host)

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/human_host, client/preference_source = null)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/human_host, client/preference_source = null)
	human_host.update_mutant_bodyparts()

// Do species-specific reagent handling here
// Return 1 if it should do normal processing too
// Return 0 if it shouldn't deplete and do its normal effect
// Other return values will cause weird badness

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/human_host)
	if(chem.type == exotic_blood)
		human_host.blood_volume = min(human_host.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
		human_host.reagents.del_reagent(chem.type)
		return TRUE
	//This handles dumping unprocessable reagents.
	var/dump_reagent = TRUE
	if((chem.process_flags & SYNTHETIC) && (human_host.dna.species.reagent_tag & PROCESS_SYNTHETIC))		//SYNTHETIC-oriented reagents require PROCESS_SYNTHETIC
		dump_reagent = FALSE
	if((chem.process_flags & ORGANIC) && (human_host.dna.species.reagent_tag & PROCESS_ORGANIC))		//ORGANIC-oriented reagents require PROCESS_ORGANIC
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

/datum/species/proc/handle_digestion(mob/living/carbon/human/human_host)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(human_host, TRAIT_FAT, OBESITY))//I share your pain, past coder.
		if(human_host.overeatduration < 100)
			to_chat(human_host, "<span class='notice'>You feel fit again!</span>")
			REMOVE_TRAIT(human_host, TRAIT_FAT, OBESITY)
			human_host.remove_movespeed_modifier(MOVESPEED_ID_FAT)
			human_host.update_inv_w_uniform()
			human_host.update_inv_wear_suit()
	else
		if(human_host.overeatduration >= 100)
			to_chat(human_host, "<span class='danger'>You suddenly feel blubbery!</span>")
			ADD_TRAIT(human_host, TRAIT_FAT, OBESITY)
			human_host.add_movespeed_modifier(MOVESPEED_ID_FAT, multiplicative_slowdown = 1.5)
			human_host.update_inv_w_uniform()
			human_host.update_inv_wear_suit()

	// nutrition decrease and satiety
	if (human_host.nutrition > 0 && human_host.stat != DEAD && !HAS_TRAIT(human_host, TRAIT_NOHUNGER))
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		var/datum/component/mood/mood = human_host.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(0.5, 1 - 0.002 * mood.sanity) //0.85 to 0.75
		// Whether we cap off our satiety or move it towards 0
		if(human_host.satiety > MAX_SATIETY)
			human_host.satiety = MAX_SATIETY
		else if(human_host.satiety > 0)
			human_host.satiety--
		else if(human_host.satiety < -MAX_SATIETY)
			human_host.satiety = -MAX_SATIETY
		else if(human_host.satiety < 0)
			human_host.satiety++
			if(prob(round(-human_host.satiety/40)))
				human_host.Jitter(5)
			hunger_rate = 3 * HUNGER_FACTOR
		hunger_rate *= human_host.physiology.hunger_mod
		human_host.adjust_nutrition(-hunger_rate)


	if (human_host.nutrition > NUTRITION_LEVEL_FULL)
		if(human_host.overeatduration < 600) //capped so people don't take forever to unfat
			human_host.overeatduration++
	else
		if(human_host.overeatduration > 1)
			human_host.overeatduration -= 2 //doubled the unfat rate

	//metabolism change
	if(human_host.nutrition > NUTRITION_LEVEL_FAT)
		human_host.metabolism_efficiency = 1
	else if(human_host.nutrition > NUTRITION_LEVEL_FED && human_host.satiety > 80)
		if(human_host.metabolism_efficiency != 1.25 && !HAS_TRAIT(human_host, TRAIT_NOHUNGER))
			to_chat(human_host, "<span class='notice'>You feel vigorous.</span>")
			human_host.metabolism_efficiency = 1.25
	else if(human_host.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if(human_host.metabolism_efficiency != 0.8)
			to_chat(human_host, "<span class='notice'>You feel sluggish.</span>")
		human_host.metabolism_efficiency = 0.8
	else
		if(human_host.metabolism_efficiency == 1.25)
			to_chat(human_host, "<span class='notice'>You no longer feel vigorous.</span>")
		human_host.metabolism_efficiency = 1

	//Hunger slowdown for if mood isn't enabled
	if(CONFIG_GET(flag/disable_human_mood))
		if(!HAS_TRAIT(human_host, TRAIT_NOHUNGER))
			var/hungry = (500 - human_host.nutrition) / 5 //So overeat would be 100 and default level would be 80
			if(hungry >= 70)
				human_host.add_movespeed_modifier(MOVESPEED_ID_HUNGRY, override = TRUE, multiplicative_slowdown = (hungry / 50))
			else
				human_host.remove_movespeed_modifier(MOVESPEED_ID_HUNGRY)

	if(HAS_TRAIT(human_host, TRAIT_POWERHUNGRY))
		handle_charge(human_host)
	else
		switch(human_host.nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				human_host.throw_alert("nutrition", /atom/movable/screen/alert/fat)
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
				human_host.clear_alert("nutrition")
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				human_host.throw_alert("nutrition", /atom/movable/screen/alert/hungry)
			if(0 to NUTRITION_LEVEL_STARVING)
				human_host.throw_alert("nutrition", /atom/movable/screen/alert/starving)

/datum/species/proc/handle_charge(mob/living/carbon/human/human_host)
	switch(human_host.nutrition)
		if(NUTRITION_LEVEL_FED to INFINITY)
			human_host.clear_alert("nutrition")
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			human_host.throw_alert("nutrition", /atom/movable/screen/alert/lowcell, 1)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			human_host.throw_alert("nutrition", /atom/movable/screen/alert/lowcell, 2)
		if(1 to NUTRITION_LEVEL_STARVING)
			human_host.throw_alert("nutrition", /atom/movable/screen/alert/lowcell, 3)
		else
			var/obj/item/organ/stomach/battery/battery = human_host.getorganslot(ORGAN_SLOT_STOMACH)
			if(!istype(battery))
				human_host.throw_alert("nutrition", /atom/movable/screen/alert/nocell)
			else
				human_host.throw_alert("nutrition", /atom/movable/screen/alert/emptycell)

/datum/species/proc/update_health_hud(mob/living/carbon/human/human_host)
	return 0

/datum/species/proc/handle_mutations_and_radiation(mob/living/carbon/human/human_host)
	. = FALSE
	var/radiation = human_host.radiation

	if(HAS_TRAIT(human_host, TRAIT_RADIMMUNE))
		radiation = 0
		return TRUE

	if(radiation > RAD_MOB_KNOCKDOWN && prob(RAD_MOB_KNOCKDOWN_PROB))
		if(!human_host.IsParalyzed())
			human_host.emote("collapse")
		human_host.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(human_host, "<span class='danger'>You feel weak.</span>")

	if(radiation > RAD_MOB_VOMIT && prob(RAD_MOB_VOMIT_PROB))
		human_host.vomit(10, TRUE)

	if(radiation > RAD_MOB_MUTATE)
		if(prob(1))
			to_chat(human_host, "<span class='danger'>You mutate!</span>")
			human_host.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
			human_host.emote("gasp")
			human_host.domutcheck()

	if(radiation > RAD_MOB_HAIRLOSS)
		if(prob(15) && !(human_host.hair_style == "Bald") && (HAIR in species_traits))
			to_chat(human_host, "<span class='danger'>Your hair starts to fall out in clumps.</span>")
			addtimer(CALLBACK(src, .proc/go_bald, human_host), 50)

/datum/species/proc/go_bald(mob/living/carbon/human/human_host)
	if(QDELETED(human_host))	//may be called from a timer
		return
	human_host.facial_hair_style = "Shaved"
	human_host.hair_style = "Bald"
	human_host.update_hair()

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

/datum/species/proc/movement_delay(mob/living/carbon/human/human_host)
	. = 0	//We start at 0.
	var/gravity = 0
	gravity = human_host.has_gravity()

	if(!HAS_TRAIT(human_host, TRAIT_IGNORESLOWDOWN) && gravity)
		if(human_host.wear_suit)
			. += human_host.wear_suit.slowdown
		if(human_host.shoes)
			. += human_host.shoes.slowdown
		if(human_host.back)
			. += human_host.back.slowdown
		for(var/obj/item/I in human_host.held_items)
			if(I.item_flags & SLOWS_WHILE_IN_HAND)
				. += I.slowdown

		if(gravity > STANDARD_GRAVITY)
			var/grav_force = min(gravity - STANDARD_GRAVITY,3)
			. += 1 + grav_force

	return .


#undef HEALTH_DEF_MOVESPEED_DAMAGE_MIN
#undef HEALTH_DEF_MOVESPEED_DELAY_MAX
#undef HEALTH_DEF_MOVESPEED_DIV
#undef HEALTH_DEF_MOVESPEED_FLIGHT_DIV
#undef HEALTH_DEF_MOVESPEED_POW

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_updatehealth(mob/living/carbon/human/human_host)
	return

/datum/species/proc/spec_fully_heal(mob/living/carbon/human/human_host)
	return

/datum/species/proc/spec_emp_act(mob/living/carbon/human/human_host, severity)
	return

/datum/species/proc/spec_electrocute_act(mob/living/carbon/human/human_host, shock_damage, obj/source, siemens_coeff = 1, safety = 0, override = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	return

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(!((target.health < 0 || HAS_TRAIT(target, TRAIT_FAKEDEATH)) && !(target.mobility_flags & MOBILITY_STAND)))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return 1
	else
		var/we_breathe = !HAS_TRAIT(user, TRAIT_NOBREATH)
		var/we_lung = user.getorganslot(ORGAN_SLOT_LUNGS)

		if(we_breathe && we_lung)
			user.do_cpr(target)
		else if(we_breathe && !we_lung)
			to_chat(user, "<span class='warning'>You have no lungs to breathe with, so you cannot perform CPR.</span>")
		else
			to_chat(user, "<span class='notice'>You do not breathe, so you cannot perform CPR.</span>")

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(target, TRAIT_ONEWAYROAD))
		user.visible_message("<span class='userdanger'>Your wrist twists unnaturally as you attempt to grab [target]!</span>", "<span class='warning'>[user]'s wrist twists unnaturally away from [target]!</span>")
		user.apply_damage(rand(15, 25), BRUTE, pick(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
		return FALSE
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s grab attempt!</span>", \
							"<span class='userdanger'>You block [user]'s grab attempt!</span>")
		return FALSE
	if(attacker_style && attacker_style.grab_act(user,target))
		return TRUE
	else
		//Steal them shoes
		if(!(target.mobility_flags & MOBILITY_STAND) && (user.zone_selected == BODY_ZONE_L_LEG || user.zone_selected == BODY_ZONE_R_LEG) && user.a_intent == INTENT_GRAB && target.shoes)
			if(HAS_TRAIT(target.shoes, TRAIT_NODROP))
				target.grabbedby(user)
				return TRUE
			user.visible_message("<span class='warning'>[user] starts stealing [target]'s shoes!</span>",
								"<span class='warning'>You start stealing [target]'s shoes!</span>")
			var/obj/item/I = target.shoes
			if(do_after(user, I.strip_delay, TRUE, target, TRUE))
				target.dropItemToGround(I, TRUE)
				user.put_in_hands(I)
				user.visible_message("<span class='warning'>[user] stole your [I]!</span>",
									"<span class='warning'>You steal [target]'s [I]!</span>")
		target.grabbedby(user)
		return TRUE

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(target, TRAIT_ONEWAYROAD))
		user.visible_message("<span class='userdanger'>Your wrist twists unnaturally as you attempt to hit [target]!</span>", "<span class='warning'>[user]'s wrist twists unnaturally away from [target]!</span>")
		user.apply_damage(rand(15, 25), BRUTE, pick(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [target]!</span>")
		return FALSE
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s attack!</span>", \
							"<span class='userdanger'>You block [user]'s attack!</span>")
		return FALSE
	if(attacker_style && attacker_style.harm_act(user,target))
		return TRUE
	else

		var/atk_verb = user.dna.species.attack_verb
		if(!(target.mobility_flags & MOBILITY_STAND))
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

		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))

		if(!damage || !affecting)//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, user.dna.species.miss_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user]'s [atk_verb] misses [target]!</span>",\
			"<span class='userdanger'>[user]'s [atk_verb] misses you!</span>", null, COMBAT_MESSAGE_RANGE)
			log_combat(user, target, "attempted to punch")
			return FALSE

		var/armor_block = target.run_armor_check(affecting, "melee")

		playsound(target.loc, user.dna.species.attack_sound, 25, 1, -1)

		target.visible_message("<span class='danger'>[user] [atk_verb]ed [target]!</span>", \
					"<span class='userdanger'>[user] [atk_verb]ed you!</span>", null, COMBAT_MESSAGE_RANGE)

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		user.dna.species.spec_unarmedattacked(user, target)

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		if(atk_verb == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage
			target.apply_damage(damage*1.5, attack_type, affecting, armor_block)
			log_combat(user, target, "kicked")
		else//other attacks deal full raw damage + 1.5x in stamina damage
			target.apply_damage(damage, attack_type, affecting, armor_block)
			target.apply_damage(damage*1.5, STAMINA, affecting, armor_block)
			log_combat(user, target, "punched")

/datum/species/proc/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/species/proc/disarm(mob/living/carbon/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(target, TRAIT_ONEWAYROAD))
		user.visible_message("<span class='userdanger'>Your wrist twists unnaturally as you attempt to shove [target]!</span>", "<span class='warning'>[user]'s wrist twists unnaturally away from [target]!</span>")
		user.apply_damage(15, BRUTE, pick(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
		return FALSE
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s shoving attempt!</span>", \
							"<span class='userdanger'>You block [user]'s shoving attempt!</span>")
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user,target))
		return TRUE
	if(user.resting || user.IsKnockdown())
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	else
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)

		var/turf/target_oldturf = target.loc
		var/shove_dir = get_dir(user.loc, target_oldturf)
		var/turf/target_shove_turf = get_step(target.loc, shove_dir)
		var/mob/living/carbon/human/target_collateral_human
		var/obj/structure/table/target_table
		var/obj/machinery/disposal/bin/target_disposal_bin
		var/turf/open/indestructible/sound/pool/target_pool	//This list is getting pretty long, but its better than calling shove_act or something on every atom
		var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied

		//Thank you based whoneedsspace
		target_collateral_human = locate(/mob/living/carbon) in target_shove_turf.contents
		if(target_collateral_human)
			shove_blocked = TRUE
		else
			target.Move(target_shove_turf, shove_dir)
			if(get_turf(target) == target_oldturf)
				target_table = locate(/obj/structure/table) in target_shove_turf.contents
				target_disposal_bin = locate(/obj/machinery/disposal/bin) in target_shove_turf.contents
				target_pool = istype(target_shove_turf, /turf/open/indestructible/sound/pool) ? target_shove_turf : null
				shove_blocked = TRUE

		if(target.IsKnockdown())
			var/target_held_item = target.get_active_held_item()
			if(target_held_item)
				target.visible_message("<span class='danger'>[user.name] kicks \the [target_held_item] out of [target]'s hand!</span>",
									"<span class='danger'>[user.name] kicks \the [target_held_item] out of your hand!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "disarms [target_held_item]")
			else
				target.visible_message("<span class='danger'>[user.name] kicks [target.name] onto [target.p_their()] side!</span>",
									"<span class='danger'>[user.name] kicks you onto your side!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "kicks", "onto their side (paralyzing)")
			target.Paralyze(SHOVE_CHAIN_PARALYZE) //duration slightly shorter than disarm cd
		if(shove_blocked && !target.is_shove_knockdown_blocked() && !target.buckled)
			var/directional_blocked = FALSE
			if(shove_dir in GLOB.cardinals) //Directional checks to make sure that we're not shoving through a windoor or something like that
				var/target_turf = get_turf(target)
				for(var/obj/O in target_turf)
					if(O.flags_1 & ON_BORDER_1 && O.dir == shove_dir && O.density)
						directional_blocked = TRUE
						break
				if(target_turf != target_shove_turf) //Make sure that we don't run the exact same check twice on the same tile
					for(var/obj/O in target_shove_turf)
						if(O.flags_1 & ON_BORDER_1 && O.dir == turn(shove_dir, 180) && O.density)
							directional_blocked = TRUE
							break
			if((!target_table && !target_collateral_human && !target_disposal_bin && !target_pool && !target.IsKnockdown()) || directional_blocked)
				target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
				target.Immobilize(SHOVE_IMMOBILIZE_SOLID)
				user.visible_message("<span class='danger'>[user.name] shoves [target.name], knocking [target.p_them()] down!</span>",
					"<span class='danger'>You shove [target.name], knocking [target.p_them()] down!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "shoved", "knocking them down")
			else if(target_table)
				target.Paralyze(SHOVE_KNOCKDOWN_TABLE)
				user.visible_message("<span class='danger'>[user.name] shoves [target.name] onto \the [target_table]!</span>",
					"<span class='danger'>You shove [target.name] onto \the [target_table]!</span>", null, COMBAT_MESSAGE_RANGE)
				target.throw_at(target_table, 1, 1, null, FALSE) //1 speed throws with no spin are basically just forcemoves with a hard collision check
				log_combat(user, target, "shoved", "onto [target_table] (table)")
			else if(target_collateral_human)
				target.Knockdown(SHOVE_KNOCKDOWN_HUMAN)
				target_collateral_human.Knockdown(SHOVE_KNOCKDOWN_COLLATERAL)
				user.visible_message("<span class='danger'>[user.name] shoves [target.name] into [target_collateral_human.name]!</span>",
					"<span class='danger'>You shove [target.name] into [target_collateral_human.name]!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "shoved", "into [target_collateral_human.name]")
			else if(target_disposal_bin)
				target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
				target.forceMove(target_disposal_bin)
				user.visible_message("<span class='danger'>[user.name] shoves [target.name] into \the [target_disposal_bin]!</span>",
					"<span class='danger'>You shove [target.name] into \the [target_disposal_bin]!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "shoved", "into [target_disposal_bin] (disposal bin)")
			else if(target_pool)
				target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
				target.forceMove(target_pool)
				user.visible_message("<span class='danger'>[user.name] shoves [target.name] into \the [target_pool]!</span>",
					"<span class='danger'>You shove [target.name] into \the [target_pool]!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "shoved", "into [target_pool] (swimming pool)")
		else
			user.visible_message("<span class='danger'>[user.name] shoves [target.name]!</span>",
				"<span class='danger'>You shove [target.name]!</span>", null, COMBAT_MESSAGE_RANGE)
			/*var/target_held_item = target.get_active_held_item()
			var/knocked_item = FALSE
			if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types))
				target_held_item = null
			if(!target.has_movespeed_modifier(MOVESPEED_ID_SHOVE))
				target.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
				if(target_held_item)
					target.visible_message("<span class='danger'>[target.name]'s grip on \the [target_held_item] loosens!</span>",
						"<span class='danger'>Your grip on \the [target_held_item] loosens!</span>", null, COMBAT_MESSAGE_RANGE)
				addtimer(CALLBACK(target, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)
			else if(target_held_item)
				target.dropItemToGround(target_held_item)
				knocked_item = TRUE
				target.visible_message("<span class='danger'>[target.name] drops \the [target_held_item]!!</span>",
					"<span class='danger'>You drop \the [target_held_item]!!</span>", null, COMBAT_MESSAGE_RANGE)
			var/append_message = ""
			if(target_held_item)
				if(knocked_item)
					append_message = "causing them to drop [target_held_item]"
				else
					append_message = "loosening their grip on [target_held_item]"*/
			log_combat(user, target, "shoved")

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/human_host)
	return

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/human_host, datum/martial_art/attacker_style)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(human_host)

	if(!istype(M)) //sanity check for drones.
		return
	if(M.mind)
		attacker_style = M.mind.martial_art
	if((M != human_host) && M.a_intent != INTENT_HELP && human_host.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		log_combat(M, human_host, "attempted to touch")
		human_host.visible_message("<span class='warning'>[M] attempts to touch [human_host]!</span>", \
						"<span class='userdanger'>[M] attempts to touch you!</span>")
		return 0
	SEND_SIGNAL(M, COMSIG_MOB_ATTACK_HAND, M, human_host, attacker_style)
	SEND_SIGNAL(human_host, COMSIG_MOB_HAND_ATTACKED, human_host, M, attacker_style)
	switch(M.a_intent)
		if("help")
			help(M, human_host, attacker_style)

		if("grab")
			grab(M, human_host, attacker_style)

		if("harm")
			harm(M, human_host, attacker_style)

		if("disarm")
			disarm(M, human_host, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/human_host)
	// Allows you to put in item-specific reactions based on species
	if(user != human_host)
		if(human_host.check_shields(I, I.force, "the [I.name]", MELEE_ATTACK, I.armour_penetration))
			return 0
	if(human_host.check_block())
		human_host.visible_message("<span class='warning'>[human_host] blocks [I]!</span>", \
						"<span class='userdanger'>You block [I]!</span>")
		return 0

	var/hit_area
	if(!affecting) //Something went wrong. Maybe the limb is missing?
		affecting = human_host.bodyparts[1]

	hit_area = parse_zone(affecting.body_zone)
	var/def_zone = affecting.body_zone

	var/armor_block = human_host.run_armor_check(affecting, "melee", "<span class='notice'>Your armor has protected your [hit_area]!</span>", "<span class='warning'>Your armor has softened a hit to your [hit_area]!</span>",I.armour_penetration)
	armor_block = min(90,armor_block) //cap damage reduction at 90%
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	var/weakness = human_host.check_weakness(I, user)
	apply_damage(I.force * weakness, I.damtype, def_zone, armor_block, human_host)

	human_host.send_item_attack_message(I, user, hit_area)

	if(!I.force)
		return 0 //item force is zero

	//dismemberment
	var/dismemberthreshold = ((affecting.max_damage * 2) - affecting.get_damage()) //don't take the current hit into account.
	var/attackforce = (((I.w_class - 3) * 5) + ((I.attack_weight - 1) * 14) + ((I.is_sharp()-1) * 20)) //all the variables that go into ripping off a limb in one handy package. Force is absent because it's already been taken into account by the limb being damaged
	if(HAS_TRAIT(src, TRAIT_EASYDISMEMBER))
		dismemberthreshold -= 30
	if(I.is_sharp())
		attackforce = max(attackforce, I.force)
	if(attackforce >= dismemberthreshold && I.force >= 10)
		if(affecting.dismember(I.damtype))
			I.add_mob_blood(human_host)
			playsound(get_turf(human_host), I.get_dismember_sound(), 80, 1)

	var/bloody = 0
	if((I.damtype == BRUTE) && (I.force >= max(10, armor_block) || I.is_sharp()))
		if(IS_ORGANIC_LIMB(affecting))
			I.add_mob_blood(human_host)	//Make the weapon bloody, not the person.
			if(prob(I.force * 2))	//blood spatter!
				bloody = 1
				var/turf/location = human_host.loc
				if(istype(location))
					human_host.add_splatter_floor(location)
				if(get_dist(user, human_host) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(human_host)

		switch(hit_area)
			if(BODY_ZONE_HEAD)
				if(!I.is_sharp())
					if(human_host.mind && human_host.stat == CONSCIOUS && human_host != user && (human_host.health - (I.force * I.attack_weight)) <= 0) // rev deconversion through blunt trauma.
						var/datum/antagonist/rev/rev = human_host.mind.has_antag_datum(/datum/antagonist/rev)
						if(rev)
							rev.remove_revolutionary(FALSE, user)

				if(bloody)	//Apply blood
					if(human_host.wear_mask)
						human_host.wear_mask.add_mob_blood(human_host)
						human_host.update_inv_wear_mask()
					if(human_host.head)
						human_host.head.add_mob_blood(human_host)
						human_host.update_inv_head()
					if(human_host.glasses && prob(33))
						human_host.glasses.add_mob_blood(human_host)
						human_host.update_inv_glasses()

			if(BODY_ZONE_CHEST)
				if(bloody)
					if(human_host.wear_suit)
						human_host.wear_suit.add_mob_blood(human_host)
						human_host.update_inv_wear_suit()
					if(human_host.w_uniform)
						human_host.w_uniform.add_mob_blood(human_host)
						human_host.update_inv_w_uniform()

		if(Iforce > 10 || Iforce >= 5 && prob(33))
			human_host.forcesay(GLOB.hit_appends)	//forcesay checks stat already.
	return TRUE

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/human_host, forced = FALSE)
	SEND_SIGNAL(human_host, COMSIG_MOB_APPLY_DAMGE, damage, damagetype, def_zone)
	var/hit_percent = (100-(blocked+armor))/100
	hit_percent = (hit_percent * (100-human_host.physiology.damage_resistance))/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(isbodypart(def_zone))
		BP = def_zone
	else
		if(!def_zone)
			def_zone = check_zone(def_zone)
		BP = human_host.get_bodypart(check_zone(def_zone))
		if(!BP)
			BP = human_host.bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			human_host.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * brutemod * human_host.physiology.brute_mod
			if(BP)
				if(BP.receive_damage(damage_amount, 0))
					human_host.update_damage_overlays()
			else//no bodypart, we deal damage with a more general method.
				human_host.adjustBruteLoss(damage_amount)
		if(BURN)
			human_host.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * burnmod * human_host.physiology.burn_mod
			if(BP)
				if(BP.receive_damage(0, damage_amount))
					human_host.update_damage_overlays()
			else
				human_host.adjustFireLoss(damage_amount)
		if(TOX)
			var/damage_amount = forced ? damage : damage * hit_percent * toxmod * human_host.physiology.tox_mod
			human_host.adjustToxLoss(damage_amount)
		if(OXY)
			var/damage_amount = forced ? damage : damage * oxymod * hit_percent * human_host.physiology.oxy_mod
			human_host.adjustOxyLoss(damage_amount)
		if(CLONE)
			var/damage_amount = forced ? damage : damage * hit_percent * clonemod * human_host.physiology.clone_mod
			human_host.adjustCloneLoss(damage_amount)
		if(STAMINA)
			var/damage_amount = forced ? damage : damage * hit_percent * staminamod * human_host.physiology.stamina_mod
			if(BP)
				if(BP.receive_damage(0, 0, damage_amount))
					human_host.update_stamina(TRUE)
			else
				human_host.adjustStaminaLoss(damage_amount)
		if(BRAIN)
			var/damage_amount = forced ? damage : damage * hit_percent * human_host.physiology.brain_mod
			human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)
	return 1

/datum/species/proc/on_hit(obj/item/projectile/P, mob/living/carbon/human/human_host)
	// called when hit by a projectile
	switch(P.type)
		if(/obj/item/projectile/energy/floramut) // overwritten by plants/pods
			human_host.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		if(/obj/item/projectile/energy/florayield)
			human_host.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/human_host)
	// called before a projectile hit
	return 0

/////////////
//BREATHING//
/////////////

/datum/species/proc/breathe(mob/living/carbon/human/human_host)
	if(HAS_TRAIT(human_host, TRAIT_NOBREATH))
		return TRUE


/datum/species/proc/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/human_host)
	if(!environment)
		return
	if(istype(human_host.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/loc_temp = human_host.get_temperature(environment)

	//Body temperature is adjusted in two parts: first there your body tries to naturally preserve homeostasis (shivering/sweating), then it reacts to the surrounding environment
	//Thermal protection (insulation) has mixed benefits in two situations (hot in hot places, cold in hot places)
	if(!human_host.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		var/natural = 0
		if(human_host.stat != DEAD)
			natural = human_host.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		if(loc_temp < human_host.bodytemperature) //Place is colder than we are
			thermal_protection -= human_host.get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(human_host.bodytemperature < BODYTEMP_NORMAL) //we're cold, insulation helps us retain body heat and will reduce the heat we lose to the environment
				human_host.adjust_bodytemperature((thermal_protection+1)*natural + max(thermal_protection * (loc_temp - human_host.bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
			else //we're sweating, insulation hinders our ability to reduce heat - and it will reduce the amount of cooling you get from the environment
				human_host.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + max((thermal_protection * (loc_temp - human_host.bodytemperature) + BODYTEMP_NORMAL - human_host.bodytemperature) / BODYTEMP_COLD_DIVISOR , BODYTEMP_COOLING_MAX)) //Extra calculation for hardsuits to bleed off heat
	if (loc_temp > human_host.bodytemperature) //Place is hotter than we are
		var/natural = 0
		if(human_host.stat != DEAD)
			natural = human_host.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		thermal_protection -= human_host.get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
		if(human_host.bodytemperature < BODYTEMP_NORMAL) //and we're cold, insulation enhances our ability to retain body heat but reduces the heat we get from the environment
			human_host.adjust_bodytemperature((thermal_protection+1)*natural + min(thermal_protection * (loc_temp - human_host.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
		else //we're sweating, insulation hinders out ability to reduce heat - but will reduce the amount of heat we get from the environment
			human_host.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + min(thermal_protection * (loc_temp - human_host.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))

	// +/- 50 degrees from 310K is the 'safe' zone, where no damage is dealt.
	if(human_host.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !HAS_TRAIT(human_host, TRAIT_RESISTHEAT))
		//Body temperature is too hot.

		SEND_SIGNAL(human_host, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(human_host, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		human_host.remove_movespeed_modifier(MOVESPEED_ID_COLD)

		var/burn_damage
		var/firemodifier = human_host.fire_stacks / 50
		if (human_host.on_fire)
			burn_damage = max(log(2-firemodifier,(human_host.bodytemperature-BODYTEMP_NORMAL))-5,0)
		else
			firemodifier = min(firemodifier, 0)
			burn_damage = max(log(2-firemodifier,(human_host.bodytemperature-BODYTEMP_NORMAL))-5,0) // this can go below 5 at log 2.5
		if (burn_damage)
			switch(burn_damage)
				if(0 to 2)
					human_host.throw_alert("temp", /atom/movable/screen/alert/hot, 1)
				if(2 to 4)
					human_host.throw_alert("temp", /atom/movable/screen/alert/hot, 2)
				else
					human_host.throw_alert("temp", /atom/movable/screen/alert/hot, 3)
		burn_damage = burn_damage * heatmod * human_host.physiology.heat_mod
		if (human_host.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4) //40% for level 3 damage on humans
			human_host.emote("scream")
		human_host.apply_damage(burn_damage, BURN)

	else if(human_host.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(human_host, TRAIT_RESISTCOLD))
		SEND_SIGNAL(human_host, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(human_host, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		//Sorry for the nasty oneline but I don't want to assign a variable on something run pretty frequently
		human_host.add_movespeed_modifier(MOVESPEED_ID_COLD, override = TRUE, multiplicative_slowdown = ((BODYTEMP_COLD_DAMAGE_LIMIT - human_host.bodytemperature) / COLD_SLOWDOWN_FACTOR), blacklisted_movetypes = FLOATING)
		switch(human_host.bodytemperature)
			if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)
				human_host.throw_alert("temp", /atom/movable/screen/alert/cold, 1)
				human_host.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod*human_host.physiology.cold_mod, BURN)
			if(120 to 200)
				human_host.throw_alert("temp", /atom/movable/screen/alert/cold, 2)
				human_host.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod*human_host.physiology.cold_mod, BURN)
			else
				human_host.throw_alert("temp", /atom/movable/screen/alert/cold, 3)
				human_host.apply_damage(COLD_DAMAGE_LEVEL_3*coldmod*human_host.physiology.cold_mod, BURN)

	else
		human_host.clear_alert("temp")
		human_host.remove_movespeed_modifier(MOVESPEED_ID_COLD)
		SEND_SIGNAL(human_host, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(human_host, COMSIG_CLEAR_MOOD_EVENT, "hot")

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = human_host.calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!HAS_TRAIT(human_host, TRAIT_RESISTHIGHPRESSURE))
				human_host.adjustBruteLoss(min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 ) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * human_host.physiology.pressure_mod)
				human_host.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)
			else
				human_host.clear_alert("pressure")
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			human_host.throw_alert("pressure", /atom/movable/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			human_host.clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			human_host.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 1)
		else
			if(HAS_TRAIT(human_host, TRAIT_RESISTLOWPRESSURE))
				human_host.clear_alert("pressure")
			else
				human_host.adjustBruteLoss(LOW_PRESSURE_DAMAGE * human_host.physiology.pressure_mod)
				human_host.throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/human_host, no_protection = FALSE)
	if(!CanIgniteMob(human_host))
		return TRUE
	if(human_host.on_fire)
		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		var/obscured = human_host.check_obscured_slots(TRUE)
		//HEAD//

		if(human_host.glasses && !(obscured & ITEM_SLOT_EYES))
			burning_items += human_host.glasses
		if(human_host.wear_mask && !(obscured & ITEM_SLOT_MASK))
			burning_items += human_host.wear_mask
		if(human_host.wear_neck && !(obscured & ITEM_SLOT_NECK))
			burning_items += human_host.wear_neck
		if(human_host.ears && !(obscured & ITEM_SLOT_EARS))
			burning_items += human_host.ears
		if(human_host.head)
			burning_items += human_host.head

		//CHEST//
		if(human_host.w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
			burning_items += human_host.w_uniform
		if(human_host.wear_suit)
			burning_items += human_host.wear_suit

		//ARMS & HANDS//
		var/obj/item/clothing/arm_clothes = null
		if(human_host.gloves && !(obscured & ITEM_SLOT_GLOVES))
			arm_clothes = human_host.gloves
		else if(human_host.wear_suit && ((human_host.wear_suit.body_parts_covered & HANDS) || (human_host.wear_suit.body_parts_covered & ARMS)))
			arm_clothes = human_host.wear_suit
		else if(human_host.w_uniform && ((human_host.w_uniform.body_parts_covered & HANDS) || (human_host.w_uniform.body_parts_covered & ARMS)))
			arm_clothes = human_host.w_uniform
		if(arm_clothes)
			burning_items |= arm_clothes

		//LEGS & FEET//
		var/obj/item/clothing/leg_clothes = null
		if(human_host.shoes && !(obscured & ITEM_SLOT_FEET))
			leg_clothes = human_host.shoes
		else if(human_host.wear_suit && ((human_host.wear_suit.body_parts_covered & FEET) || (human_host.wear_suit.body_parts_covered & LEGS)))
			leg_clothes = human_host.wear_suit
		else if(human_host.w_uniform && ((human_host.w_uniform.body_parts_covered & FEET) || (human_host.w_uniform.body_parts_covered & LEGS)))
			leg_clothes = human_host.w_uniform
		if(leg_clothes)
			burning_items |= leg_clothes

		for(var/obj/item/I as() in burning_items)
			I.fire_act((human_host.fire_stacks * 50)) //damage taken is reduced to 2% of this value by fire_act()

		var/thermal_protection = human_host.get_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
			human_host.adjust_bodytemperature(11)
		else
			human_host.adjust_bodytemperature(BODYTEMP_HEATING_MAX + (human_host.fire_stacks * 12))
			SEND_SIGNAL(human_host, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)

/datum/species/proc/CanIgniteMob(mob/living/carbon/human/human_host)
	if(HAS_TRAIT(human_host, TRAIT_NOFIRE))
		return FALSE
	return TRUE

/datum/species/proc/ExtinguishMob(mob/living/carbon/human/human_host)
	return

/datum/species/proc/spec_revival(mob/living/carbon/human/human_host)
	return


////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/human_host,amount)
	var/obj/item/organ/wings/wings = human_host.getorganslot(ORGAN_SLOT_WINGS)
	if(human_host.getorgan(/obj/item/organ/wings))
		if(wings.flight_level >= WINGS_FLYING && human_host.movement_type & FLYING)
			flyslip(human_host)
	. = stunmod * human_host.physiology.stun_mod * amount

//////////////
//Space Move//
//////////////

/datum/species/proc/space_move(mob/living/carbon/human/human_host)
	if(human_host.loc && !isspaceturf(human_host.loc) && human_host.getorgan(/obj/item/organ/wings))
		var/obj/item/organ/wings/wings = human_host.getorganslot(ORGAN_SLOT_WINGS)
		if(wings.flight_level == WINGS_FLIGHTLESS)
			var/datum/gas_mixture/current = human_host.loc.return_air()
			if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
				return TRUE
	if(human_host.movement_type & FLYING)
		return TRUE
	return FALSE

/datum/species/proc/negates_gravity(mob/living/carbon/human/human_host)
	if(human_host.movement_type & FLYING)
		return TRUE
	return FALSE

////////////////
//Tail Wagging//
////////////////

/datum/species/proc/can_wag_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/is_wagging_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/start_wagging_tail(mob/living/carbon/human/H)

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)

///////////////
//FLIGHT SHIT//
///////////////

/datum/species/proc/handle_flight(mob/living/carbon/human/human_host)
	if(human_host.movement_type & FLYING)
		if(!CanFly(human_host))
			toggle_flight(human_host)
			return FALSE
		return TRUE
	else
		return FALSE

/datum/species/proc/CanFly(mob/living/carbon/human/human_host)
	var/obj/item/organ/wings/wings = human_host.getorganslot(ORGAN_SLOT_WINGS)
	if(!human_host.getorgan(/obj/item/organ/wings))
		return FALSE
	if(human_host.stat || !(human_host.mobility_flags & MOBILITY_STAND))
		return FALSE
	var/turf/T = get_turf(human_host)
	if(!T)
		return FALSE

	var/datum/gas_mixture/environment = T.return_air()
	if(environment && !(environment.return_pressure() > 30) && wings.flight_level <= WINGS_FLYING)
		to_chat(human_host, "<span class='warning'>The atmosphere is too thin for you to fly!</span>")
		return FALSE
	else
		return TRUE

/datum/species/proc/flyslip(mob/living/carbon/human/human_host)
	var/obj/buckled_obj
	if(human_host.buckled)
		buckled_obj = human_host.buckled

	to_chat(human_host, "<span class='notice'>Your wings spazz out and launch you!</span>")

	for(var/obj/item/I in human_host.held_items)
		human_host.accident(I)

	var/olddir = human_host.dir

	human_host.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(human_host)
		step(buckled_obj, olddir)
	else
		new /datum/forced_movement(human_host, get_ranged_target_turf(human_host, olddir, 4), 1, FALSE, CALLBACK(human_host, /mob/living/carbon/.proc/spin, 1, 1))
	return TRUE

//UNSAFE PROC, should only be called through the Activate or other sources that check for CanFly
/datum/species/proc/toggle_flight(mob/living/carbon/human/human_host)
	if(!(human_host.movement_type & FLYING))
		stunmod *= 2
		speedmod -= 0.35
		human_host.setMovetype(human_host.movement_type | FLYING)
		override_float = TRUE
		human_host.pass_flags |= PASSTABLE
		human_host.update_mobility()
		if(("wings" in human_host.dna.species.mutant_bodyparts) || ("moth_wings" in human_host.dna.species.mutant_bodyparts))
			human_host.Togglewings()
	else
		stunmod *= 0.5
		speedmod += 0.35
		human_host.setMovetype(human_host.movement_type & ~FLYING)
		override_float = FALSE
		human_host.pass_flags &= ~PASSTABLE
		if(("wingsopen" in human_host.dna.species.mutant_bodyparts) || ("moth_wingsopen" in human_host.dna.species.mutant_bodyparts))
			human_host.Togglewings()
		if(isturf(human_host.loc))
			var/turf/T = human_host.loc
			T.Entered(human_host)

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
