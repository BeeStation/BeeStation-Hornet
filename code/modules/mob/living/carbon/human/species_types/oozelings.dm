/datum/species/oozeling
	name = "\improper Oozeling"
	id = SPECIES_OOZELING
	bodyflag = FLAG_OOZELING
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		HAIR,
		FACEHAIR,
		NOAUGMENTS
	)
	inherent_traits = list(
		TRAIT_TOXINLOVER,
		TRAIT_NOHAIRLOSS,
		TRAIT_NOFIRE,
		TRAIT_EASYDISMEMBER,
	)
	hair_color = "mutcolor"
	hair_alpha = 150
	mutantlungs = /obj/item/organ/lungs/slime
	mutanttongue = /obj/item/organ/tongue/slime
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	inherent_factions = list(FACTION_SLIME)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/oozeling
	swimming_component = /datum/component/swimming/dissolve
	inert_mutation = /datum/mutation/acidooze

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oozeling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oozeling,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oozeling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oozeling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oozeling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oozeling
	)

/datum/species/oozeling/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.oozeling_first_names)]"
	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.oozeling_last_names)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/oozeling/on_species_loss(mob/living/carbon/C)
	if(regenerate_limbs)
		regenerate_limbs.Remove(C)
	..()

/datum/species/oozeling/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		regenerate_limbs = new
		regenerate_limbs.Grant(C)

/datum/species/oozeling/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	..()
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return

	if(!H.blood_volume)
		H.blood_volume += 2.5 * delta_time
		H.adjustBruteLoss(2.5 * delta_time)
		to_chat(H, span_danger("You feel empty!"))
	if(H.nutrition >= NUTRITION_LEVEL_WELL_FED && H.blood_volume <= 672)
		if(H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
			H.blood_volume += 5 * delta_time
			H.adjust_nutrition(-2.5 * delta_time)
		else
			H.blood_volume += 4 * delta_time
	if(H.nutrition <= NUTRITION_LEVEL_HUNGRY)
		if(H.nutrition <= NUTRITION_LEVEL_STARVING)
			H.blood_volume -= 4 * delta_time
			if(DT_PROB(2.5, delta_time))
				to_chat(H, span_info("You're starving! Get some food!"))
		else
			if(DT_PROB(17.5, delta_time))
				H.blood_volume -= 1 * delta_time
				if(prob(5))
					to_chat(H, span_danger("You're feeling pretty hungry..."))
	var/atmos_sealed = FALSE
	if(H.wear_suit && H.head && isclothing(H.wear_suit) && isclothing(H.head))
		var/obj/item/clothing/CS = H.wear_suit
		var/obj/item/clothing/CH = H.head
		if(CS.clothing_flags & CH.clothing_flags & STOPSPRESSUREDAMAGE)
			atmos_sealed = TRUE
	if(H.w_uniform && H.head)
		var/obj/item/clothing/CU = H.w_uniform
		var/obj/item/clothing/CH = H.head
		if (CU.envirosealed && (CH.clothing_flags & STOPSPRESSUREDAMAGE))
			atmos_sealed = TRUE
	if(!atmos_sealed)
		var/datum/gas_mixture/environment = H.loc.return_air()
		if(environment?.total_moles())
			if(GET_MOLES(/datum/gas/water_vapor, environment) >= 1)
				H.blood_volume -= 15
				if(prob(50))
					to_chat(H, span_danger("Your ooze melts away rapidly in the water vapor!"))
			if(H.blood_volume <= 672 && GET_MOLES(/datum/gas/plasma, environment) >= 1)
				H.blood_volume += 15
	if(H.blood_volume < BLOOD_VOLUME_OKAY && prob(5))
		to_chat(H, span_danger("You feel drained!"))
	if(H.blood_volume < BLOOD_VOLUME_OKAY)
		Cannibalize_Body(H)
	if(regenerate_limbs)
		regenerate_limbs.update_buttons()

/datum/species/oozeling/proc/Cannibalize_Body(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_OOZELING_NO_CANNIBALIZE))
		return
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	for(var/L in limbs_to_consume) //Check every bodypart the oozeling has, see if they're organic or not
		if(!IS_ORGANIC_LIMB(H.get_bodypart(L))) //Get actual limb, list only has body zone
			limbs_to_consume -= L //If it's inorganic, remove it from the consumption list
	if(!length(limbs_to_consume))
		H.losebreath++
		return
	if((BODY_ZONE_L_LEG in limbs_to_consume) || (BODY_ZONE_R_LEG in limbs_to_consume)) //Check if there are any organic legs left
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM) //If there are, autocannibalize those first
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, span_userdanger("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	H.blood_volume += 80
	H.nutrition += 20

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/regenerate_limbs/is_available()
	if(..())
		var/mob/living/carbon/human/H = owner
		var/list/limbs_to_heal = H.get_missing_limbs()
		if(limbs_to_heal.len && H.blood_volume >= BLOOD_VOLUME_OKAY+80)
			return TRUE
		return FALSE

/datum/action/innate/regenerate_limbs/on_activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!LAZYLEN(limbs_to_heal))
		to_chat(H, span_notice("You feel intact enough as it is."))
		return
	to_chat(H, span_notice("You focus intently on your missing [limbs_to_heal.len >= 2 ? "limbs" : "limb"]..."))
	if(H.blood_volume >= 80*limbs_to_heal.len+BLOOD_VOLUME_OKAY)
		if(do_after(H, 60, target = H))
			H.regenerate_limbs()
			H.blood_volume -= 80*limbs_to_heal.len
			H.nutrition -= 20*limbs_to_heal.len
			to_chat(H, span_notice("...and after a moment you finish reforming!"))
		return
	if(H.blood_volume >= 80)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+80 && LAZYLEN(limbs_to_heal))
			if(do_after(H, 30, target = H))
				var/healed_limb = pick(limbs_to_heal)
				H.regenerate_limb(healed_limb)
				limbs_to_heal -= healed_limb
				H.blood_volume -= 80
				H.nutrition -= 20
			to_chat(H, span_warning("...but there is not enough of you to fix everything! You must attain more blood volume to heal completely!"))
		return
	to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more blood volume to heal!"))

/datum/species/oozeling/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/water)
		if(chem.volume > 10)
			H.reagents.remove_reagent(chem.type, chem.volume - 10)
			to_chat(H, span_warning("The water you consumed is melting away your insides!"))
		H.blood_volume -= 25
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/oozeling/z_impact_damage(mob/living/carbon/human/H, turf/T, levels)
	// Splat!
	H.visible_message(span_notice("[H] hits the ground, flattening on impact!"),
		span_warning("You fall [levels] level\s into [T]. Your body flattens upon landing!"))
	H.Paralyze(levels * 8 SECONDS)
	var/amount_total = H.get_distributed_zimpact_damage(levels) * 0.45
	H.adjustBruteLoss(amount_total)
	playsound(H, 'sound/effects/blobattack.ogg', 40, TRUE)
	playsound(H, 'sound/effects/splat.ogg', 50, TRUE)
	H.AddElement(/datum/element/squish, levels * 15 SECONDS)
	// SPLAT!
	// 5: 25%, 4: 16%, 3: 9%
	if(levels >= 3 && prob(min((levels ** 2), 50)))
		H.gib()
		return

/datum/species/oozeling/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	. = ..()
	if(. && target != user && target.on_fire)
		target.visible_message(span_notice("[user] begins to closely hug [target]..."), span_boldnotice("[user] holds you closely in a tight hug!"))
		if(do_after(user, 1 SECONDS, target, IGNORE_HELD_ITEM))
			target.visible_message(span_notice("[user] extingushes [target] with a hug!"), span_boldnotice("[user] extingushes you with a hug!"), span_italics("You hear a fire sizzle out."))
			target.fire_stacks = max(target.fire_stacks - 5, 0)
			if(target.fire_stacks <= 0)
				target.ExtinguishMob()
		else
			target.visible_message(span_notice("[target] wriggles out of [user]'s close hug!"), span_notice("You wriggle out of [user]'s close hug."))

/datum/species/oozeling/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/oozeling/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/oozeling/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/oozeling/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/oozeling/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)

/datum/species/oozeling/get_giggle_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GIGGLE_SOUND(user)

/datum/species/oozeling/get_species_description()
	return "Literally made of jelly, Oozelings are squishy friends aboard Space Station 13."

/datum/species/oozeling/get_species_lore()
	return null

/datum/species/oozeling/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "angle-double-down",
			SPECIES_PERK_NAME = "Splat!",
			SPECIES_PERK_DESC = "[plural_form] have special resistance to falling, because their body and organs can flatten on impact. \
			It might hurt a bit, but generally [plural_form] can fall a lot further before their vitals organs start being pulverized.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "street-view",
			SPECIES_PERK_NAME = "Regenerative Limbs",
			SPECIES_PERK_DESC = "[plural_form] can regrow their limbs at will, provided they have enough Jelly.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Hydrophobic",
			SPECIES_PERK_DESC = "[plural_form] are decomposed by water - contact with water, water vapor, or ingesting water can lead to rapid loss of body mass.",
		)
	)

	return to_add

/datum/species/oozeling/create_pref_blood_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Jelly Blood",
		SPECIES_PERK_DESC = "[plural_form] don't have blood, but instead have toxic [initial(exotic_blood.name)]! \
			Jelly is extremely important, as losing it will cause you to cannibalize your limbs. Having low jelly will make medical treatment very difficult. \
			Jelly is also extremely sensitive to cold, and you may rapidy solidify. [plural_form] regain jelly passively by eating, but supplemental injections are possible.",
	))

	return to_add
