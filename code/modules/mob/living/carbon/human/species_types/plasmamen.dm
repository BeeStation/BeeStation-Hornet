/datum/species/plasmaman
	name = "\improper Plasmaman"
	plural_form = "Plasmamen"
	id = SPECIES_PLASMAMAN
	sexes = 0
	meat = /obj/item/stack/sheet/mineral/plasma
	species_traits = list(
		ENVIROSUIT
	)
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_NOHUNGER,
		TRAIT_NOBLOOD,
		TRAIT_NOT_TRANSMORPHIC,
	)
	inherent_biotypes = MOB_INORGANIC | MOB_HUMANOID
	mutantlungs = /obj/item/organ/lungs/plasmaman
	mutanttongue = /obj/item/organ/tongue/bone/plasmaman
	mutantliver = /obj/item/organ/liver/bone/plasmaman
	mutantstomach = /obj/item/organ/stomach/bone/plasmaman
	mutantappendix = null
	mutantheart = null
	heatmod = 1.5
	breathid = GAS_PLASMA
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	outfit_important_for_life = /datum/outfit/plasmaman
	species_language_holder = /datum/language_holder/skeleton

	// Body temperature for Plasmen is much lower human as they can handle colder environments
	bodytemp_normal = (BODYTEMP_NORMAL - 40)
	// The minimum amount they stabilize per tick is reduced making hot areas harder to deal with
	bodytemp_autorecovery_min = 2
	// They are hurt at hot temps faster as it is harder to hold their form
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 20) // about 40C
	// This effects how fast body temp stabilizes, also if cold resit is lost on the mob
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 50) // about -50c

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/plasmaman,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/plasmaman,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/plasmaman,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/plasmaman,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/plasmaman,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/plasmaman,
	)

	var/internal_fire = FALSE //If the bones themselves are burning clothes won't help you much

/datum/species/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.set_safe_hunger_level()

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	var/atmos_sealed = FALSE
	if (H.wear_suit && H.head && isclothing(H.wear_suit) && isclothing(H.head))
		var/obj/item/clothing/CS = H.wear_suit
		var/obj/item/clothing/CH = H.head
		if (CS.clothing_flags & CH.clothing_flags & STOPSPRESSUREDAMAGE)
			atmos_sealed = TRUE
	if(H.w_uniform && H.head)
		var/obj/item/clothing/CU = H.w_uniform
		var/obj/item/clothing/CH = H.head
		if (CU.envirosealed && (CH.clothing_flags & STOPSPRESSUREDAMAGE))
			atmos_sealed = TRUE
	if(!atmos_sealed && (!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman) || !istype(H.gloves, /obj/item/clothing/gloves)))
		var/datum/gas_mixture/environment = H.loc.return_air()
		if(environment?.total_moles())
			if(!HAS_TRAIT(H, TRAIT_NOFIRE) && !HAS_TRAIT(H, TRAIT_NOSELFIGNITION))
				if(GET_MOLES(/datum/gas/oxygen, environment) >= 1) //Same threshold that extinguishes fire
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message(span_danger("[H]'s body reacts with the atmosphere and bursts into flames!"),span_userdanger("Your body reacts with the atmosphere and bursts into flame!"))
					H.ignite_mob()
					internal_fire = TRUE
	else if(H.fire_stacks)
		var/obj/item/clothing/under/plasmaman/P = H.w_uniform
		if(istype(P))
			P.Extinguish(H)
			internal_fire = FALSE
	else
		internal_fire = FALSE
	H.update_appearance(UPDATE_OVERLAYS)

/datum/species/plasmaman/handle_fire(mob/living/carbon/human/H, delta_time, times_fired, no_protection = FALSE)
	if(internal_fire)
		no_protection = TRUE
	. = ..()

/datum/species/plasmaman/after_equip_job(datum/job/J, mob/living/carbon/human/H, visuals_only = FALSE, client/preference_source = null)
	H.open_internals(H.get_item_for_held_index(2))

	if(!preference_source?.prefs)
		return
	var/path = J.species_outfits?[SPECIES_PLASMAMAN]
	if (!path) //Somehow we were given a job without a plasmaman suit, use the default one so we don't go in naked!
		path = /datum/outfit/plasmaman
		stack_trace("Job [J] lacks a species_outfits entry for plasmamen!")
	var/datum/outfit/plasmaman/O = new path
	var/selected_style = preference_source.prefs.read_character_preference(/datum/preference/choiced/helmet_style)
	if(selected_style != HELMET_DEFAULT)
		if(O.helmet_variants[selected_style])
			var/helmet = O.helmet_variants[selected_style]
			qdel(H.head)
			H.equip_to_slot(new helmet, ITEM_SLOT_HEAD)
			H.open_internals(H.get_item_for_held_index(2))

/datum/species/plasmaman/give_important_for_life(mob/living/carbon/human/human_to_equip)
	. = ..()
	human_to_equip.open_internals(human_to_equip.get_item_for_held_index(2))

/datum/species/plasmaman/qualifies_for_rank(rank, list/features)
	if(rank in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
		return 0
	if(rank == JOB_NAME_CLOWN || rank == JOB_NAME_MIME)//No funny bussiness
		return 0
	return ..()

/datum/species/plasmaman/get_scream_sound(mob/living/carbon/user)
	return pick('sound/voice/plasmaman/plasmeme_scream_1.ogg', 'sound/voice/plasmaman/plasmeme_scream_2.ogg', 'sound/voice/plasmaman/plasmeme_scream_3.ogg')

/datum/species/plasmaman/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/plasmaman/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/plasmaman/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/plasmaman/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/plasmaman/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)

/datum/species/plasmaman/get_giggle_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GIGGLE_SOUND(user)

/datum/species/plasmaman/get_species_description()
	return "Found on the Icemoon of Freyja, plasmamen consist of colonial \
		fungal organisms which together form a sentient being. In human space, \
		they're usually attached to skeletons to afford a human touch."

/datum/species/plasmaman/get_species_lore()
	return list(
		"A confusing species, plasmamen are truly \"a fungus among us\". \
		What appears to be a singular being is actually a colony of millions of organisms \
		surrounding a found (or provided) skeletal structure.",

		"Originally discovered by NT when a researcher \
		fell into an open tank of liquid plasma, the previously unnoticed fungal colony overtook the body creating \
		the first \"true\" plasmaman. The process has since been streamlined via generous donations of convict corpses and plasmamen \
		have been deployed en masse throughout NT to bolster the workforce.",

		"New to the galactic stage, plasmamen are a blank slate. \
		Their appearance, generally regarded as \"ghoulish\", inspires a lot of apprehension in their crewmates. \
		It might be the whole \"flammable purple skeleton\" thing.",

		"The colonids that make up plasmamen require the plasma-rich atmosphere they evolved in. \
		Their psuedo-nervous system runs with externalized electrical impulses that immediately ignite their plasma-based bodies when oxygen is present.",
	)

/datum/species/plasmaman/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-shield",
			SPECIES_PERK_NAME = "Protected",
			SPECIES_PERK_DESC = "Plasmamen are immune to radiation, poisons, and most diseases.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hard-hat",
			SPECIES_PERK_NAME = "Protective Helmet",
			SPECIES_PERK_DESC = "Plasmamen's helmets provide them shielding from the flashes of welding, as well as an inbuilt flashlight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Living Torch",
			SPECIES_PERK_DESC = "Plasmamen instantly ignite when their body makes contact with oxygen.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Breathing",
			SPECIES_PERK_DESC = "Plasmamen must breathe plasma to survive. You receive a tank when you arrive.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Complex Biology",
			SPECIES_PERK_DESC = "Plasmamen take specialized medical knowledge to be \
				treated. Do not expect speedy revival, if you are lucky enough to get \
				one at all.",
		),
	)

	return to_add
