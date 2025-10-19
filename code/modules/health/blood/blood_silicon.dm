#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/datum/blood_source/silicon
	bleed_effect_type = /datum/status_effect/bleeding/robotic
	circulation_type_provided = CIRCULATION_COOLANT
	/// Type of the mob's blood
	var/datum/reagent/blood_type

/datum/blood_source/silicon/Initialize(mob/living/owner)
	. = ..()
	// Determine the blood type
	src.blood_type = /datum/reagent/oil
	if (iscarbon(owner))
		var/mob/living/carbon/carbon = owner
		if (carbon.dna.species.exotic_blood)
			src.blood_type = carbon.dna.species.exotic_blood

/datum/blood_source/silicon/get_blood_id()
	return blood_type

/datum/blood_source/silicon/restore_blood()
	volume = BLOOD_VOLUME_NORMAL

/datum/blood_source/silicon/blood_tick(mob/living/source, delta_time)
	// How much oxyloss we want to be on
	var/desired_damage = (source.getMaxHealth() * 1.2) * CLAMP01((volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
	// Make it so we only go unconcious at 25% blood remaining
	desired_damage = max(0, (source.getMaxHealth() * 1.2) - ((desired_damage ** 0.3) / ((source.getMaxHealth() * 1.2) ** (-0.7))))
	if (desired_damage >= source.getMaxHealth() * 1.2)
		desired_damage = source.getMaxHealth() * 2.0
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
	if (source.bodytemperature < BODYTEMP_HEAT_WARNING_1)
		source.adjust_bodytemperature(1)

/datum/blood_source/silicon/bleed(amount)
	if(!volume || HAS_TRAIT(owner, TRAIT_NO_BLEEDING))
		return
	if (ishuman(owner))
		var/mob/living/carbon/human/human = owner
		amount *= human.physiology.bleed_mod
	// As you get less bloodloss, you bleed slower
	// See the top of this file for desmos lines
	var/blood_loss_amount = volume - volume * NUM_E ** (-(amount * BLEED_RATE_MULTIPLIER)/BLOOD_VOLUME_NORMAL)
	volume = max(volume - blood_loss_amount, 0)
	if(isturf(owner.loc) && prob(sqrt(blood_loss_amount)*BLOOD_DRIP_RATE_MOD)) //Blood loss still happens in locker, floor stays clean
		if(blood_loss_amount >= 2)
			owner.add_splatter_floor(owner.loc)
		else
			owner.add_splatter_floor(owner.loc, 1)

/datum/blood_source/silicon/get_blood_data()
	return list()

/datum/blood_source/silicon/get_effectiveness()
	if (!owner.needs_heart())
		return 1
	// Multiplied by blood volume
	var/base_proportion = ..()
	base_proportion *= CLAMP01((volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
	return base_proportion


#undef BLOOD_DRIP_RATE_MOD
