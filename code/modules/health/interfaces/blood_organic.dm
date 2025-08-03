#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/datum/blood_source/organic
	/// Type of the mob's blood
	var/datum/reagent/blood_type

/datum/blood_source/organic/New(mob/living/owner)
	. = ..()
	// Determine the blood type
	src.blood_type = /datum/reagent/blood
	if (iscarbon(owner))
		var/mob/living/carbon/carbon = owner
		if (carbon.dna.species.exotic_blood)
			src.blood_type = carbon.dna.species.exotic_blood

/datum/blood_source/organic/get_blood_id()
	return blood_type

/datum/blood_source/organic/restore_blood()
	volume = BLOOD_VOLUME_NORMAL

/datum/blood_source/organic/blood_tick(mob/living/source, delta_time)
	if(source.bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.
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

		// How much oxyloss we want to be on
		var/desired_damage = (source.getMaxHealth() * 1.2) * CLAMP01((volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
		// Make it so we only go unconcious at 25% blood remaining
		desired_damage = max(0, (source.getMaxHealth() * 1.2) - ((desired_damage ** 0.3) / ((source.getMaxHealth() * 1.2) ** (-0.7))))
		if (desired_damage >= source.getMaxHealth() * 1.2)
			desired_damage = source.getMaxHealth() * 2.0
		if (HAS_TRAIT(src, TRAIT_BLOOD_COOLANT))
			switch(volume)
				if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_SAFE)
					if(prob(3))
						to_chat(src, span_warning("Your sensors indicate [pick("overheating", "thermal throttling", "coolant issues")]."))
				if(-INFINITY to BLOOD_VOLUME_SURVIVE)
					desired_damage = source.getMaxHealth() * 2.0
					// Rapidly die with no saving you
					source.adjustFireLoss(clamp(source.getMaxHealth() * 2.0 - source.getFireLoss(), 0, 10))
			var/health_difference = clamp(desired_damage - source.getFireLoss(), 0, 5)
			source.adjustFireLoss(health_difference)
			return
		switch(volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(DT_PROB(2.5, delta_time))
					to_chat(src, span_warning("You feel [word]."))
				//adjustOxyLoss(round(0.005 * (BLOOD_VOLUME_NORMAL - blood_volume) * delta_time, 1))
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				//adjustOxyLoss(round(0.01 * (BLOOD_VOLUME_NORMAL - blood_volume) * delta_time, 1))
				if(DT_PROB(2.5, delta_time))
					source.blur_eyes(6)
					to_chat(src, span_warning("You feel very [word]."))
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				//adjustOxyLoss(2.5 * delta_time)
				if(DT_PROB(15, delta_time))
					source.blur_eyes(6)
					source.Unconscious(rand(3,6))
					to_chat(src, span_warning("You feel extremely [word]."))
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				desired_damage = source.getMaxHealth() * 2.0
				// Rapidly die with no saving you
				source.adjustOxyLoss(clamp(source.getMaxHealth() * 2.0 - source.getOxyLoss(), 0, 10))
		var/health_difference = clamp(desired_damage - source.getOxyLoss(), 0, 5)
		source.adjustOxyLoss(health_difference)


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

#undef BLOOD_DRIP_RATE_MOD
