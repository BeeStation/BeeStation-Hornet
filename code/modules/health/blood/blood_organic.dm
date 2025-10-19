#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/datum/blood_source/organic
	bleed_effect_type = /datum/status_effect/bleeding
	circulation_type_provided = CIRCULATION_BLOOD
	/// Type of the mob's blood
	var/datum/reagent/blood_type

/datum/blood_source/organic/Initialize(mob/living/owner)
	. = ..()
	// Determine the blood type
	src.blood_type = /datum/reagent/blood
	if (iscarbon(owner))
		var/mob/living/carbon/carbon = owner
		if (carbon.dna?.species?.exotic_blood)
			src.blood_type = carbon.dna.species.exotic_blood

/datum/blood_source/organic/get_blood_id()
	return blood_type

/datum/blood_source/organic/restore_blood()
	volume = BLOOD_VOLUME_NORMAL

/// Every tick update ourselves
/datum/blood_source/organic/blood_tick(mob/living/source, delta_time)
	if(source.bodytemperature < TCRYO || HAS_TRAIT(src, TRAIT_HUSK)) //cryosleep or husked people do not pump the blood.
		return
	//Blood regeneration if there is some space
	if(!source.is_bleeding() && volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER) && !HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		var/nutrition_ratio = 0
		switch(source.nutrition)
			if(0 to NUTRITION_LEVEL_STARVING)
				nutrition_ratio = 0.2
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				nutrition_ratio = 0.4
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				nutrition_ratio = 0.6
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				nutrition_ratio = 0.8
			else
				nutrition_ratio = 1
		if(source.satiety > 80)
			nutrition_ratio *= 1.25
		source.adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * delta_time)
		volume = min(volume + (BLOOD_REGEN_FACTOR * nutrition_ratio * delta_time), BLOOD_VOLUME_NORMAL)

	//Effects of bloodloss
	var/word = pick("dizzy","woozy","faint")

	switch(volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			if(DT_PROB(2.5, delta_time))
				to_chat(src, span_warning("You feel [word]."))
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			if(DT_PROB(2.5, delta_time))
				source.blur_eyes(6)
				to_chat(src, span_warning("You feel very [word]."))
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			//adjustOxyLoss(2.5 * delta_time)
			if(DT_PROB(15, delta_time))
				source.blur_eyes(6)
				source.Unconscious(rand(3,6))
				to_chat(src, span_warning("You feel extremely [word]."))

/// Bleed out of the mob
/datum/blood_source/organic/bleed(amount)
	if(!volume || HAS_TRAIT(owner, TRAIT_NO_BLEEDING) || IS_IN_STASIS(owner))
		return
	if (ishuman(owner))
		var/mob/living/carbon/human/human = owner
		amount *= human.physiology.bleed_mod
	// As you get less bloodloss, you bleed slower
	// See the top of this file for desmos lines
	var/decrease_multiplier = BLEED_RATE_MULTIPLIER
	var/obj/item/organ/heart/heart = owner.get_organ_slot(ORGAN_SLOT_HEART)
	if (!heart || !heart.beating)
		decrease_multiplier = BLEED_RATE_MULTIPLIER_NO_HEART
	var/blood_loss_amount = volume - volume * NUM_E ** (-(amount * decrease_multiplier)/BLOOD_VOLUME_NORMAL)
	volume = max(volume - blood_loss_amount, 0)
	if(isturf(owner.loc) && prob(sqrt(blood_loss_amount)*BLOOD_DRIP_RATE_MOD)) //Blood loss still happens in locker, floor stays clean
		if(blood_loss_amount >= 2)
			owner.add_splatter_floor(owner.loc)
		else
			owner.add_splatter_floor(owner.loc, 1)

/// Get the data to be associated with the blood that we bleed
/datum/blood_source/organic/get_blood_data()
	// DNA not supported
	if(blood_type != /datum/reagent/blood)
		return
	var/mob/living/carbon/carbon_owner = null
	if (istype(owner, /mob/living/carbon))
		carbon_owner = owner
	var/blood_data = list()
	//set the blood data
	blood_data["viruses"] = list()

	for(var/thing in owner.diseases)
		var/datum/disease/D = thing
		blood_data["viruses"] += D.Copy()

	blood_data["blood_DNA"] = carbon_owner?.dna.unique_enzymes
	if(owner.disease_resistances?.len)
		blood_data["resistances"] = owner.disease_resistances.Copy()
	var/list/temp_chem = list()
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		temp_chem[R.type] = R.volume
	blood_data["trace_chem"] = list2params(temp_chem)
	if(owner.mind)
		blood_data["mind"] = owner.mind
	else if(carbon_owner?.last_mind)
		blood_data["mind"] = carbon_owner.last_mind
	if(owner.ckey)
		blood_data["ckey"] = owner.ckey
	else if(carbon_owner?.last_mind)
		blood_data["ckey"] = ckey(carbon_owner.last_mind.key)

	if(!owner.suiciding)
		blood_data["cloneable"] = 1
	blood_data["blood_type"] = carbon_owner?.dna.blood_type
	blood_data["gender"] = owner.gender
	blood_data["real_name"] = owner.real_name
	blood_data["features"] = carbon_owner?.dna.features || list()
	blood_data["factions"] = owner.faction

	return blood_data

/// Calculate the circulation rating of the mob, cardiac arrest can limit it and cause damage
/datum/blood_source/organic/get_effectiveness()
	if (!owner.needs_heart())
		return 1
	// Multiplied by blood volume
	var/base_proportion = ..()
	base_proportion *= CLAMP01((volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
	return base_proportion

#undef BLOOD_DRIP_RATE_MOD
