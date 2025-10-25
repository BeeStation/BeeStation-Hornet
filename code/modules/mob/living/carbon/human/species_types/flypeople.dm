/datum/species/fly
	name = "Flyperson"
	plural_form = "Flypeople"
	id = SPECIES_FLYPERSON
	inherent_traits = list(
		TRAIT_TACKLING_FRAIL_ATTACKER,
		TRAIT_NO_UNDERWEAR,
		TRAIT_BEEFRIEND
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	meat = /obj/item/food/meat/slab/human/mutant/fly
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/fly
	mutanttongue = /obj/item/organ/tongue/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	mutant_bodyparts = list("insect_type" = "fly", "body_size" = "Normal")

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/fly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/fly,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/fly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/fly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/fly,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/fly,
	)

	species_height = SPECIES_HEIGHTS(2, 1, 0)

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE
	if(istype(chem, /datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor > 0)
			var/turf/pos = get_turf(H)
			H.vomit(10, FALSE, FALSE, 2, TRUE)
			H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
			playsound(pos, 'sound/effects/splat.ogg', 50, 1)
			H.visible_message(span_danger("[H] vomits on the floor!"), \
						span_userdanger("You throw up on the floor!"))
		return TRUE
	return ..()

/datum/species/fly/replace_body(mob/living/carbon/C, datum/species/new_species)
	..()

	var/datum/sprite_accessory/insect_type/type_selection = SSaccessories.insect_type_list[C.dna.features["insect_type"]]
	if(!istype(type_selection))
		return

	for(var/obj/item/bodypart/BP as() in C.bodyparts) //Override bodypart data as necessary
		BP.should_draw_greyscale = !!type_selection.color_src
		if(BP.should_draw_greyscale)
			BP.species_color = C.dna?.features["mcolor"]
		else
			BP.species_color = null

		// Hardcoded bullshit that will probably break. Woo shitcode. Bee insect_type has dimorphic parts while flies do not.
		BP.is_dimorphic = type_selection.gender_specific && (istype(BP, /obj/item/bodypart/head) || istype(BP, /obj/item/bodypart/chest))

		BP.limb_id = type_selection.limbs_id
		BP.name = "\improper[type_selection.name] [parse_zone(BP.body_zone)]"
		BP.update_limb()

/datum/species/fly/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))

/datum/species/fly/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/datum/species/fly/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 30 // Yes, a 30x damage modifier

/datum/species/fly/get_species_description()
	return "With no official documentation or knowledge of the origin of \
		this species, they remain a mystery to most. Any and all rumours among \
		Nanotrasen staff regarding flypeople are often quickly silenced by high \
		ranking staff or officials."

/datum/species/fly/get_species_lore()
	return list(
		"Flypeople are a curious species with a striking resemblance to the insect order of Diptera, \
		commonly known as flies. With no publically known origin, flypeople are rumored to be a side effect of bluespace travel, \
		despite statements from Nanotrasen officials.",

		"Little is known about the origins of this race, \
		however they posess the ability to communicate with giant spiders, originally discovered in the Australicus sector \
		and now a common occurence in black markets as a result of a breakthrough in syndicate bioweapon research.",

		"Flypeople are often feared or avoided among other species, their appearance often described as unclean or frightening in some cases, \
		and their eating habits even more so with an insufferable accent to top it off.",
	)

/datum/species/fly/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Uncanny Digestive System",
			SPECIES_PERK_DESC = "Flypeople regurgitate their stomach contents and drink it \
				off the floor to eat and drink with little care for taste, favoring gross foods.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Insectoid Biology",
			SPECIES_PERK_DESC = "Fly swatters will deal significantly higher amounts of damage to a Flyperson.",
		),
	)

	return to_add
