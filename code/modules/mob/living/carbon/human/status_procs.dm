
/mob/living/carbon/human/Stun(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Paralyze(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Immobilize(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/Sleeping(amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/cure_husk(list/sources)
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/become_husk(source)
	if(NOHUSK in dna.species.species_traits)
		cure_husk()
		return
	. = ..()
	if(.)
		update_hair()
