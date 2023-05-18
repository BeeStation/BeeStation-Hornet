/datum/species/oozeling
	name = "\improper Oozeling"
	id = SPECIES_OOZELING
	bodyflag = FLAG_OOZELING
	default_color = "00FF90"
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR)
	inherent_traits = list(TRAIT_TOXINLOVER,TRAIT_NOFIRE,TRAIT_ALWAYS_CLEAN,TRAIT_EASYDISMEMBER)
	hair_color = "mutcolor"
	hair_alpha = 150
	mutantlungs = /obj/item/organ/lungs/slime
	mutanttongue = /obj/item/organ/tongue/slime
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	damage_overlay_type = ""
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	inherent_factions = list("slime")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/oozeling
	swimming_component = /datum/component/swimming/dissolve
	inert_mutation = ACIDOOZE

	species_chest = /obj/item/bodypart/chest/oozeling
	species_head = /obj/item/bodypart/head/oozeling
	species_l_arm = /obj/item/bodypart/l_arm/oozeling
	species_r_arm = /obj/item/bodypart/r_arm/oozeling
	species_l_leg = /obj/item/bodypart/l_leg/oozeling
	species_r_leg = /obj/item/bodypart/r_leg/oozeling

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

/datum/species/oozeling/spec_life(mob/living/carbon/human/H)
	..()
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return
	if(!H.blood_volume)
		H.blood_volume += 5
		H.adjustBruteLoss(5)
		to_chat(H, "<span class='danger'>You feel empty!</span>")
	if(H.nutrition >= NUTRITION_LEVEL_WELL_FED && H.blood_volume <= 672)
		if(H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
			H.adjust_nutrition(-5)
			H.blood_volume += 10
		else
			H.blood_volume += 8
	if(H.nutrition <= NUTRITION_LEVEL_HUNGRY)
		if(H.nutrition <= NUTRITION_LEVEL_STARVING)
			H.blood_volume -= 8
			if(prob(5))
				to_chat(H, "<span class='info'>You're starving! Get some food!</span>")
		else
			if(prob(35))
				H.blood_volume -= 2
				if(prob(5))
					to_chat(H, "<span class='danger'>You're feeling pretty hungry...</span>")
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
			if(environment.get_moles(GAS_H2O) >= 1)
				H.blood_volume -= 15
				if(prob(50))
					to_chat(H, "<span class='danger'>Your ooze melts away rapidly in the water vapor!</span>")
			if(H.blood_volume <= 672 && environment.get_moles(GAS_PLASMA) >= 1)
				H.blood_volume += 15
	if(H.blood_volume < BLOOD_VOLUME_OKAY && prob(5))
		to_chat(H, "<span class='danger'>You feel drained!</span>")
	if(H.blood_volume < BLOOD_VOLUME_OKAY)
		Cannibalize_Body(H)
	if(regenerate_limbs)
		regenerate_limbs.UpdateButtonIcon()

/datum/species/oozeling/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!limbs_to_consume.len)
		H.losebreath++
		return
	if(H.get_num_legs(FALSE)) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, "<span class='userdanger'>Your [consumed_limb] is drawn back into your body, unable to maintain its shape!</span>")
	qdel(consumed_limb)
	H.blood_volume += 80
	H.nutrition += 20

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/regenerate_limbs/IsAvailable()
	if(..())
		var/mob/living/carbon/human/H = owner
		var/list/limbs_to_heal = H.get_missing_limbs()
		if(limbs_to_heal.len && H.blood_volume >= BLOOD_VOLUME_OKAY+80)
			return TRUE
		return FALSE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!LAZYLEN(limbs_to_heal))
		to_chat(H, "<span class='notice'>You feel intact enough as it is.</span>")
		return
	to_chat(H, "<span class='notice'>You focus intently on your missing [limbs_to_heal.len >= 2 ? "limbs" : "limb"]...</span>")
	if(H.blood_volume >= 80*limbs_to_heal.len+BLOOD_VOLUME_OKAY)
		if(do_after(H, 60, target = H))
			H.regenerate_limbs()
			H.blood_volume -= 80*limbs_to_heal.len
			H.nutrition -= 20*limbs_to_heal.len
			to_chat(H, "<span class='notice'>...and after a moment you finish reforming!</span>")
		return
	if(H.blood_volume >= 80)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+80 && LAZYLEN(limbs_to_heal))
			if(do_after(H, 30, target = H))
				var/healed_limb = pick(limbs_to_heal)
				H.regenerate_limb(healed_limb)
				limbs_to_heal -= healed_limb
				H.blood_volume -= 80
				H.nutrition -= 20
			to_chat(H, "<span class='warning'>...but there is not enough of you to fix everything! You must attain more blood volume to heal completely!</span>")
		return
	to_chat(H, "<span class='warning'>...but there is not enough of you to go around! You must attain more blood volume to heal!</span>")

/datum/species/oozeling/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/water)
		if(chem.volume > 10)
			H.reagents.remove_reagent(chem.type, chem.volume - 10)
			to_chat(H, "<span class='warning'>The water you consumed is melting away your insides!</span>")
		H.blood_volume -= 25
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/oozeling/z_impact_damage(mob/living/carbon/human/H, turf/T, levels)
	// Splat!
	H.visible_message("<span class='notice'>[H] hits the ground, flattening on impact!</span>",
		"<span class='warning'>You fall [levels] level\s into [T]. Your body flattens upon landing!</span>")
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
