/datum/species/apid
	// Beepeople, god damn it. It's hip, and alive! - Fuck ubunutu edition
	name = "Apids"
	id = "apid"
	say_mod = "buzzes"
	default_color = "FFE800"
	species_traits = list(LIPS,NOEYESPRITES)
	inherent_traits = list(TRAIT_BEEFRIEND)
	inherent_biotypes = list(MOB_ORGANIC,MOB_HUMANOID,MOB_BUG)
	mutanttongue = /obj/item/organ/tongue/bee
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/apid
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/apid
	mutantlungs = /obj/item/organ/lungs/apid
	mutantwings = /obj/item/organ/wings/bee
	burnmod = 1.5
	toxmod = 1.5
	staminamod = 1.25
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/apid
	inert_mutation = WAXSALIVA
	var/cold_cycle = 0

/datum/species/apid/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !H.IsSleeping()) // Sleep when cold, like bees
		cold_cycle++
		if(prob(5))
			to_chat(H, "<span class='warning'>The cold is making you feel tired...</span>")
		switch(cold_cycle)
			if(5 to 10)
				H.drowsyness++
			if(10 to INFINITY)
				H.SetSleeping(50) // Should be 5 seconds
				cold_cycle = 0 // Resets the cycle, they have a chance to get out after waking up

	else
		cold_cycle = 0

/datum/species/apid/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_apid_name(gender)

	var/randname = apid_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/apid/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Bees get x30 damage from flyswatters
	return 0

/datum/species/apid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)

/datum/species/apid/after_equip_job(datum/job/J, mob/living/carbon/human/H) // For roundstart
	H.mind?.teach_crafting_recipe(/datum/crafting_recipe/honeycomb)
	return ..()

/datum/species/apid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load) // For transformations
	C.mind?.teach_crafting_recipe(/datum/crafting_recipe/honeycomb)
	return ..()

/datum/species/apid/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.mind?.forget_crafting_recipe(/datum/crafting_recipe/honeycomb)
	return ..()
